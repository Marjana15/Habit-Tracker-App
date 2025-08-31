import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit_model.dart';
import '../models/quote_model.dart';

class LocalStorageService {
  static const String _habitsKey = 'cached_habits';
  static const String _quotesKey = 'cached_quotes';
  static const String _favoriteQuotesKey = 'cached_favorite_quotes';
  static const String _lastSyncKey = 'last_sync_timestamp';

  Future<void> cacheHabits(String userId, List<Habit> habits) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = habits.map((habit) => habit.toFirestore()).toList();
      await prefs.setString('${_habitsKey}_$userId', jsonEncode(habitsJson));
      await _updateLastSyncTime();
      debugPrint('Cached ${habits.length} habits locally');
    } catch (e) {
      debugPrint('Error caching habits: $e');
    }
  }

  Future<List<Habit>> getCachedHabits(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsData = prefs.getString('${_habitsKey}_$userId');
      
      if (habitsData != null) {
        final List<dynamic> habitsJson = jsonDecode(habitsData);
        final habits = habitsJson.map((json) {
          return Habit(
            id: json['id'] ?? '',
            userId: json['userId'] ?? '',
            title: json['title'] ?? '',
            category: HabitCategory.values.firstWhere(
              (c) => c.name == json['category'],
              orElse: () => HabitCategory.other,
            ),
            frequency: HabitFrequency.values.firstWhere(
              (f) => f.name == json['frequency'],
              orElse: () => HabitFrequency.daily,
            ),
            createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
            startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
            notes: json['notes'],
            currentStreak: json['currentStreak'] ?? 0,
            completionHistory: (json['completionHistory'] as List<dynamic>? ?? [])
                .map((dateStr) => DateTime.parse(dateStr))
                .toList(),
          );
        }).toList();
        
        debugPrint('Loaded ${habits.length} habits from cache');
        return habits;
      }
    } catch (e) {
      debugPrint('Error loading cached habits: $e');
    }
    return [];
  }

  Future<void> cacheQuotes(List<Quote> quotes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quotesJson = quotes.map((quote) => quote.toJson()).toList();
      await prefs.setString(_quotesKey, jsonEncode(quotesJson));
      debugPrint('Cached ${quotes.length} quotes locally');
    } catch (e) {
      debugPrint('Error caching quotes: $e');
    }
  }

  Future<List<Quote>> getCachedQuotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quotesData = prefs.getString(_quotesKey);
      
      if (quotesData != null) {
        final List<dynamic> quotesJson = jsonDecode(quotesData);
        final quotes = quotesJson.map((json) => Quote.fromJson(json)).toList();
        debugPrint('Loaded ${quotes.length} quotes from cache');
        return quotes;
      }
    } catch (e) {
      debugPrint('Error loading cached quotes: $e');
    }
    return [];
  }

  Future<void> cacheFavoriteQuotes(String userId, List<FavoriteQuote> quotes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quotesJson = quotes.map((quote) => {
        ...quote.toJson(),
        'favoritedAt': quote.favoritedAt.toIso8601String(),
      }).toList();
      await prefs.setString('${_favoriteQuotesKey}_$userId', jsonEncode(quotesJson));
      debugPrint('Cached ${quotes.length} favorite quotes locally');
    } catch (e) {
      debugPrint('Error caching favorite quotes: $e');
    }
  }

  Future<List<FavoriteQuote>> getCachedFavoriteQuotes(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quotesData = prefs.getString('${_favoriteQuotesKey}_$userId');
      
      if (quotesData != null) {
        final List<dynamic> quotesJson = jsonDecode(quotesData);
        final quotes = quotesJson.map((json) => FavoriteQuote(
          id: json['_id'] ?? '',
          content: json['content'] ?? '',
          author: json['author'] ?? '',
          tags: List<String>.from(json['tags'] ?? []),
          length: json['length'] ?? 0,
          favoritedAt: DateTime.parse(json['favoritedAt']),
        )).toList();
        debugPrint('Loaded ${quotes.length} favorite quotes from cache');
        return quotes;
      }
    } catch (e) {
      debugPrint('Error loading cached favorite quotes: $e');
    }
    return [];
  }

  Future<void> _updateLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
    } catch (e) {
      debugPrint('Error updating last sync time: $e');
    }
  }

  Future<DateTime?> getLastSyncTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncData = prefs.getString(_lastSyncKey);
      if (lastSyncData != null) {
        return DateTime.parse(lastSyncData);
      }
    } catch (e) {
      debugPrint('Error getting last sync time: $e');
    }
    return null;
  }

  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keysToRemove = prefs.getKeys().where((key) => 
          key.startsWith(_habitsKey) || 
          key.startsWith(_quotesKey) || 
          key.startsWith(_favoriteQuotesKey) ||
          key == _lastSyncKey
      ).toList();
      
      for (final key in keysToRemove) {
        await prefs.remove(key);
      }
      debugPrint('Cleared local cache');
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }

  Future<bool> hasCachedData(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey('${_habitsKey}_$userId') || 
             prefs.containsKey(_quotesKey);
    } catch (e) {
      debugPrint('Error checking cached data: $e');
      return false;
    }
  }
}