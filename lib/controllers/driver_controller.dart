import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../models/driver_model.dart';
import '../models/payout_model.dart';
import '../models/ride_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_io/io.dart' as uio;
import 'package:path/path.dart' as p;

class DriverController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UI'da çarkın dönmesi ve butonun kilitlenmesi için gerekli
  final RxBool isLoading = false.obs;
  final RxBool isOnline = false.obs;

  final Rx<Driver?> driver = Rx<Driver?>(null);
  final RxList<Payout> payouts = <Payout>[].obs;
  final Rx<Ride?> currentRide = Rx<Ride?>(null);
  final Rx<Ride?> incomingRide = Rx<Ride?>(null);

  StreamSubscription? _locationSubscription;
  StreamSubscription? _rideSubscription;

  @override
  void onClose() {
    _locationSubscription?.cancel();
    _rideSubscription?.cancel();
    super.onClose();
  }

  /// Çevrimiçi / çevrimdışı geçiş
  Future<void> goOnline() async {
    if (driver.value == null) return;
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );

      await _firestore.collection('driver_locations').doc(driver.value!.id).set({
        'lat': position.latitude,
        'lng': position.longitude,
        'isOnline': true,
        'name': driver.value!.name,
        'phone': driver.value!.phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      isOnline.value = true;

      // Konumu periyodik güncelle
      _locationSubscription?.cancel();
      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 50, // 50 metre hareket edince güncelle
        ),
      ).listen((position) {
        _firestore.collection('driver_locations').doc(driver.value!.id).update({
          'lat': position.latitude,
          'lng': position.longitude,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Gelen çağrıları dinle
      _listenForRides();

      Get.snackbar("Çevrimiçi", "Artık yolculuk çağrıları alabilirsiniz.",
          backgroundColor: const Color(0xFF2C2C2C));
    } catch (e) {
      debugPrint("Çevrimiçi hatası: $e");
      Get.snackbar("Hata", "Çevrimiçi olunamadı: $e");
    }
  }

  Future<void> goOffline() async {
    if (driver.value == null) return;
    try {
      await _firestore.collection('driver_locations').doc(driver.value!.id).update({
        'isOnline': false,
      });
      isOnline.value = false;
      _locationSubscription?.cancel();
      _rideSubscription?.cancel();
      Get.snackbar("Çevrimdışı", "Artık yolculuk çağrıları almıyorsunuz.");
    } catch (e) {
      debugPrint("Çevrimdışı hatası: $e");
    }
  }

  /// Gelen yolculuk çağrılarını dinle
  void _listenForRides() {
    if (driver.value == null) return;
    _rideSubscription?.cancel();
    _rideSubscription = _firestore
        .collection('rides')
        .where('driverId', isEqualTo: driver.value!.id)
        .where('status', isEqualTo: 'matched')
        .snapshots()
        .listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        incomingRide.value = Ride.fromFirestore(snapshot.docs.first);
      }
    });
  }

  /// Çağrıyı kabul et
  Future<void> acceptRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': 'driver_arriving',
      });
      currentRide.value = incomingRide.value;
      incomingRide.value = null;
      Get.snackbar("Kabul Edildi", "Yolcuya doğru yola çıkın!");
    } catch (e) {
      debugPrint("Kabul hatası: $e");
    }
  }

  /// Çağrıyı reddet
  Future<void> rejectRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverId': null,
        'driverName': null,
        'driverPhone': null,
        'status': 'searching',
      });
      incomingRide.value = null;
    } catch (e) {
      debugPrint("Red hatası: $e");
    }
  }

  /// Yolcuya vardım
  Future<void> arrivedAtPickup() async {
    if (currentRide.value == null) return;
    // Durumu güncellemiyoruz ama UI'da gösteriyoruz
  }

  /// Yolculuğu başlat
  Future<void> startRide() async {
    if (currentRide.value == null) return;
    try {
      await _firestore.collection('rides').doc(currentRide.value!.id).update({
        'status': 'in_progress',
        'startedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint("Başlatma hatası: $e");
    }
  }

  /// Yolculuğu tamamla
  Future<void> completeRide() async {
    if (currentRide.value == null) return;
    try {
      final ride = currentRide.value!;
      await _firestore.collection('rides').doc(ride.id).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Kazancı payout olarak ekle
      if (ride.grossTotal > 0) {
        await _firestore.collection('payouts').add({
          'driverId': driver.value?.id ?? '',
          'amount': ride.driverNet,
          'description': '${ride.pickupAddress} → ${ride.destAddress}',
          'status': 'completed',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      currentRide.value = null;
      await fetchPayouts();
      Get.snackbar("Tamamlandı", "Yolculuk başarıyla tamamlandı. Kazancınız eklendi!");
    } catch (e) {
      debugPrint("Tamamlama hatası: $e");
    }
  }

  // Sürücü verilerini çeken metod
  Future<void> fetchDriverData(String driverId) async {
    isLoading.value = true;
    try {
      final doc = await _firestore
          .collection('drivers')
          .doc(driverId)
          .get();
      if (doc.exists) {
        driver.value = Driver.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint("Sürücü hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reportPenalty({
    required XFile image,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;
    try {
      final String driverId = driver.value?.id ?? 'unknown';
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final Reference storageRef = FirebaseStorage.instance.ref().child('penalties/$driverId/$fileName');

      // Upload file
      final String contentType = p.extension(image.path).replaceAll('.', '');
      final SettableMetadata metadata = SettableMetadata(contentType: 'image/$contentType');
      
      final UploadTask uploadTask;
      if (kIsWeb) {
        final byteData = await image.readAsBytes();
        uploadTask = storageRef.putData(byteData, metadata);
      } else {
        uploadTask = storageRef.putFile(uio.File(image.path), metadata);
      }
      
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save to Firestore
      await _firestore.collection('penalties').add({
        'driverId': driverId,
        'driverName': driver.value?.name ?? 'Anonim',
        'imageUrl': downloadUrl,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Başarılı", "Ceza bildirimi avukatlarımıza iletildi.");
    } catch (e) {
      Get.snackbar("Hata", "Bildirim gönderilemedi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPayouts([String? driverId]) async {
    String id = driverId ?? driver.value?.id ?? '';
    if (id.isEmpty) return;
    try {
      final snap = await _firestore
          .collection('payouts').where('driverId', isEqualTo: id).get();
      payouts.value = snap.docs.map((doc) => Payout.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Payout hatası: $e");
    }
  }

  double getTotalEarnings() {
    return payouts
        .where((p) => p.status == PayoutStatus.completed)
        .fold(0.0, (total, item) => total + item.amount);
  }

  double getPendingPayouts() {
    return payouts
        .where((p) => p.status == PayoutStatus.pending)
        .fold(0.0, (total, item) => total + item.amount);
  }

  Future<void> requestPayout(double amount, String description) async {
    isLoading.value = true;
    try {
      await _firestore.collection('payouts').add({
        'driverId': driver.value?.id ?? '',
        'amount': amount,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchPayouts();
      Get.snackbar("Başarılı", "Talebiniz iletildi");
    } catch (e) {
      Get.snackbar("Hata", "Talep gönderilemedi");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleOnlineStatus() async {
    if (isOnline.value) {
      await goOffline();
    } else {
      await goOnline();
    }
  }
}