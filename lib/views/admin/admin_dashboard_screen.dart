import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../models/driver_model.dart';
import '../../models/payout_model.dart';
import '../../models/ride_model.dart';
import '../../utils/app_colors.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  final AuthController authController = Get.find<AuthController>();
  final AdminController adminController = Get.find<AdminController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _checkAdminAccess();
  }

  void _checkAdminAccess() {
    if (authController.user?.email != 'gumussalimm@gmail.com') {
      Get.snackbar(
        'Erişim Reddedildi',
        'Bu sayfaya erişim yetkiniz bulunmamaktadır.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      Get.offAllNamed('/role-selection');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'YÖNETİM MERKEZİ',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textDisabled,
          labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 11),
          isScrollable: true,
          tabs: const [
            Tab(text: 'PANEL'),
            Tab(text: 'SÜRÜCÜLER'),
            Tab(text: 'ÖDEMELER'),
            Tab(text: 'YOLCULUKLAR'),
            Tab(text: 'CEZALAR'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: () {
              adminController.fetchDrivers();
              adminController.fetchPayouts();
              adminController.fetchRides();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.primary),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildDriversTab(),
          _buildPayoutsTab(),
          _buildRidesTab(),
          _buildPenaltiesTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('Sistem Özeti', 'Canlı veriler ve performans'),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 30),
          _sectionHeader('Finansal Analiz', 'Hizmet bazlı kazanç dağılımı'),
          const SizedBox(height: 15),
          _buildSegmentBar(),
          const SizedBox(height: 30),
          _sectionHeader('Son Aktiviteler', 'Sistemdeki güncel hareketler'),
          const SizedBox(height: 15),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
        Text(subtitle, style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Obx(() => GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.4,
      children: [
        _buildStatCard('Sürücüler', adminController.drivers.length.toString(), Icons.people_rounded, AppColors.info),
        _buildStatCard('Bekleyen', adminController.getDriversCountByStatus(DriverStatus.pending).toString(), Icons.pending_rounded, AppColors.warning),
        _buildStatCard('Komisyon', '₺${adminController.totalCommission.toStringAsFixed(0)}', Icons.account_balance_rounded, AppColors.primary),
        _buildStatCard('Brüt Ciro', '₺${adminController.totalGrossRevenue.toStringAsFixed(0)}', Icons.trending_up_rounded, AppColors.success),
      ],
    ));
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(title, style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentBar() {
    return Obx(() {
      final stats = adminController.segmentDistribution;
      if (stats.isEmpty) return const SizedBox.shrink();
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(20)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: stats.entries.map((e) => Column(
            children: [
              Text(e.value.toString(), style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(e.key.toUpperCase(), style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.bold)),
            ],
          )).toList(),
        ),
      );
    });
  }

  Widget _buildRecentActivity() {
    return Obx(() {
      final recent = adminController.drivers.take(5).toList();
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: recent.length,
        itemBuilder: (context, index) {
          final driver = recent[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(driver.name, style: GoogleFonts.publicSans(fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Yeni Sürücü Kaydı', style: GoogleFonts.publicSans(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                )),
                Text(DateFormat('HH:mm').format(driver.createdAt), style: GoogleFonts.publicSans(fontSize: 10, color: AppColors.textDisabled)),
              ],
            ),
          );
        },
      );
    });
  }

  // --- Diğer Tablar (Özetlenmiş Versiyon) ---
  Widget _buildDriversTab() {
     return Obx(() {
       final drivers = adminController.filteredDrivers;
       return ListView.builder(
         padding: const EdgeInsets.all(15),
         itemCount: drivers.length,
         itemBuilder: (context, index) => _driverListItem(drivers[index]),
       );
     });
  }

  Widget _driverListItem(Driver driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(16), border: Border.all(color: _statusColor(driver.status).withOpacity(0.2))),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: _statusColor(driver.status).withOpacity(0.1), child: Icon(Icons.person, color: _statusColor(driver.status))),
              const SizedBox(width: 15),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(driver.name, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(driver.phone, style: GoogleFonts.publicSans(fontSize: 12, color: AppColors.textSecondary)),
                ],
              )),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: _statusColor(driver.status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Text(driver.statusText, style: TextStyle(color: _statusColor(driver.status), fontSize: 10, fontWeight: FontWeight.bold))),
            ],
          ),
          if (driver.status == DriverStatus.pending) ...[
            const SizedBox(height: 15),
            Row(children: [
            Expanded(child: ElevatedButton(onPressed: () => adminController.updateDriverStatus(driver.id, DriverStatus.approved), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white), child: const Text('ONAYLA'))),
            const SizedBox(width: 10),
            Expanded(child: ElevatedButton(onPressed: () => adminController.updateDriverStatus(driver.id, DriverStatus.rejected), style: ElevatedButton.styleFrom(backgroundColor: AppColors.error, foregroundColor: Colors.white), child: const Text('REDDET'))),
            ])
          ]
        ],
      ),
    );
  }

  Widget _buildPayoutsTab() => const Center(child: Text('Finans Modülü Yükleniyor...', style: TextStyle(color: AppColors.textSecondary)));
  Widget _buildRidesTab() => const Center(child: Text('Yolculuk Modülü Yükleniyor...', style: TextStyle(color: AppColors.textSecondary)));
  Widget _buildPenaltiesTab() => const Center(child: Text('Raporlar Modülü Yükleniyor...', style: TextStyle(color: AppColors.textSecondary)));

  Color _statusColor(DriverStatus s) {
    switch (s) {
      case DriverStatus.approved: return AppColors.success;
      case DriverStatus.pending: return AppColors.warning;
      case DriverStatus.rejected: return AppColors.error;
      default: return AppColors.error;
    }
  }
}
