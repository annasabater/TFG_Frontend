//lib/screens/mapa_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:SkyNet/geolocation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';
import 'package:SkyNet/widgets/map_legend.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';

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
  List<Map<String, dynamic>> _suggestions = [];
  bool _searchLoading = false;
  FocusNode _searchFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
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

  void _onSearchChanged(String value) async {
    if (value.trim().isEmpty) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() => _searchLoading = true);
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(value)}&format=json&addressdetails=1&limit=5&countrycodes=es');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _suggestions = data.cast<Map<String, dynamic>>();
          _searchLoading = false;
        });
      } else {
        setState(() {
          _suggestions = [];
          _searchLoading = false;
        });
      }
    } catch (_) {
      setState(() {
        _suggestions = [];
        _searchLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa')),
      body: Stack(
        children: [
          Column(
            children: [
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
                              // Zonas de restricción de vuelo
                              CircleLayer(
                                circles: [
                                  // Aeropuerto de Barcelona (rojo)
                                  CircleMarker(
                                    point: const LatLng(41.2971, 2.0785), // Aeropuerto de Barcelona
                                    radius: 3360, // 4.8km * 0.7 = 3.36km
                                    useRadiusInMeter: true,
                                    color: Colors.red.withOpacity(0.6),
                                    borderColor: Colors.red,
                                    borderStrokeWidth: 2,
                                  ),
                                  // Centro de Barcelona (rojo)
                                  CircleMarker(
                                    point: const LatLng(41.3851, 2.1734), // Centro de Barcelona
                                    radius: 5400, // 5.4km
                                    useRadiusInMeter: true,
                                    color: Colors.red.withOpacity(0.6),
                                    borderColor: Colors.red,
                                    borderStrokeWidth: 2,
                                  ),
                                  // EETAC (verde)
                                  CircleMarker(
                                    point: const LatLng(41.2757, 1.9881), // EETAC
                                    radius: 492, // 0.492km (un 59% més petit)
                                    useRadiusInMeter: true,
                                    color: Colors.green.withOpacity(0.6),
                                    borderColor: Colors.green,
                                    borderStrokeWidth: 2,
                                  ),
                                  // Montseny (verde)
                                  CircleMarker(
                                    point: const LatLng(41.7667, 2.4000), // Montseny
                                    radius: 7200, // 7.2km
                                    useRadiusInMeter: true,
                                    color: Colors.green.withOpacity(0.6),
                                    borderColor: Colors.green,
                                    borderStrokeWidth: 2,
                                  ),
                                  // Collserola (verde)
                                  CircleMarker(
                                    point: const LatLng(41.4167, 2.1000), // Collserola
                                    radius: 5399, // Just per tocar el de Barcelona sense solapar
                                    useRadiusInMeter: true,
                                    color: Colors.green.withOpacity(0.6),
                                    borderColor: Colors.green,
                                    borderStrokeWidth: 2,
                                  ),
                                  // Creueta dels Aragalls (groc)
                                  CircleMarker(
                                    point: const LatLng(41.4181, 1.8417), // Creueta dels Aragalls
                                    radius: 3360, // 3.36km
                                    useRadiusInMeter: true,
                                    color: Colors.yellow.withOpacity(0.6),
                                    borderColor: Colors.yellow,
                                    borderStrokeWidth: 2,
                                  ),
                                ],
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
                            top: MediaQuery.of(context).size.height * 0.4,
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
          // Buscador petit a la part superior dreta
          Positioned(
            top: 16,
            right: 32,
            child: SizedBox(
              width: 350,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    decoration: InputDecoration(
                      hintText: 'Buscar lloc...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _onSearchChanged,
                  ),
                  if (_searchController.text.isNotEmpty && _suggestions.isNotEmpty && _searchFocus.hasFocus)
                    Container(
                      width: 350,
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final s = _suggestions[index];
                          final display = s['display_name'] ?? '';
                          return ListTile(
                            title: Text(display, maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () {
                              final lat = double.tryParse(s['lat'] ?? '');
                              final lon = double.tryParse(s['lon'] ?? '');
                              if (lat != null && lon != null) {
                                _mapController.move(LatLng(lat, lon), 16);
                              }
                              setState(() {
                                _searchController.text = display;
                                _suggestions = [];
                              });
                              _searchFocus.unfocus();
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getLocation,
            tooltip: 'Mi ubicació',
            child: const Icon(Icons.my_location),
            heroTag: 'my-location',
          ),
        ],
      ),
    );
  }
} 