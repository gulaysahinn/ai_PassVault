import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_theme.dart';
import '../services/password_generator.dart';
import '../services/storage_service.dart';
import '../widgets/custom_widgets.dart';
import 'vault_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();

  double _length = 12;
  bool _useUpper = true;
  bool _useLower = true;
  bool _useNumbers = true;
  bool _useSymbols = true;

  String _password = "Şifre Bekleniyor";
  Map<String, dynamic> _strength = {"label": "Yok", "color": 0xFF9E9E9E};

  void _generate() {
    setState(() {
      _password = PasswordGenerator.generate(
        length: _length.toInt(),
        useUpper: _useUpper,
        useLower: _useLower,
        useNumbers: _useNumbers,
        useSymbols: _useSymbols,
      );
      _strength = PasswordGenerator.analyzeStrength(_password);
    });
  }

  void _copyToClipboard() {
    if (_password == "Şifre Bekleniyor" || _password == "Seçim Yapınız") return;
    Clipboard.setData(ClipboardData(text: _password));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text("Şifre Kopyalandı!"),
          backgroundColor: AppTheme.secondary),
    );
  }

  void _showSaveDialog() {
    if (_password == "Şifre Bekleniyor" || _password == "Seçim Yapınız") return;

    final TextEditingController titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title:
            const Text("Şifreyi Kaydet", style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: titleController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Örn: Instagram, E-Okul...",
            hintStyle: TextStyle(color: Colors.grey),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey)),
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppTheme.primary)),
          ),
        ),
        actions: [
          TextButton(
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child: const Text("KAYDET", style: TextStyle(color: Colors.black)),
            onPressed: () {
              _storage.savePassword(
                titleController.text,
                _password,
                _strength['label'],
                _strength['color'],
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Şifre Kasaya Eklendi! ✅"),
                    backgroundColor: AppTheme.secondary),
              );
            },
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
        title: Text("AI PassVault",
            style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: AppTheme.primary),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const VaultScreen()));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("OLUŞTURULAN ŞİFRE",
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 12)),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Color(_strength['color']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Color(_strength['color'])),
                        ),
                        child: Text(
                          _strength['label'],
                          style: TextStyle(
                              color: Color(_strength['color']),
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: _copyToClipboard,
                    child: Text(
                      _password,
                      style: GoogleFonts.sourceCodePro(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _password == "Seçim Yapınız"
                            ? AppTheme.error
                            : Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, color: Colors.grey),
                        onPressed: _copyToClipboard,
                        tooltip: "Kopyala",
                      ),
                      const SizedBox(width: 20),
                      IconButton(
                        icon:
                            const Icon(Icons.save_alt, color: AppTheme.primary),
                        onPressed: _showSaveDialog,
                        tooltip: "Kasaya Kaydet",
                      ),
                    ],
                  )
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 30),
            Text("Yapılandırma",
                style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 15),
            GlassCard(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Uzunluk",
                          style: TextStyle(color: Colors.white70)),
                      Text("${_length.toInt()}",
                          style: const TextStyle(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                    ],
                  ),
                  Slider(
                    value: _length,
                    min: 4,
                    max: 32,
                    activeColor: AppTheme.primary,
                    inactiveColor: Colors.grey[800],
                    onChanged: (v) => setState(() => _length = v),
                  ),
                  const Divider(color: Colors.white10),
                  OptionRow(
                      label: "Büyük Harfler (A-Z)",
                      value: _useUpper,
                      onChanged: (v) => setState(() => _useUpper = v)),
                  OptionRow(
                      label: "Küçük Harfler (a-z)",
                      value: _useLower,
                      onChanged: (v) => setState(() => _useLower = v)),
                  OptionRow(
                      label: "Rakamlar (0-9)",
                      value: _useNumbers,
                      onChanged: (v) => setState(() => _useNumbers = v)),
                  OptionRow(
                      label: "Semboller (!@#)",
                      value: _useSymbols,
                      onChanged: (v) => setState(() => _useSymbols = v)),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).moveY(begin: 20, end: 0),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _generate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                elevation: 15,
                shadowColor: AppTheme.primary.withOpacity(0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.auto_awesome),
                  const SizedBox(width: 10),
                  Text("ŞİFRE OLUŞTUR",
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
            ).animate().shimmer(delay: 1.seconds, duration: 2.seconds),
          ],
        ),
      ),
    );
  }
}
