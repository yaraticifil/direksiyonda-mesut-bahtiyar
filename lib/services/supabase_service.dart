import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:get/get.dart';

class SupabaseService extends GetxService {
  static SupabaseService get to => Get.find();
  
  final SupabaseClient client = Supabase.instance.client;

  Future<SupabaseService> init() async {
    return this;
  }

  // Örnek: Veri ekleme fonksiyonu
  Future<void> logActivity(String activity) async {
    try {
      await client.from('activities').insert({
        'content': activity,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Supabase Log Error: $e');
    }
  }

  // Auth işlemleri için kolay erişim
  GoTrueClient get auth => client.auth;
}
