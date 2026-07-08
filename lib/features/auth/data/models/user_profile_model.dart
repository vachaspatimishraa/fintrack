class UserProfileModel {
  final String userId;
  final String displayName;
  final String email;
  final String? photoUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastLogin;
  final String preferredCurrency;
  final String preferredTheme;
  final String language;

  UserProfileModel({
    required this.userId,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.createdAt,
    required this.updatedAt,
    required this.lastLogin,
    this.preferredCurrency = 'USD',
    this.preferredTheme = 'system',
    this.language = 'en',
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['user_id'] as String? ?? json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      photoUrl: json['photo_url'] as String?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : DateTime.now(),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login'] as String) : DateTime.now(),
      preferredCurrency: json['preferred_currency'] as String? ?? 'USD',
      preferredTheme: json['preferred_theme'] as String? ?? 'system',
      language: json['language'] as String? ?? 'en',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'display_name': displayName,
      'email': email,
      'photo_url': photoUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'last_login': lastLogin.toIso8601String(),
      'preferred_currency': preferredCurrency,
      'preferred_theme': preferredTheme,
      'language': language,
    };
  }

  UserProfileModel copyWith({
    String? userId,
    String? displayName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLogin,
    String? preferredCurrency,
    String? preferredTheme,
    String? language,
  }) {
    return UserProfileModel(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLogin: lastLogin ?? this.lastLogin,
      preferredCurrency: preferredCurrency ?? this.preferredCurrency,
      preferredTheme: preferredTheme ?? this.preferredTheme,
      language: language ?? this.language,
    );
  }
}
