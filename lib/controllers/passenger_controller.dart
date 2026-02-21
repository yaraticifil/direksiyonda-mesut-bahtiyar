import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../models/ride_model.dart';
import '../services/ride_service.dart';

class PassengerController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RideService _rideService = RideService();

  final RxBool isLoading = false.obs;
  final Rx<Ride?> currentRide = Rx<Ride?>(null);
  final RxList<Ride> rideHistory = <Ride>[].obs;
  final Rx<Position?> currentPosition = Rx<Position?>(null);
  final RxDouble estimatedFare = 0.0.obs;
  final RxDouble estimatedDistance = 0.0.obs;
  final RxInt estimatedDuration = 0.obs;

  StreamSubscription? _rideSubscription;

  @override
  void onClose() {
    _rideSubscription?.cancel();
    super.onClose();
  }

  /// Mevcut konumu al
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Hata", "Konum servisleri kapalı. Lütfen açın.");
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Hata", "Konum izni reddedildi.");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("Hata", "Konum izni kalıcı olarak reddedildi. Ayarlardan açın.");
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      currentPosition.value = position;
      return position;
    } catch (e) {
      debugPrint("Konum hatası: $e");
      return null;
    }
  }

  /// Tahmini ücret hesapla
  void calculateEstimate(double pickupLat, double pickupLng, double destLat, double destLng) {
    double distance = _rideService.calculateDistance(pickupLat, pickupLng, destLat, destLng);
    int duration = _rideService.estimateDuration(distance);
    double fare = _rideService.calculateFare(distance, duration);

    estimatedDistance.value = distance;
    estimatedDuration.value = duration;
    estimatedFare.value = fare;
  }

  /// Yolculuk talebi oluştur
  Future<void> requestRide({
    required String passengerId,
    required double pickupLat,
    required double pickupLng,
    required String pickupAddress,
    required double destLat,
    required double destLng,
    required String destAddress,
  }) async {
    isLoading.value = true;
    try {
      // Firestore'a yolculuk kaydı oluştur
      final docRef = await _firestore.collection('rides').add({
        'passengerId': passengerId,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'pickupAddress': pickupAddress,
        'destLat': destLat,
        'destLng': destLng,
        'destAddress': destAddress,
        'status': 'searching',
        'fare': estimatedFare.value,
        'distanceKm': estimatedDistance.value,
        'durationMin': estimatedDuration.value,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Yolculuğu dinlemeye başla
      _listenToRide(docRef.id);

      // Yakın sürücü ara
      final driverId = await _rideService.findAndMatchDriver(
        docRef.id, pickupLat, pickupLng,
      );

      if (driverId == null) {
        Get.snackbar(
          "Sürücü Bulunamadı",
          "Yakınızda müsait sürücü yok. Lütfen tekrar deneyin.",
          duration: const Duration(seconds: 5),
        );
        // İptal et
        await _firestore.collection('rides').doc(docRef.id).update({
          'status': 'cancelled',
        });
      }
    } catch (e) {
      debugPrint("Yolculuk talebi hatası: $e");
      Get.snackbar("Hata", "Yolculuk talebi oluşturulamadı.");
    } finally {
      isLoading.value = false;
    }
  }

  /// Yolculuğu gerçek zamanlı dinle
  void _listenToRide(String rideId) {
    _rideSubscription?.cancel();
    _rideSubscription = _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        currentRide.value = Ride.fromFirestore(snapshot);

        // Yolculuk tamamlandıysa dinlemeyi durdur
        if (currentRide.value?.status == RideStatus.completed ||
            currentRide.value?.status == RideStatus.cancelled) {
          _rideSubscription?.cancel();
        }
      }
    });
  }

  /// Yolculuğu iptal et
  Future<void> cancelRide() async {
    if (currentRide.value == null) return;
    try {
      await _firestore.collection('rides').doc(currentRide.value!.id).update({
        'status': 'cancelled',
      });
      currentRide.value = null;
      _rideSubscription?.cancel();
      Get.snackbar("İptal Edildi", "Yolculuk talebi iptal edildi.");
    } catch (e) {
      debugPrint("İptal hatası: $e");
    }
  }

  /// Yolculuk geçmişini getir
  Future<void> fetchRideHistory(String passengerId) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('passengerId', isEqualTo: passengerId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      rideHistory.value = snapshot.docs
          .map((doc) => Ride.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint("Geçmiş yolculuk hatası: $e");
    }
  }

  /// Aktif yolculuk var mı kontrol et
  Future<void> checkActiveRide(String passengerId) async {
    try {
      final snapshot = await _firestore
          .collection('rides')
          .where('passengerId', isEqualTo: passengerId)
          .where('status', whereIn: ['searching', 'matched', 'driver_arriving', 'in_progress'])
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        currentRide.value = Ride.fromFirestore(snapshot.docs.first);
        _listenToRide(snapshot.docs.first.id);
      }
    } catch (e) {
      debugPrint("Aktif yolculuk kontrol hatası: $e");
    }
  }
}
