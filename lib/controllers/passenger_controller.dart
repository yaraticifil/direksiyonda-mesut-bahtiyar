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

  // Fiyat hesaplama sonucu
  final Rx<FareBreakdown?> fareBreakdown = Rx<FareBreakdown?>(null);

  // Segment ve kişi seçimi
  final Rx<VehicleSegment> selectedSegment = VehicleSegment.standard.obs;
  final RxInt selectedPersonCount = 1.obs;

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

  /// Tahmini ücret hesapla — tam kırılımlı
  void calculateEstimate(double pickupLat, double pickupLng, double destLat, double destLng) {
    double distance = _rideService.calculateDistance(pickupLat, pickupLng, destLat, destLng);

    fareBreakdown.value = _rideService.calculateFare(
      distanceKm: distance,
      segment: selectedSegment.value,
      personCount: selectedPersonCount.value,
      marketRate: 1.0,
    );
  }

  /// Segment değiştir → yeniden hesapla
  void setSegment(VehicleSegment segment) {
    selectedSegment.value = segment;
    _recalculate();
  }

  /// Kişi sayısı değiştir → yeniden hesapla
  void setPersonCount(int count) {
    selectedPersonCount.value = count.clamp(1, 4);
    _recalculate();
  }

  void _recalculate() {
    if (fareBreakdown.value != null) {
      fareBreakdown.value = _rideService.calculateFare(
        distanceKm: fareBreakdown.value!.distanceKm,
        segment: selectedSegment.value,
        personCount: selectedPersonCount.value,
        marketRate: 1.0,
      );
    }
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
    if (fareBreakdown.value == null) return;
    isLoading.value = true;
    try {
      final fb = fareBreakdown.value!;

      final docRef = await _firestore.collection('rides').add({
        'passengerId': passengerId,
        'pickupLat': pickupLat,
        'pickupLng': pickupLng,
        'pickupAddress': pickupAddress,
        'destLat': destLat,
        'destLng': destLng,
        'destAddress': destAddress,
        'status': 'searching',
        'segment': fb.segment.name,
        'personCount': fb.personCount,
        'distanceKm': fb.distanceKm,
        'estimatedMinutes': fb.estimatedMinutes,
        'invoiceNo': fb.invoiceNo,
        'openingFee': fb.openingFee,
        'distanceFee': fb.distanceFee,
        'segmentSurcharge': fb.segmentSurcharge,
        'marketAdjustment': fb.marketAdjustment,
        'discount': fb.discount,
        'grossTotal': fb.grossTotal,
        'commission': fb.commission,
        'driverNet': fb.driverNet,
        'perPersonFee': fb.perPersonFee,
        'marketRate': fb.marketRate,
        'createdAt': FieldValue.serverTimestamp(),
      });

      _listenToRide(docRef.id);

      final driverId = await _rideService.findAndMatchDriver(
        docRef.id, pickupLat, pickupLng,
      );

      if (driverId == null) {
        Get.snackbar(
          "Sürücü Bulunamadı",
          "Yakınızda müsait sürücü yok. Lütfen tekrar deneyin.",
          duration: const Duration(seconds: 5),
        );
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

  /// Yolculuk geçmişi
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

  /// Aktif yolculuk kontrolü
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
