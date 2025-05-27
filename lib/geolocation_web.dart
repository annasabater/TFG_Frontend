// geolocation_web.dart

import 'dart:async';
import 'dart:html' as html;
import 'package:latlong2/latlong.dart';

/// Devuelve la posición web como un LatLng
Future<LatLng> getCurrentPosition() {
  final completer = Completer<LatLng>();
  bool isCompleted = false;
  
  try {
    // Solicitar la ubicación actual con el método básico
    html.window.navigator.geolocation.getCurrentPosition().then((pos) {
      try {
        if (!isCompleted) {
          if (pos.coords != null) {
      final coords = pos.coords!;
            isCompleted = true;
      completer.complete(
        LatLng(
                coords.latitude!.toDouble(),
                coords.longitude!.toDouble(),
              ),
            );
          } else {
            isCompleted = true;
            completer.completeError('Coordenadas no disponibles');
          }
        }
      } catch (e) {
        if (!isCompleted) {
          isCompleted = true;
          completer.completeError('Error al procesar coordenadas: $e');
        }
      }
    }).catchError((error) {
      if (!isCompleted) {
        isCompleted = true;
        completer.completeError('Error al obtener ubicación: $error');
      }
    });
    
    // Establecer un timeout
    Future.delayed(const Duration(seconds: 15), () {
      if (!isCompleted) {
        isCompleted = true;
        completer.completeError('Timeout al obtener la ubicación');
      }
    });
  } catch (e) {
    if (!isCompleted) {
      isCompleted = true;
      completer.completeError('Error al inicializar geolocalización: $e');
    }
  }
  
  return completer.future;
}
