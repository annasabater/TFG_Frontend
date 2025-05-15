import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/models/user.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading = false;

  static const _allRoles = [
    'Administrador',
    'Usuario',
    'Empresa',
    'Gobierno',
  ];
  String _selectedRole = 'Usuario';

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_refreshRoles);
  }

  @override
  void dispose() {
    _emailCtrl.removeListener(_refreshRoles);
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _refreshRoles() => setState(() {});

  Future<void> _register() async {
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final pw    = _passwordCtrl.text;

    if (name.isEmpty || email.isEmpty || pw.isEmpty) {
      return _showError('Completa tots els camps');
    }
    final isUpc = email.endsWith('@upc.edu');
    if (_selectedRole == 'Administrador' && !isUpc) {
      return _showError('Només es pot registrar com Administrador amb un correu @upc.edu');
    }

    setState(() => _isLoading = true);

    // 1) registro
    final signRes = await AuthService().signup(
      userName: name,
      email:    email,
      password: pw,
      role:     _selectedRole,
    );
    if (signRes.containsKey('error')) {
      setState(() => _isLoading = false);
      return _showError(signRes['error'] as String);
    }

    // 2) login automático para obtener token
    final loginRes = await AuthService().login(email, pw);
    setState(() => _isLoading = false);

    if (loginRes.containsKey('error')) {
      return _showError('Usuario creado, pero falló el login automático: ${loginRes['error']}');
    }

    // 3) guardamos user en el provider y navegamos
    final mapUser = loginRes['user'] as Map<String, dynamic>;
    context.read<UserProvider>().setCurrentUser(User.fromJson(mapUser));
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isUpc  = _emailCtrl.text.endsWith('@upc.edu');
    final roles  = isUpc
        ? _allRoles
        : _allRoles.where((r) => r != 'Administrador').toList();
    if (!roles.contains(_selectedRole)) _selectedRole = roles.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Registra’t')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextfield(controller: _nameCtrl,  hintText: 'Nom',    obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: _emailCtrl, hintText: 'Email',  obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: _passwordCtrl, hintText: 'Contrasenya', obscureText: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              items: roles.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            const SizedBox(height: 24),
            _isLoading
              ? CircularProgressIndicator(color: colors.primary)
              : MyButton(onTap: _register, text: 'Registrarse'),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }
}
