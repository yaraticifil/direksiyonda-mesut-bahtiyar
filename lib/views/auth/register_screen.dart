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
  final TextEditingController emailController = TextEditingController(); // EKLENDİ
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  int adminTapCount = 0;
  DateTime? lastTapTime;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose(); // EKLENDİ
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
        Get.snackbar('Admin Access', 'Admin login activated');
      }
    } else {
      adminTapCount = 1;
    }
    lastTapTime = now;
  }

  void _register() {
    if (nameController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your name');
      return;
    }

    if (emailController.text.trim().isEmpty || !GetUtils.isEmail(emailController.text.trim())) {
      Get.snackbar('Error', 'Please enter a valid email');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your phone number');
      return;
    }

    if (passwordController.text.length < 6) {
      Get.snackbar('Error', 'Password must be at least 6 characters');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('Error', 'Passwords do not match');
      return;
    }

    // BURASI KRİTİK: AuthController'daki (name, email, password, phone) sırasına göre gönderiyoruz.
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
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Driver Registration'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _handleAdminTap,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(Icons.person_add, size: 40, color: Colors.blue[700]),
                    const SizedBox(height: 10),
                    Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: nameController,
              label: 'Full Name',
              hint: 'Enter your full name',
              icon: Icons.person,
            ),
            const SizedBox(height: 20),
            // E-POSTA ALANI EKLENDİ - BU OLMADAN FIREBASE KAYIT YAPAMAZ!
            CustomTextField(
              controller: emailController,
              label: 'Email Address',
              hint: 'Enter your email',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: phoneController,
              label: 'Phone Number',
              hint: 'Enter your phone number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: passwordController,
              label: 'Password',
              hint: 'Enter your password',
              icon: Icons.lock,
              obscureText: true,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: confirmPasswordController,
              label: 'Confirm Password',
              hint: 'Confirm your password',
              icon: Icons.lock_outline,
              obscureText: true,
            ),
            const SizedBox(height: 30),
            Obx(() => CustomButton(
              text: 'Register',
              onPressed: _register,
              isLoading: authController.isLoading.value,
            )),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => Get.toNamed('/login'),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}