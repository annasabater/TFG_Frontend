// lib/screens/social/edit_post_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/post.dart';
import '../../services/social_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/auth_service.dart';

class EditPostScreen extends StatefulWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  late final TextEditingController _descCtrl;
  final bool _isAdmin = AuthService().currentUser?['role'] == 'admin';
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _descCtrl = TextEditingController(text: widget.post.description ?? '');
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    await SocialService.updatePost(widget.post.id, _descCtrl.text.trim());
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    final loc = AppLocalizations.of(context)!;
    final sure = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.delete),
        content: Text(loc.deleteConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(loc.cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(loc.accept)),
        ],
      ),
    );
    if (sure != true) return;
    await SocialService.deletePost(widget.post.id);
    if (mounted) context.go('/xarxes');
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.editPost),
        actions: [
          if (_isAdmin)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              tooltip: loc.delete,
              onPressed: _delete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _descCtrl,
              maxLines: 4,
              decoration: InputDecoration(labelText: loc.description),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitting ? null : _save,
              child: _submitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(loc.saveChanges),
            ),
          ],
        ),
      ),
    );
  }
}
