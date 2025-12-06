class PasswordModel {
  final String id;
  final String title; // Örn: "Instagram Hesabım"
  final String password;
  final DateTime createdAt;
  final String strengthLabel; // "Güçlü", "Zayıf" vb.
  final int strengthColor; // Renk kodu

  PasswordModel({
    required this.id,
    required this.title,
    required this.password,
    required this.createdAt,
    required this.strengthLabel,
    required this.strengthColor,
  });

  // Veritabanına kaydederken JSON'a çevir (Map)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'password': password,
      'createdAt': createdAt.toIso8601String(),
      'strengthLabel': strengthLabel,
      'strengthColor': strengthColor,
    };
  }

  // Veritabanından okurken Nesneye çevir
  factory PasswordModel.fromMap(Map<dynamic, dynamic> map) {
    return PasswordModel(
      id: map['id'],
      title: map['title'],
      password: map['password'],
      createdAt: DateTime.parse(map['createdAt']),
      strengthLabel: map['strengthLabel'],
      strengthColor: map['strengthColor'],
    );
  }
}
