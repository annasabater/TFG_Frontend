import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
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

  static const _allRoles = [
    'Administrador',
    'Usuario',
    'Empresa',
    'Gobierno',
  ];

  @override
  void initState() {
    super.initState();
    _emailCtrl.addListener(_refreshRoles);
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _visible = true;
      });
    });
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context)!;
    final isWide = MediaQuery.of(context).size.width > 700;

    final isUpc  = _emailCtrl.text.endsWith('@upc.edu');
    final roles  = isUpc
        ? _allRoles
        : _allRoles.where((r) => r != 'Administrador').toList();
    if (!roles.contains(_selectedRole)) _selectedRole = roles.first;

    return Scaffold(
      backgroundColor: colors.background,
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
                        MyTextfield(
                          controller: _nameCtrl,
                          hintText: localizations.username,
                          obscureText: false,
                          prefixIcon: Icons.person_outline,
                        ),
                        const SizedBox(height: 25),
                        MyTextfield(
                          controller: _emailCtrl,
                          hintText: localizations.email,
                          obscureText: false,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 25),
                        MyTextfield(
                          controller: _passwordCtrl,
                          hintText: localizations.password,
                          obscureText: true,
                          prefixIcon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 25),
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
                          items: roles.map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(_getRoleTranslation(r)),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedRole = v!),
                        ),
                        const SizedBox(height: 40),
                        _isLoading
                            ? Center(child: CircularProgressIndicator(color: colors.primary))
                            : MyButton(
                                onTap: _register,
                                text: localizations.register,
                                color: colors.primary,
                                textColor: Colors.white,
                                borderRadius: 25,
                                height: 55,
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
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
