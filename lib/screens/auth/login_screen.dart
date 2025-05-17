import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/models/user.dart';
import 'package:SkyNet/services/socket_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _visible = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _visible = true;
      });
    });
  }

  Future<void> _signUserIn(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final loc = AppLocalizations.of(context)!;

    if (email.isEmpty || password.isEmpty) {
      _showError(context, loc.emptyFieldsError);
      return;
    }

    try {
      final result = await AuthService().login(email, password);
      if (result.containsKey('error')) {
        if (context.mounted) _showError(context, result['error'] as String);
        return;
      }

      final mapUser = result['user'] as Map<String, dynamic>;
      if (context.mounted) {
        context.read<UserProvider>().setCurrentUser(User.fromJson(mapUser));
        SocketService.setUserEmail(mapUser['email'] as String);
        context.go('/');
      }
    } catch (e) {
      if (context.mounted) _showError(context, e.toString());
    }
  }

  void _showError(BuildContext ctx, String msg) {
    final loc = AppLocalizations.of(ctx)!;
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(loc.error),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width > 700;

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
                    'assets/barcelona2.png',
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
                          loc.welcome,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Campo email con tu MyTextfield personalizado
                        MyTextfield(
                          controller: emailController,
                          hintText: loc.email,
                          obscureText: false,
                          prefixIcon: Icons.email_outlined,
                        ),
                        const SizedBox(height: 25),
                        // Campo contraseña con TextField estándar para usar suffixIcon
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: loc.password,
                            prefixIcon: Icon(Icons.lock_outline, color: colors.onSurfaceVariant),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: colors.primary.withOpacity(0.7),
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            filled: true,
                            fillColor: colors.surface.withOpacity(0.05),
                            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        MyButton(
                          onTap: () => _signUserIn(context),
                          text: loc.login,
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
                              loc.notAMember,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () => context.go('/register'),
                              child: Text(
                                loc.register,
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
