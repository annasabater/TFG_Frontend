// lib/screens/register_page.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with TickerProviderStateMixin {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLoading     = false;
  bool _visible       = false;
  String _selectedRole = 'Usuario';

  static const _allRoles = [
    'Administrador',
    'Usuario',
    'Empresa',
    'Gobierno',
  ];

  // Variables para validar la contraseña
  bool _hasMinLength    = false;
  bool _hasMaxLength    = false;
  bool _hasLowercase    = false;
  bool _hasUppercase    = false;
  bool _hasNumber       = false;
  bool _hasSpecialChar  = false;

  // Validaciones visuales para username y email
  bool _isUsernameValid = false;
  bool _isEmailValid    = false;

  @override
  void initState() {
    super.initState();

    _nameCtrl.addListener(() {
      setState(() {
        _isUsernameValid = _nameCtrl.text.trim().length >= 3;
      });
    });

    _emailCtrl.addListener(() {
      setState(() {
        _isEmailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
            .hasMatch(_emailCtrl.text.trim());
      });
      _refreshRoles();
    });

    _passwordCtrl.addListener(() {
      _validatePassword(_passwordCtrl.text);
    });

    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _refreshRoles() => setState(() {});

  void _validatePassword(String pw) {
    setState(() {
      _hasMinLength   = pw.length >= 8;
      _hasMaxLength   = pw.length <= 20;
      _hasLowercase   = RegExp(r'[a-z]').hasMatch(pw);
      _hasUppercase   = RegExp(r'[A-Z]').hasMatch(pw);
      _hasNumber      = RegExp(r'\d').hasMatch(pw);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pw);
    });
  }

  String _getRoleTranslation(String role) {
    final loc = AppLocalizations.of(context)!;
    switch (role) {
      case 'Administrador': return loc.roleAdministrator;
      case 'Usuario':       return loc.roleUser;
      case 'Empresa':       return loc.roleCompany;
      case 'Gobierno':      return loc.roleGovernment;
      default:              return role;
    }
  }

  Future<void> _register() async {
    final loc   = AppLocalizations.of(context)!;
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final pw    = _passwordCtrl.text;

    if (name.isEmpty || email.isEmpty || pw.isEmpty) {
      _showError(loc.emptyFieldsError);
      return;
    }
    if (!_isUsernameValid) {
      _showError('El nombre de usuario debe tener al menos 3 caracteres');
      return;
    }
    if (!_isEmailValid) {
      _showError('El email no tiene un formato válido');
      return;
    }
    if (!(_hasMinLength && _hasMaxLength && _hasLowercase &&
          _hasUppercase && _hasNumber && _hasSpecialChar)) {
      _showError('La contraseña no cumple todos los requisitos');
      return;
    }

    final isUpc = email.endsWith('@upc.edu');
    if (_selectedRole == 'Administrador' && !isUpc) {
      _showError('Solo puedes registrarte como Administrador con un correo @upc.edu');
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
      if (mounted) context.go('/login');
    } catch (e) {
      // e.toString() viene como "Exception: mensaje", así que lo limpiamos
      final msg = e.toString().replaceFirst('Exception: ', '');
      _showError(msg);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.error),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckItem(bool met, String text) {
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle : Icons.cancel,
          color: met ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: met ? Colors.green : Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon, bool valid) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: valid ? Colors.green : Colors.red, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: valid ? Colors.green : Colors.red, width: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final loc    = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;

    final isUpc = _emailCtrl.text.endsWith('@upc.edu');
    final roles = isUpc
        ? _allRoles
        : _allRoles.where((r) => r != 'Administrador').toList();
    if (!roles.contains(_selectedRole)) _selectedRole = roles.first;

    return Scaffold(
      backgroundColor: colors.surface,
      body: Row(
        children: [
          if (isWide) Expanded(
            flex: 3,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: const Duration(milliseconds: 1500),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
                child: Image.asset('assets/barcelona.jpg', fit: BoxFit.cover),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: AnimatedOpacity(
                opacity: _visible ? 1 : 0,
                duration: const Duration(milliseconds: 1500),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 30)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(child: Image.asset('assets/logo_skynet.png', width: 100, height: 100)),
                        const SizedBox(height: 30),
                        Text(loc.register, textAlign: TextAlign.center, style: TextStyle(
                          color: colors.primary, fontSize: 28, fontWeight: FontWeight.bold,
                        )),
                        const SizedBox(height: 40),

                        TextFormField(
                          controller: _nameCtrl,
                          decoration: _inputDecoration(loc.username, Icons.person_outline, _isUsernameValid),
                        ),
                        const SizedBox(height: 25),

                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(loc.email, Icons.email_outlined, _isEmailValid),
                        ),
                        const SizedBox(height: 25),

                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: loc.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        const SizedBox(height: 15),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCheckItem(_hasMinLength, 'Min 8 caracteres'),
                            _buildCheckItem(_hasMaxLength, 'Max 20 caracteres'),
                            _buildCheckItem(_hasLowercase, 'Al menos una minúscula'),
                            _buildCheckItem(_hasUppercase, 'Al menos una mayúscula'),
                            _buildCheckItem(_hasNumber, 'Al menos un número'),
                            _buildCheckItem(_hasSpecialChar, 'Al menos un carácter especial'),
                          ],
                        ),
                        const SizedBox(height: 25),

                        DropdownButtonFormField<String>(
                          value: _selectedRole,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: colors.surface.withOpacity(0.05),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            labelText: loc.role,
                          ),
                          items: roles.map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(_getRoleTranslation(r)),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),
                        const SizedBox(height: 40),

                        _isLoading
                          ? Center(child: CircularProgressIndicator(color: colors.primary))
                          : ElevatedButton(
                              onPressed: _register,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: colors.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                                minimumSize: const Size(double.infinity, 55),
                              ),
                              child: Text(loc.register, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                            ),
                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(loc.login, style: TextStyle(color: colors.onSurfaceVariant)),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(loc.login, style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
