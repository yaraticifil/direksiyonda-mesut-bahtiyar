import 'package:cloud_firestore/cloud_firestore.dart';

enum DriverStatus { pending, approved, rejected }

class Driver {
  final String id;
  final String name;
  final String phone;
  final DriverStatus status;
  final DateTime createdAt;

  Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.status,
    required this.createdAt,
  });

  factory Driver.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Driver(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      status: _parseStatus(data['status']),
      createdAt: data['createdAt'] != null ? DateTime.parse(data['createdAt']) : DateTime.now(),
    );
  }

  static DriverStatus _parseStatus(String? status) {
    if (status == 'approved') return DriverStatus.approved;
    if (status == 'rejected') return DriverStatus.rejected;
    return DriverStatus.pending;
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Eksik olan statusText ve Renk getterları:
  String get statusText {
    switch (status) {
      case DriverStatus.approved: return 'Onaylandı';
      case DriverStatus.rejected: return 'Reddedildi';
      default: return 'Beklemede';
    }
  }
}