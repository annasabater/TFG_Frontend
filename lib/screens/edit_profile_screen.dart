// lib/screens/auth/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loadingUser = true;
  bool _isUpdating  = false;

  final List<String> _roles = ['Administrador', 'Usuario', 'Empresa', 'Gobierno'];
  String _selectedRole       = 'Usuario';

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = AuthService();
    final id   = auth.currentUser?['_id'] as String?;
    if (id != null) {
      final res = await auth.getUserById(id);
      if (!res.containsKey('error')) {
        setState(() {
          _nameCtrl.text    = res['userName'] ?? '';
          _emailCtrl.text   = res['email']    ?? '';
          _selectedRole     = (res['role'] as String?) ?? _selectedRole;
        });
      }
    }
    setState(() => _loadingUser = false);
  }

  Future<void> _update() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw    = _passwordCtrl.text;
    final role  = _selectedRole;

    if (name.isEmpty || email.isEmpty) {
      return _showError('El nom i email son obligatoris.');
    }

    setState(() => _isUpdating = true);
    final res = await AuthService().updateProfile(
      userName: name,
      email:    email,
      password: pw.isEmpty ? null : pw,
      role:     role,
    );
    setState(() => _isUpdating = false);

    if (res.containsKey('error')) {
      _showError(res['error'] as String);
    } else {
      final updatedUser = User.fromJson(res);
      context.read<UserProvider>().setCurrentUser(updatedUser);
      if (context.mounted) context.pop();
    }
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isUpdating = true);
    final auth = AuthService();
    final id   = auth.currentUser?['_id'] as String?;
    if (id == null) {
      setState(() => _isUpdating = false);
      return _showError('No se ha encontrado el usuario.');
    }
    final res = await auth.deleteUserById(id);
    setState(() => _isUpdating = false);
    if (res['success'] == true) {
      auth.logout();
      if (mounted) context.go('/login');
    } else {
      _showError(res['error'] ?? 'No se pudo eliminar la cuenta');
    }
  }

  @override

  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_loadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyTextfield(
              controller: _nameCtrl,
              hintText: 'Nom',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: _emailCtrl,
              hintText: 'Email',
              obscureText: false,
            ),
            const SizedBox(height: 12),
            MyTextfield(
              controller: _passwordCtrl,
              hintText: 'Nova contrasenya',
              obscureText: true,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _roles
                  .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedRole = val!),
            ),
            const SizedBox(height: 24),

            if (_isUpdating)
              Center(child: CircularProgressIndicator(color: colors.primary))
            else ...[
              MyButton(
                onTap: _update,
                text: 'Actualitzar Perfil',
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar'),
              ),
              const SizedBox(height: 24),
              TextButton.icon(
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text('Eliminar compte',
                    style: TextStyle(color: Colors.red)),
                onPressed: _deleteAccount,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
