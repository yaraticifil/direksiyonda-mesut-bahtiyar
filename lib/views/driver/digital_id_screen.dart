import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import '../../controllers/auth_controller.dart';
import '../../controllers/driver_controller.dart';
import '../../models/ride_model.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DigitalIdScreen extends StatefulWidget {
  const DigitalIdScreen({super.key});

  @override
  State<DigitalIdScreen> createState() => _DigitalIdScreenState();
}

class _DigitalIdScreenState extends State<DigitalIdScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;
  
  final FlutterTts flutterTts = FlutterTts();
  bool isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
    _initTts();
  }

  void _initTts() async {
    await flutterTts.setLanguage("tr-TR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    flutterTts.setCompletionHandler(() {
      if (mounted) {
        setState(() => isSpeaking = false);
      }
    });
  }

  Future<void> _toggleAssistant() async {
    if (isSpeaking) {
      await flutterTts.stop();
      setState(() => isSpeaking = false);
    } else {
      setState(() => isSpeaking = true);
      String text = "Lütfen sakin olun. Memur beye sadece ön yüzdeki karekodu ve kiralama sözleşmenizi gösterin. Tartışmaya girmeyin. İhtiyaç halinde ekrandaki butondan doğrudan avukatınızı bağlayabilirsiniz.";
      await flutterTts.speak(text);
    }
  }

  void _flipCard() {
    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
    setState(() {
      isFront = !isFront;
    });
  }

  void _showLegislationReference() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Mevzuat Referans Motoru',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const SizedBox(height: 15),
              _buildReferenceItem(
                'İtiraz: "Belediye İzni Yok"',
                'Danıştay 15. Daire, 2015/4585 E.',
                'Şoförlü araç kiralama faaliyetinde belediye izni veya tahdidi ticari plaka şartı aranmaz. Zira bu taşıma değil, hususi kiralama sözleşmesidir.',
              ),
              const SizedBox(height: 10),
              _buildReferenceItem(
                'İtiraz: "Korsan Taşımacılık Yapıyorsunuz (Ek 2/3)"',
                'Danıştay 8. Daire, 2019/2919 E.',
                'Taraflar arasında fatura ve yazılı kira sözleşmesi ibraz edildiğinde korsan taşımacılık sayılamaz, fiili durum ticari taksi ile aynı değerlendirilemez.',
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final ride = Get.find<DriverController>().currentRide.value;
                  final driver = Get.find<AuthController>().driver;
                  final bool hasActiveRide = ride != null && 
                      (ride.status == 'in_progress' || ride.status == 'driver_arriving' || ride.status == 'driver_arrived');

                  return ElevatedButton.icon(
                    onPressed: hasActiveRide
                        ? () => _showPetitionModal(context, driver, ride)
                        : () => Get.snackbar(
                              "Hata", 
                              "Dilekçe oluşturmak için aktif bir yolculuğunuz (sözleşmeniz) olmalıdır.",
                              backgroundColor: Colors.redAccent,
                              colorText: Colors.white,
                            ),
                    icon: const Icon(Icons.article),
                    label: const Text('İPTAL DİLEKÇESİ HAZIRLA'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasActiveRide ? Colors.blueAccent : Colors.grey[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPetitionModal(BuildContext context, dynamic driver, dynamic ride) {
    Navigator.pop(context); // Close the previous bottom sheet

    final String petitionText = '''
### NÖBETÇİ SULH CEZA HAKİMLİĞİNE

**İTİRAZ EDEN (SÜRÜCÜ):** ${driver?.name ?? 'Bilinmiyor'}
**VEKİLİ:** Ortak Yol Nöbetçi Avukatı
**KARŞI TARAF:** İlgili Trafik Denetleme Şube Müdürlüğü
**KONU:** ${DateFormat('dd.MM.yyyy').format(DateTime.now())} tarihli İdari Para Cezası ve Trafikten Men İşleminin İPTALİ talebidir.

**AÇIKLAMALAR:**
1. Müvekkil, olay tarihinde "Ortak Yol" platformu üzerinden, Türk Borçlar Kanunu m. 299 uyarınca "Şoförlü Araç Kiralama" hizmeti ifa etmektedir.
2. Ekte sunulan e-Arşiv Fatura ve **${ride?.id?.substring(0, 8).toUpperCase() ?? '-'}** numaralı Kira Sözleşmesi, faaliyetin ticari taksi (korsan) değil, yasal bir kiralama olduğunu ispatlamaktadır.
3. Danıştay 8. Dairesi'nin 2019/2919 E. sayılı kararında belirtildiği üzere; "ticari amaçlı yolcu taşımacılığı yapıldığı hususu her türlü şüpheden uzak, açık ve kesin delillerle ortaya konulmalıdır." 
4. Somut olayda, taraflar arasında yazılı bir kira sözleşmesi ve vergilendirilmiş bir bedel mevcut olup, Anayasa m. 48 (Sözleşme Hürriyeti) kapsamında yürütülen bu faaliyetin cezalandırılması hukuka aykırıdır.

**SONUÇ VE İSTEM:** Hukuka aykırı düzenlenen idari para cezasının iptaline ve aracın trafikten men şerhinin kaldırılmasına karar verilmesini arz ederiz.
''';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1C1C1C),
          title: const Row(
            children: [
              Icon(Icons.gavel, color: Colors.blueAccent),
              SizedBox(width: 10),
              Expanded(
                child: Text('Dilekçe Önizlemesi', style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Text(
              petitionText,
              style: const TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Kapat', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _generateAndUploadPetition(driver, ride);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
              child: const Text('Hukuk Birimine İlet (PDF Oluştur)', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _generateAndUploadPetition(dynamic driver, dynamic ride) async {
    // Show loading
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
      barrierDismissible: false,
    );

    try {
      final pdf = pw.Document();
      final font = await PdfGoogleFonts.robotoRegular();
      final fontBold = await PdfGoogleFonts.robotoBold();

      final String dateStr = DateFormat('dd.MM.yyyy').format(DateTime.now());
      final String driverName = driver?.name ?? 'Bilinmiyor';
      final String contractId = ride?.id?.substring(0, 8).toUpperCase() ?? '-';

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Padding(
              padding: const pw.EdgeInsets.all(32),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Text('NÖBETÇİ SULH CEZA HAKİMLİĞİNE', 
                      style: pw.TextStyle(font: fontBold, fontSize: 16)),
                  ),
                  pw.SizedBox(height: 30),
                  pw.Text('İTİRAZ EDEN (SÜRÜCÜ): $driverName', style: pw.TextStyle(font: fontBold)),
                  pw.Text('VEKİLİ: Ortak Yol Nöbetçi Avukatı', style: pw.TextStyle(font: fontBold)),
                  pw.Text('KARŞI TARAF: İlgili Trafik Denetleme Şube Müdürlüğü', style: pw.TextStyle(font: fontBold)),
                  pw.SizedBox(height: 10),
                  pw.Text('KONU: $dateStr tarihli İdari Para Cezası ve Trafikten Men İşleminin İPTALİ talebidir.', 
                    style: pw.TextStyle(font: fontBold)),
                  pw.SizedBox(height: 20),
                  pw.Text('AÇIKLAMALAR:', style: pw.TextStyle(font: fontBold, fontSize: 14)),
                  pw.SizedBox(height: 10),
                  pw.Text('1. Müvekkil, olay tarihinde "Ortak Yol" platformu üzerinden, Türk Borçlar Kanunu m. 299 uyarınca "Şoförlü Araç Kiralama" hizmeti ifa etmektedir.', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 5),
                  pw.Text('2. Ekte sunulan e-Arşiv Fatura ve $contractId numaralı Kira Sözleşmesi, faaliyetin ticari taksi (korsan) değil, yasal bir kiralama olduğunu ispatlamaktadır.', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 5),
                  pw.Text('3. Danıştay 8. Dairesi\'nin 2019/2919 E. sayılı kararında belirtildiği üzere; "ticari amaçlı yolcu taşımacılığı yapıldığı hususu her türlü şüpheden uzak, açık ve kesin delillerle ortaya konulmalıdır."', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 5),
                  pw.Text('4. Somut olayda, taraflar arasında yazılı bir kira sözleşmesi ve vergilendirilmiş bir bedel mevcut olup, Anayasa m. 48 (Sözleşme Hürriyeti) kapsamında yürütülen bu faaliyetin cezalandırılması hukuka aykırıdır.', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 20),
                  pw.Text('SONUÇ VE İSTEM:', style: pw.TextStyle(font: fontBold, fontSize: 14)),
                  pw.SizedBox(height: 10),
                  pw.Text('Hukuka aykırı düzenlenen idari para cezasının iptaline ve aracın trafikten men şerhinin kaldırılmasına karar verilmesini arz ederiz.', style: pw.TextStyle(font: font)),
                  pw.SizedBox(height: 40),
                  pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('İtiraz Eden Vekili\\nOrtak Yol Nöbetçi Avukatı', style: pw.TextStyle(font: fontBold), textAlign: pw.TextAlign.center),
                  ),
                ],
              ),
            );
          },
        ),
      );

      final Uint8List pdfBytes = await pdf.save();
      
      final String fileName = 'petition_${driver?.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final Reference storageRef = FirebaseStorage.instance.ref().child('petitions/$fileName');
      
      final SettableMetadata metadata = SettableMetadata(contentType: 'application/pdf');
      final UploadTask uploadTask = storageRef.putData(pdfBytes, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      await FirebaseFirestore.instance.collection('petitions').add({
        'driverId': driver?.id ?? 'unknown',
        'driverName': driverName,
        'rideId': ride?.id ?? 'unknown',
        'pdfUrl': downloadUrl,
        'status': 'pending_review',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.back(); // Close loading dialog
      
      Get.snackbar(
        "PDF Başarıyla Üretildi", 
        "Resmi dilekçeniz sistemde (PDF) oluşturuldu ve Hukuk Birimi'ne iletildi.",
        backgroundColor: Colors.green.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        duration: const Duration(seconds: 4),
      );

    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        "Hata Oluştu", 
        "Dilekçe PDF'e dönüştürülürken bir hata meydana geldi: \$e",
        backgroundColor: Colors.redAccent.withOpacity(0.8),
        colorText: Colors.white,
        icon: const Icon(Icons.error, color: Colors.white),
      );
    }
  }

  Widget _buildReferenceItem(String objection, String lawRef, String detail) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(objection, style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 4),
          Text(lawRef, style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 4),
          Text(detail, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text('Dinamik Hukuki Pasaport'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Çevirme anında memura sadece bu kartı gösterin. Tartışmaya girmeyin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _flipCard,
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    final angle = _animation.value * pi;
                    final isBackVisible = angle >= pi / 2;
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isBackVisible
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildBackFace(),
                            )
                          : _buildFrontFace(),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _flipCard,
                    icon: const Icon(Icons.flip_camera_android),
                    label: Text(isFront ? "Arkayı Çevir (Polis İçin)" : "Ön Yüze Dön"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white10,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  ElevatedButton.icon(
                    onPressed: () => Get.find<AuthController>().launchEmergencySupport(),
                    icon: const Icon(Icons.gavel),
                    label: const Text("Avukatı Ara"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              GestureDetector(
                onTap: _toggleAssistant,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  decoration: BoxDecoration(
                    color: isSpeaking ? Colors.redAccent.withOpacity(0.2) : Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: isSpeaking ? Colors.redAccent : Colors.blueAccent,
                      width: 2,
                    ),
                    boxShadow: isSpeaking ? [
                      BoxShadow(color: Colors.redAccent.withOpacity(0.5), blurRadius: 20, spreadRadius: 5)
                    ] : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(isSpeaking ? Icons.record_voice_over : Icons.mic, 
                           color: isSpeaking ? Colors.redAccent : Colors.blueAccent),
                      const SizedBox(width: 10),
                      Text(
                        isSpeaking ? "ASİSTAN KONUŞUYOR..." : "SESLİ SAVUNMA ASİSTANI",
                        style: TextStyle(
                          color: isSpeaking ? Colors.redAccent : Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontFace() {
    final driver = Get.find<AuthController>().driver;
    return Obx(() {
      final currentRide = Get.find<DriverController>().currentRide.value;
      final bool hasActiveRide = currentRide != null && 
          (currentRide.status == 'in_progress' || currentRide.status == 'driver_arriving' || currentRide.status == 'driver_arrived');
      
      final String qrData = hasActiveRide 
          ? 'https://ortakyol.web.app/contract/${currentRide.id}'
          : 'https://ortakyol.web.app/verify/${driver?.id ?? "unknown"}';

      return Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasActiveRide ? Colors.greenAccent : const Color(0xFFFFD700), 
            width: hasActiveRide ? 3 : 2
          ),
          boxShadow: [
            BoxShadow(
              color: hasActiveRide ? Colors.greenAccent.withValues(alpha: 0.15) : const Color(0xFFFFD700).withValues(alpha: 0.1),
              blurRadius: 15,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Live Status Indicator
            if (hasActiveRide)
              Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.greenAccent),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'HUKUKİ KORUMA AKTİF',
                      style: TextStyle(
                        color: Colors.greenAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              hasActiveRide ? 'ŞOFÖRLÜ ARAÇ KİRALAMA\nSÖZLEŞMESİ VE FATURA' : 'RESMİ FAALİYET BİLDİRİMİ\nVE SÜRÜCÜ PROFİLİ',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: hasActiveRide ? Colors.white : const Color(0xFFFFD700),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 140.0,
              ),
            ),
            const SizedBox(height: 15),

            if (hasActiveRide) ...[
              Text(
                'Sözleşme No: ${currentRide.id.substring(0, 8).toUpperCase()}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 5),
              Text(
                'Kiracı (Yolcu): ${currentRide.passengerName}',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 5),
              Text(
                'Başlangıç: ${DateFormat('HH:mm').format(currentRide.createdAt)}',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
              const SizedBox(height: 15),
            ],

            const Text(
              "Bu araçta icra edilen faaliyet, 6098 sayılı Türk Borçlar Kanunu (TBK) Madde 299 uyarınca akdedilmiş bir Şoförlü Araç Kiralama hizmetidir. Yolcu, aracın ve şoförün kullanım hakkını belirli bir süre için kiralamış olan 'Kiracı' sıfatındadır.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(color: Colors.white24, thickness: 1),
            const SizedBox(height: 10),
            Text(
              'ACİL HAT: ${AuthController.supportPhoneNumber}\n(7/24 Nöbetçi Avukat Hattı)',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildBackFace() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blueAccent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.1),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'HUKUKİ ZIRH',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: Colors.blueAccent,
                  letterSpacing: 1,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showLegislationReference,
                icon: const Icon(Icons.saved_search, size: 16),
                label: const Text('Hızlı Yanıt'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent.withValues(alpha: 0.2),
                  foregroundColor: Colors.blueAccent,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          const _LegalItem(
            title: 'Suç ve Cezada Kanunilik İlkesi (Anayasa m. 38)',
            text: "İlgili faaliyet, 2918 sayılı KTK Ek 2/3 (Korsan Taşımacılık) kapsamında değildir. Taraflar arasında rızai, faturalı ve yazılı bir özel hukuk sözleşmesi mevcuttur.",
          ),
          const SizedBox(height: 12),
          const _LegalItem(
            title: 'Sözleşme Hürriyeti (Anayasa m. 48)',
            text: "Herkes dilediği alanda çalışma ve sözleşme hürriyetine sahiptir. Vergilendirilmiş bir kiralama faaliyeti idari kararla engellenemez.",
          ),
          const SizedBox(height: 12),
          const _LegalItem(
            title: 'Danıştay 8. Daire Atfı (E. 2019/2919)',
            text: "Taşımacılık faaliyetinin ticari taksi olduğu iddiası, somut ve kesin delillerle ispatlanmalıdır. Elinizdeki e-arşiv fatura ve kira sözleşmesi, faaliyetin yasal kiralama olduğunu ispatlayan kesin delildir.",
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.redAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
            ),
            child: const Text(
              '"Resmi fatura ve geçerli bir özel hukuk sözleşmesi ibraz edilmesine rağmen, fiilin hukuki niteliği araştırılmaksızın tesis edilen işlemler; mülkiyet hakkının ihlali ve hizmet kusuru teşkil edebilir."',
              style: TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.bold,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24, thickness: 1),
          const SizedBox(height: 10),
          const Text(
            '🚨 ÇEVİRME ANI PROTOKOLÜ (Sürücü İçin)',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.amberAccent),
          ),
          const SizedBox(height: 8),
          const _ProtocolStep(step: '1', text: 'KART UZAT: Sadece ön yüzü polise göster ve sözleşmeden bahset.'),
          const SizedBox(height: 6),
          const _ProtocolStep(step: '2', text: 'AVUKAT ARA: Ön ekrandaki butona bas, avukatı hoparlöre al.'),
          const SizedBox(height: 6),
          const _ProtocolStep(step: '3', text: 'TUTANAK ŞERHİ: "Faaliyetim TBK m.299 kiralama sözleşmesidir, kabul etmiyorum." yaz.'),
        ],
      ),
    );
  }
}

class _LegalItem extends StatelessWidget {
  final String title;
  final String text;
  const _LegalItem({required this.title, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.4)),
      ],
    );
  }
}

class _ProtocolStep extends StatelessWidget {
  final String step;
  final String text;
  const _ProtocolStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 9,
          backgroundColor: Colors.redAccent,
          child: Text(step, style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 11, height: 1.3)),
        ),
      ],
    );
  }
}
