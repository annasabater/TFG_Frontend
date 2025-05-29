//lib/screens/mapa_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:SkyNet/geolocation.dart';
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
  FocusNode _searchFocus = FocusNode();
  String? _selectedColor; // Nuevo: color seleccionado para el filtro
  
  final Map<String, Color> _colorOptions = {
    'Todos': Colors.transparent,
    'Rojo': Colors.red,
    'Verde': Colors.green,
    'Amarillo': Colors.yellow,
    'Ninguno': Colors.transparent, // Añadido para evitar error en el Dropdown
  };

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
    setState(() => _loading = true);
    final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(value)}&format=json&addressdetails=1&limit=5&countrycodes=es');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _suggestions = data.cast<Map<String, dynamic>>();
          _loading = false;
        });
      } else {
        setState(() {
          _suggestions = [];
          _loading = false;
        });
      }
    } catch (_) {
      setState(() {
        _suggestions = [];
        _loading = false;
      });
    }
  }

  // Nuevo: filtro visual con botones al lado de la leyenda
  Widget _buildColorFilterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor == 'Rojo' ? Colors.red : Colors.white,
            foregroundColor: _selectedColor == 'Rojo' ? Colors.white : Colors.red,
            side: const BorderSide(color: Colors.red),
          ),
          onPressed: () => setState(() => _selectedColor = 'Rojo'),
          child: const Text('Zona Restringida'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor == 'Verde' ? Colors.green : Colors.white,
            foregroundColor: _selectedColor == 'Verde' ? Colors.white : Colors.green,
            side: const BorderSide(color: Colors.green),
          ),
          onPressed: () => setState(() => _selectedColor = 'Verde'),
          child: const Text('Zona Permitida'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor == 'Amarillo' ? Colors.yellow : Colors.white,
            foregroundColor: _selectedColor == 'Amarillo' ? Colors.white : Colors.orange,
            side: const BorderSide(color: Colors.yellow),
          ),
          onPressed: () => setState(() => _selectedColor = 'Amarillo'),
          child: const Text('Zona de Precaución \n o con permiso especial'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor == 'Todos' ? Colors.blueGrey : Colors.white,
            foregroundColor: _selectedColor == 'Todos' ? Colors.white : Colors.blueGrey,
            side: const BorderSide(color: Colors.blueGrey),
          ),
          onPressed: () => setState(() => _selectedColor = 'Todos'),
          child: const Text('Mostrar Todas las Zonas'),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _selectedColor == 'Ninguno' ? Colors.black : Colors.white,
            foregroundColor: _selectedColor == 'Ninguno' ? Colors.white : Colors.black,
            side: const BorderSide(color: Colors.black),
          ),
          onPressed: () => setState(() => _selectedColor = 'Ninguno'),
          child: const Text('Limpiar Mapa'),
        ),
      ],
    );
  }

  void _onMapSecondaryTap(TapPosition tapPosition, LatLng latlng) {
    if (_currentPosition != null) {
      final distance = const Distance().as(LengthUnit.Meter, _currentPosition!, latlng);
      final distanceStr = distance >= 1000
          ? (distance / 1000).toStringAsFixed(2) + ' km'
          : distance.toStringAsFixed(0) + ' m';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Distancia desde tu ubicación: $distanceStr')),
      );
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
              // Filtro de color
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const Text('Filtrar zonas por color: '),
                    DropdownButton<String>(
                      value: _selectedColor ?? 'Todos',
                      items: _colorOptions.keys.map((String color) {
                        return DropdownMenuItem<String>(
                          value: color,
                          child: Text(color),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        setState(() {
                          _selectedColor = value;
                        });
                      },
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
                              onSecondaryTap: _onMapSecondaryTap, // <-- Añadido para click derecho
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
                                  if (_selectedColor == null || _selectedColor == 'Todos') ...[
                                    // Todos los círculos
                                    CircleMarker(
                                      point: const LatLng(41.2971, 2.0785),
                                      radius: 3360,
                                      useRadiusInMeter: true,
                                      color: Colors.red.withOpacity(0.6),
                                      borderColor: Colors.red,
                                      borderStrokeWidth: 2,
                                    ),
                                    CircleMarker(
                                      point: const LatLng(41.3851, 2.1734),
                                      radius: 5400,
                                      useRadiusInMeter: true,
                                      color: Colors.red.withOpacity(0.6),
                                      borderColor: Colors.red,
                                      borderStrokeWidth: 2,
                                    ),
                                    CircleMarker(
                                      point: const LatLng(41.2757, 1.9881),
                                      radius: 492,
                                      useRadiusInMeter: true,
                                      color: Colors.green.withOpacity(0.6),
                                      borderColor: Colors.green,
                                      borderStrokeWidth: 2,
                                    ),
                                    CircleMarker(
                                      point: const LatLng(41.7667, 2.4000),
                                      radius: 7200,
                                      useRadiusInMeter: true,
                                      color: Colors.green.withOpacity(0.6),
                                      borderColor: Colors.green,
                                      borderStrokeWidth: 2,
                                    ),
                                    CircleMarker(
                                      point: const LatLng(41.4167, 2.1000),
                                      radius: 5399,
                                      useRadiusInMeter: true,
                                      color: Colors.green.withOpacity(0.6),
                                      borderColor: Colors.green,
                                      borderStrokeWidth: 2,
                                    ),
                                    CircleMarker(
                                      point: const LatLng(41.4181, 1.8417),
                                      radius: 3360,
                                      useRadiusInMeter: true,
                                      color: Colors.yellow.withOpacity(0.6),
                                      borderColor: Colors.yellow,
                                      borderStrokeWidth: 2,
                                    ),
                                  ]
                                  else if (_selectedColor == 'Rojo') ...[
                                    CircleMarker(
                                      point: const LatLng(41.2971, 2.0785),
                                      radius: 3360,
                                      useRadiusInMeter: true,
                                      color: Colors.red.withOpacity(0.6),
                                      borderColor: Colors.red,
                                      borderStrokeWidth: 2,
                                    ),
                                    CircleMarker(
                                      point: const LatLng(41.3851, 2.1734),
                                      radius: 5400,
                                      useRadiusInMeter: true,
                                      color: Colors.red.withOpacity(0.6),
                                      borderColor: Colors.red,
                                      borderStrokeWidth: 2,
                                    ),
                                  ]
                                  else if (_selectedColor == 'Verde') ...[
                                    CircleMarker(
                                      point: const LatLng(41.2757, 1.9881),
                                      radius: 492,
                                      useRadiusInMeter: true,
                                      color: Colors.green.withOpacity(0.6),
                                      borderColor: Colors.green,
                                      borderStrokeWidth: 2,
                                    ),
                                    CircleMarker(
                                      point: const LatLng(41.7667, 2.4000),
                                      radius: 7200,
                                      useRadiusInMeter: true,
                                      color: Colors.green.withOpacity(0.6),
                                      borderColor: Colors.green,
                                      borderStrokeWidth: 2,
                                    ),
                                    CircleMarker(
                                      point: const LatLng(41.4167, 2.1000),
                                      radius: 5399,
                                      useRadiusInMeter: true,
                                      color: Colors.green.withOpacity(0.6),
                                      borderColor: Colors.green,
                                      borderStrokeWidth: 2,
                                    ),
                                  ]
                                  else if (_selectedColor == 'Amarillo') ...[
                                    CircleMarker(
                                      point: const LatLng(41.4181, 1.8417),
                                      radius: 3360,
                                      useRadiusInMeter: true,
                                      color: Colors.yellow.withOpacity(0.6),
                                      borderColor: Colors.yellow,
                                      borderStrokeWidth: 2,
                                    ),
                                  ]
                                  // Si es 'Ninguno', no se muestra ningún círculo
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MapLegend(),
                                const SizedBox(height: 12),
                                _buildColorFilterButtons(),
                              ],
                            ),
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