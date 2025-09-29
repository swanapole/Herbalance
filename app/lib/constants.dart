class AppConfig {
  // Update this if your backend host changes.
  // For Android emulator to reach host machine, you may use 10.0.2.2 instead of localhost.
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:4000',
  );
}
