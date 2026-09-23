import 'package:flutter_test/flutter_test.dart';
import 'package:to_do/models/task.dart';

void main() {
  group('Task Model Tests', () {
    test(
      'Task.create generates a task with default priority and false completion',
      () {
        final task = Task.create(
          title: 'Complete homework',
          subtitle: 'Math chapter 4',
          category: 'Study',
        );

        expect(task.title, equals('Complete homework'));
        expect(task.subtitle, equals('Math chapter 4'));
        expect(task.category, equals('Study'));
        expect(task.priority, equals('Medium'));
        expect(task.isCompleted, isFalse);
        expect(task.id, isNotEmpty);
      },
    );

    test('Task.create supports custom priority and dates', () {
      final testDate = DateTime(2026, 10, 15);
      final task = Task.create(
        title: 'Pay electricity bill',
        subtitle: 'Due this Friday',
        category: 'Shopping',
        priority: 'High',
        createdAtDate: testDate,
      );

      expect(task.priority, equals('High'));
      expect(task.createdAtDate, equals(testDate));
      expect(task.category, equals('Shopping'));
    });

    test('Task completion status can be toggled', () {
      final task = Task.create(title: 'Walk the dog', subtitle: 'In the park');

      expect(task.isCompleted, isFalse);
      task.isCompleted = true;
      expect(task.isCompleted, isTrue);
    });
  });
}
