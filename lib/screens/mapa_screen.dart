//lib/screens/mapa_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:SkyNet/geolocation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:SkyNet/widgets/map_legend.dart';

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
  double _currentZoom = 15.0;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
        if (_currentPosition != null && _mapInitialized && mounted) {
          _mapController.move(_currentPosition!, _currentZoom);
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

  void _zoomIn() {
    if (_mapInitialized && mounted) {
      setState(() {
        _currentZoom = _currentZoom + 1;
        if (_currentZoom > 18) _currentZoom = 18;
      });
      _mapController.move(_mapController.center, _currentZoom);
    }
  }

  void _zoomOut() {
    if (_mapInitialized && mounted) {
      setState(() {
        _currentZoom = _currentZoom - 1;
        if (_currentZoom < 3) _currentZoom = 3;
      });
      _mapController.move(_mapController.center, _currentZoom);
    }
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    
    final query = _searchController.text.trim();
    
    // En un entorno real, aquí se haría una llamada a un servicio de geocodificación
    // Por ahora, simplemente abrimos Google Maps con la búsqueda
    if (kIsWeb) {
      final url = 'https://www.openstreetmap.org/search?query=${Uri.encodeComponent(query)}';
      try {
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al buscar ubicación: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar lugar...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (_) => _searchLocation(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchLocation,
                  tooltip: 'Buscar',
                ),
              ],
            ),
          ),
          
          // Mapa
          Expanded(
            child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
                : Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          center: _currentPosition ?? const LatLng(41.3851, 2.1734), // Barcelona por defecto
                          zoom: _currentZoom,
                          onMapReady: () {
                            setState(() {
                              _mapInitialized = true;
                            });
                            if (_currentPosition != null && mounted) {
                              _mapController.move(_currentPosition!, _currentZoom);
                            }
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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
                      
                      // Leyenda
                      Positioned(
                        right: 16,
                        top: 16,
                        child: MapLegend(),
                      ),
                      
                      // Botones de zoom
                      Positioned(
                        left: 16,
                        bottom: 90,
                        child: Column(
                          children: [
                            FloatingActionButton(
                              mini: true,
                              onPressed: _zoomIn,
                              child: const Icon(Icons.add),
                              heroTag: 'zoom-in',
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              mini: true,
                              onPressed: _zoomOut,
                              child: const Icon(Icons.remove),
                              heroTag: 'zoom-out',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getLocation,
        tooltip: 'Mi ubicación',
        child: const Icon(Icons.my_location),
        heroTag: 'my-location',
      ),
    );
  }
} 