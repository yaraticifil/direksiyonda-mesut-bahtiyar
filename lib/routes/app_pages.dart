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

class AppPages {
  static const INITIAL = '/';

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
  ];
}
