import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/admin_controller.dart';
import '../../models/driver_model.dart';
import '../../models/payout_model.dart';

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
    _tabController = TabController(length: 3, vsync: this);
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
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFFFD700)),
            onPressed: () {
              adminController.fetchDrivers();
              adminController.fetchPayouts();
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
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1C1C1C),
                  const Color(0xFF2C2C2C),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              border: Border(
                bottom: BorderSide(
                  color: const Color(0xFFFFD700).withOpacity(0.3),
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
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.5),
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
              const SizedBox(height: 20),
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
                'BEKLEYEN ÖDEME',
                '\$${adminController.getTotalPayoutsByStatus(PayoutStatus.pending).toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.purple,
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
          color: color.withOpacity(0.3),
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
              color: color.withOpacity(0.2),
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

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SON HAREKETLER',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFFD700),
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
                  color: Colors.grey.withOpacity(0.3),
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
          color: Colors.grey.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
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
          color: Colors.grey.withOpacity(0.3),
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
          color: Colors.grey.withOpacity(0.3),
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
                  color: Colors.purple.withOpacity(0.2),
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
                    onPressed: () => _showPayoutApprovalDialog(payout, true),
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

  void _showPayoutApprovalDialog(Payout payout, bool approve) {
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        title: Text(
          approve ? 'Ödemeyi Onayla' : 'Ödemeyi Reddet',
          style: const TextStyle(color: Colors.white),
        ),
        content: Text(
          '\$${payout.amount.toStringAsFixed(2)} tutarındaki ödeme talebini ${approve ? 'onaylamak' : 'reddetmek'} istediğinizden emin misiniz?',
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
}
