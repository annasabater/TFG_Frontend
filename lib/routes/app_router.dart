// lib/routes/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:SkyNet/screens/auth/login_screen.dart';
import 'package:SkyNet/screens/auth/register_screen.dart';
import 'package:SkyNet/screens/edit_profile_screen.dart';
import 'package:SkyNet/screens/home_screen.dart';
import 'package:SkyNet/screens/details_screen.dart';
import 'package:SkyNet/screens/editar_screen.dart';
import 'package:SkyNet/screens/borrar_screen.dart';
import 'package:SkyNet/screens/imprimir_screen.dart';
import 'package:SkyNet/screens/perfil_screen.dart';
import 'package:SkyNet/screens/jocs_page.dart';
import 'package:SkyNet/screens/waiting_room_page.dart';
import 'package:SkyNet/screens/drone_control_page.dart';
import 'package:SkyNet/services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AuthService().isLoggedIn ? '/' : '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (_, __) => LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (_, __) => const RegisterPage(),
    ),
    GoRoute(
      path: '/',
      name: 'home',
      builder: (_, __) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details',
          name: 'details',
          builder: (_, __) => const DetailsScreen(),
          routes: [
            GoRoute(
              path: 'imprimir',
              name: 'imprimir',
              builder: (_, __) => const ImprimirScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'editar',
          name: 'editar',
          builder: (_, __) => const EditarScreen(),
        ),
        GoRoute(
          path: 'borrar',
          name: 'borrar',
          builder: (_, __) => const BorrarScreen(),
        ),
        GoRoute(
          path: 'profile',
          name: 'profile',
          builder: (_, __) => const PerfilScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              name: 'editProfile',
              builder: (_, __) => const EditProfileScreen(),
            ),
          ],
        ),

        // ----------------- JOCS -----------------
        GoRoute(
          path: 'jocs',
          name: 'jocs',
          builder: (_, __) => const JocsPage(),
          routes: [
            // Al pulsar "Competencia" va directamente a la sala de espera
            GoRoute(
              path: 'open',
              name: 'jocsOpen',
              builder: (_, __) => const WaitingRoomPage(),
            ),
            // Al recibir 'game_started' navega a /jocs/control
            GoRoute(
              path: 'control',
              name: 'jocsControl',
              builder: (_, __) => const DroneControlPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
