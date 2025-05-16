// geolocation_web.dart

import 'dart:async';                  // ← Necesario para Completer
import 'dart:html' as html;
import 'package:latlong2/latlong.dart';

/// Devuelve la posición web como un LatLng
Future<LatLng> getCurrentPosition() {
  final completer = Completer<LatLng>();
  html.window.navigator.geolocation
    .getCurrentPosition()
    .then((pos) {
      final coords = pos.coords!;
      completer.complete(
        LatLng(
          coords.latitude!.toDouble(),   // ← .toDouble() convierte num → double
          coords.longitude!.toDouble(),  // ← lo mismo aquí
        ),
      );
    })
    .catchError((e) => completer.completeError(e));
  return completer.future;
}
