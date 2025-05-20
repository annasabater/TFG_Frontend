// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:SkyNet/routes/app_router.dart';
import 'package:SkyNet/services/socket_service.dart';
import 'package:SkyNet/services/auth_service.dart';

/* ───── Providers ───── */
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/provider/theme_provider.dart';
import 'package:SkyNet/provider/language_provider.dart';
import 'package:SkyNet/provider/drone_provider.dart';
import 'package:SkyNet/provider/social_provider.dart';        // <-- NUEVO

/* ───── Modelos ───── */
import 'package:SkyNet/models/user.dart';

/* ───── i18n ───── */
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  SocketService.serverUrl = dotenv.env['SERVER_URL']!;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final lightScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF81D4FA),
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => DroneProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()), // <-- añadido

        /* Mantén sincronizado UserProvider con el usuario logueado */
        ProxyProvider<UserProvider, void>(
          update: (_, prov, __) {
            final raw = AuthService().currentUser;
            if (raw != null) prov.setCurrentUser(User.fromJson(raw));
          },
        ),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (_, themeProv, langProv, __) => MaterialApp.router(
          title: 'S K Y N E T',
          debugShowCheckedModeBanner: false,
          routerConfig: appRouter,
          themeMode: themeProv.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: langProv.currentLocale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'), // English
            Locale('es'), // Spanish
            Locale('ca'), // Catalan
          ],

          /* ───── Tema claro ───── */
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightScheme,
            scaffoldBackgroundColor: lightScheme.background,
            appBarTheme: AppBarTheme(
              backgroundColor: lightScheme.primary,
              foregroundColor: lightScheme.onPrimary,
              elevation: 0,
            ),
            drawerTheme: DrawerThemeData(backgroundColor: lightScheme.surface),
            cardTheme: CardTheme(
              color: lightScheme.surface,
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: lightScheme.primary,
                foregroundColor: lightScheme.onPrimary,
                elevation: 2,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: lightScheme.primaryContainer),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: lightScheme.primaryContainer),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: lightScheme.primary),
              ),
              filled: true,
              fillColor: lightScheme.surfaceVariant,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),

          /* ───── Tema oscuro ───── */
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF263238),
              brightness: Brightness.dark,
            ),
          ),
        ),
      ),
    );
  }
}
