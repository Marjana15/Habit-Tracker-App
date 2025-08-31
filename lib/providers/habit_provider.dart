import 'package:flutter/material.dart';
import 'dart:async';
import '../models/habit_model.dart';
import '../services/habit_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';

class HabitProvider extends ChangeNotifier {
  final HabitService _habitService = HabitService();
  final LocalStorageService _localStorage = LocalStorageService();
  final ConnectivityService _connectivity = ConnectivityService();
  
  List<Habit> _habits = [];
  bool _isLoading = false;
  bool _isOffline = false;
  String? _errorMessage;
  StreamSubscription<List<Habit>>? _habitsSubscription;
  StreamSubscription<bool>? _connectivitySubscription;
  Map<String, int> _stats = {
    'totalHabits': 0,
    'completedToday': 0,
    'maxStreak': 0,
    'totalCompletions': 0,
  };

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;
  Map<String, int> get stats => _stats;

  List<Habit> get habitsCompletedToday => 
      _habits.where((habit) => habit.isCompletedToday).toList();

  List<Habit> get pendingHabits => 
      _habits.where((habit) => !habit.isCompletedToday).toList();

  void startListening(String userId) {
    _habitsSubscription?.cancel();
    _connectivitySubscription?.cancel();
    
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((isOnline) {
      final wasOffline = _isOffline;
      _isOffline = !isOnline;
      
      if (wasOffline && isOnline) {
        _syncDataOnReconnect(userId);
      }
      
      notifyListeners();
    });
    
    _isOffline = !_connectivity.isOnline;
    
    if (_connectivity.isOnline) {
      _habitsSubscription = _habitService.getUserHabits(userId).listen(
        (habits) {
          _habits = habits;
          _updateStats();
          _localStorage.cacheHabits(userId, habits);
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error.toString();
          _loadCachedData(userId);
          notifyListeners();
        },
      );
    } else {
      _loadCachedData(userId);
    }
  }

  void stopListening() {
    _habitsSubscription?.cancel();
    _habitsSubscription = null;
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  Future<void> refreshHabits(String userId) async {
    if (_connectivity.isOnline) {
      try {
        final habits = await _habitService.getUserHabitsOnce(userId);
        _habits = habits;
        _updateStats();
        await _localStorage.cacheHabits(userId, habits);
        notifyListeners();
      } catch (e) {
        _errorMessage = e.toString();
        await _loadCachedData(userId);
        notifyListeners();
      }
    } else {
      await _loadCachedData(userId);
    }
  }

  Future<void> _loadCachedData(String userId) async {
    try {
      final cachedHabits = await _localStorage.getCachedHabits(userId);
      _habits = cachedHabits;
      _updateStats();
      if (cachedHabits.isNotEmpty) {
        _errorMessage = null;
      }
    } catch (e) {
      _errorMessage = 'Failed to load offline data: $e';
    }
  }

  Future<void> _syncDataOnReconnect(String userId) async {
    try {
      await refreshHabits(userId);
    } catch (e) {
      debugPrint('Error syncing data on reconnect: $e');
    }
  }

  Future<bool> createHabit({
    required String userId,
    required String title,
    required HabitCategory category,
    required HabitFrequency frequency,
    DateTime? startDate,
    String? notes,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _habitService.createHabit(
        userId: userId,
        title: title,
        category: category,
        frequency: frequency,
        startDate: startDate,
        notes: notes,
      );
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> updateHabit(Habit habit) async {
    _setLoading(true);
    _clearError();

    try {
      await _habitService.updateHabit(habit);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteHabit(String userId, String habitId) async {
    _setLoading(true);
    _clearError();

    try {
      await _habitService.deleteHabit(userId, habitId);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> markHabitComplete(String userId, String habitId) async {
    _clearError();

    try {
      await _habitService.markHabitComplete(userId, habitId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markHabitIncomplete(String userId, String habitId) async {
    _clearError();

    try {
      await _habitService.markHabitIncomplete(userId, habitId);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleHabitCompletion(String userId, String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    
    if (habit.isCompletedToday) {
      return await markHabitIncomplete(userId, habitId);
    } else {
      return await markHabitComplete(userId, habitId);
    }
  }

  Future<void> refreshStats(String userId) async {
    try {
      _stats = await _habitService.getHabitStats(userId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  void _updateStats() {
    _stats = {
      'totalHabits': _habits.length,
      'completedToday': _habits.where((h) => h.isCompletedToday).length,
      'maxStreak': _habits.isNotEmpty 
          ? _habits.map((h) => h.currentStreak).reduce((a, b) => a > b ? a : b)
          : 0,
      'totalCompletions': _habits
          .map((h) => h.completionHistory.length)
          .fold(0, (a, b) => a + b),
    };
  }

  Habit? getHabitById(String habitId) {
    try {
      return _habits.firstWhere((habit) => habit.id == habitId);
    } catch (e) {
      return null;
    }
  }

  List<Habit> getHabitsByCategory(HabitCategory category) {
    return _habits.where((habit) => habit.category == category).toList();
  }

  List<Habit> getHabitsByFrequency(HabitFrequency frequency) {
    return _habits.where((habit) => habit.frequency == frequency).toList();
  }

  double get overallCompletionRate {
    if (_habits.isEmpty) return 0.0;
    
    final totalRate = _habits
        .map((habit) => habit.completionRate)
        .fold(0.0, (a, b) => a + b);
    
    return totalRate / _habits.length;
  }

  int get currentStreakSum {
    return _habits
        .map((habit) => habit.currentStreak)
        .fold(0, (a, b) => a + b);
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  @override
  void dispose() {
    _habitsSubscription?.cancel();
    super.dispose();
  }
}