import 'package:go_router/go_router.dart';

/* ──────────── Auth ──────────── */
import 'package:SkyNet/screens/auth/login_screen.dart';
import 'package:SkyNet/screens/auth/register_screen.dart';

/* ──────────── Perfil & social ──────────── */
import 'package:SkyNet/screens/perfil_screen.dart';
import 'package:SkyNet/screens/social/feed_screen.dart';
import 'package:SkyNet/screens/social/explore_screen.dart';
import 'package:SkyNet/screens/social/create_post_screen.dart';
import 'package:SkyNet/screens/social/post_detail_screen.dart';
import 'package:SkyNet/screens/social/user_profile_screen.dart';
import 'package:SkyNet/screens/edit_profile_screen.dart';

/* ──────────── Otras pantallas existentes ──────────── */
import 'package:SkyNet/screens/home_screen.dart';
import 'package:SkyNet/screens/details_screen.dart';
import 'package:SkyNet/screens/editar_screen.dart';
import 'package:SkyNet/screens/borrar_screen.dart';
import 'package:SkyNet/screens/imprimir_screen.dart';
import 'package:SkyNet/screens/jocs_page.dart';
import 'package:SkyNet/screens/waiting_room_page.dart';
import 'package:SkyNet/screens/drone_control_page.dart';
import 'package:SkyNet/screens/mapa_screen.dart';
import 'package:SkyNet/screens/chat_list_screen.dart';
import 'package:SkyNet/screens/chat_screen.dart';
import 'package:SkyNet/screens/search_user_screen.dart';
import 'package:SkyNet/screens/store/drone_store_screen.dart';
import 'package:SkyNet/screens/store/drone_detail_screen.dart';
import 'package:SkyNet/screens/store/add_drone_screen.dart';

import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/models/drone.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: AuthService().isLoggedIn ? '/feed' : '/login',
  routes: [
    /* ─────────── Login & Register ─────────── */
    GoRoute(path: '/login',    builder: (_, __) => LoginPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

    /* ─────────── Shell/Home (opcional) ─────────── */
    GoRoute(
      path: '/',
      builder: (_, __) => const HomeScreen(),   // si tu Home contiene el BottomNav
      routes: [
        /* ==== 1) Social ==== */
        GoRoute(path: 'feed',    builder: (_, __) => const FeedScreen()),
        GoRoute(path: 'explore', builder: (_, __) => const ExploreScreen()),
        GoRoute(path: 'create',  builder: (_, __) => const CreatePostScreen()),
        GoRoute(
          path: 'posts/:pid',
          builder: (ctx, st) => PostDetailScreen(postId: st.pathParameters['pid']!),
        ),
        GoRoute(
          path: 'u/:uid',
          builder: (ctx, st) => UserProfileScreen(userId: st.pathParameters['uid']!),
        ),

        /* Perfil propio */
        GoRoute(
          path: 'profile',
          builder: (_, __) => const PerfilScreen(),
          routes: [
            GoRoute(path: 'edit', builder: (_, __) => const EditProfileScreen()),
          ],
        ),

        /* ==== 2) Resto de rutas que ya tenías ==== */
        GoRoute(
          path: 'details',
          builder: (_, __) => const DetailsScreen(),
          routes: [
            GoRoute(path: 'imprimir', builder: (_, __) => const ImprimirScreen()),
          ],
        ),
        GoRoute(path: 'editar', builder: (_, __) => const EditarScreen()),
        GoRoute(path: 'borrar', builder: (_, __) => const BorrarScreen()),
        GoRoute(
          path: 'jocs',
          builder: (_, __) => const JocsPage(),
          routes: [
            GoRoute(
              path: 'open/:sessionId',
              builder: (ctx, st) =>
                  WaitingRoomPage(sessionId: st.pathParameters['sessionId']!),
            ),
            GoRoute(
              path: 'control/:sessionId',
              builder: (ctx, st) =>
                  DroneControlPage(sessionId: st.pathParameters['sessionId']!),
            ),
          ],
        ),
        GoRoute(path: 'mapa', builder: (_, __) => const MapaScreen()),
        GoRoute(
          path: 'store',
          builder: (_, __) => const DroneStoreScreen(),
          routes: [
            GoRoute(path: 'add', name: 'addDrone', builder: (_, __) => const AddDroneScreen()),
            GoRoute(
              path: 'dron/:id',
              name: 'droneDetail',
              builder: (ctx, st) =>
                  DroneDetailScreen(drone: st.extra! as Drone),
            ),
          ],
        ),
        GoRoute(
          path: 'chat',
          builder: (_, __) => const ChatListScreen(),
          routes: [
            GoRoute(path: 'search', builder: (_, __) => const SearchUserScreen()),
            GoRoute(
              path: ':userId',
              builder: (ctx, st) =>
                  ChatScreen(userId: st.pathParameters['userId']!),
            ),
          ],
        ),
      ],
    ),
  ],
);

