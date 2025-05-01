//app_router.dart
import 'package:go_router/go_router.dart';
import 'package:SkyNet/screens/auth/login_screen.dart';
import 'package:SkyNet/screens/borrar_screen.dart';
import 'package:SkyNet/screens/details_screen.dart';
import 'package:SkyNet/screens/editar_screen.dart';
import 'package:SkyNet/screens/imprimir_screen.dart';
import 'package:SkyNet/screens/home_screen.dart';
import 'package:SkyNet/screens/perfil_screen.dart';
import 'package:SkyNet/screens/jocs_page.dart';
import 'package:SkyNet/screens/drone_control_page.dart';
import 'package:SkyNet/services/auth_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AuthService().isLoggedIn ? '/' : '/login',
  routes: [
    GoRoute(path: '/login', builder: (context, state) => LoginPage()),
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
      routes: [
        GoRoute(
          path: 'details',
          builder: (context, state) => const DetailsScreen(),
          routes: [
            GoRoute(
              path: 'imprimir',
              builder: (context, state) => const ImprimirScreen(),
            ),
          ],
        ),
        GoRoute(
          path: 'editar',
          builder: (context, state) => const EditarScreen(),
        ),
        GoRoute(
          path: 'borrar',
          builder: (context, state) => const BorrarScreen(),
        ),
        GoRoute(
          path: 'profile',
          builder: (context, state) => const PerfilScreen(),
        ),
        GoRoute(
          path: 'jocs',
          builder: (context, state) => const JocsPage(),
          routes: [
            GoRoute(
              path: 'competencia',
              builder: (context, state) => const DroneControlPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);
