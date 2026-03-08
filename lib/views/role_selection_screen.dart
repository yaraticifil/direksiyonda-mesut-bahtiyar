import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              // App Logo or Icon
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.handshake_rounded,
                    size: 50,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Hoş Geldiniz',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Uygulamaya nasıl devam etmek istersiniz?',
                style: GoogleFonts.publicSans(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              
              // Role Cards
              _buildRoleCard(
                context,
                title: 'Sürücü',
                description: 'Kendi aracınızla kazanç sağlayın ve hukuki güvence altına alın.',
                icon: Icons.directions_car_filled_rounded,
                onTap: () => Get.toNamed('/login'), // Default to login then it redirects
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                context,
                title: 'Yolcu',
                description: 'Güvenli, şeffaf ve adil fiyatlı yolculukların tadını çıkarın.',
                icon: Icons.person_pin_circle_rounded,
                onTap: () => Get.toNamed('/login'),
              ),
              const SizedBox(height: 20),
              _buildRoleCard(
                context,
                title: 'Yönetici',
                description: 'Sistemi denetleyin, onayları yönetin ve finansal verileri izleyin.',
                icon: Icons.admin_panel_settings_rounded,
                onTap: () => Get.toNamed('/admin-login'),
                isSecondary: true,
              ),
              
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  '© 2026 Ortak Yol - Hukuki ve Teknolojik Altyapı',
                  style: GoogleFonts.publicSans(
                    fontSize: 12,
                    color: AppColors.textDisabled,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSecondary ? Colors.transparent : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSecondary ? AppColors.divider : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSecondary 
                    ? AppColors.textDisabled.withOpacity(0.1) 
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSecondary ? AppColors.textSecondary : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: GoogleFonts.publicSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}
