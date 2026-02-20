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
      Get.snackbar('Hata', 'Lütfen bir miktar giriniz');
      return;
    }

    double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Get.snackbar('Hata', 'Geçerli bir miktar giriniz');
      return;
    }

    if (description.isEmpty) {
      Get.snackbar('Hata', 'Lütfen bir açıklama giriniz');
      return;
    }

    // Controller'daki (double amount, String description) imzasına tam uyumlu:
    driverController.requestPayout(amount, description);

    // İşlemden sonra temizle ve geri dön
    amountController.clear();
    descriptionController.clear();
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ödeme Talebi'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                children: [
                  Icon(Icons.account_balance_wallet, size: 50, color: Colors.green[700]),
                  const SizedBox(height: 15),
                  Text(
                    'Para Çekme Talebi',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green[700]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Talebiniz manuel onay için yöneticilere iletilecektir',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.green[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            CustomTextField(
              controller: amountController,
              label: 'Miktar',
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
              text: 'Talebi Gönder',
              onPressed: _submitRequest,
              isLoading: driverController.isLoading.value,
              backgroundColor: Colors.green,
            )),
          ],
        ),
      ),
    );
  }
}