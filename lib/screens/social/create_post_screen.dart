//lib/screens/social/create_post_screen.dart

import 'dart:typed_data';
import 'dart:io' show File;                      
import 'package:flutter/foundation.dart' show kIsWeb;
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

  File?     _fileMobile;          
  XFile?    _xFileWeb;            
  Uint8List? _bytesWebPreview;   

  final _descCtrl = TextEditingController();
  final _locCtrl  = TextEditingController();

  bool _uploading = false;

  //  foto
  Future<void> _pick() async {
    final picker = ImagePicker();
    final img    = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;

    if (kIsWeb) {
      final bytes = await img.readAsBytes();
      setState(() {
        _xFileWeb        = img;
        _bytesWebPreview = bytes;
      });
    } else {
      setState(() => _fileMobile = File(img.path));
    }
  }

  Future<void> _publish() async {
    if (!kIsWeb && _fileMobile == null) return;
    if (kIsWeb  && _xFileWeb  == null) return;

    setState(() => _uploading = true);

    if (kIsWeb) {
      await SocialService.createPostWeb(
        xfile:       _xFileWeb!,
        mediaType:   'image',
        description: _descCtrl.text.trim(),
        location:    _locCtrl.text.trim(),
      );
    } else {
      await SocialService.createPost(
        file:        _fileMobile!,
        mediaType:   'image',
        description: _descCtrl.text.trim(),
        location:    _locCtrl.text.trim(),
      );
    }

    setState(() => _uploading = false);
    if (mounted) context.go('/profile');   
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

    Widget preview() {
      if (kIsWeb && _bytesWebPreview != null) {
        return Image.memory(_bytesWebPreview!, height: 250, fit: BoxFit.contain);
      }
      if (!kIsWeb && _fileMobile != null) {
        return Image.file(_fileMobile!,    height: 250, fit: BoxFit.contain);
      }
      return OutlinedButton.icon(
        icon: const Icon(Icons.photo_library),
        label: const Text('Elegir foto'),
        onPressed: _pick,
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            preview(),
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
