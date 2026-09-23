import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../utils/colors.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _isCleaning = false;

  Future<void> _clearCompletedTasks() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Completed Tasks'),
        content: const Text(
          'Are you sure you want to remove all completed tasks? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (shouldClear == true && mounted) {
      setState(() => _isCleaning = true);
      try {
        await BaseWidget.of(context).dataStore.clearCompletedTasks();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Completed tasks cleared successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isCleaning = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // Appearance Section
            const Text(
              'Appearance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, currentMode, _) {
                      return ListTile(
                        leading: Icon(
                          currentMode == ThemeMode.dark
                              ? Icons.dark_mode
                              : (currentMode == ThemeMode.light
                                    ? Icons.light_mode
                                    : Icons.brightness_auto),
                          color: MyColors.primaryColor,
                        ),
                        title: const Text('App Theme'),
                        subtitle: Text(
                          currentMode == ThemeMode.dark
                              ? 'Dark Mode'
                              : (currentMode == ThemeMode.light
                                    ? 'Light Mode'
                                    : 'System Default'),
                        ),
                        trailing: DropdownButton<ThemeMode>(
                          value: currentMode,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(
                              value: ThemeMode.system,
                              child: Text('System'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.light,
                              child: Text('Light'),
                            ),
                            DropdownMenuItem(
                              value: ThemeMode.dark,
                              child: Text('Dark'),
                            ),
                          ],
                          onChanged: (mode) {
                            if (mode != null) {
                              themeNotifier.value = mode;
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Task Management Section
            const Text(
              'Task Management',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.clear_circled,
                      color: Colors.orange,
                    ),
                    title: const Text('Clear Completed Tasks'),
                    subtitle: const Text(
                      'Delete all tasks marked as completed',
                    ),
                    trailing: _isCleaning
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _isCleaning ? null : _clearCompletedTasks,
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(
                      CupertinoIcons.trash,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Delete All Tasks',
                      style: TextStyle(color: Colors.red),
                    ),
                    subtitle: const Text('Wipe all tasks from your account'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () async {
                      final shouldDelete = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Delete All Tasks'),
                          content: const Text(
                            'Are you sure you want to delete ALL your tasks? This cannot be undone!',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Delete Everything'),
                            ),
                          ],
                        ),
                      );

                      if (shouldDelete == true && context.mounted) {
                        await BaseWidget.of(context).dataStore.clearAllTasks();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All tasks deleted')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // About Section
            const Text(
              'About & Info',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.info_outline,
                      color: MyColors.primaryColor,
                    ),
                    title: const Text('About Task Manager'),
                    subtitle: const Text('Features, credits, and tips'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pushNamed(context, '/about');
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  const ListTile(
                    leading: Icon(Icons.verified_outlined, color: Colors.green),
                    title: Text('Version'),
                    subtitle: Text('1.0.0+1 (Stable)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
