import 'dart:math';

class PasswordGenerator {
  // Şifre Üretme Fonksiyonu
  static String generate({
    required int length,
    required bool useUpper,
    required bool useLower,
    required bool useNumbers,
    required bool useSymbols,
  }) {
    const String _charsLower = "abcdefghijklmnopqrstuvwxyz";
    const String _charsUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const String _charsNumbers = "0123456789";
    const String _charsSymbols = "!@#\$%^&*()_+-=[]{}|;:,.<>?";

    String allowedChars = "";
    if (useLower) allowedChars += _charsLower;
    if (useUpper) allowedChars += _charsUpper;
    if (useNumbers) allowedChars += _charsNumbers;
    if (useSymbols) allowedChars += _charsSymbols;

    if (allowedChars.isEmpty) return "Seçim Yapınız";

    final Random rnd =
        Random.secure(); // Kriptografik olarak güvenli rastgele sayı
    return List.generate(length, (index) {
      return allowedChars[rnd.nextInt(allowedChars.length)];
    }).join('');
  }

  // Şifre Gücü Analizi (Basit Entropi Hesabı)
  static Map<String, dynamic> analyzeStrength(String password) {
    if (password.isEmpty || password == "Seçim Yapınız")
      return {"score": 0, "label": "Yok"};

    int poolSize = 0;
    if (password.contains(RegExp(r'[a-z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[A-Z]'))) poolSize += 26;
    if (password.contains(RegExp(r'[0-9]'))) poolSize += 10;
    if (password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) poolSize += 32;

    // Entropi formülü: Length * log2(poolSize)
    double entropy = password.length * (log(poolSize) / log(2));

    if (entropy < 28)
      return {"score": 1, "label": "Zayıf 🔴", "color": 0xFFCF6679};
    if (entropy < 36)
      return {"score": 2, "label": "Orta 🟠", "color": 0xFFFFB74D};
    if (entropy < 60)
      return {"score": 3, "label": "Güçlü 🟢", "color": 0xFF81C784};
    return {"score": 4, "label": "Mükemmel 🚀", "color": 0xFF03DAC6};
  }
}
