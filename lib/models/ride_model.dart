import 'package:cloud_firestore/cloud_firestore.dart';

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
  final double? fare;
  final double? distanceKm;
  final int? durationMin;
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
    this.fare,
    this.distanceKm,
    this.durationMin,
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
      fare: data['fare']?.toDouble(),
      distanceKm: data['distanceKm']?.toDouble(),
      durationMin: data['durationMin'],
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
      'status': status.name == 'driverArriving' ? 'driver_arriving' : status.name == 'inProgress' ? 'in_progress' : status.name,
      'fare': fare,
      'distanceKm': distanceKm,
      'durationMin': durationMin,
      'createdAt': FieldValue.serverTimestamp(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
    };
  }
}
