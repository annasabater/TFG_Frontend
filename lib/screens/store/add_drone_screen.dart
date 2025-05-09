//lib/screens/store/add_drone_screen.dart

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

class _AddDroneScreenState extends State<AddDroneScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _locCtrl   = TextEditingController();

  String _category  = 'venta';
  String _condition = 'nuevo';
  final List<File> _images = [];

  Future<void> _pickImage() async {
    final img = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (img != null && _images.length < 4) {
      setState(() => _images.add(File(img.path)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final droneProv = context.read<DroneProvider>();
    final userProv  = context.read<UserProvider>();
    final uid       = userProv.currentUser?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('Nou anunci')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Títol'),
                validator: (v) => v!.isEmpty ? 'Obligatori' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(labelText: 'Descripció'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceCtrl,
                decoration: const InputDecoration(labelText: 'Preu (€)'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Obligatori' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _locCtrl,
                decoration: const InputDecoration(labelText: 'Ubicació'),
                validator: (v) => v!.isEmpty ? 'Obligatori' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: const [
                  DropdownMenuItem(value: 'venta',   child: Text('Compra drons')),
                  DropdownMenuItem(value: 'alquiler', child: Text('Serveis / Lloguer')),
                ],
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: const InputDecoration(labelText: 'Estat'),
                items: const [
                  DropdownMenuItem(value: 'nuevo',     child: Text('Nou')),
                  DropdownMenuItem(value: 'usado', child: Text('Usat')),
                ],
                onChanged: (v) => setState(() => _condition = v!),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  for (var img in _images)
                    Stack(
                      children: [
                        Image.file(img, width: 80, height: 80, fit: BoxFit.cover),
                        Positioned(
                          right: -8,
                          top: -8,
                          child: IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() => _images.remove(img)),
                          ),
                        ),
                      ],
                    ),
                  if (_images.length < 4)
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.add_a_photo),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  if (uid == null) {
                    showSnack(context, 'Has d\'iniciar sessió');
                    return;
                  }

                  final ok = await droneProv.createDrone(
                    ownerId    : uid,
                    model      : _titleCtrl.text.trim(),
                    price      : double.parse(_priceCtrl.text),
                    description: _descCtrl.text.trim(),
                    category   : _category,
                    condition  : _condition,
                    location   : _locCtrl.text.trim(),
                  );

                  if (!mounted) return;
                  showSnack(context, ok ? 'Producte publicat!' : 'Error publicant');
                  if (ok) GoRouter.of(context).pop();
                },
                child: const Text('Publica'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

