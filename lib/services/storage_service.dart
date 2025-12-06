import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/password_model.dart';

class StorageService {
  static const String _boxName = 'passwords';
  static const String _keyName = 'hive_encryption_key';

  // Kutuyu dışarıdan çağırmak için
  Box get _box => Hive.box(_boxName);
  final _uuid = const Uuid();

  // --- 🛡️ KRİTİK: BAŞLATMA VE ŞİFRELEME ---
  static Future<void> init() async {
    await Hive.initFlutter();

    // 1. Güvenli Depolamayı (Keystore/Keychain) Hazırla
    const secureStorage = FlutterSecureStorage();

    // 2. Daha önce oluşturulmuş bir anahtarımız var mı?
    String? encryptionKeyString = await secureStorage.read(key: _keyName);

    List<int> encryptionKey;

    if (encryptionKeyString == null) {
      // 3. Yoksa: Yeni, benzersiz bir şifreleme anahtarı oluştur
      print("🔐 Yeni AES-256 Anahtarı Oluşturuluyor...");
      encryptionKey = Hive.generateSecureKey();

      // 4. Bu anahtarı güvenli depoya kaydet (String'e çevirerek)
      await secureStorage.write(
          key: _keyName, value: base64UrlEncode(encryptionKey));
    } else {
      // 3. Varsa: Mevcut anahtarı oku ve listeye çevir
      print("🔑 Mevcut Anahtar ile Kasa Açılıyor...");
      encryptionKey = base64Url.decode(encryptionKeyString);
    }

    // 5. Kutuyu bu anahtarla (AES-256) ŞİFRELİ olarak aç
    await Hive.openBox(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  // --- STANDART İŞLEMLER (Aynı Kaldı) ---

  // Tüm şifreleri getir
  List<PasswordModel> getAllPasswords() {
    List<PasswordModel> passwords = [];
    // Kutunun açık olup olmadığını kontrol et (Güvenlik önlemi)
    if (Hive.isBoxOpen(_boxName)) {
      for (var i = 0; i < _box.length; i++) {
        final map = _box.getAt(i) as Map<dynamic, dynamic>;
        passwords.add(PasswordModel.fromMap(map));
      }
      passwords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return passwords;
  }

  // Yeni şifre kaydet
  Future<void> savePassword(String title, String password, String strengthLabel,
      int strengthColor) async {
    final newPassword = PasswordModel(
      id: _uuid.v4(),
      title: title.isEmpty ? "İsimsiz Kayıt" : title,
      password: password,
      createdAt: DateTime.now(),
      strengthLabel: strengthLabel,
      strengthColor: strengthColor,
    );

    await _box.add(newPassword.toMap());
  }

  // Şifre sil
  Future<void> deletePassword(int index) async {
    await _box.deleteAt(index);
  }
}
