abstract class WebConfig {
  static WebConfig? _instance;

  static WebConfig get instance {
    _instance ??= getWebConfig();
    return _instance!;
  }

  // Implementación que será reemplazada por plataformas específicas
  static WebConfig getWebConfig() {
    try {
      // Esta función será sobreescrita por la implementación de cada plataforma
      throw UnimplementedError('getWebConfig() no ha sido implementado');
    } catch (e) {
      print('Error en getWebConfig: $e');
      // Devuelve una implementación mínima para evitar errores
      return _FallbackWebConfig();
    }
  }

  String get googleMapsApiKey;
}

// Implementación de respaldo para evitar errores
class _FallbackWebConfig implements WebConfig {
  @override
  String get googleMapsApiKey => '';
} 