// Example: How to use FirebaseService in your app

// ==================== In Login View ====================

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/task.dart';
import 'firebase_service.dart';

class LoginExample {
  final firebaseService = FirebaseService();

  // Sign up
  Future<void> handleSignUp(String email, String password, String name) async {
    try {
      await firebaseService.signUp(
        email: email,
        password: password,
        name: name,
      );
      // Navigate to home
    } on FirebaseAuthException catch (e) {
      print('Sign up error: ${e.message}');
    }
  }

  // Sign in
  Future<void> handleSignIn(String email, String password) async {
    try {
      await firebaseService.signIn(email: email, password: password);
      // Navigate to home
    } on FirebaseAuthException catch (e) {
      print('Sign in error: ${e.message}');
    }
  }

  // Sign out
  Future<void> handleSignOut() async {
    await firebaseService.signOut();
  }
}

// ==================== In Home View (Tasks) ====================

class HomeViewExample extends StatefulWidget {
  const HomeViewExample({super.key});

  @override
  State<HomeViewExample> createState() => _HomeViewExampleState();
}

class _HomeViewExampleState extends State<HomeViewExample> {
  final firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Task>>(
        stream: firebaseService.getUserTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final tasks = snapshot.data ?? [];

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return ListTile(
                title: Text(task.title),
                trailing: Checkbox(
                  value: task.isCompleted,
                  onChanged: (value) {
                    if (value != null) {
                      firebaseService.toggleTaskCompletion(task.id, value);
                    }
                  },
                ),
                onLongPress: () {
                  firebaseService.deleteTask(task.id);
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTaskDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTaskDialog(BuildContext context) {
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Task'),
          content: TextField(
            controller: titleController,
            decoration: const InputDecoration(hintText: 'Enter task title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  final task = Task(
                    id: '',
                    title: titleController.text,
                    subtitle: '',
                    createdAtTime: DateTime.now(),
                    createdAtDate: DateTime.now(),
                    isCompleted: false,
                    category: 'General',
                  );

                  await firebaseService.addTask(task);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}

// ==================== Check Authentication Status ====================

void checkAuthStatus() {
  final firebaseService = FirebaseService();
  final currentUser = firebaseService.currentUser;

  if (currentUser != null) {
    print('User logged in: ${currentUser.email}');
  } else {
    print('User not logged in');
  }
}

// ==================== Get User Profile ====================

Future<void> loadUserProfile() async {
  final firebaseService = FirebaseService();
  try {
    final profile = await firebaseService.getUserProfile();
    if (profile != null) {
      print('User: ${profile.name}, Email: ${profile.email}');
    }
  } catch (e) {
    print('Error loading profile: $e');
  }
}
