import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';

class LegalContractScreen extends StatelessWidget {
  const LegalContractScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final driver = authController.driver;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dijital Kira Sözleşmesi'),
        backgroundColor: Colors.blueGrey[900],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(Icons.gavel_rounded, size: 60, color: Colors.blueGrey),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'TAŞIT KİRALAMA VE HİZMET SÖZLEŞMESİ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 40),
            _buildSection('1. TARAFLAR', 
              'İşbu sözleşme, Bahtiyar Teknoloji Platformu (Ortak Yol) ve sistemde kayıtlı sürücü ${driver?.name ?? 'Sürücü'} arasında akdedilmiştir.'),
            _buildSection('2. KONU', 
              'İşbu belge, 6098 sayılı Türk Borçlar Kanunu ve ilgili mevzuat uyarınca düzenlenen "Taşıt Kira Sözleşmesi"nin dijital bir suretidir. Sürücü, platform üzerinden aldığı çağrılar kapsamında hukuki bir "Hizmet Sağlayıcı" statüsündedir.'),
            _buildSection('3. PLATFORM HİZMETİ', 
              'Bu ekran, hizmet kapsamına ilişkin platform kayıt özetidir. Nihai değerlendirme, somut olaya ve yetkili mercilere göre yapılır.'),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.blueGrey[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   const Text('DİJİTAL ONAY BİLGİLERİ', style: TextStyle(fontWeight: FontWeight.bold)),
                   const Divider(),
                   _buildRow('Sürücü Adı:', driver?.name ?? '-'),
                   _buildRow('TC/ID:', driver?.id.substring(0, 10).toUpperCase() ?? '-'),
                   _buildRow('Sözleşme Tarihi:', DateTime.now().toString().substring(0, 10)),
                   _buildRow('Durum:', 'PLATFORMDA AKTİF'),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Center(
              child: Text(
                'Bahtiyar Platformu Destek Hattı, acil durumlarda\nolay kaydını ve yönlendirmeyi hızlandırmayı amaçlar.',
                textAlign: TextAlign.center,
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.blueGrey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 5),
          Text(content, style: const TextStyle(fontSize: 13, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
