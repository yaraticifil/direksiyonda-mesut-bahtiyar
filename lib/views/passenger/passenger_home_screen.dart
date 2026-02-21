import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/passenger_controller.dart';
import '../../models/ride_model.dart';
import 'package:url_launcher/url_launcher.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  final AuthController authController = Get.find<AuthController>();
  final PassengerController passengerController = Get.find<PassengerController>();

  GoogleMapController? _mapController;
  final TextEditingController _destinationController = TextEditingController();

  LatLng? _pickupLocation;
  LatLng? _destinationLocation;
  String _pickupAddress = 'Konumunuz alınıyor...';
  String _destAddress = '';
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _showRidePanel = false;

  @override
  void initState() {
    super.initState();
    _initLocation();
    // Aktif yolculuk var mı kontrol et
    if (authController.user != null) {
      passengerController.checkActiveRide(authController.user!.uid);
    }
  }

  Future<void> _initLocation() async {
    final position = await passengerController.getCurrentLocation();
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
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_pickupLocation!, 15),
      );
      // Adres çözümle
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude, position.longitude,
        );
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          setState(() {
            _pickupAddress = '${p.street ?? ''}, ${p.subLocality ?? ''}, ${p.locality ?? ''}';
          });
        }
      } catch (_) {}
    }
  }

  Future<void> _searchDestination(String query) async {
    if (query.length < 3) return;
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final loc = locations.first;
        setState(() {
          _destinationLocation = LatLng(loc.latitude, loc.longitude);
          _destAddress = query;

          _markers.removeWhere((m) => m.markerId.value == 'destination');
          _markers.add(Marker(
            markerId: const MarkerId('destination'),
            position: _destinationLocation!,
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            infoWindow: InfoWindow(title: _destAddress),
          ));

          _showRidePanel = true;
        });

        // Haritayı her iki noktayı gösterecek şekilde ayarla
        if (_pickupLocation != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(
              LatLngBounds(
                southwest: LatLng(
                  _pickupLocation!.latitude < _destinationLocation!.latitude
                      ? _pickupLocation!.latitude
                      : _destinationLocation!.latitude,
                  _pickupLocation!.longitude < _destinationLocation!.longitude
                      ? _pickupLocation!.longitude
                      : _destinationLocation!.longitude,
                ),
                northeast: LatLng(
                  _pickupLocation!.latitude > _destinationLocation!.latitude
                      ? _pickupLocation!.latitude
                      : _destinationLocation!.latitude,
                  _pickupLocation!.longitude > _destinationLocation!.longitude
                      ? _pickupLocation!.longitude
                      : _destinationLocation!.longitude,
                ),
              ),
              80,
            ),
          );

          // Tahmini ücret hesapla
          passengerController.calculateEstimate(
            _pickupLocation!.latitude,
            _pickupLocation!.longitude,
            _destinationLocation!.latitude,
            _destinationLocation!.longitude,
          );

          // Basit çizgi çiz
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: const PolylineId('route'),
            points: [_pickupLocation!, _destinationLocation!],
            color: const Color(0xFFFFD700),
            width: 4,
          ));
        }
      }
    } catch (e) {
      Get.snackbar("Hata", "Adres bulunamadı. Lütfen daha detaylı yazın.");
    }
  }

  void _requestRide() {
    if (_pickupLocation == null || _destinationLocation == null) return;

    // Kısa süreli kiralama sözleşmesi onayı
    Get.dialog(
      AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.description, color: Color(0xFFFFD700)),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Kısa Süreli Araç Kiralama',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 16),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bu hizmeti kullanarak, Ortak Yol platformu üzerinden kısa süreli araç kiralama sözleşmesi akdetmiş olursunuz.',
              style: TextStyle(color: Colors.grey[300], fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Text(
              '• Araç sigortalıdır\n• Sürücü lisanslıdır\n• 6098 sayılı TBK kapsamındadır',
              style: TextStyle(color: Colors.grey[400], fontSize: 12, height: 1.6),
            ),
            const SizedBox(height: 15),
            Obx(() => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C1C1C),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tahmini Ücret:', style: TextStyle(color: Colors.white)),
                  Text(
                    '₺${passengerController.estimatedFare.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('İptal', style: TextStyle(color: Colors.grey[500])),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _confirmRide();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD700),
              foregroundColor: Colors.black,
            ),
            child: const Text('KABUL ET VE ÇAĞIR', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmRide() {
    passengerController.requestRide(
      passengerId: authController.user!.uid,
      pickupLat: _pickupLocation!.latitude,
      pickupLng: _pickupLocation!.longitude,
      pickupAddress: _pickupAddress,
      destLat: _destinationLocation!.latitude,
      destLng: _destinationLocation!.longitude,
      destAddress: _destAddress,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Haritalar
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _pickupLocation ?? const LatLng(41.0082, 28.9784), // İstanbul
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
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
                  // Logo ve menü
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1C),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.handshake, color: Color(0xFFFFD700), size: 20),
                            SizedBox(width: 8),
                            Text(
                              'ORTAK YOL',
                              style: TextStyle(
                                color: Color(0xFFFFD700),
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
                          _topBarButton(Icons.history, () {
                            Get.toNamed('/ride-history');
                          }),
                          const SizedBox(width: 8),
                          _topBarButton(Icons.logout, () {
                            authController.logout();
                          }),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Hedef arama çubuğu
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Nereden
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          child: Row(
                            children: [
                              const Icon(Icons.my_location, color: Colors.green, size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _pickupAddress,
                                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey[700], height: 1),
                        // Nereye
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, color: Color(0xFFFFD700), size: 18),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _destinationController,
                                  style: const TextStyle(color: Colors.white, fontSize: 14),
                                  decoration: InputDecoration(
                                    hintText: 'Nereye gitmek istiyorsun?',
                                    hintStyle: TextStyle(color: Colors.grey[600]),
                                    border: InputBorder.none,
                                  ),
                                  onSubmitted: _searchDestination,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search, color: Color(0xFFFFD700)),
                                onPressed: () => _searchDestination(_destinationController.text),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Aktif yolculuk takibi
          Obx(() {
            final ride = passengerController.currentRide.value;
            if (ride != null && ride.status != RideStatus.completed && ride.status != RideStatus.cancelled) {
              return _buildActiveRidePanel(ride);
            }
            return const SizedBox.shrink();
          }),

          // Alt panel — araç çağır
          if (_showRidePanel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildRideRequestPanel(),
            ),

          // Konum butonu
          Positioned(
            bottom: _showRidePanel ? 210 : 30,
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

  Widget _topBarButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 10),
          ],
        ),
        child: Icon(icon, color: Colors.grey[400], size: 20),
      ),
    );
  }

  Widget _buildRideRequestPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.3)),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hedef', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                  const SizedBox(height: 2),
                  SizedBox(
                    width: 180,
                    child: Text(
                      _destAddress,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₺${passengerController.estimatedFare.value.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '~${passengerController.estimatedDistance.value.toStringAsFixed(1)} km • ${passengerController.estimatedDuration.value} dk',
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                ],
              )),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: Obx(() => ElevatedButton(
              onPressed: passengerController.isLoading.value ? null : _requestRide,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFD700),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: passengerController.isLoading.value
                  ? const SizedBox(
                      width: 24, height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.local_taxi, size: 22),
                        SizedBox(width: 10),
                        Text(
                          'ARAÇ ÇAĞIR',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1),
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
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1C),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(color: const Color(0xFFFFD700).withValues(alpha: 0.5)),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),

            // Durum göstergesi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _getStatusColor(ride.status).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _getStatusColor(ride.status).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_getStatusIcon(ride.status), color: _getStatusColor(ride.status), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    ride.statusText,
                    style: TextStyle(
                      color: _getStatusColor(ride.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sürücü bilgisi (eşleşme olduysa)
            if (ride.driverName != null) ...[
              Row(
                children: [
                  Container(
                    width: 45, height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(23),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFFFFD700), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ride.driverName!,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Text(
                          ride.driverPhone ?? '',
                          style: TextStyle(color: Colors.grey[500], fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  // Sürücüyü ara butonu
                  if (ride.driverPhone != null)
                    IconButton(
                      onPressed: () async {
                        final uri = Uri.parse('tel:${ride.driverPhone}');
                        await launchUrl(uri);
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.phone, color: Colors.green, size: 20),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
            ],

            // Ücret
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tahmini Ücret', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                Text(
                  '₺${ride.fare?.toStringAsFixed(2) ?? '—'}',
                  style: const TextStyle(color: Color(0xFFFFD700), fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // İptal butonu (sürücü gelmeden önce)
            if (ride.status == RideStatus.searching || ride.status == RideStatus.matched)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => passengerController.cancelRide(),
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

  Color _getStatusColor(RideStatus status) {
    switch (status) {
      case RideStatus.searching: return Colors.orange;
      case RideStatus.matched: return Colors.blue;
      case RideStatus.driverArriving: return Colors.blue;
      case RideStatus.inProgress: return Colors.green;
      case RideStatus.completed: return Colors.green;
      case RideStatus.cancelled: return Colors.red;
    }
  }

  IconData _getStatusIcon(RideStatus status) {
    switch (status) {
      case RideStatus.searching: return Icons.search;
      case RideStatus.matched: return Icons.check_circle;
      case RideStatus.driverArriving: return Icons.directions_car;
      case RideStatus.inProgress: return Icons.navigation;
      case RideStatus.completed: return Icons.flag;
      case RideStatus.cancelled: return Icons.cancel;
    }
  }

  // Koyu harita stili
  static const String _darkMapStyle = '''
[
  {"elementType": "geometry", "stylers": [{"color": "#212121"}]},
  {"elementType": "labels.icon", "stylers": [{"visibility": "off"}]},
  {"elementType": "labels.text.fill", "stylers": [{"color": "#757575"}]},
  {"elementType": "labels.text.stroke", "stylers": [{"color": "#212121"}]},
  {"featureType": "administrative", "elementType": "geometry", "stylers": [{"color": "#757575"}]},
  {"featureType": "poi", "elementType": "geometry", "stylers": [{"color": "#181818"}]},
  {"featureType": "road", "elementType": "geometry.fill", "stylers": [{"color": "#2c2c2c"}]},
  {"featureType": "road", "elementType": "labels.text.fill", "stylers": [{"color": "#8a8a8a"}]},
  {"featureType": "road.highway", "elementType": "geometry", "stylers": [{"color": "#3c3c3c"}]},
  {"featureType": "water", "elementType": "geometry", "stylers": [{"color": "#000000"}]},
  {"featureType": "water", "elementType": "labels.text.fill", "stylers": [{"color": "#3d3d3d"}]}
]
''';
}
