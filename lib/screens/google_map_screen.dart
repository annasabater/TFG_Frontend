import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:SkyNet/web_config.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  String? _searchError;
  
  // Ubicación inicial del mapa (Barcelona)
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(41.3851, 2.1734),
    zoom: 12,
  );

  @override
  void initState() {
    super.initState();
    // Cargar datos del mapa, como marcadores, zonas, etc.
    _loadMapData();
    _getCurrentLocation();
  }

  void _loadMapData() {
    // Aquí cargarías los marcadores, polígonos, etc. desde tu backend o servicio
    setState(() {
      _markers.add(
        const Marker(
          markerId: MarkerId('eetac'),
          position: LatLng(41.2757, 1.9881),
          infoWindow: InfoWindow(title: 'EETAC', snippet: 'Escuela de ingeniería'),
        ),
      );
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);
      
      // Verificar si los servicios de ubicación están habilitados
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _searchError = 'Los servicios de ubicación están desactivados';
        });
        return;
      }

      // Verificar permisos
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
            _searchError = 'Los permisos de ubicación fueron denegados';
          });
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
          _searchError = 'Los permisos de ubicación están permanentemente denegados';
        });
        return;
      }

      // Obtener la posición actual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
      );
      
      // Añadir un marcador para la ubicación actual
      final LatLng currentLatLng = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: currentLatLng,
            infoWindow: const InfoWindow(title: 'Mi ubicación'),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          ),
        );
        _isLoading = false;
      });

      // Mover la cámara a la ubicación actual
      _controller?.animateCamera(CameraUpdate.newLatLngZoom(currentLatLng, 15));
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchError = 'Error al obtener la ubicación: $e';
      });
    }
  }

  Future<void> _searchPlace(String query) async {
    if (query.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _searchError = null;
    });
    
    try {
      // Usamos la API de geocodificación de Google Maps
      final apiKey = _apiKey;
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=$apiKey'
        ),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          final result = data['results'][0];
          final geometry = result['geometry']['location'];
          final lat = geometry['lat'];
          final lng = geometry['lng'];
          
          final latLng = LatLng(lat, lng);
          
          // Añadimos un marcador para el lugar buscado
          setState(() {
            // Eliminamos marcadores anteriores de búsqueda
            _markers.removeWhere((marker) => marker.markerId.value == 'searchResult');
            
            _markers.add(
              Marker(
                markerId: const MarkerId('searchResult'),
                position: latLng,
                infoWindow: InfoWindow(
                  title: result['formatted_address'],
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
              ),
            );
            
            _isLoading = false;
          });
          
          // Movemos la cámara al lugar buscado
          _controller?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 15));
          
        } else {
          setState(() {
            _isLoading = false;
            _searchError = 'No se encontraron resultados';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _searchError = 'Error en la búsqueda: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchError = 'Error en la búsqueda: $e';
      });
    }
  }

  String get _apiKey {
    // En web, la clave API se obtiene del meta tag
    if (kIsWeb) {
      return WebConfig.instance.googleMapsApiKey;
    } 
    // En otras plataformas, se obtiene de las variables de entorno
    return dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa de Drones'),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar ubicación...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      errorText: _searchError,
                    ),
                    onSubmitted: _searchPlace,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchPlace(_searchController.text),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          
          // Mapa
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialPosition,
                  markers: _markers,
                  polygons: _polygons,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            tooltip: 'Mi ubicación',
            child: const Icon(Icons.my_location),
            heroTag: 'my-location',
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              _controller?.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
            },
            tooltip: 'Centro del mapa',
            child: const Icon(Icons.center_focus_strong),
            heroTag: 'center-map',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    _searchController.dispose();
    super.dispose();
  }
} 