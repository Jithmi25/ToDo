import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;

///
import '../models/task.dart';
import '../models/user.dart';

class HiveDataStore {
  static const usersCollection = 'users';
  static const tasksSubCollection = 'tasks';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  CollectionReference<Map<String, dynamic>>? get _tasksRef {
    final userId = _currentUserId;
    if (userId == null) return null;
    return _firestore
        .collection(usersCollection)
        .doc(userId)
        .collection(tasksSubCollection);
  }

  // ===== Task Methods =====

  /// Add new Task
  Future<void> addTask({required Task task}) async {
    final tasksRef = _tasksRef;
    if (tasksRef == null) {
      throw StateError('User not logged in');
    }

    await tasksRef.doc(task.id).set(_taskToMap(task));
  }

  /// Show task
  Future<Task?> getTask({required String id}) async {
    final tasksRef = _tasksRef;
    if (tasksRef == null) {
      return null;
    }

    final doc = await tasksRef.doc(id).get();
    if (!doc.exists) {
      return null;
    }

    return _taskFromDoc(doc);
  }

  /// Update task
  Future<void> updateTask({required Task task}) async {
    final tasksRef = _tasksRef;
    if (tasksRef == null) {
      throw StateError('User not logged in');
    }

    await tasksRef.doc(task.id).set(_taskToMap(task), SetOptions(merge: true));
  }

  /// Delete task
  Future<void> dalateTask({required Task task}) async {
    final tasksRef = _tasksRef;
    if (tasksRef == null) {
      return;
    }

    await tasksRef.doc(task.id).delete();
  }

  Stream<List<Task>> listenToTask() {
    final tasksRef = _tasksRef;
    if (tasksRef == null) {
      return Stream.value(<Task>[]);
    }

    return tasksRef
        .orderBy('createdAtDate')
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_taskFromDoc).toList());
  }

  Future<void> clearAllTasks() async {
    final tasksRef = _tasksRef;
    if (tasksRef == null) {
      return;
    }

    final snapshot = await tasksRef.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  // ===== User/Auth Methods =====

  /// Register a new user
  Future<bool> registerUser({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(fullName);

      final userId = credential.user?.uid;
      if (userId != null) {
        await _firestore.collection(usersCollection).doc(userId).set({
          'email': email,
          'fullName': fullName,
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      await _auth.signOut();
      return true;
    } on fb_auth.FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        return false;
      }
      debugPrint('Error registering user: ${e.message}');
      return false;
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
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final authUser = credential.user;
      if (authUser == null) {
        return null;
      }

      final userDoc = await _firestore
          .collection(usersCollection)
          .doc(authUser.uid)
          .get();

      final data = userDoc.data();
      final createdAtTimestamp = data?['createdAt'];

      return User(
        id: authUser.uid,
        email: authUser.email ?? email,
        password: '',
        fullName:
            (data?['fullName'] as String?) ?? authUser.displayName ?? 'User',
        createdAt: createdAtTimestamp is Timestamp
            ? createdAtTimestamp.toDate()
            : DateTime.now(),
      );
    } on fb_auth.FirebaseAuthException {
      return null;
    } catch (e) {
      debugPrint('Error logging in: $e');
      return null;
    }
  }

  /// Reset user password using email
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    try {
      final signInMethods = await _auth.fetchSignInMethodsForEmail(email);
      if (signInMethods.isEmpty) {
        return false;
      }

      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Error resetting password: $e');
      return false;
    }
  }

  /// Get current logged-in user
  User? getCurrentUser() {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        return null;
      }

      return User(
        id: currentUser.uid,
        email: currentUser.email ?? '',
        password: '',
        fullName: currentUser.displayName ?? 'User',
        createdAt: currentUser.metadata.creationTime ?? DateTime.now(),
      );
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  /// Logout user
  Future<void> logoutUser() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Error logging out: $e');
    }
  }

  /// Check if user is logged in
  bool isUserLoggedIn() {
    return _auth.currentUser != null;
  }

  Map<String, dynamic> _taskToMap(Task task) {
    return {
      'title': task.title,
      'subtitle': task.subtitle,
      'createdAtTime': Timestamp.fromDate(task.createdAtTime),
      'createdAtDate': Timestamp.fromDate(task.createdAtDate),
      'isCompleted': task.isCompleted,
      'category': task.category,
    };
  }

  Task _taskFromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    final createdAtTime = data['createdAtTime'];
    final createdAtDate = data['createdAtDate'];

    return Task(
      id: doc.id,
      title: (data['title'] as String?) ?? '',
      subtitle: (data['subtitle'] as String?) ?? '',
      createdAtTime: createdAtTime is Timestamp
          ? createdAtTime.toDate()
          : DateTime.now(),
      createdAtDate: createdAtDate is Timestamp
          ? createdAtDate.toDate()
          : DateTime.now(),
      isCompleted: (data['isCompleted'] as bool?) ?? false,
      category: (data['category'] as String?) ?? 'General',
    );
  }
}
