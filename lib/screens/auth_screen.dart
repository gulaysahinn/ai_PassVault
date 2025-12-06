import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import '../core/app_theme.dart';
import '../widgets/custom_widgets.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticating = false;
  String _statusMessage = "Giriş Yapın";

  @override
  void initState() {
    super.initState();
    // Uygulama açılır açılmaz parmak izi sor
    _authenticate();
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    setState(() {
      _isAuthenticating = true;
      _statusMessage = "Kimlik doğrulanıyor...";
    });

    try {
      // Cihazda biyometrik donanım var mı kontrol et
      final bool canAuthenticateWithBiometrics = await auth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await auth.isDeviceSupported();

      if (!canAuthenticate) {
        setState(() {
          _statusMessage = "Cihazınızda Biyometrik Giriş Desteklenmiyor.";
        });
        // Desteklemiyorsa direkt ana sayfaya al (veya şifre sorulabilir)
        await Future.delayed(const Duration(seconds: 2));
        _navigateToHome();
        return;
      }

      // Parmak İzi / Yüz Tanıma Penceresini Aç
      authenticated = await auth.authenticate(
        localizedReason: 'Kasanıza erişmek için kimliğinizi doğrulayın',
        options: const AuthenticationOptions(
          stickyAuth: true, // Uygulama alta atılsa bile sormaya devam et
          biometricOnly: false, // Yüz/Parmak izi yoksa PIN kodu sorabilsin
        ),
      );
    } on PlatformException catch (e) {
      print(e);
      setState(() {
        _statusMessage = "Hata: ${e.message}";
        _isAuthenticating = false;
      });
      return;
    }

    if (!mounted) return;

    if (authenticated) {
      _navigateToHome();
    } else {
      setState(() {
        _isAuthenticating = false;
        _statusMessage = "Giriş Başarısız. Tekrar Deneyin.";
      });
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 100, color: AppTheme.primary),
              const SizedBox(height: 30),
              Text(
                "AI PassVault",
                style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 10),
              Text(
                "Güvenli Bölge",
                style: GoogleFonts.outfit(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 50),
              if (_isAuthenticating)
                const CircularProgressIndicator(color: AppTheme.primary)
              else
                GlassCard(
                  child: Column(
                    children: [
                      Text(
                        _statusMessage,
                        style: const TextStyle(color: Colors.white70),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _authenticate,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.black,
                        ),
                        child: const Text("Tekrar Dene"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
