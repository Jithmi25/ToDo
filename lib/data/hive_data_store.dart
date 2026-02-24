import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

///
import '../models/task.dart';
import '../models/user.dart';

class HiveDataStore {
  static const taskBoxName = "tasksBox";
  static const userBoxName = "usersBox";
  static const currentUserBoxName = "currentUserBox";

  final Box<Task> taskBox = Hive.box<Task>(taskBoxName);
  final Box<User> userBox = Hive.box<User>(userBoxName);
  final Box<dynamic> currentUserBox = Hive.box(currentUserBoxName);

  // ===== Task Methods =====

  /// Add new Task
  Future<void> addTask({required Task task}) async {
    await taskBox.put(task.id, task);
  }

  /// Show task
  Future<Task?> getTask({required String id}) async {
    return taskBox.get(id);
  }

  /// Update task
  Future<void> updateTask({required Task task}) async {
    await task.save();
  }

  /// Delete task
  Future<void> dalateTask({required Task task}) async {
    await task.delete();
  }

  ValueListenable<Box<Task>> listenToTask() {
    return taskBox.listenable();
  }

  // ===== User/Auth Methods =====

  /// Register a new user
  Future<bool> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      // Check if email already exists
      final userExists = userBox.values.any((user) => user.email == email);
      if (userExists) {
        return false;
      }

      final newUser = User.create(
        email: email,
        password: password,
        fullName: fullName,
      );

      await userBox.put(newUser.id, newUser);
      return true;
    } catch (e) {
      debugPrint('Error registering user: $e');
      return false;
    }
  }

  /// Login user
  Future<User?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      User? user;
      for (var u in userBox.values) {
        if (u.email == email && u.password == password) {
          user = u;
          break;
        }
      }

      if (user != null) {
        // Store current user ID
        await currentUserBox.put('currentUserId', user.id);
      }

      return user;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  /// Get current logged-in user
  User? getCurrentUser() {
    try {
      final userId = currentUserBox.get('currentUserId');
      if (userId == null) return null;
      return userBox.get(userId);
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      await currentUserBox.delete('currentUserId');
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return currentUserBox.get('currentUserId') != null;
  }
}
