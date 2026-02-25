import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import '../../models/ride_model.dart';
import '../../services/ride_service.dart';
import '../../utils/app_colors.dart';

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
            color: AppColors.primary,
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
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.description_rounded, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(
              'Yolculuk Özeti',
              style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
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
              const Divider(color: AppColors.divider, height: 30),
              Text(
                'ÜCRET DETAYLARI',
                style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
              const SizedBox(height: 12),
              _fareRow('Açılış Bedeli', fb.openingFee),
              _fareRow('Mesafe Bedeli', fb.distanceFee),
              if (fb.segmentSurcharge > 0) _fareRow('Segment Farkı', fb.segmentSurcharge),
              if (fb.marketAdjustment > 0) _fareRow('Piyasa Ayarı', fb.marketAdjustment),
              if (fb.discount > 0) _fareRow('İndirim', -fb.discount, isDiscount: true),
              const Divider(color: AppColors.divider, height: 24),
              _fareRow('TOPLAM BEDEL', fb.grossTotal, isBold: true, isGold: true),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: AppColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Bahtiyar Güvencesi',
                          style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bu yolculuk TBK md. 305 kapsamında hukuk zemininde gerçekleştirilmektedir. Şeffaf fiyatlandırma garantisi sunulur.',
                      style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 11, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Vazgeç', style: GoogleFonts.publicSans(color: AppColors.textDisabled)),
          ),
          ElevatedButton(
            onPressed: () { Get.back(); _confirmRide(); },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              'ONAYLA VE KİRALA',
              style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
            ),
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
      backgroundColor: AppColors.background,
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

          // Üst Çubuk
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 15),
                  _buildSearchBar(),
                ],
              ),
            ),
          ),

          // Aktif Yolculuk Paneli
          Obx(() {
            final ride = pc.currentRide.value;
            if (ride != null && ride.status != RideStatus.completed && ride.status != RideStatus.cancelled) {
              return _buildActiveRidePanel(ride);
            }
            return const SizedBox.shrink();
          }),

          // Alt Panel (Fiyat & Segment)
          if (_showFarePanel)
            Positioned(bottom: 0, left: 0, right: 0, child: _buildFarePanel()),

          // Konum Butonu
          Positioned(
            bottom: _showFarePanel ? 320 : 30,
            right: 20,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.cardBg,
              onPressed: _initLocation,
              child: const Icon(Icons.my_location, color: AppColors.primary),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              const Icon(Icons.handshake_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'ORTAK YOL',
                style: GoogleFonts.spaceGrotesk(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _topBtn(Icons.history_rounded, () => Get.toNamed('/ride-history')),
            const SizedBox(width: 10),
            _topBtn(Icons.sos_rounded, () => authController.launchEmergencySupport()),
            const SizedBox(width: 10),
            _topBtn(Icons.logout_rounded, () => authController.logout()),
          ],
        ),
      ],
    );
  }

  Widget _topBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 4))],
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 20),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          _searchRow(Icons.my_location_rounded, Colors.green, _pickupAddress, isReadOnly: true),
          const Divider(color: AppColors.divider, height: 1),
          _searchRow(
            Icons.location_on_rounded, 
            AppColors.primary, 
            'Nereye gitmek istiyorsun?',
            controller: _destController,
            onSubmitted: _searchDest,
          ),
        ],
      ),
    );
  }

  Widget _searchRow(IconData icon, Color iconColor, String hint, {bool isReadOnly = false, TextEditingController? controller, Function(String)? onSubmitted}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: isReadOnly 
                ? Text(hint, style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 14), overflow: TextOverflow.ellipsis)
                : TextField(
                    controller: controller,
                    style: GoogleFonts.publicSans(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: GoogleFonts.publicSans(color: AppColors.textDisabled),
                      border: InputBorder.none,
                    ),
                    onSubmitted: onSubmitted,
                  ),
          ),
          if (!isReadOnly)
            IconButton(
              icon: const Icon(Icons.search_rounded, color: AppColors.primary),
              onPressed: () => onSubmitted?.call(controller?.text ?? ''),
            ),
        ],
      ),
    );
  }

  Widget _buildFarePanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(top: BorderSide(color: AppColors.primary.withOpacity(0.3))),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, -10))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),

          // Segment Seçici
          Obx(() => Row(
            children: VehicleSegment.values.map((seg) {
              final config = SegmentConfig.get(seg);
              final isSelected = pc.selectedSegment.value == seg;
              return Expanded(
                child: GestureDetector(
                  onTap: () => pc.setSegment(seg),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.cardBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isSelected ? AppColors.primary : AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        Text(config.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(height: 4),
                        Text(
                          config.label,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12, 
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.black : AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '×${config.multiplier}',
                          style: GoogleFonts.publicSans(
                            fontSize: 10, 
                            color: isSelected ? Colors.black54 : AppColors.textDisabled,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
          const SizedBox(height: 20),

          // Fiyat Özeti
          Obx(() {
            final fb = pc.fareBreakdown.value;
            if (fb == null) return const SizedBox.shrink();
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _destAddress, 
                        style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${fb.distanceKm.toStringAsFixed(1)} km • ~${fb.estimatedMinutes} dakika',
                        style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '₺${fb.grossTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontSize: 28, fontWeight: FontWeight.w900),
                ),
              ],
            );
          }),
          const SizedBox(height: 24),

          // Buton
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
              onPressed: pc.isLoading.value ? null : _showRentalAgreement,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                elevation: 0,
              ),
              child: pc.isLoading.value
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded, size: 24),
                      const SizedBox(width: 10),
                      Text(
                        'ONAYLA VE KİRALA',
                        style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
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
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border(top: BorderSide(color: _statusColor(ride.status).withOpacity(0.5))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.6), blurRadius: 30, offset: const Offset(0, -10))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: _statusColor(ride.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _statusColor(ride.status).withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_statusIcon(ride.status), color: _statusColor(ride.status), size: 24),
                  const SizedBox(width: 12),
                  Text(
                    ride.statusText,
                    style: GoogleFonts.spaceGrotesk(color: _statusColor(ride.status), fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (ride.driverName != null) ...[
              Row(
                children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driverName!,
                          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        Text(
                          ride.driverPhone ?? '',
                          style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  if (ride.driverPhone != null)
                    _actionBtn(Icons.phone_rounded, Colors.green, () async => await launchUrl(Uri.parse('tel:${ride.driverPhone}'))),
                ],
              ),
              const SizedBox(height: 20),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Kiralama Bedeli', style: GoogleFonts.publicSans(color: AppColors.textSecondary, fontSize: 14)),
                Text(
                  '₺${ride.grossTotal.toStringAsFixed(0)}',
                  style: GoogleFonts.spaceGrotesk(color: AppColors.primary, fontWeight: FontWeight.w900, fontSize: 22),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (ride.status == RideStatus.searching || ride.status == RideStatus.matched)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => pc.cancelRide(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'YOLCULUĞU İPTAL ET',
                    style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }

  // ── Yardımcı widgetlar ──
  Widget _summaryRow(String label, String value, {bool isRoute = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: GoogleFonts.publicSans(color: AppColors.textDisabled, fontSize: 12)),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.publicSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: isRoute ? FontWeight.normal : FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fareRow(String label, double amount, {bool isBold = false, bool isGold = false, bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.publicSans(
              color: isBold ? Colors.white : AppColors.textSecondary,
              fontSize: 13,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${isDiscount ? "-" : ""}₺${amount.abs().toStringAsFixed(2)}',
            style: GoogleFonts.spaceGrotesk(
              color: isGold ? AppColors.primary : (isDiscount ? AppColors.success : Colors.white),
              fontSize: isBold ? 16 : 13,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(RideStatus s) {
    switch (s) {
      case RideStatus.searching: return AppColors.warning;
      case RideStatus.matched: case RideStatus.driverArriving: return AppColors.info;
      case RideStatus.inProgress: case RideStatus.completed: return AppColors.success;
      case RideStatus.cancelled: return AppColors.error;
    }
  }

  IconData _statusIcon(RideStatus s) {
    switch (s) {
      case RideStatus.searching: return Icons.radar_rounded;
      case RideStatus.matched: return Icons.check_circle_rounded;
      case RideStatus.driverArriving: return Icons.directions_car_rounded;
      case RideStatus.inProgress: return Icons.navigation_rounded;
      case RideStatus.completed: return Icons.flag_rounded;
      case RideStatus.cancelled: return Icons.cancel_rounded;
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
