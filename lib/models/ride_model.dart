import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/ride_service.dart';

enum RideStatus {
  searching,
  matched,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

class Ride {
  final String id;
  final String passengerId;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final double pickupLat;
  final double pickupLng;
  final String pickupAddress;
  final double destLat;
  final double destLng;
  final String destAddress;
  final RideStatus status;
  final VehicleSegment segment;
  final int personCount;
  final double distanceKm;
  final int estimatedMinutes;
  final String invoiceNo;

  // Ücret kırılımı
  final double openingFee;
  final double distanceFee;
  final double segmentSurcharge;
  final double marketAdjustment;
  final double discount;
  final double grossTotal;
  final double commission;
  final double driverNet;
  final double perPersonFee;
  final double marketRate;

  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Ride({
    required this.id,
    required this.passengerId,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.pickupLat,
    required this.pickupLng,
    required this.pickupAddress,
    required this.destLat,
    required this.destLng,
    required this.destAddress,
    required this.status,
    this.segment = VehicleSegment.standard,
    this.personCount = 1,
    this.distanceKm = 0,
    this.estimatedMinutes = 0,
    this.invoiceNo = '',
    this.openingFee = 0,
    this.distanceFee = 0,
    this.segmentSurcharge = 0,
    this.marketAdjustment = 0,
    this.discount = 0,
    this.grossTotal = 0,
    this.commission = 0,
    this.driverNet = 0,
    this.perPersonFee = 0,
    this.marketRate = 1.0,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  factory Ride.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Ride(
      id: doc.id,
      passengerId: data['passengerId'] ?? '',
      driverId: data['driverId'],
      driverName: data['driverName'],
      driverPhone: data['driverPhone'],
      pickupLat: (data['pickupLat'] ?? 0).toDouble(),
      pickupLng: (data['pickupLng'] ?? 0).toDouble(),
      pickupAddress: data['pickupAddress'] ?? '',
      destLat: (data['destLat'] ?? 0).toDouble(),
      destLng: (data['destLng'] ?? 0).toDouble(),
      destAddress: data['destAddress'] ?? '',
      status: _parseStatus(data['status']),
      segment: _parseSegment(data['segment']),
      personCount: data['personCount'] ?? 1,
      distanceKm: (data['distanceKm'] ?? 0).toDouble(),
      estimatedMinutes: data['estimatedMinutes'] ?? 0,
      invoiceNo: data['invoiceNo'] ?? '',
      openingFee: (data['openingFee'] ?? 0).toDouble(),
      distanceFee: (data['distanceFee'] ?? 0).toDouble(),
      segmentSurcharge: (data['segmentSurcharge'] ?? 0).toDouble(),
      marketAdjustment: (data['marketAdjustment'] ?? 0).toDouble(),
      discount: (data['discount'] ?? 0).toDouble(),
      grossTotal: (data['grossTotal'] ?? 0).toDouble(),
      commission: (data['commission'] ?? 0).toDouble(),
      driverNet: (data['driverNet'] ?? 0).toDouble(),
      perPersonFee: (data['perPersonFee'] ?? 0).toDouble(),
      marketRate: (data['marketRate'] ?? 1.0).toDouble(),
      createdAt: _parseDate(data['createdAt']),
      startedAt: data['startedAt'] != null ? _parseDate(data['startedAt']) : null,
      completedAt: data['completedAt'] != null ? _parseDate(data['completedAt']) : null,
    );
  }

  static DateTime _parseDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  static RideStatus _parseStatus(String? status) {
    switch (status) {
      case 'matched': return RideStatus.matched;
      case 'driver_arriving': return RideStatus.driverArriving;
      case 'in_progress': return RideStatus.inProgress;
      case 'completed': return RideStatus.completed;
      case 'cancelled': return RideStatus.cancelled;
      default: return RideStatus.searching;
    }
  }

  static VehicleSegment _parseSegment(String? s) {
    switch (s) {
      case 'wide': return VehicleSegment.wide;
      case 'luxury': return VehicleSegment.luxury;
      default: return VehicleSegment.standard;
    }
  }

  String get statusText {
    switch (status) {
      case RideStatus.searching: return 'Sürücü Aranıyor';
      case RideStatus.matched: return 'Sürücü Bulundu';
      case RideStatus.driverArriving: return 'Sürücü Yolda';
      case RideStatus.inProgress: return 'Yolculuk Devam Ediyor';
      case RideStatus.completed: return 'Tamamlandı';
      case RideStatus.cancelled: return 'İptal Edildi';
    }
  }

  String get segmentLabel => SegmentConfig.get(segment).label;
  String get segmentIcon => SegmentConfig.get(segment).icon;

  Map<String, dynamic> toMap() {
    return {
      'passengerId': passengerId,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'pickupLat': pickupLat,
      'pickupLng': pickupLng,
      'pickupAddress': pickupAddress,
      'destLat': destLat,
      'destLng': destLng,
      'destAddress': destAddress,
      'status': _statusToString(status),
      'segment': segment.name,
      'personCount': personCount,
      'distanceKm': distanceKm,
      'estimatedMinutes': estimatedMinutes,
      'invoiceNo': invoiceNo,
      'openingFee': openingFee,
      'distanceFee': distanceFee,
      'segmentSurcharge': segmentSurcharge,
      'marketAdjustment': marketAdjustment,
      'discount': discount,
      'grossTotal': grossTotal,
      'commission': commission,
      'driverNet': driverNet,
      'perPersonFee': perPersonFee,
      'marketRate': marketRate,
      'createdAt': FieldValue.serverTimestamp(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  static String _statusToString(RideStatus s) {
    switch (s) {
      case RideStatus.driverArriving: return 'driver_arriving';
      case RideStatus.inProgress: return 'in_progress';
      default: return s.name;
    }
  }
}
