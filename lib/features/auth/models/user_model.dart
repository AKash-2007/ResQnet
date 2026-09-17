class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String gender;
  final bool availableToHelp;
  final String language;
  final String themeMode;

  const UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.gender,
    this.availableToHelp = false,
    this.language = 'en',
    this.themeMode = 'system',
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? gender,
    bool? availableToHelp,
    String? language,
    String? themeMode,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      gender: gender ?? this.gender,
      availableToHelp: availableToHelp ?? this.availableToHelp,
      language: language ?? this.language,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String? ?? '',
      gender: json['gender'] as String? ?? 'Not specified',
      availableToHelp: json['available_to_help'] as bool? ?? false,
      language: json['language'] as String? ?? 'en',
      themeMode: json['theme_mode'] as String? ?? 'system',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'gender': gender,
      'available_to_help': availableToHelp,
      'language': language,
      'theme_mode': themeMode,
    };
  }
}
