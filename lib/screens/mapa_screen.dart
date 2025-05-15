//lib/screens/mapa_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:SkyNet/geolocation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;



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

  _getLocation() async {
  setState(() => _loading = true);
  try {
    final latLng = await getCurrentPosition();
    setState(() {
      _currentPosition = latLng as LatLng?;
      _loading = false;
    });
  } catch (e) {
    setState(() {
      _error = 'Error obteniendo ubicación: $e';
      _loading = false;
    });
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