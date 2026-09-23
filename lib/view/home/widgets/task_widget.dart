import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../main.dart';
import '../../../models/task.dart';
import '../../../utils/colors.dart';
import '../../../view/tasks/task_view.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({super.key, required this.task});

  final Task task;

  static const Map<String, Color> _categoryColors = {
    'General': Color(0xff4568dc),
    'Work': Color(0xff2563eb),
    'Personal': Color(0xff7c3aed),
    'Study': Color(0xff059669),
    'Shopping': Color(0xffd97706),
    'Health': Color(0xffdc2626),
  };

  static const Map<String, IconData> _categoryIcons = {
    'General': Icons.folder_outlined,
    'Work': Icons.business_center_outlined,
    'Personal': Icons.person_outline,
    'Study': Icons.school_outlined,
    'Shopping': Icons.shopping_bag_outlined,
    'Health': Icons.favorite_border,
  };

  static const Map<String, Color> _priorityColors = {
    'Low': Color(0xff10b981),
    'Medium': Color(0xfff59e0b),
    'High': Color(0xffef4444),
  };

  bool get _isOverdue {
    if (task.isCompleted) return false;
    final now = DateTime.now();
    final taskDateTime = DateTime(
      task.createdAtDate.year,
      task.createdAtDate.month,
      task.createdAtDate.day,
      task.createdAtTime.hour,
      task.createdAtTime.minute,
    );
    return taskDateTime.isBefore(now);
  }

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColors[task.category] ?? MyColors.primaryColor;
    final catIcon = _categoryIcons[task.category] ?? Icons.folder_outlined;
    final priorityColor =
        _priorityColors[task.priority] ?? const Color(0xfff59e0b);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (ctx) => TaskView(task: task)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: task.isCompleted ? Colors.grey.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: task.isCompleted
                ? Colors.grey.shade200
                : (_isOverdue
                      ? Colors.red.withValues(alpha: 0.3)
                      : Colors.grey.shade200),
            width: _isOverdue && !task.isCompleted ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              offset: const Offset(0, 3),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Checkbox button
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: GestureDetector(
                onTap: () async {
                  task.isCompleted = !task.isCompleted;
                  await BaseWidget.of(context).dataStore.updateTask(task: task);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: task.isCompleted
                        ? MyColors.primaryColor
                        : Colors.transparent,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: task.isCompleted
                          ? MyColors.primaryColor
                          : Colors.grey.shade400,
                      width: 2,
                    ),
                  ),
                  child: task.isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Content Section (Title, notes, tags)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: task.isCompleted
                          ? Colors.grey.shade400
                          : Colors.black87,
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: Colors.grey.shade400,
                    ),
                  ),
                  if (task.subtitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      task.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: task.isCompleted
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),

                  // Metadata Badges (Category, Priority, Overdue)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(catIcon, size: 12, color: catColor),
                            const SizedBox(width: 4),
                            Text(
                              task.category,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: catColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Priority Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: priorityColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.priority,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: priorityColor,
                          ),
                        ),
                      ),

                      // Overdue Tag
                      if (_isOverdue)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 12,
                                color: Colors.red,
                              ),
                              SizedBox(width: 3),
                              Text(
                                'Overdue',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Due Date & Time column
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateFormat('hh:mm a').format(task.createdAtTime),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _isOverdue
                        ? Colors.red
                        : (task.isCompleted
                              ? Colors.grey.shade400
                              : MyColors.primaryColor),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  DateFormat.yMMMd().format(task.createdAtDate),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    CupertinoIcons.trash,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  onPressed: () async {
                    final shouldDelete = await showCupertinoDialog<bool>(
                      context: context,
                      builder: (ctx) => CupertinoAlertDialog(
                        title: const Text('Delete Task'),
                        content: const Text(
                          'Are you sure you want to delete this task?',
                        ),
                        actions: [
                          CupertinoDialogAction(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancel'),
                          ),
                          CupertinoDialogAction(
                            isDestructiveAction: true,
                            onPressed: () => Navigator.pop(ctx, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true && context.mounted) {
                      await BaseWidget.of(
                        context,
                      ).dataStore.deleteTask(task: task);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Task deleted'),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () {
                                BaseWidget.of(
                                  context,
                                ).dataStore.addTask(task: task);
                              },
                            ),
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
