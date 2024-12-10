class AppConfig {
  // Base URL untuk endpoint API
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://172.16.115.100/aquagrow/hidroponik/api',
  );
}
