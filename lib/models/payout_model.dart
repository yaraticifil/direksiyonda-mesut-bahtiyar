import 'package:cloud_firestore/cloud_firestore.dart';

enum PayoutStatus { pending, completed, rejected }

class Payout {
  final String id;
  final String driverId;
  final double amount;
  final String description;
  final PayoutStatus status;
  final DateTime createdAt;
  final DateTime? completedAt; // Terminaldeki hata buradaydı, eklendi.

  Payout({
    required this.id,
    required this.driverId,
    required this.amount,
    required this.description,
    required this.status,
    required this.createdAt,
    this.completedAt,
  });

  factory Payout.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Payout(
      id: doc.id,
      driverId: data['driverId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      description: data['description'] ?? 'Ödeme Talebi',
      status: _parseStatus(data['status']),
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
      completedAt: data['completedAt'] != null ? (data['completedAt'] as Timestamp).toDate() : null,
    );
  }

  static PayoutStatus _parseStatus(String? status) {
    if (status == 'completed') return PayoutStatus.completed;
    if (status == 'rejected') return PayoutStatus.rejected;
    return PayoutStatus.pending;
  }

  String get statusText => status.toString().split('.').last.toUpperCase();
}