import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/driver_controller.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class PayoutRequestScreen extends StatefulWidget {
  const PayoutRequestScreen({super.key});

  @override
  State<PayoutRequestScreen> createState() => _PayoutRequestScreenState();
}

class _PayoutRequestScreenState extends State<PayoutRequestScreen> {
  final DriverController driverController = Get.find<DriverController>();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    final amountText = amountController.text.trim();
    final description = descriptionController.text.trim();

    if (amountText.isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen bir miktar giriniz');
      return;
    }

    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Uyarı', 'Geçerli bir miktar giriniz');
      return;
    }

    if (description.isEmpty) {
      Get.snackbar('Uyarı', 'Lütfen bir açıklama giriniz');
      return;
    }

    driverController.requestPayout(amount, description);

    amountController.clear();
    descriptionController.clear();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1C1C1C),
      appBar: AppBar(
        title: const Text('Ödeme Talebi'),
        backgroundColor: const Color(0xFF1C1C1C),
        foregroundColor: const Color(0xFFFFD700),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2C),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: const Color(0xFFFFD700).withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700).withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      size: 30,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Para Çekme Talebi',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFFD700),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Talebiniz yöneticilere iletilecektir',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: amountController,
              label: 'Miktar (₺)',
              hint: 'Çekilecek tutarı girin',
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            CustomTextField(
              controller: descriptionController,
              label: 'Açıklama',
              hint: 'Ödeme detayını yazın (Örn: Haftalık kazanç)',
              icon: Icons.description,
              maxLines: 3,
            ),
            const SizedBox(height: 30),
            Obx(() => CustomButton(
              text: 'TALEBİ GÖNDER',
              onPressed: _submitRequest,
              isLoading: driverController.isLoading.value,
              backgroundColor: const Color(0xFFFFD700),
            )),
          ],
        ),
      ),
    );
  }
}