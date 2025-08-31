import 'package:cloud_firestore/cloud_firestore.dart';

enum HabitCategory {
  health('Health', '🏥'),
  study('Study', '📚'),
  fitness('Fitness', '💪'),
  productivity('Productivity', '⚡'),
  mentalHealth('Mental Health', '🧘'),
  other('Others', '📌');

  const HabitCategory(this.displayName, this.icon);
  final String displayName;
  final String icon;
}

enum HabitFrequency {
  daily('Daily'),
  weekly('Weekly');

  const HabitFrequency(this.displayName);
  final String displayName;
}

class Habit {
  final String id;
  final String userId;
  final String title;
  final HabitCategory category;
  final HabitFrequency frequency;
  final DateTime createdAt;
  final DateTime? startDate;
  final String? notes;
  final int currentStreak;
  final List<DateTime> completionHistory;

  Habit({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.frequency,
    required this.createdAt,
    this.startDate,
    this.notes,
    this.currentStreak = 0,
    this.completionHistory = const [],
  });

  factory Habit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return Habit(
      id: doc.id,
      userId: data['userId'] ?? '',
      title: data['title'] ?? '',
      category: HabitCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => HabitCategory.other,
      ),
      frequency: HabitFrequency.values.firstWhere(
        (f) => f.name == data['frequency'],
        orElse: () => HabitFrequency.daily,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      startDate: (data['startDate'] as Timestamp?)?.toDate(),
      notes: data['notes'],
      currentStreak: data['currentStreak'] ?? 0,
      completionHistory: (data['completionHistory'] as List<dynamic>? ?? [])
          .map((timestamp) => (timestamp as Timestamp).toDate())
          .toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'category': category.name,
      'frequency': frequency.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'notes': notes,
      'currentStreak': currentStreak,
      'completionHistory': completionHistory
          .map((date) => Timestamp.fromDate(date))
          .toList(),
    };
  }

  Habit copyWith({
    String? title,
    HabitCategory? category,
    HabitFrequency? frequency,
    DateTime? startDate,
    String? notes,
    int? currentStreak,
    List<DateTime>? completionHistory,
  }) {
    return Habit(
      id: id,
      userId: userId,
      title: title ?? this.title,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      createdAt: createdAt,
      startDate: startDate ?? this.startDate,
      notes: notes ?? this.notes,
      currentStreak: currentStreak ?? this.currentStreak,
      completionHistory: completionHistory ?? this.completionHistory,
    );
  }

  bool get isCompletedToday {
    final today = DateTime.now();
    return completionHistory.any((date) => 
      date.year == today.year &&
      date.month == today.month &&
      date.day == today.day
    );
  }

  bool get isCompletedThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return completionHistory.any((date) => 
      date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
      date.isBefore(now.add(const Duration(days: 1)))
    );
  }

  int get completionsThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    
    return completionHistory.where((date) => 
      date.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
      date.isBefore(now.add(const Duration(days: 1)))
    ).length;
  }

  double get completionRate {
    if (completionHistory.isEmpty) return 0.0;
    
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
    final expectedCompletions = frequency == HabitFrequency.daily 
        ? daysSinceCreation 
        : (daysSinceCreation / 7).ceil();
    
    return (completionHistory.length / expectedCompletions).clamp(0.0, 1.0);
  }
}