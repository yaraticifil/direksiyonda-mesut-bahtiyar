import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/driver_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rx<User?> _user = Rx<User?>(null);
  final Rx<Driver?> _driver = Rx<Driver?>(null);
  final RxBool isLoading = false.obs;

  User? get user => _user.value;
  Driver? get driver => _driver.value;

  @override
  void onInit() {
    super.onInit();
    _user.bindStream(_auth.authStateChanges());
    ever(_user, _handleAuthChange);
  }

  void _handleAuthChange(User? user) async {
    if (user != null) {
      await fetchDriverData(user.uid);
    } else {
      _driver.value = null;
    }
  }

  Future<void> fetchDriverData(String uid) async {
    try {
      // Tip güvenliği sağlandı
      DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
          .collection('drivers')
          .doc(uid)
          .get() as DocumentSnapshot<Map<String, dynamic>>;

      if (doc.exists) {
        _driver.value = Driver.fromFirestore(doc);
      }
    } catch (e) {
      print("Veri çekme hatası: $e");
    }
  }

  Future<void> loginDriver(String email, String password) async {
    isLoading.value = true;
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      Get.snackbar("Hata", "Giriş başarısız: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginAdmin(String email, String password) async => loginDriver(email, password);

  Future<void> registerDriver(String name, String email, String password, String phone) async {
    isLoading.value = true;
    try {
      UserCredential res = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      Driver d = Driver(
          id: res.user!.uid,
          name: name,
          phone: phone,
          status: DriverStatus.pending,
          createdAt: DateTime.now()
      );
      
      try {
        await _firestore.collection('drivers').doc(d.id).set(d.toMap());
      } catch (firestoreError) {
        // Firestore yazma hatası durumunda created user'ı silerek tutarsızlığı önle
        await res.user!.delete();
        throw "Veritabanı hatası: $firestoreError. Lütfen tekrar deneyin.";
      }
    } catch (e) {
      Get.snackbar("Hata", "Kayıt hatası: $e", duration: const Duration(seconds: 5));
    } finally {
      isLoading.value = false;
    }
  }

  void logout() async {
    await _auth.signOut();
    Get.offAllNamed('/login');
  }

  Future<void> launchEmergencySupport() async {
    final Uri whatsappUrl = Uri.parse("https://wa.me/905000000000?text=ACIL%20YARDIM!%20Hukuki%20destek%20istiyorum.");
    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        Get.snackbar("Hata", "WhatsApp uygulaması bulunamadı veya açılamadı.");
      }
    } catch (e) {
      Get.snackbar("Hata", "Bir sorun oluştu: $e");
    }
  }
}