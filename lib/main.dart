import 'package:flutter/material.dart';

// Klasörlerden import ediyoruz
import 'core/app_theme.dart';
import 'screens/auth_screen.dart'; // Parmak İzi ekranı
import 'services/storage_service.dart'; // Şifreli veritabanı servisi

void main() async {
  // Flutter motorunun asenkron işlemler için hazır olduğundan emin oluyoruz
  WidgetsFlutterBinding.ensureInitialized();

  // --- KRİTİK ADIM ---
  // Şifreli Veritabanını ve Güvenli Anahtarı Hazırlıyoruz
  // (Eskiden burada Hive.initFlutter() vardı, artık servisin içinde yapılıyor)
  await StorageService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AI PassVault', // Uygulamanın adı
      theme: AppTheme.darkTheme, // core/app_theme.dart dosyasındaki tema
      // GÜVENLİK: Uygulama açılır açılmaz önce kimlik doğrulaması (AuthScreen) yapılacak
      home: const AuthScreen(),
    );
  }
}
