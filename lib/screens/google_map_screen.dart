import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:SkyNet/web_config.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _controller;
  final Set<Marker> _markers = {};
  final Set<Polygon> _polygons = {};
  
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
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        markers: _markers,
        polygons: _polygons,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          _controller = controller;
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _controller?.animateCamera(CameraUpdate.newCameraPosition(_initialPosition));
        },
        child: const Icon(Icons.center_focus_strong),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
} 