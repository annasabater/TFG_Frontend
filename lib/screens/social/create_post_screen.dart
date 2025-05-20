// lib/screens/social/create_post_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../services/social_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  File? _file;
  final _descCtrl = TextEditingController();
  final _locCtrl = TextEditingController();
  bool _uploading = false;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _file = File(img.path));
  }

  Future<void> _publish() async {
    if (_file == null) return;
    setState(() => _uploading = true);
    await SocialService.createPost(
      file: _file!,
      mediaType: 'image',
      description: _descCtrl.text.trim(),
      location: _locCtrl.text.trim(),
    );
    setState(() => _uploading = false);
    if (mounted) context.go('/profile'); // vuelve a tu perfil
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _locCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final btnText = _uploading ? 'Publicando…' : 'Publicar';
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _file == null
                ? OutlinedButton.icon(
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Elegir foto'),
                    onPressed: _pick,
                  )
                : Image.file(_file!, height: 250, fit: BoxFit.contain),
            const SizedBox(height: 20),
            TextField(
              controller: _descCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _locCtrl,
              decoration: const InputDecoration(
                labelText: 'Ubicación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _uploading ? null : _publish,
              child: Text(btnText),
            ),
          ],
        ),
      ),
    );
  }
}
