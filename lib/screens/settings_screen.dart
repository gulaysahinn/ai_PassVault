import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // HapticFeedback
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart'; // Verileri silmek için
import 'package:flutter_animate/flutter_animate.dart';

import '../core/app_theme.dart';
import '../widgets/custom_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Bu ayarları ileride Hive'da "settings" kutusunda tutabilirsin.
  bool _biometricEnabled = false;
  bool _soundEnabled = true;

  // --- TÜM VERİLERİ SİLME FONKSİYONU ---
  void _clearAllData() {
    HapticFeedback.heavyImpact(); // Titreşim

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title:
            const Text("DİKKAT! ⚠️", style: TextStyle(color: AppTheme.error)),
        content: const Text(
          "Tüm şifreleriniz kalıcı olarak silinecek. Bu işlem geri alınamaz!\n\nDevam etmek istiyor musunuz?",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              // SİLME İŞLEMİ
              var box = Hive.box('passwords');
              await box.clear(); // Tüm veriyi uçurur

              Navigator.pop(context); // Dialogu kapat

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Tüm veriler temizlendi."),
                  backgroundColor: AppTheme.secondary,
                ),
              );
            },
            child:
                const Text("EVET, SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Ayarlar",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BÖLÜM 1: GÜVENLİK ---
            _buildSectionHeader("Güvenlik"),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: AppTheme.primary,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    title: const Text("Biyometrik Giriş",
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text("Parmak izi veya FaceID",
                        style: TextStyle(color: Colors.grey)),
                    secondary:
                        const Icon(Icons.fingerprint, color: AppTheme.primary),
                    value: _biometricEnabled,
                    onChanged: (val) {
                      setState(() => _biometricEnabled = val);
                      HapticFeedback.lightImpact();
                      // Buraya ileride LocalAuth entegrasyonu gelecek
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- BÖLÜM 2: GENEL ---
            _buildSectionHeader("Genel"),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    activeColor: AppTheme.secondary,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    title: const Text("Uygulama Sesleri",
                        style: TextStyle(color: Colors.white)),
                    secondary:
                        const Icon(Icons.volume_up, color: AppTheme.secondary),
                    value: _soundEnabled,
                    onChanged: (val) {
                      setState(() => _soundEnabled = val);
                      HapticFeedback.lightImpact();
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // --- BÖLÜM 3: VERİ YÖNETİMİ (TEHLİKELİ) ---
            _buildSectionHeader("Veri Yönetimi"),
            GlassCard(
              padding: EdgeInsets.zero,
              child: ListTile(
                onTap: _clearAllData,
                leading:
                    const Icon(Icons.delete_forever, color: AppTheme.error),
                title: const Text("Tüm Verileri Temizle",
                    style: TextStyle(
                        color: AppTheme.error, fontWeight: FontWeight.bold)),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 14, color: Colors.grey),
              ),
            ),

            const SizedBox(height: 25),

            // --- BÖLÜM 4: HAKKINDA ---
            Center(
              child: Column(
                children: [
                  const Icon(Icons.lock_person, size: 40, color: Colors.grey),
                  const SizedBox(height: 10),
                  Text("AI PassVault",
                      style: GoogleFonts.outfit(
                          color: Colors.white, fontSize: 18)),
                  Text("v1.0.0 Beta",
                      style: GoogleFonts.sourceCodePro(color: Colors.grey)),
                  const SizedBox(height: 5),
                  const Text("Gülay ŞAHİN © 2025",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}
