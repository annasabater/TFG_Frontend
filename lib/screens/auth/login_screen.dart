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
      _showError(context, 'El email y la contraseña no pueden estar vacíos.');
      return;
    }

    final result = await auth.login(email, password);
    if (result.containsKey('error')) {
      _showError(context, result['error'] as String);
      return;
    }

    final mapUser = result['user'] as Map<String, dynamic>;
    context.read<UserProvider>().setCurrentUser(User.fromJson(mapUser));

    // Inicializamos el socket
    try {
      SocketService.setUserEmail(email);
    } catch (e) {
      _showError(context, e.toString());
      return;
    }

    if (context.mounted) {
      context.go('/');
    }
  }

  void _showError(BuildContext ctx, String msg) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(msg),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
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
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                const SizedBox(height: 25),
                Text('Benvingut!', style: TextStyle(
                  color: colors.onBackground,
                  fontSize: 24, fontWeight: FontWeight.bold,
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
                    child: Text('Has oblidat la contrasenya?', style: TextStyle(color: colors.onSurfaceVariant)),
                  ),
                ),
                const SizedBox(height: 25),
                MyButton(onTap: () => _signUserIn(context), text: 'Entrar'),
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
