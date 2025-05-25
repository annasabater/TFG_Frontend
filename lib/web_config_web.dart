// Configuración específica para web
import 'dart:html' as html;
import 'dart:js' as js;
import 'web_config.dart';

void setupWebGoogleMapsApi(String apiKey) {
  // Inyectar la clave API en el objeto window
  final script = '''
    window.googleMapsApiKey = "$apiKey";
  ''';
  final scriptElement = html.ScriptElement()..innerHtml = script;
  html.document.head!.append(scriptElement);
  
  // También actualizar el meta tag para mayor seguridad
  final metaTag = html.document.querySelector('meta[name="google-maps-api-key"]');
  if (metaTag != null) {
    metaTag.setAttribute('content', apiKey);
  } else {
    // Si no existe el meta tag, lo creamos
    final newMetaTag = html.MetaElement()
      ..name = 'google-maps-api-key'
      ..content = apiKey;
    html.document.head!.append(newMetaTag);
  }
}

class WebConfigImpl implements WebConfig {
  @override
  String get googleMapsApiKey {
    // Primero intentamos obtener la clave API del objeto window usando JS interop
    if (js.context.hasProperty('googleMapsApiKey')) {
      return js.context['googleMapsApiKey'].toString();
    }
    
    // Si no está disponible, la obtenemos del meta tag
    final metaTag = html.document.querySelector('meta[name="google-maps-api-key"]');
    if (metaTag != null) {
      final apiKey = metaTag.getAttribute('content');
      if (apiKey != null && apiKey.isNotEmpty && apiKey != '\$GOOGLE_MAPS_API_KEY') {
        return apiKey;
      }
    }
    
    // Si no encontramos la clave, devolvemos una cadena vacía
    return '';
  }
}

WebConfig getWebConfig() => WebConfigImpl(); 