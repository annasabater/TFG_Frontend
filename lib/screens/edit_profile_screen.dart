import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:SkyNet/components/my_textfield.dart';
import 'package:SkyNet/components/my_button.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/models/user.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> with SingleTickerProviderStateMixin {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _loadingUser = true;
  bool _isUpdating = false;

  final List<String> _roles = ['Administrador', 'Usuario', 'Empresa', 'Gobierno'];
  String _selectedRole = 'Usuario';

  // Variables para validar la contraseña
  bool _hasMinLength = false;  // mínimo 8 caracteres
  bool _hasMaxLength = false;  // máximo 20 caracteres
  bool _hasLowercase = false;
  bool _hasUppercase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  late AnimationController _animController;
  late Animation<double> _fadeInAnim;

  @override
  void initState() {
    super.initState();
    _loadUser();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeInAnim = CurvedAnimation(parent: _animController, curve: Curves.easeIn);
    _animController.forward();

    _passwordCtrl.addListener(() {
      _validatePassword(_passwordCtrl.text);
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _validatePassword(String pw) {
    setState(() {
      _hasMinLength = pw.length >= 8;
      _hasMaxLength = pw.length <= 20;
      _hasLowercase = RegExp(r'[a-z]').hasMatch(pw);
      _hasUppercase = RegExp(r'[A-Z]').hasMatch(pw);
      _hasNumber = RegExp(r'[0-9]').hasMatch(pw);
      _hasSpecialChar = RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(pw);
    });
  }

  Future<void> _loadUser() async {
    final auth = AuthService();
    final id = auth.currentUser?['_id'] as String?;
    if (id != null) {
      final res = await auth.getUserById(id);
      if (!res.containsKey('error')) {
        setState(() {
          _nameCtrl.text = res['userName'] ?? '';
          _emailCtrl.text = res['email'] ?? '';
          _selectedRole = (res['role'] as String?) ?? _selectedRole;
        });
      }
    }
    setState(() => _loadingUser = false);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _update() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pw = _passwordCtrl.text;
    final role = _selectedRole;

    if (name.isEmpty || email.isEmpty) {
      return _showError('El nom i email son obligatoris.');
    }

    if (!_isValidEmail(email)) {
      return _showError('El email no tiene un formato válido.');
    }

    // Contraseña debe cumplir todas las condiciones
    if (pw.isNotEmpty && !(_hasMinLength && _hasMaxLength && _hasLowercase && _hasUppercase && _hasNumber && _hasSpecialChar)) {
      return _showError('La contraseña no cumple todos los requisitos');
    }

    setState(() => _isUpdating = true);
    final res = await AuthService().updateProfile(
      userName: name,
      email: email,
      password: pw.isEmpty ? null : pw,
      role: role,
    );
    setState(() => _isUpdating = false);

    if (res.containsKey('error')) {
      _showError(res['error'] as String);
    } else {
      final updatedUser = User.fromJson(res);
      context.read<UserProvider>().setCurrentUser(updatedUser);
      if (context.mounted) context.pop();
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<void> _deleteAccount() async {
    setState(() => _isUpdating = true);
    final auth = AuthService();
    final id = auth.currentUser?['_id'] as String?;
    if (id == null) {
      setState(() => _isUpdating = false);
      return _showError('No se ha encontrado el usuario.');
    }
    final res = await auth.deleteUserById(id);
    setState(() => _isUpdating = false);
    if (res['success'] == true) {
      auth.logout();
      if (mounted) context.go('/login');
    } else {
      _showError(res['error'] ?? 'No se pudo eliminar la cuenta');
    }
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

  Widget _buildProfileImage() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 80, color: Colors.grey[700]),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidad para cambiar foto no implementada'),
                  duration: Duration(seconds: 3),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.blueGrey,
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.camera_alt, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (_loadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: FadeTransition(
              opacity: _fadeInAnim,
              child: Image.asset(
                'assets/edit_profile_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 500),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.93),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildProfileImage(),
                      const SizedBox(height: 30),
                      Text(
                        'Editar Perfil',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                          letterSpacing: 1.3,
                        ),
                      ),
                      const SizedBox(height: 35),

                      MyTextfield(
                        controller: _nameCtrl,
                        hintText: 'Nom',
                        obscureText: false,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: 20),

                      MyTextfield(
                        controller: _emailCtrl,
                        hintText: 'Email',
                        obscureText: false,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 20),

                      MyTextfield(
                        controller: _passwordCtrl,
                        hintText: 'Nova contrasenya',
                        obscureText: true,
                        prefixIcon: Icons.lock_outline,
                      ),
                      const SizedBox(height: 10),

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
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: _selectedRole,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colors.surfaceContainerHighest.withOpacity(0.6),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        ),
                        items: _roles
                            .map((r) => DropdownMenuItem(
                                  value: r,
                                  child: Text(r),
                                ))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedRole = val!),
                      ),
                      const SizedBox(height: 40),

                      if (_isUpdating)
                        CircularProgressIndicator(color: colors.primary)
                      else ...[
                        MyButton(
                          onTap: _update,
                          text: 'Actualitzar Perfil',
                          color: colors.primary,
                          textColor: Colors.white,
                          height: 52,
                          borderRadius: 25,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        const SizedBox(height: 16),

                        ElevatedButton(
                          onPressed: () => context.pop(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.secondary.withOpacity(0.1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: Text(
                            'Cancelar',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),

                        const SizedBox(height: 36),
                        Divider(color: colors.surfaceContainerHighest, thickness: 1),
                        const SizedBox(height: 20),
                        TextButton.icon(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          label: const Text(
                            'Eliminar compte',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          onPressed: _deleteAccount,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ],
                    ],
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
