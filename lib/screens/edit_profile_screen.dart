// lib/screens/auth/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
import 'package:SkyNet/services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading     = false;

  final List<String> _roles = ['Administrador', 'Usuario', 'Empresa', 'Gobierno'];
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final auth = AuthService();
    final id = auth.currentUser?['_id'];
    if (id != null) {
      final res = await auth.getUserById(id);
      if (!res.containsKey('error')) {
        setState(() {
          _nameCtrl.text  = res['userName'] ?? '';
          _emailCtrl.text = res['email']    ?? '';
          _selectedRole   = res['role']     ?? 'Usuario';
        });
      }
    }
  }

  void _update() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw    = _passwordCtrl.text;
    final role  = _selectedRole ?? 'Usuario';

    if (name.isEmpty || email.isEmpty) {
      _showError('Nombre y Email son obligatorios.');
      return;
    }

    setState(() => _isLoading = true);
    final res = await AuthService().updateProfile(
      userName: name,
      email:    email,
      password: pw.isNotEmpty ? pw : null,
      role:     role,
    );
    setState(() => _isLoading = false);

    if (res.containsKey('error')) {
      _showError(res['error']);
    } else {
      context.pop();
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Editar Perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MyTextfield(controller: _nameCtrl,     hintText: 'Nombre',           obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: _emailCtrl,    hintText: 'Email',            obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: _passwordCtrl, hintText: 'Nueva Contraseña',  obscureText: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: _roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) => setState(() => _selectedRole = val),
            ),
            const SizedBox(height: 24),
            if (_isLoading)
              Center(child: CircularProgressIndicator(color: colors.primary))
            else ...[
              ElevatedButton(
                onPressed: _update,
                child: const Text('Actualizar Perfil'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancelar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
