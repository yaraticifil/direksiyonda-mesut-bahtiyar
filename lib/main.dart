import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'controllers/auth_controller.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase Initialization
  await Supabase.initialize(
    url: 'https://icqwnyylxymnihetkbxi.supabase.co',
    anonKey: 'sb_publishable_HxOjYrr12YbYUKEd3EmkEg_n6Srx3ix',
  );

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    Get.put(AuthController());
    
    runApp(const DriverApp());
  } catch (e) {
    debugPrint("Initialization Error: $e");
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;
  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 20),
                const Text("Uygulama başlatılırken hata oluştu:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(error, textAlign: TextAlign.center, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DriverApp extends StatelessWidget {
  const DriverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ortak Yol',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.primary,
          surface: AppColors.cardBg,
          onSurface: AppColors.textPrimary,
        ),
        // Premium Typography: Space Grotesk for Headings, Public Sans for body
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          ThemeData.dark().textTheme.copyWith(
            bodyLarge: GoogleFonts.publicSans(color: AppColors.textPrimary),
            bodyMedium: GoogleFonts.publicSans(color: AppColors.textSecondary),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.primary,
          elevation: 0,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        dividerColor: AppColors.divider,
      ),
      // Codex Fix P1: Preserve SplashScreen as entry for Auth Check
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
