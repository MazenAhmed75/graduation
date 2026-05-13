import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'main_screen.dart';
import 'screens/login_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: ".env");

  runApp(const MindfulCuratorApp());
}

class MindfulCuratorApp extends StatelessWidget {
  const MindfulCuratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mindful Curator',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,

      // ========================================================
      // CHANGE: Use StreamBuilder to check login state
      // ========================================================
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
  }
}