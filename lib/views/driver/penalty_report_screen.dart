import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../../controllers/driver_controller.dart';

class PenaltyReportScreen extends StatefulWidget {
  const PenaltyReportScreen({super.key});

  @override
  State<PenaltyReportScreen> createState() => _PenaltyReportScreenState();
}

class _PenaltyReportScreenState extends State<PenaltyReportScreen> {
  final DriverController driverController = Get.find<DriverController>();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  Position? _currentPosition;
  bool _isGettingLocation = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source, imageQuality: 50);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Hata", "Konum servisleri kapalı.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Hata", "Konum izni reddedildi.");
          return;
        }
      }

      _currentPosition = await Geolocator.getCurrentPosition();
      setState(() {});
    } catch (e) {
      Get.snackbar("Hata", "Konum alınamadı: $e");
    } finally {
      setState(() => _isGettingLocation = false);
    }
  }

  void _submitReport() {
    if (_selectedImage == null) {
      Get.snackbar("Hata", "Lütfen bir fotoğraf ekleyin (Ceza tutanağı veya olay yerini).");
      return;
    }
    if (_currentPosition == null) {
      Get.snackbar("Hata", "Lütfen konumunuzu ekleyin.");
      return;
    }

    driverController.reportPenalty(
      image: _selectedImage!,
      description: _descriptionController.text,
      latitude: _currentPosition!.latitude,
      longitude: _currentPosition!.longitude,
    ).then((_) {
      if (!driverController.isLoading.value) {
        Get.back();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ceza Bildir (Hukuki Kalkan)'),
        backgroundColor: Colors.red[900],
        foregroundColor: Colors.white,
      ),
      body: Obx(() => driverController.isLoading.value 
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Korsan yaftası veya haksız ceza durumunda buraya bildirim yapın. Belgeleriniz anında hukuk birimimize iletilir.',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _showImageSourceOptions(),
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.file(_selectedImage!, fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                              Text('Ceza Tutanağı Fotoğrafı Ekle'),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Not (Neler oldu?)',
                    border: OutlineInputBorder(),
                    hintText: 'Polis kontrolü, haksız ceza vb. detayları yazın.',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _isGettingLocation ? null : _getCurrentLocation,
                  icon: const Icon(Icons.location_on),
                  label: Text(_currentPosition != null 
                    ? 'Konum Alındı (${_currentPosition!.latitude.toStringAsFixed(4)})' 
                    : 'Konumu Etiketle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('AVUKATLARA GÖNDER', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )),
    );
  }

  void _showImageSourceOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text('Kamera'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('Galeri'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
