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

    // Daltonic color scheme (alta visibilidad, colores seguros para daltónicos)
    const daltonicColorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xFF0066CC), // Azul fuerte
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFFFFF00), // Amarillo fuerte
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFF00CC66), // Verde fuerte
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFFFF9900), // Naranja fuerte
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFFCC0066), // Rosa fuerte
      onTertiary: Color(0xFFFFFFFF),
      tertiaryContainer: Color(0xFF00FFFF), // Cian fuerte
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFB00020),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      outline: Color(0xFF000000),
      outlineVariant: Color(0xFF888888),
      background: Color(0xFFFFFFFF),
      onBackground: Color(0xFF000000),
      surface: Color(0xFFF2F2F2),
      onSurface: Color(0xFF000000),
      surfaceVariant: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFF000000),
      inverseSurface: Color(0xFF222222),
      onInverseSurface: Color(0xFFFFFFFF),
      inversePrimary: Color(0xFF0066CC),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      surfaceTint: Color(0xFF0066CC),
    );

    // Daltonic dark color scheme (alta visibilidad, colores seguros para daltónicos en oscuro)
    const daltonicDarkColorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF00BFFF), // Azul fuerte
      onPrimary: Color(0xFF000000),
      primaryContainer: Color(0xFFFFFF00), // Amarillo fuerte
      onPrimaryContainer: Color(0xFF000000),
      secondary: Color(0xFF00FF99), // Verde fuerte
      onSecondary: Color(0xFF000000),
      secondaryContainer: Color(0xFFFFB300), // Naranja fuerte
      onSecondaryContainer: Color(0xFF000000),
      tertiary: Color(0xFFFF00FF), // Magenta fuerte
      onTertiary: Color(0xFF000000),
      tertiaryContainer: Color(0xFF00FFFF), // Cian fuerte
      onTertiaryContainer: Color(0xFF000000),
      error: Color(0xFFFF3333),
      onError: Color(0xFF000000),
      errorContainer: Color(0xFFFFDAD6),
      onErrorContainer: Color(0xFF410002),
      outline: Color(0xFFFFFFFF),
      outlineVariant: Color(0xFF888888),
      background: Color(0xFF222222),
      onBackground: Color(0xFFFFFFFF),
      surface: Color(0xFF333333),
      onSurface: Color(0xFFFFFFFF),
      surfaceVariant: Color(0xFF444444),
      onSurfaceVariant: Color(0xFFFFFFFF),
      inverseSurface: Color(0xFFFFFFFF),
      onInverseSurface: Color(0xFF222222),
      inversePrimary: Color(0xFF00BFFF),
      shadow: Color(0xFF000000),
      scrim: Color(0xFF000000),
      surfaceTint: Color(0xFF00BFFF),
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
                colorScheme: themeProv.isDaltonicMode ? daltonicColorScheme : lightColorScheme,
                scaffoldBackgroundColor: themeProv.isDaltonicMode ? daltonicColorScheme.surface : lightColorScheme.surface,
                appBarTheme: AppBarTheme(
                  backgroundColor: themeProv.isDaltonicMode ? daltonicColorScheme.primary : lightColorScheme.primary,
                  foregroundColor: themeProv.isDaltonicMode ? daltonicColorScheme.onPrimary : lightColorScheme.onPrimary,
                  elevation: 0,
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: themeProv.isDaltonicMode ? daltonicColorScheme.surface : lightColorScheme.surface,
                ),
                cardTheme: CardTheme(
                  color: themeProv.isDaltonicMode ? daltonicColorScheme.surface : lightColorScheme.surface,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProv.isDaltonicMode ? daltonicColorScheme.primary : lightColorScheme.primary,
                    foregroundColor: themeProv.isDaltonicMode ? daltonicColorScheme.onPrimary : lightColorScheme.onPrimary,
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
                      color: themeProv.isDaltonicMode ? daltonicColorScheme.primaryContainer : lightColorScheme.primaryContainer,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: themeProv.isDaltonicMode ? daltonicColorScheme.primaryContainer : lightColorScheme.primaryContainer,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: themeProv.isDaltonicMode ? daltonicColorScheme.primary : lightColorScheme.primary,
                    ),
                  ),
                  filled: true,
                  fillColor: themeProv.isDaltonicMode ? daltonicColorScheme.surface : lightColorScheme.surfaceContainerHighest,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              darkTheme: ThemeData(
                useMaterial3: true,
                colorScheme: themeProv.isDaltonicMode ? daltonicDarkColorScheme : darkColorScheme,
                scaffoldBackgroundColor: themeProv.isDaltonicMode ? daltonicDarkColorScheme.surface : darkColorScheme.surface,
                appBarTheme: AppBarTheme(
                  backgroundColor: themeProv.isDaltonicMode ? daltonicDarkColorScheme.primary : darkColorScheme.primary,
                  foregroundColor: themeProv.isDaltonicMode ? daltonicDarkColorScheme.onPrimary : darkColorScheme.onPrimary,
                  elevation: 0,
                ),
                drawerTheme: DrawerThemeData(
                  backgroundColor: themeProv.isDaltonicMode ? daltonicDarkColorScheme.surface : darkColorScheme.surface,
                ),
                cardTheme: CardTheme(
                  color: themeProv.isDaltonicMode ? daltonicDarkColorScheme.surface : darkColorScheme.surface,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                elevatedButtonTheme: ElevatedButtonThemeData(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: themeProv.isDaltonicMode ? daltonicDarkColorScheme.primary : darkColorScheme.primary,
                    foregroundColor: themeProv.isDaltonicMode ? daltonicDarkColorScheme.onPrimary : darkColorScheme.onPrimary,
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
                      color: themeProv.isDaltonicMode ? daltonicDarkColorScheme.primaryContainer : darkColorScheme.primaryContainer,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: themeProv.isDaltonicMode ? daltonicDarkColorScheme.primaryContainer : darkColorScheme.primaryContainer,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: themeProv.isDaltonicMode ? daltonicDarkColorScheme.primary : darkColorScheme.primary,
                    ),
                  ),
                  filled: true,
                  fillColor: themeProv.isDaltonicMode ? daltonicDarkColorScheme.surface : darkColorScheme.surface,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              builder: (context, child) {
                if (themeProv.isReadingMode) {
                  return Stack(
                    children: [
                      child!,
                      IgnorePointer(
                        child: Container(
                          color: const Color(0x33FFD580), // Filtro cálido (naranja claro, 20% opacidad)
                        ),
                      ),
                    ],
                  );
                }
                return child!;
              },
            ),
      ),
    );
  }
}
