// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
import 'package:SkyNet/services/auth_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  void signUserIn(BuildContext context) async {
    final authService = AuthService();
    final email = emailController.text;
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(context, 'El email i la contrasenya no poden estar buits.');
      return;
    }

    final result = await authService.login(email, password);
    if (result.containsKey('error')) {
      _showError(context, result['error']);
    } else {
      context.go('/');
    }
  }

  void _showError(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 25),
                Text(
                  'Benvingut!',
                  style: TextStyle(
                    color: colors.onBackground,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                MyTextfield(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 12),
                MyTextfield(
                  controller: passwordController,
                  hintText: 'Contrasenya',
                  obscureText: true,
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Has oblidat la teva contrasenya?',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(onTap: () => signUserIn(context)),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Encara no ets membre? ',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text(
                        'Registra\'t',
                        style: TextStyle(
                          color: colors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
