import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';

/// Ekran 4 — Yolculuk Detayı ve Netleşme (Sürücü Derin Görünüm)
class RideDetailScreen extends StatelessWidget {
  const RideDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Ride ride = Get.arguments as Ride;
    final config = SegmentConfig.get(ride.segment);

    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        title: const Text('Yolculuk Detayı ve Netleşme', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 15)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── YOLCULUK BİLGİLERİ ──
            _card('YOLCULUK BİLGİLERİ', [
              _info('Yolculuk No', ride.invoiceNo.isNotEmpty ? ride.invoiceNo : '-'),
              _info('Başlangıç', _formatDate(ride.createdAt)),
              if (ride.completedAt != null) _info('Bitiş', _formatDate(ride.completedAt!)),
              const SizedBox(height: 8),
              // Rota
              Row(
                children: [
                  Column(
                    children: [
                      const Icon(Icons.circle, color: Colors.green, size: 10),
                      Container(width: 1, height: 24, color: Colors.grey[600]),
                      const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 10),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ride.pickupAddress, style: const TextStyle(color: Colors.white, fontSize: 12)),
                        const SizedBox(height: 16),
                        Text(ride.destAddress, style: const TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _info('Gerçekleşen Mesafe', '${ride.distanceKm.toStringAsFixed(1)} km'),
              _info('Gerçekleşen Süre', '${ride.estimatedMinutes} dk'),
              _info('Segment', '${config.icon} ${config.label}'),
            ]),
            const SizedBox(height: 16),

            // ── FİNANSAL NETLEŞME KIRILIMI ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _header('FİNANSAL NETLEŞME KIRILIMI'),
                  const SizedBox(height: 6),
                  Text('Zorunlu şeffaflık alanı', style: TextStyle(color: Colors.grey[600], fontSize: 9, fontStyle: FontStyle.italic)),
                  const SizedBox(height: 14),
                  _financialRow('Brüt Yolculuk Bedeli', ride.grossTotal, isBold: true),
                  _financialRow('Platform Komisyonu (%12)', -ride.commission, isNeg: true),
                  _financialRow('Kampanya Katkısı (Platform)', 0, note: 'Yok'),
                  _financialRow('Kampanya Katkısı (Sürücü)', 0, note: 'Yok'),
                  _financialRow('Vergi / Yasal Kesinti', 0, note: 'Mevzuata göre'),
                  _financialRow('İptal / İade Düzeltmesi', 0, note: 'Yok'),
                  const Divider(color: Color(0xFFFFD700), height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Sürücüye Yansıyan Net Tutar', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('₺${ride.driverNet.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 22)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── CÜZDAN HAREKETİ ──
            _card('CÜZDAN HAREKETİ', [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Yansıma Durumu', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 14),
                        SizedBox(width: 4),
                        Text('Yansıdı', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
              _info('Yansıma Zamanı', _formatDate(ride.completedAt ?? ride.createdAt)),
              _info('Transfer Referans No', ride.invoiceNo.isNotEmpty ? 'TRF-${ride.invoiceNo}' : '-'),
            ]),
            const SizedBox(height: 16),

            // ── BELGE VE KAYIT ──
            _card('BELGE VE KAYIT', [
              _actionButton(Icons.receipt_long, 'E-fatura görüntüle', () => Get.snackbar("Bilgi", "E-fatura henüz entegre edilmedi.")),
              _actionButton(Icons.description, 'Yolculuk sözleşmesi özeti', () => Get.snackbar("Bilgi", "Sözleşme özeti henüz entegre edilmedi.")),
              _actionButton(Icons.map, 'Rota kayıt özeti', () => Get.snackbar("Bilgi", "Rota kaydı henüz entegre edilmedi.")),
              _actionButton(Icons.support_agent, 'Destek talebi oluştur', () => Get.snackbar("Bilgi", "Destek sistemi henüz entegre edilmedi.")),
            ]),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(title),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _header(String text) {
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _financialRow(String label, double amount, {bool isBold = false, bool isNeg = false, String? note}) {
    String text;
    Color color;
    if (note != null && amount == 0) {
      text = note;
      color = Colors.grey[600]!;
    } else {
      text = '${isNeg ? "-" : ""}₺${amount.abs().toStringAsFixed(2)}';
      color = isNeg ? Colors.red : Colors.white;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(label, style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                Expanded(child: Text(
                  ' ${'.' * 30}',
                  style: TextStyle(color: Colors.grey[700], fontSize: 10),
                  overflow: TextOverflow.clip,
                  maxLines: 1,
                )),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(color: color, fontWeight: isBold ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey[800]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFFFFD700), size: 18),
              const SizedBox(width: 12),
              Expanded(child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 13))),
              Icon(Icons.chevron_right, color: Colors.grey[600], size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
