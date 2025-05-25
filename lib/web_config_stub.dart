// Stub para plataformas no web
import 'web_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void setupWebGoogleMapsApi(String apiKey) {
  // No hace nada en plataformas no web
}

class WebConfigImpl implements WebConfig {
  @override
  String get googleMapsApiKey {
    // En plataformas no web, obtenemos la clave directamente del .env
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }
}

WebConfig getWebConfig() => WebConfigImpl(); 