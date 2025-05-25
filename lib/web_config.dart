abstract class WebConfig {
  static WebConfig? _instance;

  static WebConfig get instance {
    _instance ??= getWebConfig();
    return _instance!;
  }

  // Implementación que será sobreescrita en plataformas específicas
  static WebConfig getWebConfig() {
    // Esta implementación será reemplazada por la importación específica de la plataforma
    throw UnimplementedError('getWebConfig() no ha sido implementado');
  }

  String get googleMapsApiKey;
} 