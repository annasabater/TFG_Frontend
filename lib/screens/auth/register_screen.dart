//lib/screens/auth/register_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

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

  String _getRoleTranslation(String role) {
    final localizations = AppLocalizations.of(context)!;
    switch (role) {
      case 'Administrador':
        return localizations.roleAdministrator;
      case 'Usuario':
        return localizations.roleUser;
      case 'Empresa':
        return localizations.roleCompany;
      case 'Gobierno':
        return localizations.roleGovernment;
      default:
        return role;
    }
  }

  Future<void> _register() async {
    final localizations = AppLocalizations.of(context)!;
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final pw    = _passwordCtrl.text;

    if (name.isEmpty || email.isEmpty || pw.isEmpty) {
      _showError(localizations.emptyFieldsError);
      return;
    }
    final isUpc = email.endsWith('@upc.edu');
    if (_selectedRole == 'Administrador' && !isUpc) {
      _showError('Només es pot registrar com Administrador amb un correu @upc.edu');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AuthService().signup(
        userName: name,
        email:    email,
        password: pw,
        role:     _selectedRole,
      );
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final isUpc  = _emailCtrl.text.endsWith('@upc.edu');
    final roles  = isUpc
        ? _allRoles
        : _allRoles.where((r) => r != 'Administrador').toList();
    if (!roles.contains(_selectedRole)) _selectedRole = roles.first;

    return Scaffold(
      appBar: AppBar(title: Text(localizations.register)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            MyTextfield(controller: _nameCtrl,  hintText: localizations.username,    obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: _emailCtrl, hintText: localizations.email,  obscureText: false),
            const SizedBox(height: 12),
            MyTextfield(controller: _passwordCtrl, hintText: localizations.password, obscureText: true),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                labelText: localizations.role,
              ),
              items: roles.map((r) => DropdownMenuItem(
                value: r,
                child: Text(_getRoleTranslation(r)),
              )).toList(),
              onChanged: (v) => setState(() => _selectedRole = v!),
            ),
            const SizedBox(height: 24),
            _isLoading
              ? CircularProgressIndicator(color: colors.primary)
              : MyButton(onTap: _register, text: localizations.register),
          ],
        ),
      ),
    );
  }

  void _showError(String msg) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(localizations.error),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.ok),
          ),
        ],
      ),
    );
  }
}
