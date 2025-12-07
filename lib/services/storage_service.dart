import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../core/password_model.dart';

class StorageService {
  static const String _boxName = 'passwords';
  static const String _keyName = 'hive_encryption_key';

  Box get _box => Hive.box(_boxName);
  final _uuid = const Uuid();

  static Future<void> init() async {
    await Hive.initFlutter();

    const secureStorage = FlutterSecureStorage();

    String? encryptionKeyString = await secureStorage.read(key: _keyName);

    List<int> encryptionKey;

    if (encryptionKeyString == null) {
      print("🔐 Yeni AES-256 Anahtarı Oluşturuluyor...");
      encryptionKey = Hive.generateSecureKey();

      await secureStorage.write(
          key: _keyName, value: base64UrlEncode(encryptionKey));
    } else {
      print("🔑 Mevcut Anahtar ile Kasa Açılıyor...");
      encryptionKey = base64Url.decode(encryptionKeyString);
    }

    await Hive.openBox(
      _boxName,
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
  }

  List<PasswordModel> getAllPasswords() {
    List<PasswordModel> passwords = [];

    if (Hive.isBoxOpen(_boxName)) {
      for (var i = 0; i < _box.length; i++) {
        final map = _box.getAt(i) as Map<dynamic, dynamic>;
        passwords.add(PasswordModel.fromMap(map));
      }
      passwords.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return passwords;
  }

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

  Future<void> deletePassword(int index) async {
    await _box.deleteAt(index);
  }

  Future<void> editPassword(int index, PasswordModel updatedItem) async {
    await _box.putAt(index, updatedItem.toMap());
  }
}
