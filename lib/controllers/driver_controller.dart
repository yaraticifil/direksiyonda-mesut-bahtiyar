import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/driver_model.dart';
import '../models/payout_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

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
      final doc = await _firestore
          .collection('drivers')
          .doc(driverId)
          .get();
      if (doc.exists) {
        driver.value = Driver.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint("Sürücü hatası: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reportPenalty({
    required File image,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    isLoading.value = true;
    try {
      final String driverId = driver.value?.id ?? 'unknown';
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}${p.extension(image.path)}';
      final Reference storageRef = FirebaseStorage.instance.ref().child('penalties/$driverId/$fileName');

      // Upload file
      final UploadTask uploadTask = storageRef.putFile(image);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Save to Firestore
      await _firestore.collection('penalties').add({
        'driverId': driverId,
        'driverName': driver.value?.name ?? 'Anonim',
        'imageUrl': downloadUrl,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar("Başarılı", "Ceza bildirimi avukatlarımıza iletildi.");
    } catch (e) {
      Get.snackbar("Hata", "Bildirim gönderilemedi: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPayouts([String? driverId]) async {
    String id = driverId ?? driver.value?.id ?? '';
    if (id.isEmpty) return;
    try {
      final snap = await _firestore
          .collection('payouts').where('driverId', isEqualTo: id).get();
      payouts.value = snap.docs.map((doc) => Payout.fromFirestore(doc)).toList();
    } catch (e) {
      debugPrint("Payout hatası: $e");
    }
  }

  double getTotalEarnings() {
    return payouts
        .where((p) => p.status == PayoutStatus.completed)
        .fold(0.0, (total, item) => total + item.amount);
  }

  double getPendingPayouts() {
    return payouts
        .where((p) => p.status == PayoutStatus.pending)
        .fold(0.0, (total, item) => total + item.amount);
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