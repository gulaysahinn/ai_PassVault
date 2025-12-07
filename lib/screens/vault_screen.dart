import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/app_theme.dart';
import '../core/password_model.dart';
import '../services/storage_service.dart';
import '../services/password_generator.dart';
import '../widgets/custom_widgets.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final StorageService _storage = StorageService();

  String _searchQuery = "";
  String _selectedFilter = "Tümü";

  final Set<String> _visibleIds = {};

  final List<String> _filterOptions = [
    "Tümü",
    "Zayıf",
    "Orta",
    "Güçlü",
    "Mükemmel"
  ];

  // --- SİLME İŞLEMİ ---
  void _deletePassword(int index) async {
    HapticFeedback.mediumImpact();
    await _storage.deletePassword(index);
    setState(() {});
  }

  // --- SİLME ONAY PENCERESİ ---
  Future<bool?> _confirmDelete(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Silmek İstiyor musunuz?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          "Bu işlem geri alınamaz. Şifre kalıcı olarak silinecektir.",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Vazgeç", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("SİL", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- KOPYALAMA İŞLEMİ ---
  void _copyPassword(String password) {
    HapticFeedback.selectionClick();
    Clipboard.setData(ClipboardData(text: password));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Kopyalandı! 📋"), backgroundColor: AppTheme.secondary),
    );
  }

  // --- GÖRÜNÜRLÜK DEĞİŞTİRME ---
  void _toggleVisibility(String id) {
    HapticFeedback.lightImpact();
    setState(() {
      if (_visibleIds.contains(id)) {
        _visibleIds.remove(id);
      } else {
        _visibleIds.add(id);
      }
    });
  }

  // --- DÜZENLEME İŞLEMİ ---
  void _showEditDialog(int hiveIndex, PasswordModel item) {
    final TextEditingController titleController =
        TextEditingController(text: item.title);
    final TextEditingController passController =
        TextEditingController(text: item.password);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title:
            const Text("Kayıt Düzenle", style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Başlık",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primary)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: "Şifre",
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)),
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("İptal", style: TextStyle(color: Colors.grey)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
            child:
                const Text("GÜNCELLE", style: TextStyle(color: Colors.black)),
            onPressed: () {
              HapticFeedback.mediumImpact();
              var strength =
                  PasswordGenerator.analyzeStrength(passController.text);

              final updatedItem = PasswordModel(
                id: item.id,
                title: titleController.text,
                password: passController.text,
                createdAt: item.createdAt,
                strengthLabel: strength['label'],
                strengthColor: strength['color'],
              );

              _storage.editPassword(hiveIndex, updatedItem);
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text("Güncellendi! ✅"),
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
        title: Text("Şifre Kasası",
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => setState(() => _searchQuery = value),
                decoration: InputDecoration(
                  hintText: "Kasada Ara...",
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  border: InputBorder.none,
                  icon: Icon(Icons.search,
                      color: AppTheme.primary.withOpacity(0.7)),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchQuery.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () => setState(() => _searchQuery = ""),
                        ),
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.filter_list_rounded,
                          color: _selectedFilter == "Tümü"
                              ? Colors.grey
                              : AppTheme.secondary,
                        ),
                        onSelected: (String value) {
                          setState(() {
                            _selectedFilter = value;
                          });
                          HapticFeedback.selectionClick();
                        },
                        color: AppTheme.surface,
                        itemBuilder: (BuildContext context) {
                          return _filterOptions.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Row(
                                children: [
                                  Icon(
                                    choice == _selectedFilter
                                        ? Icons.check_circle
                                        : Icons.circle_outlined,
                                    color: choice == _selectedFilter
                                        ? AppTheme.primary
                                        : Colors.grey,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(choice,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                ],
                              ),
                            );
                          }).toList();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: Hive.box('passwords').listenable(),
              builder: (context, Box box, widget) {
                List<dynamic> rawList = box.values.toList();
                List<PasswordModel> allItems =
                    rawList.map((e) => PasswordModel.fromMap(e)).toList();

                allItems.sort((a, b) => b.createdAt.compareTo(a.createdAt));

                // --- FİLTRELEME MANTIĞI BURADA ---
                List<PasswordModel> filteredItems = allItems.where((item) {
                  // 1. Arama Metni
                  final matchesSearch = item.title
                      .toLowerCase()
                      .contains(_searchQuery.toLowerCase());

                  // 2. Kategori Filtresi (EMOJİ SORUNU ÇÖZÜMÜ)
                  bool matchesFilter = false;

                  if (_selectedFilter == "Tümü") {
                    matchesFilter = true;
                  } else {
                    matchesFilter =
                        item.strengthLabel.contains(_selectedFilter);
                  }

                  return matchesSearch && matchesFilter;
                }).toList();
                // --------------------------------

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.filter_list_off,
                            size: 80, color: Colors.grey[800]),
                        const SizedBox(height: 10),
                        Text(
                          _selectedFilter == "Tümü"
                              ? "Henüz kayıt yok"
                              : "$_selectedFilter şifre bulunamadı",
                          style: GoogleFonts.outfit(
                              color: Colors.grey, fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final originalHiveIndex = rawList
                        .indexOf(rawList.firstWhere((e) => e['id'] == item.id));

                    final isVisible = _visibleIds.contains(item.id);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Dismissible(
                        key: Key(item.id),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await _confirmDelete(context);
                        },
                        onDismissed: (_) => _deletePassword(originalHiveIndex),
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: AppTheme.error,
                            borderRadius: BorderRadius.circular(24),
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
                                  color: Color(item.strengthColor)
                                      .withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.key,
                                    color: Color(item.strengthColor)),
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
                                      isVisible ? item.password : "••••••••",
                                      style: isVisible
                                          ? GoogleFonts.sourceCodePro(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500)
                                          : TextStyle(
                                              color: Colors.grey[400],
                                              fontSize: 14,
                                              letterSpacing: 2),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  isVisible
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppTheme.primary,
                                  size: 20,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: isVisible ? "Gizle" : "Göster",
                                onPressed: () => _toggleVisibility(item.id),
                              ),
                              const SizedBox(width: 15),
                              IconButton(
                                icon: const Icon(Icons.copy,
                                    color: Colors.grey, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: "Kopyala",
                                onPressed: () => _copyPassword(item.password),
                              ),
                              const SizedBox(width: 15),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.grey, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                tooltip: "Düzenle",
                                onPressed: () =>
                                    _showEditDialog(originalHiveIndex, item),
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
          ),
        ],
      ),
    );
  }
}
