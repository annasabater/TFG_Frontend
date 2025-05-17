import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../provider/drone_provider.dart';
import '../../provider/users_provider.dart';
import '../../widgets/snack.dart';

class AddDroneScreen extends StatefulWidget {
  const AddDroneScreen({Key? key}) : super(key: key);

  @override
  State<AddDroneScreen> createState() => _AddDroneScreenState();
}

class _AddDroneScreenState extends State<AddDroneScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _modelCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locCtrl = TextEditingController();

  String _category = 'venta'; // o la categoría que uses
  String _condition = 'nuevo'; // o condición que uses
  final List<File> _images = [];

  bool _isLoading = false;
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _modelCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null && _images.length < 4) {
      setState(() => _images.add(File(img.path)));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_images.isEmpty) {
      showSnack(context, 'Cal afegir almenys una imatge');
      return;
    }

    setState(() => _isLoading = true);

    final droneProv = context.read<DroneProvider>();
    final userProv = context.read<UserProvider>();
    final ownerId = userProv.currentUser?.id;

    try {
      await droneProv.createDrone(
        ownerId: ownerId!,
        model: _modelCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        price: double.tryParse(_priceCtrl.text.trim()) ?? 0,
        location: _locCtrl.text.trim(),
        category: _category,
        condition: _condition,
        
      );
      if (mounted) {
        showSnack(context, 'Anunci creat amb èxit');
        context.go('/store');
      }
    } catch (e) {
      showSnack(context, 'Error en crear l\'anunci: $e');
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nou anunci')),
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
                  validator: (v) => v == null || v.isEmpty ? 'Obligatori' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _titleCtrl,
                  decoration: _inputDecoration('Títol', Icons.title),
                  validator: (v) => v == null || v.isEmpty ? 'Obligatori' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _descCtrl,
                  decoration: _inputDecoration('Descripció', Icons.description),
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty ? 'Obligatori' : null,
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  decoration: _inputDecoration('Preu (€)', Icons.euro),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Obligatori';
                    if (double.tryParse(v) == null) return 'Preu invàlid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _locCtrl,
                  decoration: _inputDecoration('Localització', Icons.location_on),
                  validator: (v) => v == null || v.isEmpty ? 'Obligatori' : null,
                ),
                const SizedBox(height: 20),
                // Podrías agregar dropdowns para categoría y condición aquí si quieres
                ElevatedButton.icon(
                  onPressed: _images.length >= 4 ? null : _pickImage,
                  icon: const Icon(Icons.add_a_photo),
                  label: Text('Afegir imatge (${_images.length}/4)'),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _images.length,
                    itemBuilder: (context, i) => Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Stack(
                        children: [
                          Image.file(_images[i], width: 100, fit: BoxFit.cover),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () => setState(() => _images.removeAt(i)),
                              child: Container(
                                color: Colors.black54,
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Crear anunci'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
