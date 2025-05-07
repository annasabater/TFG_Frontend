import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Import condicional para web
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class MapaScreen extends StatefulWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  LatLng? _currentPosition;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    if (kIsWeb) {
      // WEB: usar la API JS
      try {
        html.window.navigator.geolocation.getCurrentPosition().then((pos) {
          setState(() {
            _currentPosition = LatLng(
              (pos.coords?.latitude as double?) ?? 41.3888,
              (pos.coords?.longitude as double?) ?? 2.159,
            );
            _loading = false;
          });
        }).catchError((e) {
          setState(() {
            _error = 'Permís de localització denegat o error en web.';
            _loading = false;
          });
        });
      } catch (e) {
        setState(() {
          _error = 'Error obtenint la localització (web): $e';
          _loading = false;
        });
      }
    } else {
      // MÓVIL: usar Geolocator
      try {
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }
        if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
          setState(() {
            _error = 'Permís de localització denegat.';
            _loading = false;
          });
          return;
        }
        final pos = await Geolocator.getCurrentPosition();
        setState(() {
          _currentPosition = LatLng(pos.latitude, pos.longitude);
          _loading = false;
        });
      } catch (e) {
        setState(() {
          _error = 'Error obtenint la localització: $e';
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : FlutterMap(
                  options: MapOptions(
                    center: _currentPosition,
                    zoom: 15,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    if (_currentPosition != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: _currentPosition!,
                            width: 60,
                            height: 60,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                          ),
                        ],
                      ),
                  ],
                ),
    );
  }
} 