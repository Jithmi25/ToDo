import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/hive_data_store.dart';
import 'firebase_options.dart';
import 'utils/colors.dart';
import 'view/home/home_view.dart';
import 'view/auth/login_view.dart';
import 'view/auth/signup_view.dart';
import 'view/profile/profile_view.dart';
import 'view/settings/settings_view.dart';
import 'view/details/about_view.dart';
import 'view/not_found/not_found_view.dart';

/// Global notifier for switching app theme mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier<ThemeMode>(
  ThemeMode.system,
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final dataStore = BaseWidget(child: Container()).dataStore;
    final isLoggedIn = dataStore.isUserLoggedIn();

    return BaseWidget(
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Task Master Pro',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode: currentMode,
            initialRoute: isLoggedIn ? '/home' : '/login',
            routes: {
              '/login': (context) => const LoginView(),
              '/signup': (context) => const SignupView(),
              '/home': (context) => const HomeView(),
              '/profile': (context) => const ProfileView(),
              '/settings': (context) => const SettingsView(),
              '/about': (context) => const AboutView(),
            },
            onUnknownRoute: (settings) =>
                MaterialPageRoute(builder: (context) => const NotFoundView()),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MyColors.primaryColor,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: const Color(0xfff8fafc),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MyColors.primaryColor, width: 2),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MyColors.primaryColor,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xff0f172a),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xff1e293b),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: const Color(0xff1e293b),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xff1e293b),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xff334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: MyColors.primaryColor, width: 2),
        ),
      ),
    );
  }
}

/// BaseWidget to provide dataStore throughout the app
class BaseWidget extends InheritedWidget {
  BaseWidget({super.key, required super.child}) : _dataStore = HiveDataStore();

  final HiveDataStore _dataStore;

  HiveDataStore get dataStore => _dataStore;

  static BaseWidget of(BuildContext context) {
    final base = context.dependOnInheritedWidgetOfExactType<BaseWidget>();
    assert(base != null, 'No BaseWidget found in context');
    return base!;
  }

  static HiveDataStore dataStoreOf(BuildContext context) {
    return of(context).dataStore;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
