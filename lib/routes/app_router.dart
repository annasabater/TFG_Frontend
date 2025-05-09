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
import 'package:SkyNet/screens/mapa_screen.dart';
import 'package:SkyNet/screens/chat_list_screen.dart';
import 'package:SkyNet/screens/chat_screen.dart';
import 'package:SkyNet/screens/search_user_screen.dart';
import 'package:SkyNet/screens/store/drone_store_screen.dart';
import 'package:SkyNet/screens/store/drone_detail_screen.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/models/drone.dart';
import 'package:SkyNet/screens/store/add_drone_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AuthService().isLoggedIn ? '/' : '/login',
  routes: [
    /* ------------------- Auth ------------------- */
    GoRoute(
      path: '/login',
      builder: (_, __) => LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (_, __) => const RegisterPage(),
    ),

    /* ------------------- Home (pare) ------------- */
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),

      /* ----------- sub-rutes de Home -------------- */
      routes: [
        GoRoute(
          path: 'details',
          builder: (_, __) => const DetailsScreen(),
          routes: [
            GoRoute(
              path: 'imprimir',
              builder: (_, __) => const ImprimirScreen(),
            ),
          ],
        ),
        GoRoute(path: 'editar', builder: (_, __) => const EditarScreen()),
        GoRoute(path: 'borrar', builder: (_, __) => const BorrarScreen()),

        GoRoute(
          path: 'profile',
          builder: (_, __) => const PerfilScreen(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, __) => const EditProfileScreen(),
            ),
          ],
        ),

        /* -------------- Joc amb sockets ----------- */
        GoRoute(
          path: 'jocs',
          builder: (_, __) => const JocsPage(),
          routes: [
            GoRoute(path: 'open',    builder: (_, __) => const WaitingRoomPage()),
            GoRoute(path: 'control', builder: (_, __) => const DroneControlPage()),
          ],
        ),

        GoRoute(path: 'mapa', builder: (_, __) => const MapaScreen()),

       /* -------------- Botiga ----------- */
        GoRoute(
          path: 'store',
          builder: (_, __) => const DroneStoreScreen(),
          routes: [
            GoRoute(
              path: 'add',
              name: 'addDrone',
              builder: (_, __) => const AddDroneScreen(),
            ),
            GoRoute(
              path: 'dron/:id',
              name: 'droneDetail',
              builder: (ctx, state) => DroneDetailScreen(drone: state.extra! as Drone),
            ),
          ],
        ),

        /* -------------- Xat ----------------------- */
        GoRoute(
          path: 'chat',
          builder: (_, __) => const ChatListScreen(),
          routes: [
            GoRoute(path: 'search',  builder: (_, __) => const SearchUserScreen()),
            GoRoute(
              path: ':userId',
              builder: (ctx, st) => ChatScreen(userId: st.pathParameters['userId']!),
            ),
          ],
        ),
      ],
    ),
  ],
);
