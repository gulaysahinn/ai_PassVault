import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/app_theme.dart';
import '../core/password_model.dart';
import '../services/storage_service.dart';
import '../widgets/custom_widgets.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final StorageService _storage = StorageService();

  void _deletePassword(int index) async {
    await _storage.deletePassword(index);
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Şifre Silindi"), backgroundColor: AppTheme.error),
    );
  }

  void _copyPassword(String password) {
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: const Text("Kopyalandı!"),
          backgroundColor: AppTheme.secondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Şifre Kasası",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('passwords').listenable(),
        builder: (context, Box box, widget) {
          List<dynamic> rawList = box.values.toList();
          List<PasswordModel> items =
              rawList.map((e) => PasswordModel.fromMap(e)).toList();
          items.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_open_rounded,
                      size: 80, color: Colors.grey[800]),
                  const SizedBox(height: 10),
                  Text("Kasa Boş",
                      style:
                          GoogleFonts.outfit(color: Colors.grey, fontSize: 18)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final originalHiveIndex = rawList
                  .indexOf(rawList.firstWhere((e) => e['id'] == item.id));

              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Dismissible(
                  key: Key(item.id),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => _deletePassword(originalHiveIndex),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.error,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Color(item.strengthColor).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(Icons.key, color: Color(item.strengthColor)),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                "••••••••",
                                style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                    letterSpacing: 2),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy, color: AppTheme.primary),
                          onPressed: () => _copyPassword(item.password),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
