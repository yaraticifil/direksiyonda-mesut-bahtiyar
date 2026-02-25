import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/driver_model.dart';
import '../models/passenger_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<User?> _user = Rx<User?>(null);
  final Rx<Driver?> _driver = Rx<Driver?>(null);
  final Rx<Passenger?> _passenger = Rx<Passenger?>(null);
  final RxBool isLoading = false.obs;
  final RxString userRole = ''.obs; // 'driver', 'passenger', 'admin'

  User? get user => _user.value;
  Driver? get driver => _driver.value;
  Passenger? get passenger => _passenger.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _handleAuthChange);
  }

  void _handleAuthChange(User? user) async {
    if (user != null) {
      await _detectUserRole(user.uid);
    } else {
      _driver.value = null;
      _passenger.value = null;
      userRole.value = '';
    }
  }

  /// Kullanıcının rolünü tespit et (drivers veya passengers koleksiyonunda mı?)
  Future<void> _detectUserRole(String uid) async {
    try {
      // Önce drivers koleksiyonuna bak
      final driverDoc = await _firestore.collection('drivers').doc(uid).get();
      if (driverDoc.exists) {
        _driver.value = Driver.fromFirestore(driverDoc);
        userRole.value = 'driver';
        return;
      }

      // Sonra passengers koleksiyonuna bak
      final passengerDoc = await _firestore.collection('passengers').doc(uid).get();
      if (passengerDoc.exists) {
        _passenger.value = Passenger.fromFirestore(passengerDoc);
        userRole.value = 'passenger';
        return;
      }

      debugPrint("Kullanıcı rolü bulunamadı: $uid");
    } catch (e) {
      debugPrint("Rol tespit hatası: $e");
    }
  }

  Future<void> fetchDriverData(String uid) async {
    try {
      final doc = await _firestore.collection('drivers').doc(uid).get();
      if (doc.exists) {
        _driver.value = Driver.fromFirestore(doc);
      }
    } catch (e) {
      debugPrint("Veri çekme hatası: $e");
    }
  }

  /// Ortak giriş — hem sürücü hem yolcu aynı fonksiyondan giriyor
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Hata", "Giriş başarısız: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Eski referanslar için bırakıldı
  Future<void> loginDriver(String email, String password) async => login(email, password);
  Future<void> loginAdmin(String email, String password) async => login(email, password);

  /// Sürücü kaydı
  Future<void> registerDriver(String name, String email, String password, String phone) async {
    isLoading.value = true;
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Driver d = Driver(
        id: res.user!.uid,
        name: name,
        phone: phone,
        status: DriverStatus.pending,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore.collection('drivers').doc(d.id).set(d.toMap());
      } catch (firestoreError) {
        await res.user!.delete();
        throw "Veritabanı hatası: $firestoreError. Lütfen tekrar deneyin.";
      }
    } catch (e) {
      Get.snackbar("Hata", "Kayıt hatası: $e", duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  /// Yolcu kaydı
  Future<void> registerPassenger(String name, String email, String password, String phone) async {
    isLoading.value = true;
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Passenger p = Passenger(
        id: res.user!.uid,
        name: name,
        phone: phone,
        email: email,
        createdAt: DateTime.now(),
      );

      try {
        await _firestore.collection('passengers').doc(p.id).set(p.toMap());
      } catch (firestoreError) {
        await res.user!.delete();
        throw "Veritabanı hatası: $firestoreError. Lütfen tekrar deneyin.";
      }
    } catch (e) {
      Get.snackbar("Hata", "Kayıt hatası: $e", duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  /// Şifre sıfırlama
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar("Başarılı", "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi.",
          duration: const Duration(seconds: 5));
    } catch (e) {
      Get.snackbar("Hata", "Şifre sıfırlama hatası: $e");
    }
  }

  void logout() async {
    _driver.value = null;
    _passenger.value = null;
    userRole.value = '';
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  /// Auth kontrolü ve role göre yönlendirme
  Future<void> checkAuthAndRedirect() async {
    if (_user.value == null) {
      Get.offAllNamed('/login');
      return;
    }

    // Rolü henüz belirlenmemişse bekle
    if (userRole.value.isEmpty) {
      await _detectUserRole(_user.value!.uid);
    }

    switch (userRole.value) {
      case 'driver':
        if (_driver.value?.status == DriverStatus.pending) {
          Get.offAllNamed('/waiting');
        } else if (_driver.value?.status == DriverStatus.rejected) {
          Get.offAllNamed('/waiting');
        } else {
          Get.offAllNamed('/dashboard');
        }
        break;
      case 'passenger':
        Get.offAllNamed('/passenger-home');
        break;
      default:
        Get.offAllNamed('/login');
        break;
    }
  }

  /// Acil destek — WhatsApp, arama ve SMS
  Future<void> launchEmergencySupport() async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/905407254626?text=ACIL%20YARDIM!%20Hukuki%20destek%20istiyorum.");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        // WhatsApp yoksa doğrudan ara
        final Uri phoneUrl = Uri.parse("tel:+905407254626");
        if (await canLaunchUrl(phoneUrl)) {
          await launchUrl(phoneUrl);
        } else {
          Get.snackbar("Hata", "Arama yapılamıyor.");
        }
      }
    } catch (e) {
      Get.snackbar("Hata", "Bir sorun oluştu: $e");
    }
  }

  /// Doğrudan arama
  Future<void> callEmergency() async {
    final Uri phoneUrl = Uri.parse("tel:+905407254626");
    try {
      if (await canLaunchUrl(phoneUrl)) {
        await launchUrl(phoneUrl);
      }
    } catch (e) {
      Get.snackbar("Hata", "Arama yapılamadı: $e");
    }
  }
}