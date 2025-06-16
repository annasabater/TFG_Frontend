//lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:SkyNet/routes/app_router.dart';
import 'package:SkyNet/services/socket_service.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/web_config.dart';
import 'package:SkyNet/web_config_web.dart'
    if (dart.library.io) 'package:SkyNet/web_config_stub.dart';
import 'package:SkyNet/routes/app_router.dart';
import 'package:SkyNet/services/socket_service.dart';
import 'package:SkyNet/services/auth_service.dart';
import 'package:SkyNet/provider/users_provider.dart';
import 'package:SkyNet/provider/theme_provider.dart';
import 'package:SkyNet/provider/language_provider.dart';
import 'package:SkyNet/provider/drone_provider.dart';
import 'package:SkyNet/provider/social_provider.dart';
import 'package:SkyNet/models/user.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:SkyNet/provider/notification_provider.dart';
import 'package:SkyNet/provider/cart_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

     try {
     await dotenv.load(fileName: '.env');
     print('Archivo .env cargado correctamente');
   } catch (e) {
     print('Error al cargar archivo .env: $e');
   }
   // En Web, inicializar Google Maps API
   if (kIsWeb) {
     try {
       print('Inicializando configuración web...');
       // Configuramos API key
       if (dotenv.env.containsKey('GOOGLE_MAPS_API_KEY') &&
           dotenv.env['GOOGLE_MAPS_API_KEY']!.isNotEmpty) {
         final apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
         print('API key encontrada en .env: ${apiKey.substring(0, 3)}***');
         setupWebGoogleMapsApi(apiKey);
       } else {
         print(
           'ADVERTENCIA: GOOGLE_MAPS_API_KEY no está definida en el archivo .env',
         );
       }
     } catch (e) {
       print('Error al inicializar configuración web: $e');
     }
   }

   runApp(const MyApp());
 }


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Esquema de color personalizado: fondo y variantes en azul suave
    const lightColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF3B5BA9), // Azul principal
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFD6E3FF), // Azul claro
      onPrimaryContainer: Color(0xFF001B3A),
      secondary: Color(0xFF6B6478),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFE8DEF8),
      onSecondaryContainer: Color(0xFF231A2B),
      tertiary: Color(0xFF7D5260),
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFFFFD8E4),
      onTertiaryContainer: Color(0xFF31101B),
      error: Color(0xFFBA1A1A),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      outline: Color(0xFF79747E),
      outlineVariant: Color(0xFFCAC4D0),
      background: Color(0xFFF4F8FF), // Azul muy claro para fondo
      onBackground: Color(0xFF1C1B1F),
      surface: Color(0xFFEAF2FB), // Azul grisáceo claro para surface
      onSurface: Color(0xFF1C1B1F),
      surfaceVariant: Color(0xFFD6E3FF), // Azul claro para surface variant
      onSurfaceVariant: Color(0xFF49454F),
      inverseSurface: Color(0xFF322F35),
      onInverseSurface: Color(0xFFF5EFF7),
      inversePrimary: Color(0xFFA3B8FF), // Azul lavanda claro
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      surfaceTint: Color(0xFF3B5BA9),
    );

    const darkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFFA3B8FF), // Azul lavanda claro
      onPrimary: Color(0xFF001B3A),
      primaryContainer: Color(0xFF254377), // Azul oscuro
      onPrimaryContainer: Color(0xFFD6E3FF),
      secondary: Color(0xFFCCC2DC),
      onSecondary: Color(0xFF332D41),
      secondaryContainer: Color(0xFF4A4458),
      onSecondaryContainer: Color(0xFFE8DEF8),
      tertiary: Color(0xFFEFB8C8),
      onTertiary: Color(0xFF492532),
      tertiaryContainer: Color(0xFF633B48),
      onTertiaryContainer: Color(0xFFFFD8E4),
      error: Color(0xFFFFB4AB),
      onError: Color(0xFF690005),
      errorContainer: Color(0xFF93000A),
      onErrorContainer: Color(0xFFFFDAD6),
      outline: Color(0xFF938F99),
      outlineVariant: Color(0xFF49454F),
      background: Color(0xFF101624), // Azul grisáceo oscuro para fondo
      onBackground: Color(0xFFE6E1E5),
      surface: Color(0xFF18213A), // Azul oscuro para surface
      onSurface: Color(0xFFE6E1E5),
      surfaceVariant: Color(0xFF254377), // Azul oscuro para surface variant
      onSurfaceVariant: Color(0xFFCAC4D0),
      inverseSurface: Color(0xFFE6E1E5),
      onInverseSurface: Color(0xFF322F35),
      inversePrimary: Color(0xFF3B5BA9), // Azul principal
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      surfaceTint: Color(0xFFA3B8FF),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => DroneProvider()),
        ChangeNotifierProvider(create: (_) => SocialProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),

        ProxyProvider<UserProvider, void>(
          update: (_, prov, __) {
            final raw = AuthService().currentUser;
            if (raw != null) prov.setCurrentUser(User.fromJson(raw));
          },
        ),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder:
            (_, themeProv, langProv, __) => MaterialApp.router(
              title: 'S K Y N E T',
              debugShowCheckedModeBanner: false,
              routerConfig: appRouter,
              themeMode:
                  themeProv.isDarkMode ? ThemeMode.dark : ThemeMode.light,
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

              theme: ThemeData(
                useMaterial3: true,
                colorScheme: lightColorScheme,
                scaffoldBackgroundColor: lightColorScheme.surface,
                appBarTheme: AppBarTheme(
                  backgroundColor: lightColorScheme.primary,
                  foregroundColor: lightColorScheme.onPrimary,
                  elevation: 0,
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: lightColorScheme.surface,
                ),
                cardTheme: CardTheme(
                  color: lightColorScheme.surface,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lightColorScheme.primary,
                    foregroundColor: lightColorScheme.onPrimary,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                inputDecorationTheme: InputDecorationTheme(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: lightColorScheme.primaryContainer,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: lightColorScheme.primaryContainer,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: lightColorScheme.primary),
                  ),
                  filled: true,
                  fillColor: lightColorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: darkColorScheme,
              ),
            ),
      ),
    );
  }
}
