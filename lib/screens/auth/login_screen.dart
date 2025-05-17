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

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final TextEditingController emailController    = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signUserIn(BuildContext context) async {
    final email    = emailController.text.trim();
    final password = passwordController.text.trim();
    final loc      = AppLocalizations.of(context)!;

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
        context.read<UserProvider>().setCurrentUser(
          User.fromJson(mapUser),
        );
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
    final colors = Theme.of(context).colorScheme;
    final loc    = AppLocalizations.of(context)!;

    return Scaffold(
      // Fondo degradado similar al diseño Dribbble
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 40),
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 40,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo_skynet.png', width: 120, height: 120),
                    const SizedBox(height: 30),
                    Text(
                      loc.welcome,
                      style: TextStyle(
                        color: colors.primary,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 35),
                    MyTextfield(
                      controller: emailController,
                      hintText: loc.email,
                      obscureText: false,
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20),
                    MyTextfield(
                      controller: passwordController,
                      hintText: loc.password,
                      obscureText: true,
                      prefixIcon: Icons.lock_outline,
                    ),
                    const SizedBox(height: 15),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          loc.forgotPassword,
                          style: TextStyle(
                            color: colors.primary.withOpacity(0.7),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
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
                    const SizedBox(height: 30),
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
                              letterSpacing: 0.8,
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
    );
  }
}
