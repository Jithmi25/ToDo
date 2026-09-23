import 'package:flutter/material.dart';
import '../../utils/colors.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'About & Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // App Banner
            Center(
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: MyColors.primaryGradientColor,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: MyColors.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_circle_outline,
                      size: 52,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Task Master Pro',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version 1.0.0+1',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A modern, intelligent task management and productivity suite powered by Firebase.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Feature Highlights
            const Text(
              'Key Features',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(
              icon: Icons.cloud_sync_outlined,
              color: MyColors.primaryColor,
              title: 'Real-Time Cloud Sync',
              description:
                  'Instant synchronization across devices with Firebase Firestore.',
            ),
            _buildFeatureItem(
              icon: Icons.label_important_outline,
              color: const Color(0xffef4444),
              title: 'Smart Priority Tracking',
              description:
                  'Organize high, medium, and low priority tasks at a glance.',
            ),
            _buildFeatureItem(
              icon: Icons.category_outlined,
              color: const Color(0xff7c3aed),
              title: 'Color-Coded Categories',
              description:
                  'Segment your tasks into Work, Study, Health, Personal, and Shopping.',
            ),
            _buildFeatureItem(
              icon: Icons.alarm,
              color: const Color(0xfff59e0b),
              title: 'Overdue Task Alerts',
              description:
                  'Never miss a deadline with automatic overdue flagging.',
            ),
            _buildFeatureItem(
              icon: Icons.dark_mode_outlined,
              color: const Color(0xff059669),
              title: 'Dark & Light Theme',
              description: 'Comfortable viewing in all lighting environments.',
            ),
            const SizedBox(height: 28),

            // Productivity Tips
            const Text(
              'Productivity Tips 💡',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: MyColors.primaryColor.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: MyColors.primaryColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '• Start each morning by reviewing High Priority tasks.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Swipe left on any task to delete, or tap the checkmark to mark done.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Use the filter chips (Pending, Completed) to maintain clarity.',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• Check your Productivity Stats on the Profile page to stay motivated!',
                    style: TextStyle(fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
