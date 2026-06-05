import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart'; // 👈 for kIsWeb
import 'dart:io';                          // 👈 for Platform.isAndroid
import 'firebase_options.dart';
import 'theme.dart';
import 'main_screen.dart';
import 'screens/login_screen.dart';
import 'services/locale_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mindful_curator/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'services/notification_service.dart';
import 'utils/app_state.dart';
import 'utils/budget_checker.dart';
import 'services/auth_service.dart';


// ── Stored globally so it's never garbage collected ──────────
final AppState _appState = AppState();


@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == "budgetHealthCheck") {
      await BudgetChecker.runDailyCheck();
    }
    return Future.value(true);
  });
}
// ── Global notifier — any widget can call this to switch language ─
final ValueNotifier<Locale> appLocale = ValueNotifier(const Locale('en'));

// ── Global notifier — any widget can call this to switch language ─
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

  // ── Notifications: only on mobile, never on web ───────────
  if (!kIsWeb) {
    try {
      await NotificationService.initialize();
    } catch (e) {
      // Don't crash the app if notifications fail to initialize
      debugPrint('Notification init failed: $e');
    }
  }

  // ── AppState: tracks foreground/background ─────────────────
  _appState.init();

  // ── Workmanager: only on Android/iOS, not web ─────────────
  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      "daily-budget-check",
      "budgetHealthCheck",
      frequency: const Duration(hours: 24),
    );
  }
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
          title: 'AI Based personal financial tracker',
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

          // ── Auth gate: shows login or main screen ──────────
          home: StreamBuilder<User?>(
            stream: AuthService().authStateChanges, // 👈 Consuming single-instance stream abstraction cleanly
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (snapshot.hasData) {
                // 📝 Note: SharedPreferences write operation successfully extracted to AuthService listener
                return const MainScreen();
              }

              return const LoginScreen();
            },
          ),
        );
      },
    );
  }
}
