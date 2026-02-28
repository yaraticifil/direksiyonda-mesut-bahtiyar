import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';

class RideHistoryScreen extends StatefulWidget {
  const RideHistoryScreen({super.key});

  @override
  State<RideHistoryScreen> createState() => _RideHistoryScreenState();
}

class _RideHistoryScreenState extends State<RideHistoryScreen> {
  final AuthController authController = Get.find<AuthController>();
  final PassengerController pc = Get.find<PassengerController>();

  @override
  void initState() {
    super.initState();
    if (authController.user != null) {
      pc.fetchRideHistory(authController.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        title: const Text('Yolculuk Geçmişi', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: Obx(() {
        if (pc.rideHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car_outlined, color: Colors.grey[700], size: 60),
                const SizedBox(height: 16),
                Text('Henüz yolculuk geçmişiniz yok', style: TextStyle(color: Colors.grey[500], fontSize: 15)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pc.rideHistory.length,
          itemBuilder: (context, index) {
            final ride = pc.rideHistory[index];
            return _rideCard(ride);
          },
        );
      }),
    );
  }

  Widget _rideCard(Ride ride) {
    final config = SegmentConfig.get(ride.segment);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst satır: tarih + durum + segment
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${ride.createdAt.day.toString().padLeft(2, '0')}.${ride.createdAt.month.toString().padLeft(2, '0')}.${ride.createdAt.year} ${ride.createdAt.hour.toString().padLeft(2, '0')}:${ride.createdAt.minute.toString().padLeft(2, '0')}',
                style: TextStyle(color: Colors.grey[500], fontSize: 11),
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text('${config.icon} ${config.label}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 9)),
                  ),
                  const SizedBox(width: 6),
                  _statusBadge(ride.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Rota
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 8),
              const SizedBox(width: 8),
              Expanded(child: Text(ride.pickupAddress, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(width: 1, height: 12, color: Colors.grey[700]),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 8),
              const SizedBox(width: 8),
              Expanded(child: Text(ride.destAddress, style: const TextStyle(color: Colors.white, fontSize: 12), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const Divider(color: Color(0xFF444444), height: 16),

          // Bilgiler
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _miniInfo('Mesafe', '${ride.distanceKm.toStringAsFixed(1)} km'),
              _miniInfo('Fiyat', '₺${ride.grossTotal.toStringAsFixed(0)}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 10)),
      ],
    );
  }

  Widget _statusBadge(RideStatus status) {
    Color color;
    String text;
    switch (status) {
      case RideStatus.completed:
        color = Colors.green; text = 'Tamamlandı'; break;
      case RideStatus.cancelled:
        color = Colors.red; text = 'İptal'; break;
      case RideStatus.inProgress:
        color = Colors.blue; text = 'Devam'; break;
      default:
        color = Colors.orange; text = 'Bekliyor'; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}
