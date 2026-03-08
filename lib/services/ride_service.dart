import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

/// Araç Segmenti
enum VehicleSegment {
  standard,  // ×1.0
  wide,      // ×1.2 (Geniş)
  luxury,    // ×1.5 (Lüks)
}

/// Segment katsayıları ve açılış bedelleri
class SegmentConfig {
  final double multiplier;
  final double openingFee;
  final String label;
  final String icon;

  const SegmentConfig({
    required this.multiplier,
    required this.openingFee,
    required this.label,
    required this.icon,
  });

  static const configs = {
    VehicleSegment.standard: SegmentConfig(
      multiplier: 1.0,
      openingFee: 50.0,
      label: 'Standart',
      icon: '🚗',
    ),
    VehicleSegment.wide: SegmentConfig(
      multiplier: 1.2,
      openingFee: 60.0,
      label: 'Geniş',
      icon: '🚙',
    ),
    VehicleSegment.luxury: SegmentConfig(
      multiplier: 1.5,
      openingFee: 75.0,
      label: 'Lüks',
      icon: '🏎️',
    ),
  };

  static SegmentConfig get(VehicleSegment segment) =>
      configs[segment] ?? configs[VehicleSegment.standard]!;
}

/// Fiyat hesaplama sonucu — tüm kırılım bilgileri
class FareBreakdown {
  final double openingFee;          // Açılış bedeli
  final double distanceFee;         // Mesafe bedeli
  final double segmentSurcharge;    // Segment farkı
  final double marketAdjustment;    // Piyasa koşulları ayarı
  final double discount;            // Kampanya/indirim
  final double grossTotal;          // Brüt toplam araç bedeli
  final double commission;          // Platform komisyonu (%12)
  final double driverNet;           // Sürücü net kazanç
  final double perPersonFee;        // Kişi başı bedel
  final int personCount;            // Kişi sayısı
  final double distanceKm;          // Mesafe
  final int estimatedMinutes;       // Tahmini süre
  final VehicleSegment segment;     // Segment
  final double marketRate;          // Piyasa katsayısı (1.0-1.3)
  final String invoiceNo;           // Fatura numarası

  const FareBreakdown({
    required this.openingFee,
    required this.distanceFee,
    required this.segmentSurcharge,
    required this.marketAdjustment,
    required this.discount,
    required this.grossTotal,
    required this.commission,
    required this.driverNet,
    required this.perPersonFee,
    required this.personCount,
    required this.distanceKm,
    required this.estimatedMinutes,
    required this.segment,
    required this.marketRate,
    required this.invoiceNo,
  });

  /// Firestore'a kaydetmek için map
  Map<String, dynamic> toMap() {
    return {
      'openingFee': openingFee,
      'distanceFee': distanceFee,
      'segmentSurcharge': segmentSurcharge,
      'marketAdjustment': marketAdjustment,
      'discount': discount,
      'grossTotal': grossTotal,
      'commission': commission,
      'driverNet': driverNet,
      'perPersonFee': perPersonFee,
      'personCount': personCount,
      'distanceKm': distanceKm,
      'estimatedMinutes': estimatedMinutes,
      'segment': segment.name,
      'marketRate': marketRate,
      'invoiceNo': invoiceNo,
    };
  }

  /// Firestore'dan okumak için
  factory FareBreakdown.fromMap(Map<String, dynamic> map) {
    return FareBreakdown(
      openingFee: (map['openingFee'] ?? 0).toDouble(),
      distanceFee: (map['distanceFee'] ?? 0).toDouble(),
      segmentSurcharge: (map['segmentSurcharge'] ?? 0).toDouble(),
      marketAdjustment: (map['marketAdjustment'] ?? 0).toDouble(),
      discount: (map['discount'] ?? 0).toDouble(),
      grossTotal: (map['grossTotal'] ?? 0).toDouble(),
      commission: (map['commission'] ?? 0).toDouble(),
      driverNet: (map['driverNet'] ?? 0).toDouble(),
      perPersonFee: (map['perPersonFee'] ?? 0).toDouble(),
      personCount: map['personCount'] ?? 1,
      distanceKm: (map['distanceKm'] ?? 0).toDouble(),
      estimatedMinutes: map['estimatedMinutes'] ?? 0,
      segment: _parseSegment(map['segment']),
      marketRate: (map['marketRate'] ?? 1.0).toDouble(),
      invoiceNo: map['invoiceNo'] ?? '',
    );
  }

