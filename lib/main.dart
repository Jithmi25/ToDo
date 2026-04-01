//? CodeWithFlexz on Instagram
//* AmirBayat0 on Github
//! Programming with Flexz on Youtube

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

///
import 'data/hive_data_store.dart';
import 'firebase_options.dart';
import 'models/task.dart';
import 'models/user.dart';
import 'view/home/home_view.dart';
import 'view/auth/login_view.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized before plugins
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
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Hive Todo App',
        theme: _buildAppTheme(),
        initialRoute: isLoggedIn ? '/home' : '/login',
        routes: {
          '/login': (context) => const LoginView(),
          '/home': (context) => const HomeView(),
        },
      ),
    );
  }

  /// Extract theme creation for better organization
  ThemeData _buildAppTheme() {
    return ThemeData(
      useMaterial3: true, // Consider using Material 3
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: Colors.black,
          fontSize: 45,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(
          color: Colors.grey,
          fontSize: 16,
          fontWeight: FontWeight.w300,
        ),
        displayMedium: TextStyle(color: Colors.white, fontSize: 21),
        displaySmall: TextStyle(
          color: Color.fromARGB(255, 234, 234, 234),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        headlineMedium: TextStyle(color: Colors.grey, fontSize: 17),
        headlineSmall: TextStyle(color: Colors.grey, fontSize: 16),
        titleSmall: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
        titleLarge: TextStyle(
          fontSize: 40,
          color: Colors.black,
          fontWeight: FontWeight.w300,
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
