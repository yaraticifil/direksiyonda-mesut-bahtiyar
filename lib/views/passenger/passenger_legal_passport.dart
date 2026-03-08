import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import 'package:intl/intl.dart';

class PassengerLegalPassport extends StatefulWidget {
  const PassengerLegalPassport({super.key});

  @override
  State<PassengerLegalPassport> createState() => _PassengerLegalPassportState();
}

class _PassengerLegalPassportState extends State<PassengerLegalPassport> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  void _flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() => isFront = !isFront);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final passengerController = Get.find<PassengerController>();
    final user = authController.userData.value;
    
    // In a real scenario, we'd fetch the active ride
    final activeRide = passengerController.activeRide.value;
    final bool hasActiveRide = activeRide != null && activeRide.status != 'completed';

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        title: const Text('HUKUKİ PASAPORT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // Status Indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: hasActiveRide ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: hasActiveRide ? Colors.green : Colors.grey, width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(
                      color: hasActiveRide ? Colors.green : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    hasActiveRide ? 'HUKUKİ KORUMA AKTİF' : 'KORUMA BEKLEMEDE',
                    style: TextStyle(
                      color: hasActiveRide ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Flip Card
            GestureDetector(
              onTap: _flipCard,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  final angle = _animation.value * 3.14159;
                  return Transform(
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.001)
                      ..rotateY(angle),
                    alignment: Alignment.center,
                    child: angle < 1.5708
                        ? _buildFrontFace(user, activeRide)
                        : Transform(
                            transform: Matrix4.identity()..rotateY(3.14159),
                            alignment: Alignment.center,
                            child: _buildBackFace(),
                          ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Helpful text
            const Text(
              "Polis çevirmesinde bu kartı göstererek 'Kiracı' olduğunuzu beyan edebilirsiniz.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFrontFace(dynamic user, dynamic ride) {
    return Container(
      width: double.infinity,
      height: 520,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(color: Colors.blueAccent.withOpacity(0.1), blurRadius: 20, spreadRadius: 5),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.blueAccent.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: const Center(
              child: Text(
                'KİRACI KİMLİK BİLGİSİ',
                style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, letterSpacing: 2),
              ),
            ),
          ),
          
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // QR Code
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: QrImageView(
                      data: 'https://ortakyol.app/contract/${ride?.id ?? 'demo'}',
                      version: QrVersions.auto,
                      size: 160.0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Passenger Info
                  _buildInfoRow('KİRACI (YOLCU)', user?.name ?? 'Kullanıcı'),
                  _buildInfoRow('KİRALAMA TARİHİ', DateFormat('dd.MM.yyyy').format(DateTime.now())),
                  _buildInfoRow('SÖZLEŞME ID', ride?.id?.substring(0, 8).toUpperCase() ?? 'YOK'),
                  
                  const Spacer(),
                  // Legal Text
                  const Text(
                    '"Bu araç, 6098 sayılı Türk Borçlar Kanunu (TBK) Madde 299 uyarınca şahsım tarafından kiralanmıştır. Araç içerisinde ticari bir yolcu taşımacılığı değil, kiralama sözleşmesine dayalı özel kullanım söz konusudur."',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic, height: 1.4),
                  ),
                ],
              ),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: const Text('Detaylar için karta dokunun ↻', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildBackFace() {
    return Container(
      width: double.infinity,
      height: 520,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 2),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: const Center(
              child: Text(
                'YOLCU İÇİN HUKUKİ REHBER',
                style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold, letterSpacing: 1),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegalPoint('Soru 1: Ücret ödediniz mi?', 'Cevap: "Evet, bu bir şoförlü araç kiralama hizmetidir. Kiralama bedelini uygulama üzerinden resmi fatura karşılığı ödedim."'),
                  _buildLegalPoint('Soru 2: Sürücüyü tanıyor musunuz?', 'Cevap: "Kendisi kiraladığım aracın tahsisli şoförüdür. Ortak Yol platformu aracılığıyla hukuki sözleşmemiz mevcuttur."'),
                  _buildLegalPoint('Haklarınız:', 'Anayasa m.48 gereği herkes sözleşme hürriyetine sahiptir. Kiraladığınız araçta bulunmanız yasal hakkınızdır.'),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.redAccent.withOpacity(0.3)),
                    ),
                    child: const Text(
                      'NOT: Özel hayatın gizliliği gereği, kiralama detayları haricinde (nereye gittiğiniz, kimle buluşacağınız vb.) bilgi verme zorunluluğunuz yoktur.',
                      style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildLegalPoint(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.orangeAccent, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.4)),
        ],
      ),
    );
  }
}
