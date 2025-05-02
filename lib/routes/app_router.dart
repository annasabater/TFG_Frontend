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
import 'package:SkyNet/screens/session_list_screen.dart';
import 'package:SkyNet/screens/lobby_screen.dart';
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
        GoRoute(
          path: 'jocs',
          name: 'jocs',
          builder: (_, __) => const JocsPage(),
          routes: [
            GoRoute(
              path: 'open',
              name: 'jocsOpen',
              builder: (_, __) => const SessionListScreen(),
            ),
            GoRoute(
              path: 'lobby',
              name: 'jocsLobby',
              builder: (_, __) => const LobbyScreen(),
              routes: [
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
    ),
  ],
);


/*
// lib/routes/app_router.dart

import 'package:go_router/go_router.dart';
import 'package:SkyNet/services/auth_service.dart';

// Auth
import 'package:SkyNet/screens/auth/login_screen.dart';
import 'package:SkyNet/screens/auth/register_screen.dart';

// Profile
import 'package:SkyNet/screens/perfil_screen.dart';
import 'package:SkyNet/screens/edit_profile_screen.dart';

// Core
import 'package:SkyNet/screens/home_screen.dart';
import 'package:SkyNet/screens/details_screen.dart';
import 'package:SkyNet/screens/imprimir_screen.dart';
import 'package:SkyNet/screens/editar_screen.dart';
import 'package:SkyNet/screens/borrar_screen.dart';

// Juego
import 'package:SkyNet/screens/jocs_page.dart';
import 'package:SkyNet/screens/session_list_screen.dart';
import 'package:SkyNet/screens/lobby_screen.dart';
import 'package:SkyNet/screens/drone_control_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AuthService().isLoggedIn ? '/' : '/login',
  routes: <GoRoute>[
    GoRoute(path: '/login', builder: (c, s) => LoginPage()),
    GoRoute(path: '/register', builder: (c, s) => const RegisterPage()),
    GoRoute(
      path: '/',
      builder: (c, s) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details',
          builder: (c, s) => const DetailsScreen(),
          routes: [
            GoRoute(path: 'imprimir', builder: (c, s) => const ImprimirScreen()),
          ],
        ),
        GoRoute(path: 'editar', builder: (c, s) => const EditarScreen()),
        GoRoute(path: 'borrar', builder: (c, s) => const BorrarScreen()),
        GoRoute(
          path: 'profile',
          builder: (c, s) => const PerfilScreen(),
          routes: [
            GoRoute(path: 'edit', builder: (c, s) => const EditProfileScreen()),
          ],
        ),

        // Juegos flow sin params
        GoRoute(
          path: 'jocs',
          builder: (c, s) => const JocsPage(),
          routes: [
            GoRoute(path: 'open', builder: (c, s) => const SessionListScreen()),
            GoRoute(path: 'lobby', builder: (c, s) => const LobbyScreen()),
            GoRoute(path: 'lobby/control', builder: (c, s) => const DroneControlPage()),
          ],
        ),
      ],
    ),
  ],
);
*/