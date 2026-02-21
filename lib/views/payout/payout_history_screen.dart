import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/driver_controller.dart';
import '../../models/payout_model.dart';

class PayoutHistoryScreen extends StatelessWidget {
  const PayoutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DriverController driverController = Get.find<DriverController>();

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text('Ödeme Geçmişi'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => driverController.fetchPayouts(),
        child: Obx(() {
          if (driverController.payouts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Henüz ödeme kaydı yok',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Ödeme geçmişiniz burada görünecek',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: driverController.payouts.length,
            itemBuilder: (context, index) {
              final payout = driverController.payouts[index];
              return _buildPayoutCard(payout);
            },
          );
        }),
      ),
    );
  }

  Widget _buildPayoutCard(Payout payout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getStatusColor(payout.status).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    _getStatusIcon(payout.status),
                    color: _getStatusColor(payout.status),
                    size: 25,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payout.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Talep: ${DateFormat('dd.MM.yyyy • HH:mm').format(payout.createdAt)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      if (payout.completedAt != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Onaylandı: ${DateFormat('dd.MM.yyyy • HH:mm').format(payout.completedAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[400],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺${payout.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(payout.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        payout.statusText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (payout.status == PayoutStatus.pending)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 16,
                    color: Colors.orange[700],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Ödeme talebiniz yöneticiler tarafından inceleniyor',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.pending:
        return Colors.orange;
      case PayoutStatus.completed:
        return Colors.green;
      case PayoutStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.pending:
        return Icons.hourglass_empty;
      case PayoutStatus.completed:
        return Icons.check_circle;
      case PayoutStatus.rejected:
        return Icons.cancel;
    }
  }
}
