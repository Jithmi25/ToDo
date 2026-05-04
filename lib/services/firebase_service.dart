import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/task.dart';
import '../models/user.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() {
    return _instance;
  }

  FirebaseService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ==================== Authentication ====================

  /// Get current user
  User? get currentUser => _auth.currentUser;

  /// Sign up with email and password
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _createUserDocument(userCredential.user!, name);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  /// Sign in with email and password
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      rethrow;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Create user document in Firestore
  Future<void> _createUserDocument(User user, String name) async {
    await _firestore.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== Tasks ====================

  /// Get all tasks for current user
  Stream<List<Task>> getUserTasks() {
    final userId = currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromJson({...doc.data(), 'id': doc.id}))
          .toList();
    });
  }

  /// Add a new task
  Future<DocumentReference> addTask(Task task) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .add({
      ...task.toJson(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Update a task
  Future<void> updateTask(String taskId, Task task) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({
      ...task.toJson(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Delete a task
  Future<void> deleteTask(String taskId) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  /// Toggle task completion status
  Future<void> toggleTaskCompletion(String taskId, bool isCompleted) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .doc(taskId)
        .update({
      'isCompleted': isCompleted,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== User Profile ====================

  /// Get user profile
  Future<UserProfile?> getUserProfile() async {
    final userId = currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserProfile.fromJson({...doc.data()!, 'uid': doc.id});
    }
    return null;
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await _firestore.collection('users').doc(userId).update({
      'name': profile.name,
      'email': profile.email,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== File Upload ====================

  /// Upload profile picture
  Future<String> uploadProfilePicture(String filePath) async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('users/$userId/profile/$fileName');

    await ref.putFile(File(filePath));
    return await ref.getDownloadURL();
  }

  // ==================== Batch Operations ====================

  /// Delete all tasks for current user
  Future<void> deleteAllTasks() async {
    final userId = currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .get();

    final batch = _firestore.batch();
    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }
}

// Model class for user profile
class UserProfile {
  final String uid;
  final String name;
  final String email;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
    };
  }
}

import 'dart:io';
