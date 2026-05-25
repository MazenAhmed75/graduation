import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'main_screen.dart';
import 'screens/login_screen.dart';
import 'services/locale_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import 'services/notification_service.dart';

// ── Global notifier — any widget can call this to switch language ─
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));
Future<void> initializeNotifications() async {
  await NotificationService.initialize();
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  // Initialize notifications
  await initializeNotifications();

  // Load the user's saved language preference before showing the app
  appLocale.value = await LocaleService.getSavedLocale();

  // Enable offline persistence with generous cache size
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED, // cache everything
  );

  runApp(const MindfulCuratorApp());
}

class MindfulCuratorApp extends StatelessWidget {
  const MindfulCuratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder rebuilds the entire app when language changes
    // This is what makes the UI switch instantly without a restart
    return ValueListenableBuilder<Locale>(
      valueListenable: appLocale,
      builder: (context, locale, _) {
        return MaterialApp(
          title: 'Mindful Curator',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,

          // ── Localization setup ──────────────────────────────
          locale: locale,
          localizationsDelegates: [
            ...AppLocalizations.localizationsDelegates,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: AppLocalizations.supportedLocales,

          // ========================================================
          // CHANGE: Use StreamBuilder to check login state
          // ========================================================

          // ── Auth gate: shows login or main screen ───────────
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              // Show loading while checking auth state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // If logged in, show MainScreen
              if (snapshot.hasData) {
                return const MainScreen();
              }

              // If not logged in, show LoginScreen
              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
