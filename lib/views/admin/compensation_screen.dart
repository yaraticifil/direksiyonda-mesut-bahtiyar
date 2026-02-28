import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/app_colors.dart';
import '../../legal/legal_texts.dart';

class CompensationScreen extends StatelessWidget {
  const CompensationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('FİNANSAL ANALİZ (DEMO)', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBalanceCard(),
            const SizedBox(height: 30),
            Text('KAZANÇ DAĞILIMI', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 20),
            _buildDonutChartPlaceholder(),
            const SizedBox(height: 30),
            Text('ÖDEME GEÇMİŞİ', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 15),
            _buildPayoutList(),
            const SizedBox(height: 20),
            Text(
              'Bu ekran, demo amaçlı örnek finansal veriler içermektedir. '
              'Gerçek operasyonel raporlar için resmi muhasebe ve raporlama sistemleri esas alınmalıdır.\n'
              '${LegalTexts.tbkGeneralReference}',
              style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Toplam Toplanan Komisyon', style: GoogleFonts.publicSans(color: Colors.black87, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text('₺142,580.00', style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.black)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _balanceSubInfo('Bekleyen', '₺12,400'),
              _balanceSubInfo('Transfer Edilen', '₺130,180'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _balanceSubInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.publicSans(fontSize: 11, color: Colors.black54)),
        Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
      ],
    );
  }

  Widget _buildDonutChartPlaceholder() {
    return Container(
      height: 200,
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.divider)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 100, height: 100, child: CircularProgressIndicator(value: 0.7, strokeWidth: 12, backgroundColor: AppColors.background, valueColor: AlwaysStoppedAnimation(AppColors.primary))),
                Text('%70', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 20),
            Text('Sürücü Payı vs Komisyon Dağılımı', style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  Widget _buildPayoutList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ahmet Yılmaz', style: GoogleFonts.publicSans(fontWeight: FontWeight.bold, color: Colors.white)),
                Text('24 Şub 2026', style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textDisabled)),
              ],
            ),
            Text('₺2,450.00', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.success)),
          ],
        ),
      ),
    );
  }
}
