import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/main.dart';
import 'package:driver_app/controllers/auth_controller.dart';
import 'package:get/get.dart';

class MockAuthController extends GetxController implements AuthController {
  @override
  Future<void> checkAuthAndRedirect() async {
    // Mock implementation doesn't redirect or do anything
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Uygulama başlangıç testi', (WidgetTester tester) async {
    Get.put<AuthController>(MockAuthController());

    await tester.pumpWidget(const DriverApp());

    expect(find.text('ORTAK YOL'), findsOneWidget);

    // Clear the pending timers from SplashScreen
    await tester.pump(const Duration(seconds: 3));
    // Another pump for the animation controller
    await tester.pump(const Duration(milliseconds: 1500));
  });
}
