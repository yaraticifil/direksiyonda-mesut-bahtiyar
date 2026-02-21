import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';

/// Ekran 2 — Yolculuk Tamamlandı · Ücret Özeti
/// Yolcu + Sürücü Ortak Görünüm
class RideCompletionScreen extends StatelessWidget {
  final Ride ride;
  const RideCompletionScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Get.back()),
        title: const Text('Yolculuk Tamamlandı', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Başarı ikonu
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), shape: BoxShape.circle),
              child: const Icon(Icons.check_circle, color: Colors.green, size: 40),
            ),
            const SizedBox(height: 16),
            Text('Ücret Özeti', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
            const SizedBox(height: 20),

            // ── ÜST BLOK: Yolculuk Bilgileri ──
            _card([
              _row('Yolculuk No', ride.invoiceNo.isNotEmpty ? ride.invoiceNo : 'OY-2026-XXXX'),
              _row('Tarih / Saat', _formatDate(ride.createdAt)),
              _routeRow(),
              _row('Gerçekleşen Mesafe', '${ride.distanceKm.toStringAsFixed(1)} km'),
              _row('Gerçekleşen Süre', '${ride.estimatedMinutes} dk'),
              _row('Araç Segmenti', SegmentConfig.get(ride.segment).label),
              _row('Paylaşım Kişi Sayısı', '${ride.personCount} kişi'),
            ]),
            const SizedBox(height: 16),

            // ── ÜCRET KIRILIMI ──
            _card([
              _sectionHeader('ÜCRET KIRILIMI (Kiralama Bedeli)'),
              const SizedBox(height: 10),
              _fareRow('Açılış Bedeli', ride.openingFee),
              _fareRow('Mesafe Bedeli', ride.distanceFee),
              if (ride.segmentSurcharge > 0) _fareRow('Segment Farkı', ride.segmentSurcharge),
              if (ride.marketAdjustment > 0) _fareRow('Piyasa Koşulları Ayarı', ride.marketAdjustment),
              if (ride.discount > 0) _fareRow('İndirim / Kampanya', -ride.discount, isDiscount: true),
              const Divider(color: Color(0xFF444444), height: 20),
              _fareRow('Kesinleşen Toplam Araç Bedeli', ride.grossTotal, isBold: true),
            ]),
            const SizedBox(height: 16),

            // ── KİŞİ BAŞI DAĞILIM ──
            if (ride.personCount > 1) ...[
              _card([
                _sectionHeader('KİŞİ BAŞI DAĞILIM'),
                const SizedBox(height: 10),
                _row('Kişi Sayısı', '${ride.personCount}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Kişi Başı Nihai Bedel', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 14)),
                    Text('₺${ride.perPersonFee.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ]),
              const SizedBox(height: 16),
            ],

            // ── E-FATURA / E-BELGE ──
            _card([
              _sectionHeader('E-FATURA / E-BELGE'),
              const SizedBox(height: 10),
              _row('Belge Tipi', 'e-Arşiv Fatura'),
              _row('Belge No', ride.invoiceNo.isNotEmpty ? ride.invoiceNo : 'Oluşturuluyor...'),
              _row('Belge Tarihi', _formatDate(ride.completedAt ?? ride.createdAt)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.snackbar("Bilgi", "E-fatura indirme henüz entegre edilmedi."),
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('İndir', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFFD700),
                        side: const BorderSide(color: Color(0xFFFFD700)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Get.snackbar("Bilgi", "QR doğrulama henüz entegre edilmedi."),
                      icon: const Icon(Icons.qr_code, size: 16),
                      label: const Text('QR Doğrula', style: TextStyle(fontSize: 12)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[400],
                        side: BorderSide(color: Colors.grey[600]!),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(height: 20),

            // Ana ekrana dön
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.offAllNamed('/passenger-home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('ANA EKRANA DÖN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }

  Widget _sectionHeader(String text) {
    return Row(
      children: [
        Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(width: 10),
          Flexible(child: Text(value, style: const TextStyle(color: Colors.white, fontSize: 12), textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _routeRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rota', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.circle, color: Colors.green, size: 8),
              const SizedBox(width: 6),
              Expanded(child: Text(ride.pickupAddress, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 3),
            child: Container(width: 1, height: 14, color: Colors.grey[600]),
          ),
          Row(
            children: [
              const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 8),
              const SizedBox(width: 6),
              Expanded(child: Text(ride.destAddress, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fareRow(String label, double amount, {bool isBold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: TextStyle(
            color: isBold ? Colors.white : Colors.grey[400],
            fontSize: isBold ? 13 : 12,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ))),
          Text(
            '${isDiscount ? "-" : ""}₺${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isDiscount ? Colors.green : (isBold ? const Color(0xFFFFD700) : Colors.white),
              fontSize: isBold ? 16 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
