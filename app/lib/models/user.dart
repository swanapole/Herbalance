class AppUser {
  final String id;
  final String email;
  final String region;
  final String language;
  final Map<String, dynamic> consents;

  const AppUser({
    required this.id,
    required this.email,
    required this.region,
    required this.language,
    required this.consents,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        region: json['region'] as String? ?? 'KE',
        language: json['language'] as String? ?? 'en',
        consents: (json['consents'] as Map?)?.cast<String, dynamic>() ?? const {},
      );
}
