import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../utils/app_colors.dart';
import '../../legal/legal_texts.dart';

class AdminAuditScreen extends StatelessWidget {
  const AdminAuditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('SİSTEM DENETİMİ', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 1)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: 15, // Mock data
              itemBuilder: (context, index) => _buildAuditItem(index),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'Bu ekran, demo amaçlı örnek denetim kayıtları göstermektedir. '
              'Gerçek sistem logları ve denetim kayıtları, ilgili mevzuat ve şirket politikalarına uygun olarak ayrı sistemlerde tutulmalıdır.\n'
              '${LegalTexts.tbkGeneralReference}',
              style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.textDisabled, height: 1.4),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      color: AppColors.cardBg,
      child: Row(
        children: [
          _filterChip('Tümü', true),
          const SizedBox(width: 10),
          _filterChip('Güvenlik', false),
          const SizedBox(width: 10),
          _filterChip('Finans', false),
          const Spacer(),
          const Icon(Icons.filter_list_rounded, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
      ),
      child: Text(
        label,
        style: GoogleFonts.publicSans(
          fontSize: 12,
          color: isSelected ? Colors.black : AppColors.textSecondary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAuditItem(int index) {
    final List<Map<String, dynamic>> logs = [
      {'type': 'Güvenlik', 'action': 'Admin Girişi', 'user': 'gumussalimm@gmail.com', 'time': '10:45', 'status': 'Başarılı'},
      {'type': 'Sürücü', 'action': 'Durum Güncelleme', 'user': 'Admin_01', 'time': '09:30', 'status': 'Onaylandı'},
      {'type': 'Finans', 'action': 'Ödeme Onayı', 'user': 'Admin_01', 'time': '08:15', 'status': '₺1,250.00'},
    ];
    
    final log = logs[index % logs.length];
    
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getIcon(log['type']), color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(log['action'], style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text(log['time'], style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textDisabled)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('Kullanıcı: ${log['user']}', style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'İşlem: ${log['status']}',
                    style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.success, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Güvenlik': return Icons.security_rounded;
      case 'Sürücü': return Icons.person_search_rounded;
      case 'Finans': return Icons.payments_rounded;
      default: return Icons.info_outline_rounded;
    }
  }
}
