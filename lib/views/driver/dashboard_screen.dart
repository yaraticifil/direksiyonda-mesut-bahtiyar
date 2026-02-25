import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/driver_controller.dart';
import '../../models/payout_model.dart';
import '../payout/payout_request_screen.dart';
import '../payout/payout_history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthController authController = Get.find<AuthController>();
  final DriverController driverController = Get.find<DriverController>();

  // Motivasyon sözleri
  final List<String> _slogans = [
    '"Korsan taksi değil, emek taksi!"',
    '"Plakam yok belki ama yolum belli."',
    '"Direksiyon başında, hukuk zemininde."',
    '"Alın terimize sahip çıkıyoruz."',
    '"Biz yedi uyuyanlarız, artık uyandık."',
  ];

  late String _currentSlogan;

  @override
  void initState() {
    super.initState();
    _currentSlogan = (_slogans..shuffle()).first;
    
    if (authController.user != null) {
      driverController.fetchDriverData(authController.user!.uid);
      if (authController.driver == null) {
        authController.fetchDriverData(authController.user!.uid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1C1C), Color(0xFF2C2C2C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFFFFD700),
            backgroundColor: const Color(0xFF2C2C2C),
            onRefresh: () async {
              if (authController.driver != null) {
                await driverController.fetchDriverData(authController.driver!.id);
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 20),
                  _buildWelcomeCard(),
                  const SizedBox(height: 20),
                  _buildStatsCards(),
                  const SizedBox(height: 25),
                  _buildQuickActions(),
                  const SizedBox(height: 25),
                  _buildRecentPayouts(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'ORTAK YOL',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFFFFD700),
            letterSpacing: 3,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.grey),
          onPressed: () => authController.logout(),
          tooltip: 'Çıkış Yap',
        ),
      ],
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C2C), Color(0xFF3C3C3C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFFFD700).withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD700).withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: Color(0xFFFFD700),
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Obx(() => Text(
                      'Merhaba, ${authController.driver?.name ?? 'Kaptan'}!',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )),
                    Obx(() => Text(
                      authController.driver?.phone ?? '',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified, color: Colors.green, size: 14),
                    SizedBox(width: 5),
                    Text(
                      'Onaylı Sürücü',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _currentSlogan,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      children: [
        Expanded(
          child: Obx(() => _buildStatCard(
            'Toplam Kazanç',
            '₺${driverController.getTotalEarnings().toStringAsFixed(2)}',
            Icons.trending_up,
            Colors.green,
          )),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(() => _buildStatCard(
            'Bekleyen Ödeme',
            '₺${driverController.getPendingPayouts().toStringAsFixed(2)}',
            Icons.hourglass_empty,
            Colors.orange,
          )),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
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
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
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

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'HIZLI İŞLEMLER',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFFFFD700),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 15),

        // ─── ÇEVRİMİÇİ / ÇEVRİMDIŞI TOGGLE ───
        Obx(() => GestureDetector(
          onTap: () => driverController.toggleOnlineStatus(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: driverController.isOnline.value
                    ? [Colors.green.withValues(alpha: 0.2), Colors.green.withValues(alpha: 0.05)]
                    : [Colors.red.withValues(alpha: 0.2), Colors.red.withValues(alpha: 0.05)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: driverController.isOnline.value
                    ? Colors.green.withValues(alpha: 0.5)
                    : Colors.red.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  driverController.isOnline.value ? Icons.wifi : Icons.wifi_off,
                  color: driverController.isOnline.value ? Colors.green : Colors.red,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  driverController.isOnline.value ? 'ÇEVRİMİÇİ — ÇAĞRI BEKLİYORSUN' : 'ÇEVRİMDIŞI — DOKUNARAK AÇ',
                  style: TextStyle(
                    color: driverController.isOnline.value ? Colors.green : Colors.red,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        )),
        const SizedBox(height: 12),

        // Hukuki Kalkan Satırı
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'ADİL\nKAZANÇ',
                Icons.account_balance_wallet,
                const Color(0xFFFFD700),
                () => Get.toNamed('/fair-earnings'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'ACİL\nAVUKAT',
                Icons.gavel,
                Colors.red,
                () => authController.launchEmergencySupport(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'CEZA\nBİLDİR',
                Icons.report_problem,
                Colors.orange[800]!,
                () => Get.toNamed('/report-penalty'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // İkinci Satır
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                'DİJİTAL\nKİMLİK',
                Icons.qr_code,
                Colors.blue,
                () => Get.toNamed('/digital-id'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'SÖZLEŞME\nİBRAZ',
                Icons.description,
                Colors.blueGrey,
                () => Get.toNamed('/legal-contract'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                'PARA\nÇEK',
                Icons.money,
                Colors.green,
                () => Get.to(() => const PayoutRequestScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[300],
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentPayouts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'SON ÖDEMELER',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFFFFD700),
                letterSpacing: 2,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const PayoutHistoryScreen()),
              child: const Text(
                'Tümünü Gör',
                style: TextStyle(
                  color: Color(0xFFFFD700),
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          if (driverController.payouts.isEmpty) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              child: Column(
                children: [
                  Icon(Icons.receipt_long, size: 40, color: Colors.grey[600]),
                  const SizedBox(height: 10),
                  Text(
                    'Henüz ödeme kaydı yok',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: driverController.payouts.take(3).map((payout) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: _getStatusColor(payout.status).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      child: Icon(
                        _getStatusIcon(payout.status),
                        color: _getStatusColor(payout.status),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payout.description,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            DateFormat('dd.MM.yyyy').format(payout.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '₺${payout.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFD700),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(payout.status).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            payout.statusText,
                            style: TextStyle(
                              color: _getStatusColor(payout.status),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Color _getStatusColor(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.pending:
        return Colors.orange;
      case PayoutStatus.completed:
        return Colors.green;
      case PayoutStatus.transferring:
        return Colors.blue;
      case PayoutStatus.rejected:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(PayoutStatus status) {
    switch (status) {
      case PayoutStatus.pending:
        return Icons.hourglass_empty;
      case PayoutStatus.completed:
        return Icons.check_circle;
      case PayoutStatus.transferring:
        return Icons.swap_horiz;
      case PayoutStatus.rejected:
        return Icons.cancel;
    }
  }
}
