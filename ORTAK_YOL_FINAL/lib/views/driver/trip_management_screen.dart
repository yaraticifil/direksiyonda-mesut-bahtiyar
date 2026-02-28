import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/app_colors.dart';

class TripManagementScreen extends StatefulWidget {
  const TripManagementScreen({super.key});

  @override
  State<TripManagementScreen> createState() => _TripManagementScreenState();
}

class _TripManagementScreenState extends State<TripManagementScreen> {
  late GoogleMapController mapController;
  final LatLng _initialPosition = const LatLng(41.0082, 28.9784); // Istanbul

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _buildMap(),
          _buildTopBar(),
          _buildDriverStatusOverlay(),
          _buildEarningsSummary(),
          _buildLiveRidePanel(),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: _initialPosition, zoom: 14),
      onMapCreated: (controller) => mapController = controller,
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      style: '''[
        {"elementType": "geometry", "stylers": [{"color": "#242f3e"}]},
        {"elementType": "labels.text.fill", "stylers": [{"color": "#746855"}]},
        {"elementType": "labels.text.stroke", "stylers": [{"color": "#242f3e"}]}
      ]''',
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50,
      left: 20,
      right: 20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primary, size: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(30), border: Border.all(color: AppColors.primary.withOpacity(0.5))),
            child: Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle)),
                const SizedBox(width: 10),
                Text('ÇEVRİMİÇİ', style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 1)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(color: AppColors.cardBg, shape: BoxShape.circle),
            child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverStatusOverlay() {
    return Positioned(
      top: 120,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.cardBg.withOpacity(0.9), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            _driverStat(Icons.star_rounded, '4.95'),
            const SizedBox(height: 10),
            _driverStat(Icons.timer_rounded, '12dk'),
          ],
        ),
      ),
    );
  }

  Widget _driverStat(IconData icon, String val) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(width: 5),
        Text(val, style: GoogleFonts.spaceGrotesk(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }

  Widget _buildEarningsSummary() {
    return Positioned(
      top: 120,
      right: 20,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10)]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('BUGÜNKÜ KAZANÇ', style: GoogleFonts.publicSans(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
            Text('₺1,240.50', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.black)),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveRidePanel() {
    return Positioned(
      bottom: 30,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.cardBg, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.divider)),
        child: Column(
          children: [
            Row(
              children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.person_pin_circle_rounded, color: AppColors.primary)),
                const SizedBox(width: 15),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('YOLCU ALINIYOR', style: GoogleFonts.publicSans(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    Text('Zeynep Demir', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                )),
                Text('2.4 km', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () {}, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), side: const BorderSide(color: AppColors.divider)), child: const Icon(Icons.call_rounded, color: Colors.white))),
                const SizedBox(width: 15),
                Expanded(flex: 3, child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white), child: Text('VARDIĞIMI BİLDİR', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
