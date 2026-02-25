import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../models/driver_model.dart';
import '../../models/payout_model.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';

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
    // Check if current user is authorized admin
    if (authController.user?.email != 'gumussalimm@gmail.com') {
      Get.snackbar(
        'Erişim Reddedildi',
        'Bu sayfaya erişim yetkiniz bulunmamaktadır.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      Get.offAllNamed('/register');
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
      backgroundColor: const Color(0xFF1C1C1C), // Siyah arka plan
      appBar: AppBar(
        title: const Text(
          'Yönetici Paneli',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFFFFD700), // Sarı yazı rengi
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFFFFD700),
          labelColor: const Color(0xFFFFD700),
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(text: 'GENEL BAKIŞ'),
            Tab(text: 'SÜRÜCÜLER'),
            Tab(text: 'ÖDEMELER'),
            Tab(text: 'YOLCULUKLAR'),
            Tab(text: 'CEZA BİLDİRİMLERİ'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
            onPressed: () {
              adminController.fetchDrivers();
              adminController.fetchPayouts();
              adminController.fetchPenalties();
              adminController.fetchRides();
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFFFD700)),
            onPressed: () => authController.logout(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Slogan banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1C1C1C),
                  Color(0xFF2C2C2C),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'KORSAN TAKSİ DEĞİL, EMEK TAKSİ!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFD700),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Plakam yok belki ama yolum belli.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[300],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          // Hızlı Erişim Butonları
          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    'SÜRÜCÜ ONAYLARI',
                    Icons.approval,
                    () => _tabController.animateTo(1),
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _buildQuickActionButton(
                    'ÖDEME TALEPLERİ',
                    Icons.account_balance_wallet,
                    () => _tabController.animateTo(2),
                    Colors.green,
                  ),
                ),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(),
                _buildDriversTab(),
                _buildPayoutsTab(),
                _buildRidesTab(),
                _buildPenaltiesTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(String title, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Container(
      color: const Color(0xFF1C1C1C),
      child: RefreshIndicator(
        onRefresh: () async {
          adminController.fetchDrivers();
          adminController.fetchPayouts();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatsCards(),
              const SizedBox(height: 25),
              _buildSegmentStats(),
              const SizedBox(height: 25),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatCard(
                'TOPLAM SÜRÜCÜ',
                adminController.drivers.length.toString(),
                Icons.people,
                const Color(0xFFFFD700),
              )),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Obx(() => _buildStatCard(
                'BEKLEYEN',
                adminController.getDriversCountByStatus(DriverStatus.pending).toString(),
                Icons.hourglass_empty,
                Colors.orange,
              )),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Obx(() => _buildStatCard(
                'ONAYLI',
                adminController.getDriversCountByStatus(DriverStatus.approved).toString(),
                Icons.check_circle,
                Colors.green,
              )),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Obx(() => _buildStatCard(
                'TOPLAM KAZANÇ',
                '₺${adminController.totalCommission.toStringAsFixed(0)}',
                Icons.account_balance,
                Colors.blue,
              )),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Obx(() => _buildStatCard(
                'TOPLAM CİRO',
                '₺${adminController.totalGrossRevenue.toStringAsFixed(0)}',
                Icons.trending_up,
                const Color(0xFFFFD700),
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SEGMENT PERFORMANSI',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
        ),
        const SizedBox(height: 15),
        Obx(() {
          final stats = adminController.segmentDistribution;
          if (stats.isEmpty) return const SizedBox.shrink();

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2C),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: stats.entries.map((entry) {
                return Column(
                  children: [
                    Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      entry.key.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SON HAREKETLER',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFD700),
          ),
        ),
        const SizedBox(height: 15),
        Obx(() {
          final recentDrivers = adminController.drivers.take(3).toList();
          final recentPayouts = adminController.payouts.take(3).toList();

          if (recentDrivers.isEmpty && recentPayouts.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.grey.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.history,
                    size: 50,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Henüz aktivite yok',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              ...recentDrivers.map((driver) => _buildActivityItem(
                'Yeni sürücü kaydı',
                driver.name,
                DateFormat('dd.MM.yyyy').format(driver.createdAt),
                Icons.person_add,
                const Color(0xFFFFD700),
              )),
              ...recentPayouts.map((payout) => _buildActivityItem(
                'Ödeme talebi',
                '\$${payout.amount.toStringAsFixed(2)}',
                DateFormat('dd.MM.yyyy').format(payout.createdAt),
                Icons.account_balance_wallet,
                Colors.purple,
              )),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildActivityItem(String title, String subtitle, String date, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriversTab() {
    return Container(
      color: const Color(0xFF1C1C1C),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            color: const Color(0xFF2C2C2C),
            child: Row(
              children: [
                Expanded(
                  child: Obx(() => DropdownButton<String>(
                    value: adminController.selectedStatus.value,
                    isExpanded: true,
                    dropdownColor: const Color(0xFF2C2C2C),
                    style: const TextStyle(color: Colors.white),
                    underline: Container(),
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tüm Sürücüler')),
                      DropdownMenuItem(value: 'pending', child: Text('Bekleyen')),
                      DropdownMenuItem(value: 'approved', child: Text('Onaylı')),
                      DropdownMenuItem(value: 'rejected', child: Text('Reddedildi')),
                    ],
                    onChanged: (value) {
                      adminController.selectedStatus.value = value!;
                    },
                  )),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (adminController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                  ),
                );
              }

              final drivers = adminController.filteredDrivers;
              if (drivers.isEmpty) {
                return Center(
                  child: Text(
                    'Sürücü bulunamadı',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: drivers.length,
                itemBuilder: (context, index) {
                  final driver = drivers[index];
                  return _buildDriverCard(driver);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(Driver driver) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      driver.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(driver.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  driver.statusText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'Katılım: ${DateFormat('dd.MM.yyyy').format(driver.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          if (driver.status == DriverStatus.pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApprovalDialog(driver, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ONAYLA'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showApprovalDialog(driver, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('REDDET'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPayoutsTab() {
    return Container(
      color: const Color(0xFF1C1C1C),
      child: Obx(() {
        if (adminController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
            ),
          );
        }

        final payouts = adminController.payouts;
        if (payouts.isEmpty) {
          return Center(
            child: Text(
              'Ödeme talebi bulunamadı',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: payouts.length,
          itemBuilder: (context, index) {
            final payout = payouts[index];
            return _buildPayoutCard(payout);
          },
        );
      }),
    );
  }

  Widget _buildPayoutCard(Payout payout) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.grey.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  color: Colors.purple[700],
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payout.description,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Sürücü ID: ${payout.driverId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${payout.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getPayoutStatusColor(payout.status),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      payout.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Talep: ${DateFormat('dd.MM.yyyy').format(payout.createdAt)}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          if (payout.status == PayoutStatus.pending) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _updatePayoutWithStatus(payout, PayoutStatus.transferring),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('HESABA TRANSFER ET'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showPayoutApprovalDialog(payout, false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('REDDET'),
                  ),
                ),
              ],
            ),
          ] else if (payout.status == PayoutStatus.transferring) ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showPayoutApprovalDialog(payout, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('TRANSFERİ TAMAMLA'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getStatusColor(DriverStatus status) {
    switch (status) {
      case DriverStatus.pending:
        return Colors.orange;
      case DriverStatus.approved:
        return Colors.green;
      case DriverStatus.rejected:
        return Colors.red;
    }
  }

  Color _getPayoutStatusColor(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.pending:
        return Colors.orange;
      case PayoutStatus.transferring:
        return Colors.blue;
      case PayoutStatus.completed:
        return Colors.green;
      case PayoutStatus.rejected:
        return Colors.red;
    }
  }

  void _showApprovalDialog(Driver driver, bool approve) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          approve ? 'Sürücüyü Onayla' : 'Sürücüyü Reddet',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '${driver.name} adlı sürücüyü ${approve ? 'onaylamak' : 'reddetmek'} istediğinizden emin misiniz?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İPTAL', style: TextStyle(color: Color(0xFFFFD700))),
          ),
          TextButton(
            onPressed: () {
              adminController.updateDriverStatus(
                driver.id,
                approve ? DriverStatus.approved : DriverStatus.rejected,
              );
              Get.back();
            },
            child: Text(
              approve ? 'ONAYLA' : 'REDDET',
              style: TextStyle(
                color: approve ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltiesTab() {
    return Container(
      color: const Color(0xFF1C1C1C),
      child: Obx(() {
        if (adminController.penalties.isEmpty) {
          return Center(
            child: Text(
              'Henüz ceza bildirimi yok',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(10),
          itemCount: adminController.penalties.length,
          itemBuilder: (context, index) {
            final penalty = adminController.penalties[index];
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.report_problem, color: Colors.orange, size: 20),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              penalty['driverName'] ?? 'Anonim',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'Durum: ${penalty['status'] ?? 'bekliyor'}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (penalty['description'] != null && penalty['description'].toString().isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      penalty['description'],
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                  if (penalty['latitude'] != null) ...[
                    const SizedBox(height: 5),
                    Text(
                      'Konum: ${(penalty['latitude'] as num).toStringAsFixed(4)}, ${(penalty['longitude'] as num).toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      }),
    );
  }

  void _updatePayoutWithStatus(Payout payout, PayoutStatus status) {
    adminController.updatePayoutStatus(payout.id, status);
  }

  void _showPayoutApprovalDialog(Payout payout, bool approve) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          approve ? 'Transferi Tamamla' : 'Ödemeyi Reddet',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '₺${payout.amount.toStringAsFixed(2)} tutarındaki ödeme talebini ${approve ? 'tamamlandı olarak işaretlemek' : 'reddetmek'} istediğinizden emin misiniz?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('İPTAL', style: TextStyle(color: Color(0xFFFFD700))),
          ),
          TextButton(
            onPressed: () {
              adminController.updatePayoutStatus(
                payout.id,
                approve ? PayoutStatus.completed : PayoutStatus.rejected,
              );
              Get.back();
            },
            child: Text(
              approve ? 'TAMAMLA' : 'REDDET',
              style: TextStyle(
                color: approve ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRidesTab() {
    return Container(
      color: const Color(0xFF1C1C1C),
      child: Obx(() {
        if (adminController.isLoading.value && adminController.rides.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)));
        }

        if (adminController.rides.isEmpty) {
          return const Center(child: Text('Henüz yolculuk kaydı yok', style: TextStyle(color: Colors.white70)));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: adminController.rides.length,
          itemBuilder: (context, index) {
            final ride = adminController.rides[index];
            return _buildRideCard(ride);
          },
        );
      }),
    );
  }

  Widget _buildRideCard(Ride ride) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ride.invoiceNo,
                    style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(ride.createdAt),
                    style: TextStyle(color: Colors.grey[400], fontSize: 12),
                  ),
                ],
              ),
              _buildStatusBadge(ride.status),
            ],
          ),
          const Divider(height: 24, color: Colors.white10),
          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.driverName ?? 'Sürücü Atanmadı',
                  style: const TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(Icons.category, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                ride.segmentLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Mesafe: ${ride.distanceKm.toStringAsFixed(1)} KM',
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
              Text(
                '₺${ride.grossTotal.toStringAsFixed(2)}',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => _showRideDetails(ride),
                child: const Text('DETAYLAR', style: TextStyle(color: Color(0xFFFFD700))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(RideStatus status) {
    Color color = Colors.grey;
    String text = status.name;

    switch (status) {
      case RideStatus.completed: color = Colors.green; text = 'Tamamlandı'; break;
      case RideStatus.cancelled: color = Colors.red; text = 'İptal'; break;
      case RideStatus.inProgress: color = Colors.blue; text = 'Devam Ediyor'; break;
      case RideStatus.matched: color = Colors.orange; text = 'Sürücü Yolda'; break;
      default: color = Colors.grey; text = 'Bekliyor';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _showRideDetails(Ride ride) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1C1C1C),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Center(
                child: Container(
                  width: 50,
                  height: 5,
                  decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Yolculuk Detayları',
                style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(ride.invoiceNo, style: const TextStyle(color: Color(0xFFFFD700), fontSize: 16)),
              const Divider(height: 48, color: Colors.white10),
              _buildDetailRow('Sürücü', ride.driverName ?? 'Arama yapılıyor'),
              _buildDetailRow('Segment', ride.segmentLabel),
              _buildDetailRow('Mesafe', '${ride.distanceKm.toStringAsFixed(1)} km'),
              const SizedBox(height: 16),
              const Text('Ücret Kırılımı', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildFareRow('Açılış Ücreti', ride.openingFee),
              _buildFareRow('Mesafe Ücreti', ride.distanceFee),
              if (ride.segmentSurcharge > 0) _buildFareRow('Segment Farkı', ride.segmentSurcharge),
              if (ride.marketAdjustment > 0) _buildFareRow('Yoğunluk Artışı', ride.marketAdjustment),
              if (ride.discount > 0) _buildFareRow('İndirim', -ride.discount, color: Colors.green),
              const Divider(color: Colors.white10),
              _buildFareRow('TOPLAM TUTAR', ride.grossTotal, isTotal: true),
              _buildFareRow('Platform Komisyonu (%12)', ride.commission, color: Colors.blue),
              _buildFareRow('Sürücü Hakediş', ride.driverNet, color: Colors.green),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFD700),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('KAPAT', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[400])),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, double amount, {bool isTotal = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isTotal ? Colors.white : color ?? Colors.grey[400],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            '₺${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color ?? (isTotal ? const Color(0xFFFFD700) : Colors.white),
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
              fontSize: isTotal ? 18 : 14,
            ),
          ),
        ],
      ),
    );
  }
}
