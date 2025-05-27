// Configuración específica para web
import 'dart:html' as html;
import 'dart:js' as js;
import 'web_config.dart';

// Esta función carga el script de Google Maps API de forma asíncrona
void loadGoogleMapsScript() {
  try {
    // Intentamos obtener la API key del meta tag
    final metaTag = html.document.querySelector('meta[name="google-maps-api-key"]');
    String apiKey = '';
    
    if (metaTag != null) {
      final content = metaTag.getAttribute('content');
      if (content != null && content.isNotEmpty) {
        apiKey = content;
      }
    }
    
    if (apiKey.isEmpty) {
      print('ERROR: No se pudo obtener la clave API de Google Maps');
      return;
    }

    // Comprueba si el script ya está cargado
    final existingScript = html.document.querySelector('script[src*="maps.googleapis.com"]');
    if (existingScript != null) {
      print('Script de Google Maps ya cargado');
      return;
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
    
    print('Script de Google Maps cargado correctamente');
  } catch (e) {
    print('Error al cargar el script de Google Maps: $e');
  }
}

void setupWebGoogleMapsApi(String apiKey) {
  try {
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
    
    print('API key configurada: $apiKey');
  } catch (e) {
    print('Error al configurar la API key: $e');
  }
}

// Configurar el iframe de Google Maps
void setupGoogleMapIframe(int id, double lat, double lng, String apiKey) {
  try {
    // Llamar a la función JavaScript definida en index.html
    js.context.callMethod('setupGoogleMapIframe', [id, lat, lng, apiKey]);
    print('Iframe de Google Maps configurado');
  } catch (e) {
    print('Error al configurar iframe de Google Maps: $e');
  }
}

class WebConfigImpl implements WebConfig {
  WebConfigImpl() {
    // Intentamos cargar el script de Google Maps si aún no se ha cargado
    try {
      final existingScript = html.document.querySelector('script[src*="maps.googleapis.com"]');
      final hasGoogleProperty = js.context.hasProperty('google');
      
      if (existingScript == null && !hasGoogleProperty) {
        print('Cargando script de Google Maps...');
        loadGoogleMapsScript();
      } else {
        print('Google Maps ya está disponible o script ya cargado');
      }
    } catch (e) {
      print('Error al verificar Google Maps: $e');
      loadGoogleMapsScript(); // Intentar cargar de todos modos
    }
  }

  @override
  String get googleMapsApiKey {
    try {
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
      
      print('No se encontró la clave API de Google Maps');
      return '';
    } catch (e) {
      print('Error al obtener la clave API: $e');
      return '';
    }
  }
}

WebConfig getWebConfig() {
  try {
    return WebConfigImpl();
  } catch (e) {
    print('Error al crear WebConfigImpl: $e');
    throw e;
  }
} 