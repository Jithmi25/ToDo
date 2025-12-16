//? CodeWithFlexz on Instagram
//* AmirBayat0 on Github
//! Programming with Flexz on Youtube

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

///
import '../data/hive_data_store.dart';
import '../models/task.dart';
import '../view/home/home_view.dart';

Future<void> main() async {
  // Ensure Flutter binding is initialized before using Hive
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive DB
  await _initializeHive();

  runApp(const MyApp());
}

/// Separated Hive initialization logic for better organization
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Register Hive Adapter
  Hive.registerAdapter<Task>(TaskAdapter());

  // Open box with error handling
  try {
    final box = await Hive.openBox<Task>('tasksBox');
    await _cleanupOldTasks(box);
  } catch (e) {
    debugPrint('Failed to initialize Hive: $e');
    // Consider rethrowing or handling based on your app's needs
  }
}

/// Cleanup tasks from previous days
Future<void> _cleanupOldTasks(Box<Task> box) async {
  final now = DateTime.now();
  final tasksSnapshot = box.values.toList();

  final tasksToDelete = tasksSnapshot
      .where((task) => task.createdAtTime.day != now.day)
      .toList();

  // Use batch operation for better performance
  await box.deleteAll(
    tasksToDelete.map((task) => task.key).whereType<String>(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseWidget(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Hive Todo App',
        theme: _buildAppTheme(),
        home: const HomeView(),
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
  const BaseWidget({super.key, required super.child})
    : _dataStore = HiveDataStore();

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
