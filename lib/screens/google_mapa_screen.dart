import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:SkyNet/geolocation.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart';

// Importaciones condicionales para Google Maps
import 'package:SkyNet/web_config.dart';
import 'package:SkyNet/web_config_web.dart' if (dart.library.io) 'package:SkyNet/web_config_stub.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  bool _loading = true;
  String? _error;
  LatLng? _currentPosition;
  bool _mapAvailable = false;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _initialize();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  Future<void> _initialize() async {
    setState(() => _loading = true);
    
    try {
      // Verificar si estamos en web y si está disponible Google Maps
      if (kIsWeb) {
        try {
          final apiKey = WebConfig.instance.googleMapsApiKey;
          if (apiKey.isEmpty) {
            setState(() {
              _error = 'No se encontró la clave API de Google Maps';
              _loading = false;
            });
            return;
          }
          
          setState(() {
            _mapAvailable = true;
          });
        } catch (e) {
          setState(() {
            _error = 'Error al inicializar Google Maps: $e';
            _loading = false;
          });
          return;
        }
      }
      
      // Obtener la ubicación actual
      try {
        final latLng = await getCurrentPosition();
        if (mounted) {
          setState(() {
            _currentPosition = latLng as LatLng?;
            _loading = false;
          });
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
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error general: $e';
          _loading = false;
        });
      }
      print('Error general: $e');
    }
  }
  
  Future<void> _launchGoogleMaps() async {
    if (_currentPosition == null) return;
    
    final lat = _currentPosition!.latitude;
    final lng = _currentPosition!.longitude;
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al abrir Google Maps: $e')),
      );
    }
  }
  
  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;
    
    final query = _searchController.text.trim();
    final url = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}';
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir Google Maps')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al buscar ubicación: $e')),
      );
    }
  }
  
  // Widget para mostrar en web con Google Maps
  Widget _buildWebMap() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initialize,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    if (_mapAvailable && _currentPosition != null) {
      // Usando un iframe para cargar Google Maps
      final lat = _currentPosition!.latitude;
      final lng = _currentPosition!.longitude;
      final apiKey = WebConfig.instance.googleMapsApiKey;
      
      return Column(
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
            child: HtmlElementView(
              viewType: 'google-map-iframe',
              onPlatformViewCreated: (int id) {
                // Configurar el iframe después de su creación
                _setupIframe(id, lat, lng, apiKey);
              },
            ),
          ),
        ],
      );
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('No se pudo cargar el mapa de Google'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _launchGoogleMaps,
            child: const Text('Abrir en Google Maps'),
          ),
        ],
      ),
    );
  }
  
  void _setupIframe(int id, double lat, double lng, String apiKey) {
    if (kIsWeb) {
      // Utilizamos la función definida en web_config_web.dart
      setupGoogleMapIframe(id, lat, lng, apiKey);
    }
  }
  
  // Widget para mostrar en dispositivos móviles o si no está disponible Google Maps
  Widget _buildFallbackMap() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initialize,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    
    return Column(
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
        
        // Contenido principal
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_currentPosition != null) 
                  Text(
                    'Tu ubicación: ${_currentPosition!.latitude.toStringAsFixed(6)}, ${_currentPosition!.longitude.toStringAsFixed(6)}',
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                const Text(
                  'Google Maps no está disponible directamente en esta plataforma',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _launchGoogleMaps,
                  icon: const Icon(Icons.map),
                  label: const Text('Abrir en Google Maps'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps')),
      body: kIsWeb ? _buildWebMap() : _buildFallbackMap(),
      floatingActionButton: FloatingActionButton(
        onPressed: _initialize,
        tooltip: 'Actualizar ubicación',
        child: const Icon(Icons.refresh),
      ),
    );
  }
} 