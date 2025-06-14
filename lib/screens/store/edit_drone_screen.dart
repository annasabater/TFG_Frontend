import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/drone.dart';
import '../../provider/drone_provider.dart';
import '../../provider/users_provider.dart';
import '../../widgets/snack.dart';

class EditDroneScreen extends StatefulWidget {
  final Drone drone;
  const EditDroneScreen({super.key, required this.drone});

  @override
  State<EditDroneScreen> createState() => _EditDroneScreenState();
}

class _EditDroneScreenState extends State<EditDroneScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _modelCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _locCtrl;
  late final TextEditingController _contactCtrl;
  late int _stock;
  late String _category;
  late String _condition;
  late String _currency;
  final List<File> _imagesMobile = [];
  final List<XFile> _imagesWeb = [];
  final List<Uint8List> _imagesWebBytes = [];
  bool _isLoading = false;
  bool _visible = false;

  static const List<String> _currencies = [
    'EUR',
    'USD',
    'GBP',
    'JPY',
    'CHF',
    'CAD',
    'AUD',
    'CNY',
    'HKD',
    'NZD',
  ];

  @override
  void initState() {
    super.initState();
    final d = widget.drone;
    _modelCtrl = TextEditingController(text: d.model);
    _descCtrl = TextEditingController(text: d.description ?? '');
    _priceCtrl = TextEditingController(text: d.price.toString());
    _locCtrl = TextEditingController(text: d.location ?? '');
    _contactCtrl = TextEditingController(text: d.contact ?? '');
    _stock = d.stock ?? 1;
    _category = d.category ?? 'venta';
    _condition = d.condition ?? 'nuevo';
    _currency =
        d.category != null && _currencies.contains(d.category)
            ? d.category!
            : 'EUR';
    _currency = d.currency ?? 'EUR'; // Usa el campo currency si existe
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img == null) return;
    if (kIsWeb) {
      if (_imagesWeb.length >= 4) return;
      final bytes = await img.readAsBytes();
      setState(() {
        _imagesWeb.add(img);
        _imagesWebBytes.add(bytes);
      });
    } else {
      if (_imagesMobile.length >= 4) return;
      setState(() => _imagesMobile.add(File(img.path)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final droneProv = context.read<DroneProvider>();
    try {
      final ok = await droneProv.createDrone(
        id: widget.drone.id, // <-- Añadido: indica edición
        ownerId: widget.drone.ownerId,
        model: _modelCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        currency: _currency, // NUEVO
        location: _locCtrl.text.trim(),
        category: _category,
        condition: _condition,
        contact: _contactCtrl.text.trim(),
        stock: _stock,
        imagesWeb: kIsWeb ? _imagesWeb : null,
        imagesMobile: !kIsWeb ? _imagesMobile : null,
        existingImages: widget.drone.images, // <-- Añade las imágenes previas
      );
      if (ok && mounted) {
        showSnack(context, 'Anuncio actualizado');
        // Recarga la tienda tras editar
        await droneProv.loadDrones();
        context.pop();
      } else if (!ok && mounted) {
        final error = droneProv.error ?? 'Error al actualizar';
        showSnack(context, error);
      }
    } catch (e) {
      showSnack(context, 'Error al actualizar: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: colors.surface.withOpacity(0.05),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageCount = kIsWeb ? _imagesWeb.length : _imagesMobile.length;
    // Mostrar imágenes existentes si no hay nuevas seleccionadas
    final existingImages = widget.drone.images ?? [];
    final showExistingImages = imageCount == 0 && existingImages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar dron')),
      body: AnimatedOpacity(
        duration: const Duration(milliseconds: 1200),
        opacity: _visible ? 1 : 0,
        curve: Curves.easeInOut,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _modelCtrl,
                  decoration: _inputDecoration('Model', Icons.title),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descCtrl,
                  decoration: _inputDecoration(
                    'Descripción',
                    Icons.description,
                  ),
                  maxLines: 3,
                  validator:
                      (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _inputDecoration('Precio', Icons.euro),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Obligatorio';
                    if (double.tryParse(v) == null) return 'Precio inválido';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _currency,
                  decoration: _inputDecoration(
                    'Divisa',
                    Icons.currency_exchange,
                  ),
                  items:
                      _currencies
                          .map(
                            (c) => DropdownMenuItem(value: c, child: Text(c)),
                          )
                          .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _currency = v);
                  },
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Obligatorio';
                    if (!_currencies.contains(v)) return 'Divisa no permitida';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _locCtrl,
                  decoration: _inputDecoration(
                    'Localización',
                    Icons.location_on,
                  ),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _inputDecoration('Categoría', Icons.category),
                  items: const [
                    DropdownMenuItem(value: 'venta', child: Text('Venta')),
                    DropdownMenuItem(
                      value: 'alquiler',
                      child: Text('Alquiler'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? 'venta'),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _condition,
                  decoration: _inputDecoration('Condición', Icons.grade),
                  items: const [
                    DropdownMenuItem(value: 'nuevo', child: Text('Nuevo')),
                    DropdownMenuItem(value: 'usado', child: Text('Usado')),
                  ],
                  onChanged: (v) => setState(() => _condition = v ?? 'nuevo'),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _contactCtrl,
                  decoration: _inputDecoration('Contacto', Icons.email),
                  validator:
                      (v) => v == null || v.isEmpty ? 'Obligatorio' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  initialValue: _stock.toString(),
                  keyboardType: TextInputType.number,
                  decoration: _inputDecoration('Stock', Icons.numbers),
                  onChanged: (v) => _stock = int.tryParse(v) ?? 1,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1)
                      return 'Stock debe ser un número positivo';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: imageCount >= 4 ? null : _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text('Añadir imagen ($imageCount/4)'),
                ),
                const SizedBox(height: 20),
                if (showExistingImages)
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: existingImages.length,
                      itemBuilder:
                          (context, i) => Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                existingImages[i],
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    ),
                  )
                else
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: imageCount,
                      itemBuilder: (context, i) {
                        if (kIsWeb) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                Image.memory(
                                  _imagesWebBytes[i],
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imagesWeb.removeAt(i);
                                        _imagesWebBytes.removeAt(i);
                                      });
                                    },
                                    child: Container(
                                      color: Colors.black54,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Stack(
                              children: [
                                Image.file(
                                  _imagesMobile[i],
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _imagesMobile.removeAt(i);
                                      });
                                    },
                                    child: Container(
                                      color: Colors.black54,
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Guardar cambios'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
