import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import '../../models/ride_model.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final AuthController authController = Get.find<AuthController>();
  final PassengerController passengerController = Get.find<PassengerController>();

  @override
  void initState() {
    super.initState();
    if (authController.user != null) {
      passengerController.fetchRideHistory(authController.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text('Yolculuk Geçmişi'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: Obx(() {
        if (passengerController.rideHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.directions_car_outlined, size: 60, color: Colors.grey[700]),
                const SizedBox(height: 16),
                Text(
                  'Henüz yolculuk kaydınız yok',
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'İlk yolculuğunuzu şimdi yapın!',
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: passengerController.rideHistory.length,
          itemBuilder: (context, index) {
            final ride = passengerController.rideHistory[index];
            return _buildRideCard(ride);
          },
        );
      }),
    );
  }

  Widget _buildRideCard(Ride ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _getStatusColor(ride.status).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarih ve durum
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd.MM.yyyy • HH:mm').format(ride.createdAt),
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(ride.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ride.statusText,
                  style: TextStyle(
                    color: _getStatusColor(ride.status),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nereden
          Row(
            children: [
              const Icon(Icons.radio_button_checked, color: Colors.green, size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.pickupAddress.isNotEmpty ? ride.pickupAddress : 'Başlangıç noktası',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 6),
            height: 15,
            width: 2,
            color: Colors.grey[700],
          ),
          // Nereye
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 14),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.destAddress.isNotEmpty ? ride.destAddress : 'Hedef noktası',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Alt bilgiler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (ride.distanceKm != null)
                _infoChip(Icons.straighten, '${ride.distanceKm!.toStringAsFixed(1)} km'),
              if (ride.durationMin != null)
                _infoChip(Icons.timer_outlined, '${ride.durationMin} dk'),
              Text(
                '₺${ride.fare?.toStringAsFixed(2) ?? '—'}',
                style: const TextStyle(
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey[500], size: 14),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.completed: return Colors.green;
      case RideStatus.cancelled: return Colors.red;
      default: return Colors.orange;
    }
  }
}
