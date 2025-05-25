//lib/screens/mapa_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:SkyNet/geolocation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';

class MapaScreen extends StatefulWidget {
  const MapaScreen({Key? key}) : super(key: key);

  @override
  State<MapaScreen> createState() => _MapaScreenState();
}

class _MapaScreenState extends State<MapaScreen> {
  LatLng? _currentPosition;
  bool _loading = true;
  String? _error;
  final MapController _mapController = MapController();
  bool _mapInitialized = false;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() => _loading = true);
    try {
      final latLng = await getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = latLng as LatLng?;
          _loading = false;
        });
        
        // Centrar el mapa en la ubicación actual
        if (_currentPosition != null && _mapInitialized) {
          _mapController.move(_currentPosition!, 15);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error obteniendo ubicación: $e';
          _loading = false;
        });
      }
      print('Error obteniendo ubicación: $e');
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
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentPosition ?? const LatLng(41.3851, 2.1734), // Barcelona por defecto
                    zoom: 15,
                    onMapReady: () {
                      setState(() {
                        _mapInitialized = true;
                      });
                      if (_currentPosition != null) {
                        _mapController.move(_currentPosition!, 15);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      // No usar subdominios con OSM para evitar advertencias
                      // subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.example.SkyNet',
                      tileProvider: NetworkTileProvider(),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            onPressed: () {
              context.go('/google-map');
            },
            label: const Text('Mapa Google'),
            icon: const Icon(Icons.map),
            heroTag: 'google-map',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getLocation,
            tooltip: 'Mi ubicación',
            child: const Icon(Icons.my_location),
            heroTag: 'my-location',
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    super.dispose();
  }
} 