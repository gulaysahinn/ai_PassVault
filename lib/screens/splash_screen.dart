import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_theme.dart';
import 'auth_screen.dart'; // <--- DEĞİŞİKLİK 1: AuthScreen import edildi

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 3 Saniye bekle ve AuthScreen'e (Kimlik Doğrulama) git
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        // DEĞİŞİKLİK 2: Hedef artık AuthScreen
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // ... (Tasarım kodları aynen kalacak, buraya dokunmana gerek yok)
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary.withOpacity(0.1),
                border: Border.all(color: AppTheme.primary, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  )
                ],
              ),
              child: const Icon(
                Icons.lock_person_rounded,
                size: 80,
                color: AppTheme.primary,
              ),
            )
                .animate()
                .scale(duration: 1.seconds, curve: Curves.elasticOut)
                .then()
                .shimmer(duration: 2.seconds, color: Colors.white),
            const SizedBox(height: 30),
            Text(
              "AI PassVault",
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 500.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 10),
            Text(
              "Güvenli. Akıllı. Hızlı.",
              style: GoogleFonts.sourceCodePro(
                fontSize: 14,
                color: Colors.grey,
              ),
            ).animate().fadeIn(delay: 1000.ms),
            const SizedBox(height: 60),
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppTheme.primary,
                strokeWidth: 3,
              ),
            ).animate().fadeIn(delay: 1500.ms),
          ],
        ),
      ),
    );
  }
}
