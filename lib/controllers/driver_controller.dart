import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/driver_model.dart';
import '../models/payout_model.dart';

class DriverController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UI'da çarkın dönmesi ve butonun kilitlenmesi için gerekli
  final RxBool isLoading = false.obs;

  final Rx<Driver?> driver = Rx<Driver?>(null);
  final RxList<Payout> payouts = <Payout>[].obs;

  // Sürücü verilerini çeken metod
  Future<void> fetchDriverData(String driverId) async {
    isLoading.value = true;
    try {
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('drivers')
          .doc(driverId)
          .get() as DocumentSnapshot<Map<String, dynamic>>;
      if (doc.exists) {
        driver.value = Driver.fromFirestore(doc);
      }
    } catch (e) {
      print("Sürücü hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPayouts([String? driverId]) async {
    String id = driverId ?? driver.value?.id ?? '';
    if (id.isEmpty) return;
    try {
      QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('payouts').where('driverId', isEqualTo: id).get() as QuerySnapshot<Map<String, dynamic>>;
      payouts.value = snap.docs.map((doc) => Payout.fromFirestore(doc)).toList();
    } catch (e) {
      print("Payout hatası: $e");
    }
  }

  double getTotalEarnings() {
    return payouts
        .where((p) => p.status == PayoutStatus.completed)
        .fold(0, (sum, item) => sum + item.amount);
  }

  double getPendingPayouts() {
    return payouts
        .where((p) => p.status == PayoutStatus.pending)
        .fold(0, (sum, item) => sum + item.amount);
  }

  Future<void> requestPayout(double amount, String description) async {
    isLoading.value = true;
    try {
      await _firestore.collection('payouts').add({
        'driverId': driver.value?.id ?? '',
        'amount': amount,
        'description': description,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      await fetchPayouts();
      Get.snackbar("Başarılı", "Talebiniz iletildi");
    } catch (e) {
      Get.snackbar("Hata", "Talep gönderilemedi");
    } finally {
      isLoading.value = false;
    }
  }
}