  static VehicleSegment _parseSegment(String? s) {
    switch (s) {
      case 'wide': return VehicleSegment.wide;
      case 'luxury': return VehicleSegment.luxury;
      default: return VehicleSegment.standard;
    }
  }
}

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ── SABİTLER (Adil Fiyat Politikası) ──
  static const double kmUnitPrice = 6.0;           // Km birim bedel (₺)
  static const double commissionRate = 0.12;        // Platform komisyonu (%12)
  static const double minPerPersonFee = 50.0;       // Min kişi başı (₺)
  static const double maxMarketRate = 1.30;         // Max piyasa katsayısı

  /// ─── ANA HESAPLAMA MOTORU ───
  /// Kullanıcıya gösterilen: Kişi Başı ≈ 50 TL + (Mesafe × 6 TL)
  /// Arka plan: segment × mesafe × birim + açılış + piyasa ayarı - kampanya
  FareBreakdown calculateFare({
    required double distanceKm,
    required VehicleSegment segment,
    int personCount = 1,
    double marketRate = 1.0,   // 1.0 = normal, 1.3 = yoğun
    double discount = 0.0,     // Kampanya indirimi (₺)
  }) {
    final config = SegmentConfig.get(segment);

    // Açılış bedeli (segment'e göre)
    double openingFee = config.openingFee;

    // Mesafe bedeli (km × birim × segment katsayısı)
    double distanceFee = distanceKm * kmUnitPrice * config.multiplier;

    // Segment farkı (standart'tan farkı)
    double segmentSurcharge = 0;
    if (segment != VehicleSegment.standard) {
      double standardTotal = distanceKm * kmUnitPrice * 1.0 + 50.0;
      double segmentTotal = distanceFee + openingFee;
      segmentSurcharge = segmentTotal - standardTotal;
    }

    // Ham toplam
    double rawTotal = openingFee + distanceFee;

    // Piyasa ayarı
    double clampedRate = marketRate.clamp(1.0, maxMarketRate);
    double marketAdjustment = 0;
    if (clampedRate > 1.0) {
      marketAdjustment = rawTotal * (clampedRate - 1.0);
    }

    // Brüt toplam
    double grossTotal = rawTotal + marketAdjustment - discount;

    // Minimum kontrol (kişi başı en az minPerPersonFee)
    double minTotal = minPerPersonFee * personCount;
    if (grossTotal < minTotal) {
      grossTotal = minTotal;
    }

    // Kişi başı
    double perPersonFee = grossTotal / personCount;

    // Komisyon ve sürücü net
    double commission = grossTotal * commissionRate;
    double driverNet = grossTotal - commission;

    // Tahmini süre (ortalama 30 km/h şehir içi)
    int estimatedMinutes = (distanceKm / 30 * 60).ceil();
    if (estimatedMinutes < 5) estimatedMinutes = 5;

    // Fatura numarası
    String invoiceNo = _generateInvoiceNo();

    return FareBreakdown(
      openingFee: _round(openingFee),
      distanceFee: _round(distanceFee),
      segmentSurcharge: _round(segmentSurcharge),
      marketAdjustment: _round(marketAdjustment),
      discount: _round(discount),
      grossTotal: _round(grossTotal),
      commission: _round(commission),
      driverNet: _round(driverNet),
      perPersonFee: _round(perPersonFee),
      personCount: personCount,
      distanceKm: distanceKm,
      estimatedMinutes: estimatedMinutes,
      segment: segment,
      marketRate: clampedRate,
      invoiceNo: invoiceNo,
    );
  }

  /// İki nokta arası mesafe (km) — Haversine formülü
  double calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const double earthRadius = 6371;
    double dLat = _toRadians(lat2 - lat1);
    double dLng = _toRadians(lng2 - lng1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  /// Yakındaki çevrimiçi sürücüleri bul
  Future<List<Map<String, dynamic>>> findNearbyDrivers(
    double lat, double lng, {
    double radiusKm = 5.0,
    VehicleSegment? segment,
  }) async {
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
      nearbyDrivers.sort((a, b) =>
          (a['distance'] as double).compareTo(b['distance'] as double));
      return nearbyDrivers;
    } catch (e) {
      debugPrint("Sürücü arama hatası: $e");
      return [];
    }
  }

  /// En yakın sürücüyü eşleştir
  Future<String?> findAndMatchDriver(
    String rideId, double pickupLat, double pickupLng,
  ) async {
    final drivers = await findNearbyDrivers(pickupLat, pickupLng);
    if (drivers.isEmpty) return null;

    final nearest = drivers.first;
    final driverId = nearest['driverId'] as String;

    await _firestore.collection('rides').doc(rideId).update({
      'driverId': driverId,
      'driverName': nearest['name'],
      'driverPhone': nearest['phone'],
      'status': 'matched',
    });

    return driverId;
  }

  // ── YARDIMCI ──

  double _round(double v) => (v * 100).roundToDouble() / 100;
  double _toRadians(double d) => d * pi / 180;

  String _generateInvoiceNo() {
    final now = DateTime.now();
    final random = Random().nextInt(9999).toString().padLeft(4, '0');
    return 'OY-${now.year}-${now.month.toString().padLeft(2, '0')}$random';
  }
}
