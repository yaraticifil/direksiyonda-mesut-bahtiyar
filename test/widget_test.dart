import 'package:flutter_test/flutter_test.dart';
import 'package:driver_app/main.dart';

void main() {
  testWidgets('Uygulama başlangıç testi', (WidgetTester tester) async {
    await tester.pumpWidget(const DriverApp());

    expect(find.text("Ortak Yol"), findsOneWidget);
  });
}
