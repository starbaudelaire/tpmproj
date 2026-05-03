import '../config/environment_config.dart';

abstract final class ApiConstants {
  static String get backendBaseUrl => EnvironmentConfig.backendBaseUrl;

  static const authTokenKey = 'auth_token';

  static const weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  /// ExchangeRate API v4 public endpoint.
  /// Endpoint ini tidak membutuhkan API key.
  static const currencyBaseUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';

  static const aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://openrouter.ai/api',
  );

  static const weatherApiKey = String.fromEnvironment(
    'WEATHER_KEY',
    defaultValue: '',
  );

  static const currencyApiKey = String.fromEnvironment(
    'CURRENCY_KEY',
    defaultValue: '',
  );

  static const aiApiKey = String.fromEnvironment('AI_KEY', defaultValue: '');

  static const aiModel = String.fromEnvironment(
    'AI_MODEL',
    defaultValue: 'openai/gpt-4o-mini',
  );
}
