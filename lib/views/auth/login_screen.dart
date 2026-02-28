import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (emailController.text.trim().isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen e-posta adresinizi girin');
      return;
    }

    if (passwordController.text.isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen şifrenizi girin');
      return;
    }

    authController.login(
      emailController.text.trim(),
      passwordController.text,
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
                const SizedBox(height: 40),
                // Logo & Başlık
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFD700), width: 2),
                        ),
                        child: const Icon(
                          Icons.handshake,
                          size: 40,
                          color: Color(0xFFFFD700),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'ORTAK YOL',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFFFD700),
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tekrar hoş geldin, yoldaş.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[400],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                // Form Alanları
                CustomTextField(
                  controller: emailController,
                  label: 'E-posta',
                  hint: 'Kayıtlı e-posta adresiniz',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                CustomTextField(
                  controller: passwordController,
                  label: 'Şifre',
                  hint: 'Şifrenizi girin',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                const SizedBox(height: 35),
                Obx(() => CustomButton(
                  text: 'GİRİŞ YAP',
                  onPressed: _login,
                  isLoading: authController.isLoading.value,
                )),
                const SizedBox(height: 12),
                // Şifremi Unuttum
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      if (emailController.text.trim().isEmpty) {
                        Get.snackbar('Uyarı', 'Önce e-posta adresinizi girin');
                        return;
                      }
                      authController.resetPassword(emailController.text.trim());
                    },
                    child: const Text(
                      'Şifremi Unuttum',
                      style: TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                TextButton(
                  onPressed: () => Get.offAllNamed('/register'),
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: 'Hesabın yok mu? ',
                      style: TextStyle(color: Colors.grey[500], fontSize: 15),
                      children: const [
                        TextSpan(
                          text: 'Aramıza katıl',
                          style: TextStyle(
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Alttaki slogan
                Center(
                  child: Text(
                    '"Direksiyon başında, hukuk zemininde."',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
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
