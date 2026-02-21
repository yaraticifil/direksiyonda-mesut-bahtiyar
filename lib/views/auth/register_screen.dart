import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool isDriver = true; // true = sürücü, false = yolcu
  int adminTapCount = 0;
  DateTime? lastTapTime;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleAdminTap() {
    final now = DateTime.now();
    if (lastTapTime != null && now.difference(lastTapTime!) < const Duration(seconds: 2)) {
      adminTapCount++;
      if (adminTapCount >= 5) {
        adminTapCount = 0;
        Get.toNamed('/admin-login');
      }
    } else {
      adminTapCount = 1;
    }
    lastTapTime = now;
  }

  void _register() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen adınızı ve soyadınızı girin');
      return;
    }

    if (emailController.text.trim().isEmpty || !GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Uyarı', 'Geçerli bir e-posta adresi girin');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('Uyarı', 'Telefon numaranızı girin');
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar('Uyarı', 'Şifre en az 6 karakter olmalıdır');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Uyarı', 'Şifreler eşleşmiyor');
      return;
    }

    if (isDriver) {
      authController.registerDriver(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        phoneController.text.trim(),
      );
    } else {
      authController.registerPassenger(
        nameController.text.trim(),
        emailController.text.trim(),
        passwordController.text,
        phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1C1C1C), Color(0xFF2C2C2C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Başlık
                GestureDetector(
                  onTap: _handleAdminTap,
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.handshake,
                          size: 50,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'ORTAK YOL',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD700),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Yolculuğa başla, birlikte güçlüyüz.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[400],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // ROL SEÇİMİ
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isDriver = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isDriver
                                  ? const Color(0xFFFFD700)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 20,
                                  color: isDriver ? Colors.black : Colors.grey[500],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'SÜRÜCÜYÜM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: isDriver ? Colors.black : Colors.grey[500],
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isDriver = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: !isDriver
                                  ? const Color(0xFFFFD700)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(13),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.person,
                                  size: 20,
                                  color: !isDriver ? Colors.black : Colors.grey[500],
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'YOLCUYUM',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: !isDriver ? Colors.black : Colors.grey[500],
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Açıklama
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C1C1C),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isDriver ? Icons.shield : Icons.map,
                        color: const Color(0xFFFFD700),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isDriver
                              ? 'Sigortalı sürücü olarak platforma katıl, hukuki güvence altında çalış.'
                              : 'Güvenli ve uygun fiyatlı yolculuk için hemen kayıt ol.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form
                CustomTextField(
                  controller: nameController,
                  label: 'Ad Soyad',
                  hint: 'Adınız ve soyadınız',
                  icon: Icons.person,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: emailController,
                  label: 'E-Posta',
                  hint: 'E-posta adresiniz',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: phoneController,
                  label: 'Telefon',
                  hint: 'Telefon numaranız',
                  icon: Icons.phone,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: passwordController,
                  label: 'Şifre',
                  hint: 'En az 6 karakter',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 18),
                CustomTextField(
                  controller: confirmPasswordController,
                  label: 'Şifre Tekrar',
                  hint: 'Şifrenizi tekrar girin',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 30),
                Obx(() => CustomButton(
                  text: isDriver ? 'SÜRÜCÜ OLARAK KAYIT OL' : 'YOLCU OLARAK KAYIT OL',
                  onPressed: _register,
                  isLoading: authController.isLoading.value,
                )),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Get.toNamed('/login'),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Zaten hesabın var mı? ',
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      children: const [
                        TextSpan(
                          text: 'Giriş yap',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                // Hukuki bilgi
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFD700).withValues(alpha: 0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isDriver
                        ? '🛡️  Kaydınız, hukuki güvence kapsamında korunur.\nBu platform bir suç örgütü değil, bir emek hareketidir.'
                        : '🚗  Yolculuklarınız kısa süreli araç kiralama sözleşmesi\nkapsamında hukuki güvence altındadır.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}