import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/habit_model.dart';

class HabitService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createHabit({
    required String userId,
    required String title,
    required HabitCategory category,
    required HabitFrequency frequency,
    DateTime? startDate,
    String? notes,
  }) async {
    try {
      final habitRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc();

      final habit = Habit(
        id: habitRef.id,
        userId: userId,
        title: title,
        category: category,
        frequency: frequency,
        createdAt: DateTime.now(),
        startDate: startDate,
        notes: notes,
      );

      await habitRef.set(habit.toFirestore());
      return habitRef.id;
    } catch (e) {
      throw Exception('Failed to create habit: ${e.toString()}');
    }
  }

  Future<void> updateHabit(Habit habit) async {
    try {
      await _firestore
          .collection('users')
          .doc(habit.userId)
          .collection('habits')
          .doc(habit.id)
          .update(habit.toFirestore());
    } catch (e) {
      throw Exception('Failed to update habit: ${e.toString()}');
    }
  }

  Future<void> deleteHabit(String userId, String habitId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete habit: ${e.toString()}');
    }
  }

  Stream<List<Habit>> getUserHabits(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('habits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
    });
  }

  Future<List<Habit>> getUserHabitsOnce(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .orderBy('createdAt', descending: true)
          .get();
      
      return snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to get habits: ${e.toString()}');
    }
  }

  Future<Habit?> getHabit(String userId, String habitId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId)
          .get();

      if (doc.exists) {
        return Habit.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get habit: ${e.toString()}');
    }
  }

  Future<void> markHabitComplete(String userId, String habitId) async {
    try {
      final habitRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(habitRef);
        if (!doc.exists) {
          throw Exception('Habit not found');
        }

        final habit = Habit.fromFirestore(doc);
        final now = DateTime.now();
        
        if (habit.frequency == HabitFrequency.daily) {
          final isAlreadyCompleted = habit.completionHistory.any((date) =>
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day
          );

          if (isAlreadyCompleted) {
            throw Exception('Habit already completed today! Come back tomorrow.');
          }
        } else if (habit.frequency == HabitFrequency.weekly) {
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final endOfWeek = startOfWeek.add(const Duration(days: 6));
          
          final isAlreadyCompletedThisWeek = habit.completionHistory.any((date) =>
            date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
            date.isBefore(endOfWeek.add(const Duration(days: 1)))
          );

          if (isAlreadyCompletedThisWeek) {
            throw Exception('Habit already completed this week! Come back next week.');
          }
        }

        final updatedHistory = [...habit.completionHistory, now];
        
        int newStreak = _calculateStreak(updatedHistory, habit.frequency);

        final updatedHabit = habit.copyWith(
          completionHistory: updatedHistory,
          currentStreak: newStreak,
        );

        transaction.update(habitRef, updatedHabit.toFirestore());
      });
    } catch (e) {
      throw Exception('Failed to mark habit complete: ${e.toString()}');
    }
  }

  Future<void> markHabitIncomplete(String userId, String habitId) async {
    try {
      final habitRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .doc(habitId);

      await _firestore.runTransaction((transaction) async {
        final doc = await transaction.get(habitRef);
        if (!doc.exists) {
          throw Exception('Habit not found');
        }

        final habit = Habit.fromFirestore(doc);
        final today = DateTime.now();

        final updatedHistory = habit.completionHistory.where((date) =>
          !(date.year == today.year &&
            date.month == today.month &&
            date.day == today.day)
        ).toList();

        int newStreak = _calculateStreak(updatedHistory, habit.frequency);

        final updatedHabit = habit.copyWith(
          completionHistory: updatedHistory,
          currentStreak: newStreak,
        );

        transaction.update(habitRef, updatedHabit.toFirestore());
      });
    } catch (e) {
      throw Exception('Failed to mark habit incomplete: ${e.toString()}');
    }
  }

  int _calculateStreak(List<DateTime> completionHistory, HabitFrequency frequency) {
    if (completionHistory.isEmpty) return 0;

    final sortedHistory = [...completionHistory]..sort((a, b) => b.compareTo(a));
    final today = DateTime.now();
    int streak = 0;

    if (frequency == HabitFrequency.daily) {
      DateTime checkDate = today;
      
      for (final completion in sortedHistory) {
        final completionDate = DateTime(completion.year, completion.month, completion.day);
        final currentCheckDate = DateTime(checkDate.year, checkDate.month, checkDate.day);
        
        if (completionDate == currentCheckDate) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (completionDate.isBefore(currentCheckDate)) {
          break;
        }
      }
    } else if (frequency == HabitFrequency.weekly) {
      final startOfCurrentWeek = today.subtract(Duration(days: today.weekday - 1));
      DateTime weekStart = startOfCurrentWeek;
      
      while (true) {
        final weekEnd = weekStart.add(const Duration(days: 6));
        
        bool hasCompletionThisWeek = sortedHistory.any((completion) =>
          completion.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          completion.isBefore(weekEnd.add(const Duration(days: 1)))
        );
        
        if (hasCompletionThisWeek) {
          streak++;
          weekStart = weekStart.subtract(const Duration(days: 7));
        } else {
          break;
        }
      }
    }

    return streak;
  }

  Future<Map<String, int>> getHabitStats(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('habits')
          .get();

      final habits = snapshot.docs.map((doc) => Habit.fromFirestore(doc)).toList();
      
      int totalHabits = habits.length;
      int completedToday = habits.where((h) => h.isCompletedToday).length;
      int maxStreak = habits.isNotEmpty 
          ? habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b)
          : 0;
      int totalCompletions = habits
          .map((h) => h.completionHistory.length)
          .fold(0, (a, b) => a + b);

      return {
        'totalHabits': totalHabits,
        'completedToday': completedToday,
        'maxStreak': maxStreak,
        'totalCompletions': totalCompletions,
      };
    } catch (e) {
      throw Exception('Failed to get habit stats: ${e.toString()}');
    }
  }
}