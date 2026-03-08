import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';

class DriverKycScreen extends StatefulWidget {
  const DriverKycScreen({super.key});

  @override
  State<DriverKycScreen> createState() => _DriverKycScreenState();
}

class _DriverKycScreenState extends State<DriverKycScreen> {
  int _currentStep = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Sürücü Doğrulama', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildStepProgress(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStepContent(),
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildStepProgress() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      color: AppColors.cardBg,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _stepIcon(0, Icons.person_search_rounded, 'Kimlik'),
          _stepDivider(),
          _stepIcon(1, Icons.badge_rounded, 'Ehliyet'),
          _stepDivider(),
          _stepIcon(2, Icons.directions_car_rounded, 'Araç'),
          _stepDivider(),
          _stepIcon(3, Icons.verified_user_rounded, 'Onay'),
        ],
      ),
    );
  }

  Widget _stepIcon(int index, IconData icon, String label) {
    bool isActive = _currentStep >= index;
    bool isCompleted = _currentStep > index;
    
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.background,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive ? AppColors.primary : AppColors.divider,
              width: 2,
            ),
          ),
          child: Icon(
            isCompleted ? Icons.check_rounded : icon,
            color: isActive ? Colors.black : AppColors.textDisabled,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.publicSans(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? AppColors.primary : AppColors.textDisabled,
          ),
        ),
      ],
    );
  }

  Widget _stepDivider() {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 20),
        color: AppColors.divider,
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildIdentityStep();
      case 1: return _buildLicenseStep();
      case 2: return _buildVehicleStep();
      case 3: return _buildPendingStep();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildIdentityStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Kimlik Bilgileri'),
        _sectionDesc('Güvenliğiniz için T.C. Kimlik kartınızın ön ve arka yüzünü yükleyin.'),
        const SizedBox(height: 30),
        _uploadCard('Kimlik Kartı Ön Yüz', Icons.add_a_photo_rounded),
        const SizedBox(height: 15),
        _uploadCard('Kimlik Kartı Arka Yüz', Icons.add_a_photo_rounded),
      ],
    );
  }

  Widget _buildLicenseStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Sürücü Belgesi'),
        _sectionDesc('Geçerli sınıf ehliyetinizin aslını taratın veya yükleyin.'),
        const SizedBox(height: 30),
        _uploadCard('Sürücü Belgesi Ön Yüz', Icons.badge_rounded),
        const SizedBox(height: 15),
        _uploadCard('Sürücü Belgesi Arka Yüz', Icons.badge_rounded),
      ],
    );
  }

  Widget _buildVehicleStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Araç Bilgileri'),
        _sectionDesc('Hizmet vereceğiniz aracın ruhsat ve sigorta belgelerini ekleyin.'),
        const SizedBox(height: 30),
        _uploadCard('Araç Ruhsatı (Görsel)', Icons.description_rounded),
        const SizedBox(height: 15),
        _uploadCard('Zorunlu Trafik Sigortası', Icons.security_rounded),
      ],
    );
  }

  Widget _buildPendingStep() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 80),
          ),
          const SizedBox(height: 30),
          Text(
            'İnceleme Altında',
            style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 15),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Belgeleriniz başarıyla sisteme iletildi. Admin onayından sonra yolculuk kabul etmeye başlayabilirsiniz.',
              style: GoogleFonts.publicSans(color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 40),
          _statusItem('Kimlik Kontrolü', 'Tamamlandı', AppColors.success),
          _statusItem('Ehliyet Kontrolü', 'İşleniyor', AppColors.warning),
          _statusItem('Adli Sicil Kaydı', 'Beklemede', AppColors.textDisabled),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
    );
  }

  Widget _sectionDesc(String desc) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        desc,
        style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }

  Widget _uploadCard(String label, IconData icon) {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(height: 10),
          Text(label, style: GoogleFonts.publicSans(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _statusItem(String label, String status, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.publicSans(color: AppColors.textSecondary)),
          Text(status, style: GoogleFonts.publicSans(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    if (_currentStep == 3) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Get.offAllNamed('/role-selection'),
            child: const Text('TAMAM'),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.divider),
                ),
                child: Text('Geri', style: GoogleFonts.publicSans(color: Colors.white)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 15),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () => setState(() => _currentStep++),
              child: Text(
                _currentStep == 2 ? 'BELGELERİ GÖNDER' : 'Devam Et',
                style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
