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

    authController.registerDriver(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text,
      phoneController.text.trim(),
    );
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
                          Icons.person_add,
                          size: 50,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(height: 15),
                        const Text(
                          'ARAMIZA KATIL',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFFFD700),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Direksiyonu tutan el, hakkını da tutsun.',
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
                const SizedBox(height: 30),
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
                  text: 'KAYIT OL',
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
                const SizedBox(height: 30),
                // Manifest ruhu
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '🛡️  Kaydınız, hukuki güvence kapsamında korunur.\nBu platform bir suç örgütü değil, bir emek hareketidir.',
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