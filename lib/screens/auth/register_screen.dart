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
  bool _isLoading = false;
  bool _visible = false;
  String _selectedRole = 'Usuario';

  // Variables para validar la contraseña
  bool _hasMinLength = false;
  bool _hasMaxLength = false;
  bool _hasLowercase = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  // Validaciones visuales para username y email
  bool _isUsernameValid = false;
  bool _isEmailValid = false;

  static const _allRoles = [
    'Usuario',
    'Administrador',
  ];

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
        _isEmailValid = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$").hasMatch(_emailCtrl.text.trim());
      });
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

  void _validatePassword(String pw) {
    setState(() {
      _hasMinLength   = pw.length >= 8;
      _hasMaxLength   = pw.length <= 20;
      _hasLowercase   = RegExp(r'[a-z]').hasMatch(pw);
      _hasUppercase   = RegExp(r'[A-Z]').hasMatch(pw);
      _hasNumber      = RegExp(r'[0-9]').hasMatch(pw);
      _hasSpecialChar = RegExp(r'[!@#\\$%\^&\*(),.?":{}|<>]').hasMatch(pw);
    });
  }

  String _getRoleTranslation(String role) {
    final localizations = AppLocalizations.of(context)!;
    switch (role) {
      case 'Administrador':
        return localizations.roleAdministrator;
      case 'Usuario':
      default:
        return localizations.roleUser;
    }
  }

  Future<void> _register() async {
    final localizations = AppLocalizations.of(context)!;
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim().toLowerCase();
    final pw    = _passwordCtrl.text;
    final isUpc = email.endsWith('@upc.edu');

    if (name.isEmpty || email.isEmpty || pw.isEmpty) {
      _showError(localizations.emptyFieldsError);
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
    if (!(_hasMinLength && _hasMaxLength && _hasLowercase && _hasUppercase && _hasNumber && _hasSpecialChar)) {
      _showError('La contraseña no cumple todos los requisitos');
      return;
    }

    // Si no es UPC, forzar rol "Usuario"
    final roleToSend = isUpc ? _selectedRole : 'Usuario';

    setState(() => _isLoading = true);
    try {
      await AuthService().signup(
        userName: name,
        email:    email,
        password: pw,
        role:     roleToSend,
      );
      if (mounted) context.go('/login');
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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

  Widget _buildCheckItem(bool conditionMet, String text) {
    return Row(
      children: [
        Icon(
          conditionMet ? Icons.check_circle : Icons.cancel,
          color: conditionMet ? Colors.green : Colors.red,
          size: 18,
        ),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(color: conditionMet ? Colors.green : Colors.red)),
      ],
    );
  }

  InputDecoration _inputDecoration(String hintText, IconData prefixIcon, bool isValid) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isValid ? Colors.green : Colors.red, width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: isValid ? Colors.green : Colors.red, width: 3),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.red, width: 3),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Colors.red, width: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;
    final isUpc  = _emailCtrl.text.trim().toLowerCase().endsWith('@upc.edu');

    return Scaffold(
      backgroundColor: colors.surface,
      body: Row(
        children: [
          if (isWide)
            Expanded(
              flex: 3,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                opacity: _visible ? 1.0 : 0.0,
                curve: Curves.easeInOut,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                  child: Image.asset(
                    'assets/barcelona.jpg',
                    fit: BoxFit.cover,
                    height: double.infinity,
                    width: double.infinity,
                  ),
                ),
              ),
            ),
          Expanded(
            flex: 3,
            child: Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                opacity: _visible ? 1.0 : 0.0,
                curve: Curves.easeInOut,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 60),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.97),
                      borderRadius: BorderRadius.circular(35),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Image.asset(
                            'assets/logo_skynet.png',
                            width: 100,
                            height: 100,
                          ),
                        ),
                        const SizedBox(height: 30),
                        Text(
                          localizations.register,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Username
                        TextFormField(
                          controller: _nameCtrl,
                          decoration: _inputDecoration(localizations.username, Icons.person_outline, _isUsernameValid),
                        ),
                        const SizedBox(height: 25),

                        // Email
                        TextFormField(
                          controller: _emailCtrl,
                          keyboardType: TextInputType.emailAddress,
                          decoration: _inputDecoration(localizations.email, Icons.email_outlined, _isEmailValid),
                        ),
                        const SizedBox(height: 25),

                        // Password
                        TextFormField(
                          controller: _passwordCtrl,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: localizations.password,
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                        ),
                        const SizedBox(height: 15),

                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildCheckItem(_hasMinLength, 'Min 8 characters'),
                            _buildCheckItem(_hasMaxLength, 'Max 20 characters'),
                            _buildCheckItem(_hasLowercase, 'At least one lowercase letter'),
                            _buildCheckItem(_hasUppercase, 'At least one uppercase letter'),
                            _buildCheckItem(_hasNumber, 'At least one number'),
                            _buildCheckItem(_hasSpecialChar, 'At least one special character'),
                          ],
                        ),
                        const SizedBox(height: 25),

                        // Solo mostrar selector de rol si email termina en @upc.edu
                        if (isUpc) ...[
                          DropdownButtonFormField<String>(
                            value: _selectedRole,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: colors.surface.withOpacity(0.05),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              labelText: localizations.role,
                            ),
                            items: _allRoles.map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(_getRoleTranslation(r)),
                            )).toList(),
                            onChanged: (v) => setState(() => _selectedRole = v!),
                          ),
                          const SizedBox(height: 40),
                        ],

                        _isLoading
                            ? Center(child: CircularProgressIndicator(color: colors.primary))
                            : ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colors.primary,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                  minimumSize: const Size(double.infinity, 55),
                                ),
                                child: Text(
                                  localizations.register,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),

                        const SizedBox(height: 40),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.login,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.go('/login'),
                              child: Text(
                                localizations.login,
                                style: TextStyle(
                                  color: colors.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
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
