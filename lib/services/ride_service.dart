import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Ücret hesaplama sabitleri
  static const double baseFare = 25.0;         // Açılış ücreti (₺)
  static const double perKmRate = 7.50;        // Km başı ücret (₺)
  static const double perMinRate = 1.50;       // Dakika başı ücret (₺)
  static const double minimumFare = 40.0;      // Minimum ücret (₺)

  /// Tahmini ücret hesapla
  double calculateFare(double distanceKm, int durationMin) {
    double fare = baseFare + (distanceKm * perKmRate) + (durationMin * perMinRate);
    return fare < minimumFare ? minimumFare : fare;
  }

  /// İki nokta arası mesafe hesapla (km) — Haversine formülü
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371; // km
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * pi / 180;

  /// Yakındaki çevrimiçi sürücüleri bul (5km yarıçap)
  Future<List<Map<String, dynamic>>> findNearbyDrivers(double lat, double lng, {double radiusKm = 5.0}) async {
    try {
      final snapshot = await _firestore
          .collection('driver_locations')
          .where('isOnline', isEqualTo: true)
          .get();

      List<Map<String, dynamic>> nearbyDrivers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        double driverLat = (data['lat'] ?? 0).toDouble();
        double driverLng = (data['lng'] ?? 0).toDouble();
        double distance = calculateDistance(lat, lng, driverLat, driverLng);

        if (distance <= radiusKm) {
          nearbyDrivers.add({
            'driverId': doc.id,
            'lat': driverLat,
            'lng': driverLng,
            'distance': distance,
            'name': data['name'] ?? 'Sürücü',
            'phone': data['phone'] ?? '',
          });
        }
      }

      // En yakından uzağa sırala
      nearbyDrivers.sort((a, b) => (a['distance'] as double).compareTo(b['distance'] as double));
      return nearbyDrivers;
    } catch (e) {
      debugPrint("Sürücü arama hatası: $e");
      return [];
    }
  }

  /// En yakın sürücüyü bul ve eşleştir
  Future<String?> findAndMatchDriver(String rideId, double pickupLat, double pickupLng) async {
    final drivers = await findNearbyDrivers(pickupLat, pickupLng);

    if (drivers.isEmpty) return null;

    // En yakın sürücüyü al
    final nearest = drivers.first;
    final driverId = nearest['driverId'] as String;

    // Ride'ı güncelle
    await _firestore.collection('rides').doc(rideId).update({
      'driverId': driverId,
      'driverName': nearest['name'],
      'driverPhone': nearest['phone'],
      'status': 'matched',
    });

    return driverId;
  }

  /// Tahmini süre hesapla (basit: ortalama 30 km/h şehir içi)
  int estimateDuration(double distanceKm) {
    return (distanceKm / 30 * 60).ceil(); // dakika
  }
}
