// lib/geolocation.dart

// Si estamos en web (dart:html existe), usaremos geolocation_web.dart
// Si no (móvil), usaremos geolocation_mobile.dart
export 'geolocation_mobile.dart'
    if (dart.library.html) 'geolocation_web.dart';