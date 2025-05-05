// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/models/user.dart';
import 'package:SkyNet/services/socket_service.dart';

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final emailController    = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _signUserIn(BuildContext context) async {
    final auth     = AuthService();
    final email    = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showError(context, 'El email i la contrasenya no poden estar buits.');
      return;
    }

    final result = await auth.login(email, password);
    if (result.containsKey('error')) {
      _showError(context, result['error'] as String);
      return;
    }

    // 1) Obtenim el user del result
    final mapUser = result['user'] ?? result;

    // 2) Desem al provider
    context.read<UserProvider>().setCurrentUser(User.fromJson(mapUser));

    // 3) Desem l’email al SocketService perquè després pugui fer initWaitingSocket()
    SocketService.setUserEmail(email);

    // 4) Ara naveguem a Home
    if (context.mounted) {
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
            onPressed: () => Navigator.pop(context),
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
                Text('Benvingut!', style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                )),
                const SizedBox(height: 25),
                MyTextfield(controller: emailController, hintText: 'Email', obscureText: false),
                const SizedBox(height: 12),
                MyTextfield(controller: passwordController, hintText: 'Contrasenya', obscureText: true),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    child: Text('Has oblidat la contrasenya?', style: TextStyle(color: colors.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(
                  onTap: () => _signUserIn(context),
                  text: 'Entrar',    
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Encara no ets membre? ', style: TextStyle(color: colors.onSurfaceVariant)),
                    GestureDetector(
                      onTap: () => context.go('/register'),
                      child: Text('Registra\'t', style: TextStyle(
                        color: colors.primary, fontWeight: FontWeight.bold
                      )),
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
