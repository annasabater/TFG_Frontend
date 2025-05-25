// Configuración específica para web
import 'dart:html' as html;
import 'dart:js' as js;
import 'web_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Esta función carga el script de Google Maps API de forma asíncrona
void loadGoogleMapsScript() {
  final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    print('ERROR: GOOGLE_MAPS_API_KEY no está definida en el archivo .env');
    return;
  }

  // Actualiza el meta tag con la clave
  final metaTag = html.document.querySelector('meta[name="google-maps-api-key"]');
  if (metaTag != null) {
    metaTag.setAttribute('content', apiKey);
  }

  // Crea un script para cargar la API de Google Maps de forma asíncrona
  final script = html.ScriptElement()
    ..src = 'https://maps.googleapis.com/maps/api/js?key=$apiKey'
    ..type = 'text/javascript'
    ..async = true;
  
  html.document.head!.append(script);

  // También inyecta la clave API en window para acceso directo
  final injectScript = html.ScriptElement()
    ..innerHtml = '''
      window.googleMapsApiKey = "$apiKey";
    ''';
  html.document.head!.append(injectScript);
}

void setupWebGoogleMapsApi(String apiKey) {
  // Actualizar el meta tag para mayor seguridad
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
  
  // Inyecta la clave API en window
  final script = html.ScriptElement()
    ..innerHtml = '''
      window.googleMapsApiKey = "$apiKey";
    ''';
  html.document.head!.append(script);
}

class WebConfigImpl implements WebConfig {
  WebConfigImpl() {
    // Intentamos cargar el script de Google Maps si aún no se ha cargado
    if (!js.context.hasProperty('google') || 
        !(js.context['google'] != null && js.context['google'].hasProperty('maps'))) {
      loadGoogleMapsScript();
    }
  }

  @override
  String get googleMapsApiKey {
    // Primero intentamos obtener la clave API del objeto window usando JS interop
    if (js.context.hasProperty('googleMapsApiKey')) {
      final key = js.context['googleMapsApiKey'].toString();
      if (key.isNotEmpty) {
        return key;
      }
    }
    
    // Si no está disponible, la obtenemos del meta tag
    final metaTag = html.document.querySelector('meta[name="google-maps-api-key"]');
    if (metaTag != null) {
      final apiKey = metaTag.getAttribute('content');
      if (apiKey != null && apiKey.isNotEmpty) {
        return apiKey;
      }
    }
    
    // Si no encontramos la clave, intentamos obtenerla del .env
    final envKey = dotenv.env['GOOGLE_MAPS_API_KEY'];
    if (envKey != null && envKey.isNotEmpty) {
      // Cargar Google Maps si aún no se ha cargado
      loadGoogleMapsScript();
      return envKey;
    }
    
    // Si no encontramos la clave, devolvemos una cadena vacía
    return '';
  }
}

WebConfig getWebConfig() => WebConfigImpl(); 