import 'package:get/get.dart';
import '../controllers/passenger_controller.dart';

class PassengerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PassengerController>(() => PassengerController());
  }
}
