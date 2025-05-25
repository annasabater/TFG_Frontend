// Configuración específica para web
import 'dart:html' as html;
import 'web_config.dart';

void setupWebGoogleMapsApi(String apiKey) {
  // Inyectar la clave API en el objeto window
  final script = '''
    window.googleMapsApiKey = "$apiKey";
  ''';
  final scriptElement = html.ScriptElement()..innerHtml = script;
  html.document.head!.append(scriptElement);
}

class WebConfigImpl implements WebConfig {
  @override
  String get googleMapsApiKey {
    // Obtiene la clave API del atributo meta en el HTML
    final metaTag = html.document.querySelector('meta[name="google-maps-api-key"]');
    if (metaTag != null) {
      return metaTag.getAttribute('content') ?? '';
    }
    return '';
  }
}

WebConfig getWebConfig() => WebConfigImpl(); 