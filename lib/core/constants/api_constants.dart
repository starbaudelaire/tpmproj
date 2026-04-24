abstract final class ApiConstants {
  static const weatherBaseUrl =
      'https://api.openweathermap.org/data/2.5/weather';
  static const currencyBaseUrl =
      'https://api.exchangerate-api.com/v4/latest/USD';
  static const aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://api.openai.com',
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
    defaultValue: 'gpt-4o-mini',
  );
}
