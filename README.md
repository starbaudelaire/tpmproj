# Jogjasplorasi

Flutter 3 app for a liquid-glass Yogyakarta tourism experience.

## Run

```bash
flutter pub get
flutter run
```

## Optional env vars

```bash
flutter run --dart-define=WEATHER_KEY=your_key
flutter run --dart-define=AI_KEY=your_key --dart-define=AI_BASE_URL=https://api.openai.com
```

If API keys are missing, weather, currency, and AI features fall back to realistic local stub data.
