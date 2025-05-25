abstract class WebConfig {
  static WebConfig? _instance;

  static WebConfig get instance {
    _instance ??= getWebConfig();
    return _instance!;
  }

  // Implementación definida en la plataforma específica
  static WebConfig getWebConfig();

  String get googleMapsApiKey;
} 