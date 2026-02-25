import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final PassengerController pc = Get.find<PassengerController>();

  GoogleMapController? _mapController;
  final TextEditingController _destController = TextEditingController();

  LatLng? _pickupLocation;
  LatLng? _destLocation;
  String _pickupAddress = 'Konumunuz alınıyor...';
  String _destAddress = '';
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _showFarePanel = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
    if (authController.user != null) {
      pc.checkActiveRide(authController.user!.uid);
    }
  }

  Future<void> _initLocation() async {
    final position = await pc.getCurrentLocation();
    if (position != null) {
      setState(() {
        _pickupLocation = LatLng(position.latitude, position.longitude);
        _markers.add(Marker(
          markerId: const MarkerId('pickup'),
          position: _pickupLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: const InfoWindow(title: 'Bulunduğunuz Konum'),
        ));
      });
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_pickupLocation!, 15));
      try {
        List<Placemark> pms = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (pms.isNotEmpty) {
          final p = pms.first;
          setState(() => _pickupAddress = '${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}');
        }
      } catch (_) {}
    }
  }

  Future<void> _searchDest(String query) async {
    if (query.length < 3) return;
    try {
      List<Location> locs = await locationFromAddress(query);
      if (locs.isNotEmpty) {
        final loc = locs.first;
        setState(() {
          _destLocation = LatLng(loc.latitude, loc.longitude);
          _destAddress = query;
          _markers.removeWhere((m) => m.markerId.value == 'destination');
          _markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: _destLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: _destAddress),
          ));
          _showFarePanel = true;
        });

        if (_pickupLocation != null) {
          _mapController?.animateCamera(CameraUpdate.newLatLngBounds(
            LatLngBounds(
              southwest: LatLng(
                _pickupLocation!.latitude < _destLocation!.latitude ? _pickupLocation!.latitude : _destLocation!.latitude,
                _pickupLocation!.longitude < _destLocation!.longitude ? _pickupLocation!.longitude : _destLocation!.longitude,
              ),
              northeast: LatLng(
                _pickupLocation!.latitude > _destLocation!.latitude ? _pickupLocation!.latitude : _destLocation!.latitude,
                _pickupLocation!.longitude > _destLocation!.longitude ? _pickupLocation!.longitude : _destLocation!.longitude,
              ),
            ),
            80,
          ));

          pc.calculateEstimate(
            _pickupLocation!.latitude, _pickupLocation!.longitude,
            _destLocation!.latitude, _destLocation!.longitude,
          );

          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: [_pickupLocation!, _destLocation!],
            color: const Color(0xFFFFD700),
            width: 4,
          ));
        }
      }
    } catch (e) {
      Get.snackbar("Hata", "Adres bulunamadı.");
    }
  }

  void _showRentalAgreement() {
    if (_pickupLocation == null || _destLocation == null || pc.fareBreakdown.value == null) return;
    final fb = pc.fareBreakdown.value!;

    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.description, color: Color(0xFFFFD700), size: 22),
            SizedBox(width: 10),
            Expanded(child: Text(
              'Tahmini Tutar ve Yolculuk Özeti',
              style: TextStyle(color: Color(0xFFFFD700), fontSize: 15, fontWeight: FontWeight.bold),
            )),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _summaryRow('Rota', '$_pickupAddress → $_destAddress', isRoute: true),
              _summaryRow('Araç Segmenti', SegmentConfig.get(fb.segment).label),
              const Divider(color: Color(0xFF444444), height: 20),
              _labelText('ÜCRET KIRILIMI', isHeader: true),
              const SizedBox(height: 8),
              _fareRow('Açılış Bedeli', fb.openingFee),
              _fareRow('Mesafe Bedeli', fb.distanceFee),
              if (fb.segmentSurcharge > 0) _fareRow('Segment Farkı', fb.segmentSurcharge),
              if (fb.marketAdjustment > 0) _fareRow('Piyasa Ayarı', fb.marketAdjustment),
              if (fb.discount > 0) _fareRow('İndirim/Kampanya', -fb.discount, isDiscount: true),
              const Divider(color: Color(0xFF444444), height: 16),
              _fareRow('Toplam Araç Bedeli', fb.grossTotal, isBold: true),
              const SizedBox(height: 12),
              // Güven metni
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_user, color: Color(0xFFFFD700), size: 14),
                        SizedBox(width: 6),
                        Text('Bahtiyar Standardı', style: TextStyle(color: Color(0xFFFFD700), fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tahmini bedel gösterilir. Nihai ücret, rota ve işlem kayıtlarına göre kesinleştirilir. Komisyon, vergi ve sürücü netleşmesi şeffaf gösterilir.',
                      style: TextStyle(color: Colors.grey[500], fontSize: 10, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '🛡️ Kısa süreli şoförlü araç kiralama sözleşmesi\nTBK md. 305 vd. kapsamında',
                style: TextStyle(color: Colors.grey[600], fontSize: 10, fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal', style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton(
            onPressed: () { Get.back(); _confirmRide(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ONAYLA VE KİRALA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void _confirmRide() {
    pc.requestRide(
      passengerId: authController.user!.uid,
      pickupLat: _pickupLocation!.latitude,
      pickupLng: _pickupLocation!.longitude,
      pickupAddress: _pickupAddress,
      destLat: _destLocation!.latitude,
      destLng: _destLocation!.longitude,
      destAddress: _destAddress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Maps
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickupLocation ?? const LatLng(41.0082, 28.9784),
              zoom: 14,
            ),
            onMapCreated: (c) => _mapController = c,
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            style: _darkMapStyle,
          ),

          // Üst çubuk
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 12),
                  _buildSearchBar(),
                ],
              ),
            ),
          ),

          // Aktif yolculuk overlay
          Obx(() {
            final ride = pc.currentRide.value;
            if (ride != null && ride.status != RideStatus.completed && ride.status != RideStatus.cancelled) {
              return _buildActiveRidePanel(ride);
            }
            return const SizedBox.shrink();
          }),

          // Alt panel — fare + segment + KİRALA
          if (_showFarePanel)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildFarePanel()),

          // Konum butonu
          Positioned(
            bottom: _showFarePanel ? 300 : 30,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: const Color(0xFF2C2C2C),
              onPressed: _initLocation,
              child: const Icon(Icons.my_location, color: Color(0xFFFFD700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1C),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
          ),
          child: const Row(
            children: [
              Icon(Icons.handshake, color: Color(0xFFFFD700), size: 20),
              SizedBox(width: 8),
              Text('ORTAK YOL', style: TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 2)),
            ],
          ),
        ),
        Row(
          children: [
            _topBtn(Icons.history, () => Get.toNamed('/ride-history')),
            const SizedBox(width: 8),
            _topBtn(Icons.sos, () => authController.launchEmergencySupport()),
            const SizedBox(width: 8),
            _topBtn(Icons.logout, () => authController.logout()),
          ],
        ),
      ],
    );
  }

  Widget _topBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10)],
        ),
        child: Icon(icon, color: Colors.grey[400], size: 20),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 15)],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: Colors.green, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(_pickupAddress, style: TextStyle(color: Colors.grey[400], fontSize: 13), overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
          ),
          Divider(color: Colors.grey[700], height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _destController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(hintText: 'Nereye gitmek istiyorsun?', hintStyle: TextStyle(color: Colors.grey[600]), border: InputBorder.none),
                    onSubmitted: _searchDest,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                  onPressed: () => _searchDest(_destController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFarePanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.3))),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),

          // Segment seçici
          Obx(() => Row(
            children: VehicleSegment.values.map((seg) {
              final config = SegmentConfig.get(seg);
              final isSelected = pc.selectedSegment.value == seg;
              return Expanded(
                child: GestureDetector(
                  onTap: () => pc.setSegment(seg),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFFFD700) : const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: isSelected ? const Color(0xFFFFD700) : Colors.grey[700]!),
                    ),
                    child: Column(
                      children: [
                        Text(config.icon, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(config.label, style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : Colors.grey[500],
                        )),
                        Text('×${config.multiplier}', style: TextStyle(
                          fontSize: 9, color: isSelected ? Colors.black54 : Colors.grey[600],
                        )),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 10),

          const SizedBox(height: 12),

          // Fiyat özeti
          Obx(() {
            final fb = pc.fareBreakdown.value;
            if (fb == null) return const SizedBox.shrink();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_destAddress, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text('~${fb.distanceKm.toStringAsFixed(1)} km • ${fb.estimatedMinutes} dk', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₺${fb.grossTotal.toStringAsFixed(0)}',
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 12),

          // KİRALA butonu
          SizedBox(
            width: double.infinity, height: 50,
            child: Obx(() => ElevatedButton(
              onPressed: pc.isLoading.value ? null : _showRentalAgreement,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: pc.isLoading.value
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.local_taxi, size: 22),
                      SizedBox(width: 10),
                      Text('KİRALA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1)),
                    ],
                  ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRidePanel(Ride ride) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.5))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _statusColor(ride.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _statusColor(ride.status).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_statusIcon(ride.status), color: _statusColor(ride.status), size: 20),
                  const SizedBox(width: 10),
                  Text(ride.statusText, style: TextStyle(color: _statusColor(ride.status), fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (ride.driverName != null) ...[
              Row(
                children: [
                  Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(color: const Color(0xFFFFD700).withValues(alpha: 0.15), borderRadius: BorderRadius.circular(23)),
                    child: const Icon(Icons.person, color: Color(0xFFFFD700), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ride.driverName!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                      Text(ride.driverPhone ?? '', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  )),
                  if (ride.driverPhone != null)
                    IconButton(
                      onPressed: () async => await launchUrl(Uri.parse('tel:${ride.driverPhone}')),
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.phone, color: Colors.green, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kiralama Bedeli', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                Text('₺${ride.grossTotal.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 12),
            if (ride.status == RideStatus.searching || ride.status == RideStatus.matched)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => pc.cancelRide(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('YOLCULUĞU İPTAL ET', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Yardımcı widgetlar ──
  Widget _summaryRow(String label, String value, {bool isRoute = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 11))),
          Expanded(child: Text(value, style: TextStyle(color: Colors.white, fontSize: isRoute ? 11 : 12))),
        ],
      ),
    );
  }

  Widget _fareRow(String label, double amount, {bool isBold = false, bool isGold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: isBold ? Colors.white : Colors.grey[400], fontSize: 12, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(
            '${isDiscount ? "-" : ""}₺${amount.abs().toStringAsFixed(2)}',
            style: TextStyle(
              color: isGold ? const Color(0xFFFFD700) : (isDiscount ? Colors.green : Colors.white),
              fontSize: isBold ? 14 : 12,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _labelText(String text, {bool isHeader = false}) {
    return Text(text, style: TextStyle(color: const Color(0xFFFFD700), fontSize: isHeader ? 11 : 10, fontWeight: FontWeight.bold, letterSpacing: 1));
  }

  Color _statusColor(RideStatus s) {
    switch (s) {
      case RideStatus.searching: return Colors.orange;
      case RideStatus.matched: case RideStatus.driverArriving: return Colors.blue;
      case RideStatus.inProgress: case RideStatus.completed: return Colors.green;
      case RideStatus.cancelled: return Colors.red;
    }
  }

  IconData _statusIcon(RideStatus s) {
    switch (s) {
      case RideStatus.searching: return Icons.search;
      case RideStatus.matched: return Icons.check_circle;
      case RideStatus.driverArriving: return Icons.directions_car;
      case RideStatus.inProgress: return Icons.navigation;
      case RideStatus.completed: return Icons.flag;
      case RideStatus.cancelled: return Icons.cancel;
    }
  }

  static const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]}
]
''';
}
