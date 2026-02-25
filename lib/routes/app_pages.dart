import 'package:get/get.dart';
import '../views/splash_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/driver/waiting_screen.dart';
import '../views/driver/dashboard_screen.dart';
import '../views/admin/admin_login_screen.dart';
import '../views/admin/admin_dashboard_screen.dart';
import '../bindings/auth_binding.dart';
import '../bindings/driver_binding.dart';
import '../bindings/admin_binding.dart';
import '../bindings/passenger_binding.dart';
import '../views/driver/digital_id_screen.dart';
import '../views/driver/legal_contract_screen.dart';
import '../views/driver/penalty_report_screen.dart';
import '../views/passenger/passenger_home_screen.dart';
import '../views/passenger/ride_history_screen.dart';
import '../views/driver/fair_earnings_screen.dart';
import '../views/driver/ride_detail_screen.dart';

class AppPages {
  static const initial = '/';

  static final routes = [
    GetPage(
      name: '/',
      page: () => const SplashScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/waiting',
      page: () => const WaitingScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: '/dashboard',
      page: () => const DashboardScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: '/admin-login',
      page: () => const AdminLoginScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: '/admin-dashboard',
      page: () => const AdminDashboardScreen(),
      binding: AdminBinding(),
    ),
    GetPage(
      name: '/digital-id',
      page: () => const DigitalIdScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: '/legal-contract',
      page: () => const LegalContractScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: '/report-penalty',
      page: () => const PenaltyReportScreen(),
      binding: DriverBinding(),
    ),
    // ─── YOLCU EKRANLARI ───
    GetPage(
      name: '/passenger-home',
      page: () => const PassengerHomeScreen(),
      binding: PassengerBinding(),
    ),
    GetPage(
      name: '/ride-history',
      page: () => const RideHistoryScreen(),
      binding: PassengerBinding(),
    ),
    // ─── SÜRÜCÜ ADİL KAZANÇ ───
    GetPage(
      name: '/fair-earnings',
      page: () => const FairEarningsScreen(),
      binding: DriverBinding(),
    ),
    GetPage(
      name: '/ride-detail',
      page: () => const RideDetailScreen(),
      binding: DriverBinding(),
    ),
  ];
}
