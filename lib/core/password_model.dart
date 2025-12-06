class PasswordModel {
  final String id;
  final String title;
  final String password;
  final DateTime createdAt;
  final String strengthLabel;
  final int strengthColor;

  PasswordModel({
    required this.id,
    required this.title,
    required this.password,
    required this.createdAt,
    required this.strengthLabel,
    required this.strengthColor,
  });

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
