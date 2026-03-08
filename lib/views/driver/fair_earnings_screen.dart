import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/driver_controller.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';

/// Ekran 3 — Sürücü Adil Kazanç Paneli
class FairEarningsScreen extends StatefulWidget {
  const FairEarningsScreen({super.key});

  @override
  State<FairEarningsScreen> createState() => _FairEarningsScreenState();
}

class _FairEarningsScreenState extends State<FairEarningsScreen> {
  final DriverController dc = Get.find<DriverController>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _selectedPeriod = 'today';
  List<Ride> _rides = [];
  bool _isLoading = false;

  // KPI değerleri
  double _grossTotal = 0;
  double _netTotal = 0;
  double _commissionTotal = 0;
  int _rideCount = 0;
  double _avgNet = 0;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    if (dc.driver.value == null) return;
    setState(() => _isLoading = true);

    try {
      DateTime startDate;
      DateTime endDate = DateTime.now();

      switch (_selectedPeriod) {
        case 'yesterday':
          startDate = DateTime(endDate.year, endDate.month, endDate.day - 1);
          endDate = DateTime(endDate.year, endDate.month, endDate.day);
          break;
        case 'week':
          startDate = endDate.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(endDate.year, endDate.month, 1);
          break;
        default: // today
          startDate = DateTime(endDate.year, endDate.month, endDate.day);
      }

      final snapshot = await _firestore
          .collection('rides')
          .where('driverId', isEqualTo: dc.driver.value!.id)
          .where('status', isEqualTo: 'completed')
          .orderBy('createdAt', descending: true)
          .get();

      List<Ride> allRides = snapshot.docs.map((d) => Ride.fromFirestore(d)).toList();

      // Tarih filtresi
      _rides = allRides.where((r) => r.createdAt.isAfter(startDate) && r.createdAt.isBefore(endDate.add(const Duration(days: 1)))).toList();

      _grossTotal = 0;
      _netTotal = 0;
      _commissionTotal = 0;
      for (var r in _rides) {
        _grossTotal += r.grossTotal;
        _netTotal += r.driverNet;
        _commissionTotal += r.commission;
      }
      _rideCount = _rides.length;
      _avgNet = _rideCount > 0 ? _netTotal / _rideCount : 0;
    } catch (e) {
      debugPrint("Kazanç veri hatası: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1C1C1C),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Get.back()),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet, color: Color(0xFFFFD700), size: 20),
            SizedBox(width: 8),
            Text('Adil Kazanç Paneli', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFD700)))
          : RefreshIndicator(
              onRefresh: _fetchData,
              color: const Color(0xFFFFD700),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // KPI Kartları
                  _buildKPICards(),
                  const SizedBox(height: 16),

                  // Dönem filtreleri
                  _buildPeriodFilter(),
                  const SizedBox(height: 16),

                  // Güven metinleri
                  _buildTrustBanner(),
                  const SizedBox(height: 16),

                  // Yolculuk listesi
                  _buildRideList(),
                ],
              ),
            ),
    );
  }

  Widget _buildKPICards() {
    return Column(
      children: [
        Row(
          children: [
            _kpi('Brüt Kazanç', '₺${_grossTotal.toStringAsFixed(0)}', Icons.trending_up, Colors.blue),
            const SizedBox(width: 10),
            _kpi('Net Kazanç', '₺${_netTotal.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.green),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _kpi('Yolculuk', '$_rideCount', Icons.directions_car, const Color(0xFFFFD700)),
            const SizedBox(width: 10),
            _kpi('Ortalama Net', '₺${_avgNet.toStringAsFixed(0)}', Icons.analytics, Colors.purple),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _kpi('Komisyon Toplamı', '₺${_commissionTotal.toStringAsFixed(0)}', Icons.percent, Colors.orange),
            const SizedBox(width: 10),
            _kpi('Tah. Vergi', '₺0', Icons.receipt_long, Colors.grey, subtitle: 'Bilgilendirme'),
          ],
        ),
      ],
    );
  }

  Widget _kpi(String label, String value, IconData icon, Color color, {String? subtitle}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const Spacer(),
                if (subtitle != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text(subtitle, style: TextStyle(color: color, fontSize: 8)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodFilter() {
    final periods = {'today': 'Bugün', 'yesterday': 'Dün', 'week': 'Bu Hafta', 'month': 'Bu Ay'};
    return Row(
      children: periods.entries.map((e) {
        final selected = _selectedPeriod == e.key;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedPeriod = e.key);
              _fetchData();
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFFFFD700) : const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? const Color(0xFFFFD700) : Colors.grey[700]!),
              ),
              child: Center(child: Text(
                e.value,
                style: TextStyle(color: selected ? Colors.black : Colors.grey[500], fontSize: 11, fontWeight: FontWeight.bold),
              )),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTrustBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield, color: Color(0xFFFFD700), size: 16),
              SizedBox(width: 6),
              Text('Şeffaflık Taahhüdü', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          _trustLine('Komisyon her yolculukta açık gösterilir (%12). Gizli kesinti yok.'),
          _trustLine('Net kazanç: brüt − komisyon − kampanya ± vergi ayrı satırlarla.'),
          _trustLine('Her işlem kayıtlı, denetlenebilir, e-fatura otomatik.'),
        ],
      ),
    );
  }

  Widget _trustLine(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('•', style: TextStyle(color: Colors.grey[500], fontSize: 10)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[500], fontSize: 10, height: 1.3))),
        ],
      ),
    );
  }

  Widget _buildRideList() {
    if (_rides.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(Icons.drive_eta_outlined, color: Colors.grey[700], size: 50),
            const SizedBox(height: 12),
            Text('Bu dönemde yolculuk yok', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 3, height: 14, decoration: BoxDecoration(color: const Color(0xFFFFD700), borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('YOLCULUK DETAYLARI', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
        const SizedBox(height: 10),
        ..._rides.map((ride) => _rideCard(ride)),
      ],
    );
  }

  Widget _rideCard(Ride ride) {
    final config = SegmentConfig.get(ride.segment);
    return GestureDetector(
      onTap: () => Get.toNamed('/ride-detail', arguments: ride),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[800]!),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${ride.createdAt.day.toString().padLeft(2, '0')}.${ride.createdAt.month.toString().padLeft(2, '0')} ${ride.createdAt.hour.toString().padLeft(2, '0')}:${ride.createdAt.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 11),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                  child: Text('${config.icon} ${config.label}', style: const TextStyle(color: Color(0xFFFFD700), fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.circle, color: Colors.green, size: 6),
                const SizedBox(width: 6),
                Expanded(child: Text(ride.pickupAddress, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis)),
              ],
            ),
            Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 6),
                const SizedBox(width: 6),
                Expanded(child: Text(ride.destAddress, style: const TextStyle(color: Colors.white, fontSize: 11), overflow: TextOverflow.ellipsis)),
              ],
            ),
            const Divider(color: Color(0xFF444444), height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _miniCol('Brüt', '₺${ride.grossTotal.toStringAsFixed(0)}', Colors.white),
                _miniCol('Komisyon', '-₺${ride.commission.toStringAsFixed(0)}', Colors.orange),
                _miniCol('Net', '₺${ride.driverNet.toStringAsFixed(0)}', Colors.green),
                _miniCol('Kişi', '${ride.personCount}', Colors.grey[400]!),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: ride.invoiceNo.isNotEmpty ? Colors.green.withValues(alpha: 0.15) : Colors.orange.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(ride.invoiceNo.isNotEmpty ? Icons.check_circle : Icons.pending, size: 10, color: ride.invoiceNo.isNotEmpty ? Colors.green : Colors.orange),
                      const SizedBox(width: 4),
                      Text('Belge', style: TextStyle(fontSize: 9, color: ride.invoiceNo.isNotEmpty ? Colors.green : Colors.orange)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: Color(0xFFFFD700), size: 18),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 9)),
      ],
    );
  }
}
