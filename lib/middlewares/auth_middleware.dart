import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class AdminAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (authController.userRole.value != 'admin') {
      return const RouteSettings(name: '/role-selection');
    }
    return null;
  }
}

class DriverAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (authController.userRole.value != 'driver') {
      return const RouteSettings(name: '/role-selection');
    }
    return null;
  }
}

class PassengerAuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authController = Get.find<AuthController>();
    if (authController.userRole.value != 'passenger') {
      return const RouteSettings(name: '/role-selection');
    }
    return null;
  }
}
