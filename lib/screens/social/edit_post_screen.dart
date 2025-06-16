//lib/screens/social/edit_post_screen.dart

import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../services/social_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditPostScreen extends StatelessWidget {
  final Post post;
  const EditPostScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final descCtrl = TextEditingController(text: post.description ?? '');

    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.editPost)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: descCtrl,
              maxLines: 4,
              decoration: InputDecoration(labelText: AppLocalizations.of(context)!.description),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await SocialService.updatePost(post.id, descCtrl.text.trim());
                if (context.mounted) Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.saveChanges),
            ),
          ],
        ),
      ),
    );
  }
}
