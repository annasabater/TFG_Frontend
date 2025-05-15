// lib/geolocation_mobile.dart

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart'; // o el paquete que uses para LatLng

/// Devuelve la posición usando Geolocator en iOS/Android.
Future<LatLng> getCurrentPosition() async {
  // 1) Comprueba servicios y permisos...
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    throw Exception('Servicios de localización desactivados.');
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.denied ||
      permission == LocationPermission.deniedForever) {
    throw Exception('Permiso de localización denegado.');
  }
  
  Position pos = await Geolocator.getCurrentPosition(
    desiredAccuracy: LocationAccuracy.high,
  );

  // ¡Aquí es donde mapeas Position → LatLng!
  return LatLng(pos.latitude, pos.longitude);
}
