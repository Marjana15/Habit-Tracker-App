# Habit Tracker App - Complete Study Guide for Viva

## 📱 Application Overview

**Habit Tracker App** is a comprehensive Flutter application designed to help users build and maintain healthy habits through gamification, progress tracking, and daily motivation. The app uses Firebase as its backend and follows modern Flutter development practices.

### Key Features
- ✅ Habit creation and management
- 📊 Progress tracking with detailed analytics
- 🔥 Streak tracking and gamification
- 💬 Daily motivational quotes
- 🌙 Light/Dark theme support
- 📴 Offline functionality
- 🔐 Authentication with Google Sign-In
- 👤 User profile management

---

## 🗂️ Lib Folder Structure

```
lib/
├── main.dart                    # App entry point
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── habit_model.dart
│   ├── quote_model.dart
│   └── user_model.dart
├── providers/                   # State management
│   ├── auth_provider.dart
│   ├── habit_provider.dart
│   ├── quotes_provider.dart
│   └── theme_provider.dart
├── screens/                     # UI screens
│   ├── splash_screen.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── home_screen.dart
│   ├── habits_screen.dart
│   ├── create_habit_screen.dart
│   ├── edit_habit_screen.dart
│   ├── habit_detail_screen.dart
│   ├── habit_progress_screen.dart
│   ├── profile_screen.dart
│   ├── edit_profile_screen.dart
│   ├── settings_screen.dart
│   └── favorites_quotes_screen.dart
├── services/                    # Business logic
│   ├── auth_service.dart
│   ├── habit_service.dart
│   ├── quotes_service.dart
│   ├── local_storage_service.dart
│   └── connectivity_service.dart
├── widgets/                     # Reusable UI components
│   ├── animated_background.dart
│   ├── completion_animation.dart
│   ├── design_system.dart
│   ├── offline_indicator.dart
│   ├── progress_chart.dart
│   └── quote_card.dart
└── utils/                       # Utilities
    ├── app_theme.dart
    └── validators.dart
```

---

## 🚀 App Entry Point & Architecture

### main.dart:14-20
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const HabitTrackerApp());
}
```

**Function:** App initialization and Firebase setup
- Initializes Firebase with platform-specific configuration
- Sets up the main app widget with providers

### HabitTrackerApp (main.dart:22-64)
- **Purpose:** Root application widget with state management setup
- **Key Components:**
  - `MultiProvider` for dependency injection
  - Theme management with light/dark modes
  - Global navigation configuration

### Provider Configuration (main.dart:44-49)
```dart
providers: [
  ChangeNotifierProvider.value(value: _themeProvider),
  ChangeNotifierProvider(create: (context) => AuthProvider()),
  ChangeNotifierProvider(create: (context) => HabitProvider()),
  ChangeNotifierProvider(create: (context) => QuotesProvider()),
]
```

---

## 📊 Data Models

### 1. Habit Model (habit_model.dart)

**Enums:**
- `HabitCategory`: Health, Study, Fitness, Productivity, Mental Health, Others
- `HabitFrequency`: Daily, Weekly

**Main Class - Habit:**
```dart
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
}
```

**Key Methods with Code Examples:**

**fromFirestore() Method (Lines 49-72):**
```dart
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
    completionHistory: (data['completionHistory'] as List<dynamic>? ?? [])
        .map((timestamp) => (timestamp as Timestamp).toDate())
        .toList(),
  );
}
```

**isCompletedToday Getter (Lines 113-120):**
```dart
bool get isCompletedToday {
  final today = DateTime.now();
  return completionHistory.any((date) => 
    date.year == today.year &&
    date.month == today.month &&
    date.day == today.day
  );
}
```

**completionRate Calculation (Lines 142-151):**
```dart
double get completionRate {
  if (completionHistory.isEmpty) return 0.0;
  
  final daysSinceCreation = DateTime.now().difference(createdAt).inDays + 1;
  final expectedCompletions = frequency == HabitFrequency.daily 
      ? daysSinceCreation 
      : (daysSinceCreation / 7).ceil();
  
  return (completionHistory.length / expectedCompletions).clamp(0.0, 1.0);
}
```

### 2. Quote Model (quote_model.dart)

**Quote Class:**
```dart
class Quote {
  final String id;
  final String content;
  final String author;
  final List<String> tags;
  final int length;
}
```

**FavoriteQuote Class:**
```dart
class FavoriteQuote extends Quote {
  final DateTime favoritedAt;
}
```

### 3. User Model (user_model.dart)

**AppUser Class:**
```dart
class AppUser {
  final String uid;
  final String displayName;
  final String email;
  final String? gender;
  final DateTime? dateOfBirth;
  final double? height;
  final String? photoURL;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

---

## 🎯 State Management (Providers)

### 1. AuthProvider (auth_provider.dart)

**Purpose:** Manages user authentication state and operations

**Key Properties:**
- `currentUser` - Current logged-in user
- `isLoading` - Authentication operation status
- `isAuthenticated` - User login status

**Key Methods with Implementation:**

**signIn() Method with Error Handling:**
```dart
Future<bool> signIn({
  required String email,
  required String password,
}) async {
  _setLoading(true);
  _clearError();

  try {
    final userCredential = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (userCredential?.user != null) {
      await _loadUserProfile(userCredential!.user!.uid);
      _setLoading(false);
      return true;
    }
  } catch (e) {
    String errorMessage;
    if (e.toString().contains('Exception: ')) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } else {
      errorMessage = e.toString();
    }
    
    _errorMessage = errorMessage;
  }
  
  _setLoading(false);
  return false;
}
```

**Google Sign-In Implementation:**
```dart
Future<bool> signInWithGoogle() async {
  _setLoading(true);
  _clearError();

  try {
    final userCredential = await _authService.signInWithGoogle();
    
    if (userCredential?.user != null) {
      await _loadUserProfile(userCredential!.user!.uid);
      _setLoading(false);
      return true;
    } else {
      _setLoading(false);
      return false;
    }
  } catch (e) {
    String errorMessage;
    if (e.toString().contains('Exception: ')) {
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } else {
      errorMessage = e.toString();
    }
    
    _errorMessage = errorMessage;
    _setLoading(false);
    return false;
  }
}
```

### 2. HabitProvider (habit_provider.dart)

**Purpose:** Manages habit data, offline caching, and real-time updates

**Key Properties:**
- `habits` - List of user's habits
- `stats` - Habit statistics (total, completed today, streaks)
- `isOffline` - Connectivity status

**Key Methods:**
- `createHabit()` - Create new habit
- `updateHabit()` - Modify existing habit
- `deleteHabit()` - Remove habit
- `toggleHabitCompletion()` - Mark habit complete/incomplete
- `startListening()` - Begin real-time updates

**Offline Features with Implementation:**

**Offline Handling with Auto-Sync (Lines 42-72):**
```dart
_connectivitySubscription = _connectivity.onConnectivityChanged.listen((isOnline) {
  final wasOffline = _isOffline;
  _isOffline = !isOnline;
  
  if (wasOffline && isOnline) {
    _syncDataOnReconnect(userId);
  }
  
  notifyListeners();
});

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
```

**Real-time Statistics Calculation (Lines 225-236):**
```dart
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
```

### 3. QuotesProvider (quotes_provider.dart)

**Purpose:** Manages motivational quotes and favorite quotes

**Key Methods with Implementation:**

**Offline-First Loading Pattern (Lines 33-71):**
```dart
Future<void> loadQuotes({bool refresh = false}) async {
  if (_isLoading) return;
  
  _isLoading = true;
  _errorMessage = null;
  _isOffline = !_connectivity.isOnline;
  notifyListeners();

  try {
    if (_connectivity.isOnline || refresh) {
      final quotes = await _quotesService.fetchRandomQuotes(limit: 15);
      _quotes = quotes;
      await _localStorage.cacheQuotes(quotes);
    } else {
      final cachedQuotes = await _localStorage.getCachedQuotes();
      if (cachedQuotes.isNotEmpty) {
        _quotes = cachedQuotes;
      } else {
        final quotes = await _quotesService.fetchRandomQuotes(limit: 15);
        _quotes = quotes;
      }
    }
  } catch (e) {
    _errorMessage = 'Failed to load quotes: $e';
    try {
      final cachedQuotes = await _localStorage.getCachedQuotes();
      if (cachedQuotes.isNotEmpty) {
        _quotes = cachedQuotes;
        _errorMessage = null;
      }
    } catch (cacheError) {
      debugPrint('Failed to load cached quotes: $cacheError');
    }
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}
```

**Clipboard Integration:**
```dart
Future<void> copyQuoteToClipboard(Quote quote) async {
  await Clipboard.setData(
    ClipboardData(text: '"${quote.content}" - ${quote.author}'),
  );
}
```

**API Integration:**
- Primary: Quotable.io API
- Fallback: ZenQuotes.io API
- Offline: 20+ hardcoded quotes

### 4. ThemeProvider (theme_provider.dart)

**Purpose:** Manages app theme (Light/Dark/System)

**Key Features with Code Implementation:**

**Theme Toggle Logic (Lines 39-54):**
```dart
Future<void> toggleTheme({String? userId}) async {
  ThemeMode newMode;
  switch (_themeMode) {
    case ThemeMode.light:
      newMode = ThemeMode.dark;
      break;
    case ThemeMode.dark:
      newMode = ThemeMode.system;
      break;
    case ThemeMode.system:
      newMode = ThemeMode.light;
      break;
  }
  
  await setThemeMode(newMode, userId: userId);
}
```

**Firebase Theme Sync (Lines 78-103):**
```dart
Future<void> _syncThemeFromFirestore(String userId) async {
  try {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('preferences')
        .doc('theme')
        .get();

    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      final themeString = data['mode'] as String?;
      
      if (themeString != null) {
        final firestoreTheme = _stringToThemeMode(themeString);
        
        if (firestoreTheme != _themeMode) {
          _themeMode = firestoreTheme;
          await _saveThemeToLocal();
        }
      }
    }
  } catch (e) {
    debugPrint('Error syncing theme from Firestore: $e');
  }
}
```

---

## 🖥️ Screens Documentation

### Authentication Screens

#### 1. SplashScreen (splash_screen.dart)
- **Function:** App initialization and route determination
- **Components:** Animated logo, loading indicator
- **Navigation:** Routes to HomeScreen or LoginScreen

**App Initialization Code (Lines 23-40):**
```dart
Future<void> _initializeApp() async {
  await Future.delayed(const Duration(seconds: 2));
  
  if (mounted) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    await authProvider.checkAuthState();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => authProvider.isAuthenticated 
              ? const HomeScreen() 
              : const LoginScreen(),
        ),
      );
    }
  }
}
```

#### 2. LoginScreen (login_screen.dart)
- **Function:** User authentication interface
- **Features:** Email/password login, Google Sign-In
- **Validation:** Email format, password requirements

**Authentication Flow (Lines 32-66):**
```dart
Future<void> _login() async {
  if (!_formKey.currentState!.validate()) return;

  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  
  final success = await authProvider.signIn(
    email: _emailController.text.trim(),
    password: _passwordController.text,
  );

  if (success && mounted) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  } else if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(authProvider.errorMessage ?? 'Login failed'),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
```

#### 3. RegisterScreen (register_screen.dart)
- **Function:** New user registration
- **Fields:** Name, email, password, gender, birth date, height
- **Features:** Terms acceptance, Google Sign-Up

### Main Screens

#### 4. HomeScreen (home_screen.dart)
**Primary Dashboard with Bottom Navigation**

**Tabs:**
1. **Dashboard Tab:** Welcome, progress, today's tasks, quotes, stats
2. **Habits Tab:** All habits with filtering
3. **Quotes Tab:** Full quotes list with actions  
4. **Profile Tab:** User information and settings

**Key Features:**
- Real-time habit progress tracking
- Daily motivational quotes with carousel
- Quick habit completion from dashboard
- Statistics overview (total habits, streaks, completions)

#### 5. HabitsScreen (habits_screen.dart)
- **Function:** Main habit management interface
- **Tabs:** "Today's Tasks" and "All Habits"
- **Features:** Category filtering, habit completion toggle
- **Navigation:** Links to create/edit/detail screens

### Habit Management Screens

#### 6. CreateHabitScreen (create_habit_screen.dart)
**Form Fields:**
- Title (required)
- Category selection (Health, Study, Fitness, etc.)
- Frequency (Daily/Weekly)
- Start date (optional)
- Notes (optional)

#### 7. EditHabitScreen (edit_habit_screen.dart)
- Pre-populated form with existing data
- Habit statistics display
- Update functionality

#### 8. HabitDetailScreen (habit_detail_screen.dart)
**Comprehensive Habit View:**
- Large completion toggle with animations
- Current streak and statistics
- Recent activity history
- Quick access to progress charts

#### 9. HabitProgressScreen (habit_progress_screen.dart)
**Advanced Analytics (3 Tabs):**
1. **Charts:** Bar/line charts for progress visualization
2. **Matrix:** Calendar-style completion grid
3. **Stats:** Detailed statistics and calculations

**Time Filters:** 7, 14, 30, 60, 90 days

### Profile & Settings

#### 10. ProfileScreen (profile_screen.dart)
- User information display
- Theme selection toggle
- Navigation to edit profile and settings
- Sign out functionality

#### 11. EditProfileScreen (edit_profile_screen.dart)
- Update display name, gender, birth date, height
- Form validation and error handling

#### 12. SettingsScreen (settings_screen.dart)
- Theme selection (Light/Dark/System)
- Data management options
- App information and help links

#### 13. FavoriteQuotesScreen (favorites_quotes_screen.dart)
- Display all favorited quotes
- Bulk operations (share all, copy all)
- Quote unfavoriting

---

## ⚙️ Services Layer

### 1. AuthService (auth_service.dart)

**Firebase Integration:**
- `FirebaseAuth` for authentication
- `FirebaseFirestore` for user profiles
- `GoogleSignIn` for OAuth

**Key Methods:**
- `signUpWithEmailAndPassword()` - Creates user and profile
- `signInWithEmailAndPassword()` - Email login
- `signInWithGoogle()` - Google OAuth flow
- `getUserProfile()` - Fetch user data from Firestore
- `updateUserProfile()` - Update user information

**Error Handling:**
- Comprehensive Firebase error mapping
- User-friendly error messages

### 2. HabitService (habit_service.dart)

**Firestore Operations:**
- Collection: `users/{userId}/habits`
- Real-time listeners for live updates
- Transaction-based completion tracking

**Key Methods with Implementation:**

**Streak Calculation Algorithm (Lines 205-248):**
```dart
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
  }
  return streak;
}
```

**Habit Completion with Transaction (Lines 111-166):**
```dart
Future<void> markHabitComplete(String userId, String habitId) async {
  try {
    final habitRef = _firestore.collection('users').doc(userId).collection('habits').doc(habitId);

    await _firestore.runTransaction((transaction) async {
      final doc = await transaction.get(habitRef);
      final habit = Habit.fromFirestore(doc);
      final now = DateTime.now();
      
      if (habit.frequency == HabitFrequency.daily) {
        final isAlreadyCompleted = habit.completionHistory.any((date) =>
          date.year == now.year && date.month == now.month && date.day == now.day
        );

        if (isAlreadyCompleted) {
          throw Exception('Habit already completed today! Come back tomorrow.');
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
```

**Business Logic:**
- Prevents duplicate completions
- Automatic streak calculation
- Statistics generation

### 3. QuotesService (quotes_service.dart)

**Multi-API Strategy with Implementation:**

**Multi-Source API with Fallback (Lines 18-47):**
```dart
Future<List<Quote>> fetchRandomQuotes({int limit = 10}) async {
  for (int attempt = 0; attempt < _apiSources.length; attempt++) {
    try {
      final apiSource = _apiSources[(_currentApiIndex + attempt) % _apiSources.length];
      List<Quote> quotes;
      
      switch (apiSource) {
        case 'quotable':
          quotes = await _fetchFromQuotable(limit);
          break;
        case 'zenquotes':
          quotes = await _fetchFromZenQuotes(limit);
          break;
        default:
          quotes = _getFallbackQuotes().take(limit).toList();
      }
      
      if (quotes.isNotEmpty) {
        _currentApiIndex = (_currentApiIndex + attempt) % _apiSources.length;
        return quotes;
      }
    } catch (e) {
      debugPrint('Failed to fetch from ${_apiSources[(_currentApiIndex + attempt) % _apiSources.length]}: $e');
    }
  }
  
  debugPrint('All APIs failed, using fallback quotes');
  return _getFallbackQuotes().take(limit).toList();
}
```

**HTTP Request with Timeout (Lines 54-81):**
```dart
Future<List<Quote>> _fetchFromQuotable(int limit) async {
  try {
    final response = await _httpClient.get(
      Uri.parse('$_quotableBaseUrl/quotes?limit=$limit'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 10));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> quotesJson = data['results'] ?? [];
      
      return quotesJson.map((json) {
        return Quote(
          id: json['_id'] ?? _generateRandomId(),
          content: json['content'] ?? '',
          author: json['author'] ?? 'Unknown',
          tags: List<String>.from(json['tags'] ?? []),
          length: (json['content'] ?? '').length,
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch from Quotable: ${response.statusCode}');
    }
  } catch (e) {
    rethrow;
  }
}
```

**Favorite Management:**
- Firestore collection: `users/{userId}/favoriteQuotes`
- Real-time favorite updates
- Duplicate prevention

### 4. LocalStorageService (local_storage_service.dart)

**Caching Implementation:**

**Complex Object Caching (Lines 25-62):**
```dart
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
          completionHistory: (json['completionHistory'] as List<dynamic>? ?? [])
              .map((dateStr) => DateTime.parse(dateStr))
              .toList(),
        );
      }).toList();
      
      return habits;
    }
  } catch (e) {
    debugPrint('Error loading cached habits: $e');
  }
  return [];
}
```

**Data Format:** JSON serialization via SharedPreferences with user-specific keys

### 5. ConnectivityService (connectivity_service.dart)

**Network Monitoring Implementation:**

**Singleton with Stream Pattern (Lines 4-40):**
```dart
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  bool _isOnline = true;
  final StreamController<bool> _connectivityController = StreamController<bool>.broadcast();

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _connectivityController.stream;

  void _updateConnectivity(bool isOnline) {
    if (_isOnline != isOnline) {
      _isOnline = isOnline;
      _connectivityController.add(isOnline);
      debugPrint('Connectivity changed: ${isOnline ? 'Online' : 'Offline'}');
    }
  }
}
```

**Key Features:**
- Singleton pattern for app-wide connectivity monitoring
- Broadcast stream for multiple listeners
- Real-time connectivity updates

---

## 🎨 UI Components & Widgets

### Design System (design_system.dart)

**Color System:**
```dart
class AppColors {
  static const Color primary = Color(0xFF4CAF50);      // Green
  static const Color primaryLight = Color(0xFF81C784);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
}
```

**Typography:**
- `AppTextStyles` - Responsive text styles
- Theme-aware color adaptation
- Material 3 design principles

**Key Components with Implementation:**

**Context-Aware Color System (Lines 23-64):**
```dart
static Color backgroundFor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark 
      ? const Color(0xFF121212) 
      : const Color(0xFFF1F8E9);
}

static Color textPrimaryFor(BuildContext context) {
  return Theme.of(context).brightness == Brightness.dark 
      ? const Color(0xFFE8F5E8) 
      : const Color(0xFF1B5E20);
}
```

**Enhanced Text Field Component (Lines 359-448):**
```dart
class EnhancedTextField extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium!.copyWith(fontWeight: FontWeight.w600)),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.primary) : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
          ),
        ),
      ],
    );
  }
}
```

### Specialized Widgets

#### 1. AnimatedBackground (animated_background.dart)
- Floating bubble animations
- Rotating leaf elements
- Theme-adaptive gradients

#### 2. CompletionAnimation (completion_animation.dart)
- Habit completion checkmark animation
- Streak celebration dialogs
- Progress ring indicators
- Feedback SnackBars

**Completion Animation Logic (Lines 16-69):**
```dart
@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.elasticOut,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isCompleted ? const Color(0xFF4CAF50) : Colors.transparent,
        border: Border.all(color: const Color(0xFF4CAF50), width: 2),
        boxShadow: isCompleted ? [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: isCompleted
          ? Icon(Icons.check, color: Colors.white, size: size * 0.5)
              .animate()
              .scale(duration: 200.ms, curve: Curves.elasticOut)
          : null,
    )
        .animate(target: isCompleted ? 1 : 0)
        .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 100.ms)
        .then()
        .scale(begin: const Offset(1.1, 1.1), end: const Offset(1, 1), duration: 200.ms),
  );
}
```

**Streak Achievement Dialog (Lines 249-345):**
```dart
static void showStreak(BuildContext context, int streak, String habitTitle) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF9800), Color(0xFFF57C00)],
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.local_fire_department, color: Colors.orange, size: 40),
            ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text('$streak days in a row!', style: const TextStyle(color: Colors.white, fontSize: 18)),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Going!'),
            ).animate().fadeIn(duration: 1200.ms),
          ],
        ),
      ),
    ),
  );
}
```

#### 3. ProgressChart (progress_chart.dart)
**Chart Types:**
- `HabitProgressChart` - Daily completion bars
- `WeeklyProgressChart` - Weekly trend lines
- `HabitCompletionMatrix` - Calendar grid view

**Chart Data Generation (Lines 108-137):**
```dart
List<BarChartGroupData> _generateChartData() {
  final data = <BarChartGroupData>[];
  final now = DateTime.now();
  
  for (int i = 0; i < days; i++) {
    final date = now.subtract(Duration(days: days - 1 - i));
    final isCompleted = _isCompletedOnDate(date);
    
    data.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: isCompleted ? 1 : 0,
            color: isCompleted 
                ? const Color(0xFF4CAF50)
                : const Color(0xFFE0E0E0),
            width: 20,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
  
  return data;
}
```

**Features:**
- Interactive tooltips with completion info
- Color-coded completion status (green = completed, gray = missed)
- Theme-aware styling with FL Chart library

#### 4. QuoteCard (quote_card.dart)
- Individual quote display
- Copy/favorite actions
- Tag display
- Author attribution
- Carousel implementation

### Utility Components

#### 5. OfflineIndicator (offline_indicator.dart)
- `ConnectivityBanner` - Full-width status bar
- `DataStatusChip` - Compact status indicator
- Last sync timestamp display

---

## 🔧 Utilities

### Validators (validators.dart)

**Form Validation Implementation:**

**Email Validation:**
```dart
static String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required';
  }
  
  if (!EmailValidator.validate(value.trim())) {
    return 'Please enter a valid email address';
  }
  
  return null;
}
```

**Password Validation with Strength Requirements:**
```dart
static String? validatePassword(String? value) {
  if (value == null || value.isEmpty) {
    return 'Password is required';
  }
  
  if (value.length < 8) {
    return 'Password must be at least 8 characters long';
  }
  
  if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter, one lowercase letter, and one number';
  }
  
  return null;
}
```

**Height Validation (Optional Field):**
```dart
static String? validateHeight(String? value) {
  if (value == null || value.trim().isEmpty) {
    return null; // Optional field
  }
  
  final height = double.tryParse(value);
  if (height == null) {
    return 'Please enter a valid number';
  }
  
  if (height < 50 || height > 300) {
    return 'Height must be between 50 and 300 cm';
  }
  
  return null;
}
```

**Validation Rules Summary:**
- **Email:** Required, EmailValidator package for format checking
- **Password:** 8+ chars, must include uppercase, lowercase, and numbers
- **Display Name:** Required, minimum 2 characters
- **Height:** Optional, numeric range 50-300 cm with null safety

### App Theme (app_theme.dart)

**Theme Configuration:**
- Light theme with green color scheme
- Material 3 design system
- Custom component themes (buttons, inputs, cards)
- Consistent border radius and elevation

---

## 🔄 Data Flow & Architecture

### State Management Pattern
```
UI Screen → Provider → Service → Firebase/Local Storage
    ↑                                       ↓
    └─────── State Updates ←─────────────────┘
```

### Authentication Flow
1. **SplashScreen** checks auth state
2. **AuthWrapper** determines route (Login/Home)
3. **AuthProvider** manages authentication state
4. **AuthService** handles Firebase operations

### Habit Management Flow
1. **HabitsScreen** displays habit list
2. **HabitProvider** manages habit state
3. **HabitService** handles Firestore operations
4. **LocalStorageService** provides offline caching

### Offline-First Architecture
1. **ConnectivityService** monitors network status
2. **Providers** adapt behavior based on connectivity
3. **LocalStorageService** caches data for offline access
4. **UI** shows offline indicators and status

---

## 🔐 Firebase Integration

### Authentication
- **Email/Password** authentication
- **Google Sign-In** OAuth integration
- **User profile** storage in Firestore

### Firestore Structure
```
users/
  {userId}/
    - displayName, email, gender, dateOfBirth, height
    habits/
      {habitId}/
        - title, category, frequency, completionHistory
    favoriteQuotes/
      {quoteId}/
        - content, author, tags, favoritedAt
    preferences/
      - theme, notifications
```

### Security Rules
- User can only access their own data
- Authenticated users only
- Read/write permissions per collection

---

## 📱 Key Features Deep Dive

### 1. Habit Tracking System

**Streak Calculation:**
- Daily habits: Consecutive days with completion
- Weekly habits: Consecutive weeks with ≥1 completion
- Handles timezone considerations
- Prevents duplicate completions

**Progress Analytics:**
- Completion rate calculation
- Weekly/monthly progress trends
- Longest streak tracking
- Category-wise statistics

### 2. Motivational Quotes System

**Quote Sources:**
- Quotable.io API (primary)
- ZenQuotes.io API (fallback)
- Local fallback quotes (20+)

**Features:**
- Daily quote rotation
- Favorite quote collection
- Share functionality (copy to clipboard)
- Offline quote caching

### 3. Offline Functionality

**Offline-First Design:**
- Local data caching with SharedPreferences
- Automatic sync on reconnection
- Offline indicators throughout UI
- Graceful degradation of features

### 4. Theme System

**Theme Options:**
- Light mode
- Dark mode  
- System (follows device setting)

**Persistence:**
- Local storage with SharedPreferences
- Cloud sync for logged-in users
- Material 3 design system

---

## 🛠️ Technical Implementation Details

### Dependencies
- **flutter**: UI framework
- **firebase_core/auth/firestore**: Backend services
- **provider**: State management
- **shared_preferences**: Local storage
- **http**: API calls
- **fl_chart**: Progress charts
- **flutter_animate**: Animations
- **google_sign_in**: OAuth authentication

### Performance Optimizations
- Lazy loading of data
- Image caching for user avatars
- Efficient list rendering
- Memory management in providers

### Error Handling
- Comprehensive try-catch blocks
- User-friendly error messages
- Graceful fallbacks
- Debug logging

### Code Organization
- Clean architecture principles
- Separation of concerns
- Modular components
- Consistent naming conventions

---

## 🎯 Common Viva Questions & Answers

### Q1: Explain the app's architecture pattern
**A:** The app uses **Provider pattern** for state management with a **service-oriented architecture**. Data flows from UI → Provider → Service → Firebase/Local Storage, with reactive state updates.

### Q2: How does offline functionality work?
**A:** The app uses an **offline-first approach** with `LocalStorageService` caching data locally. `ConnectivityService` monitors network status, and providers adapt behavior accordingly with automatic sync on reconnection.

### Q3: What is the purpose of different models?
**A:** 
- **Habit Model**: Represents habit data with business logic for streaks and completion
- **Quote Model**: Handles quote data and favorite relationships
- **User Model**: Manages user profile information and Firebase integration

### Q4: How are themes managed?
**A:** `ThemeProvider` manages three theme modes (light/dark/system) with dual persistence using SharedPreferences locally and Firestore for cloud sync.

### Q5: Explain the habit streak calculation
**A:** Streaks are calculated differently for daily vs weekly habits:
- **Daily**: Consecutive days with completion
- **Weekly**: Consecutive weeks with at least one completion
- Uses transaction-based updates to prevent race conditions

### Q6: What validation is implemented?
**A:** Form validation includes:
- Email format validation
- Password strength (8+ chars, mixed case, numbers)
- Name length validation
- Height range validation (50-300 cm)

### Q7: How does Firebase integration work?
**A:** Firebase provides:
- **Authentication**: Email/password and Google Sign-In
- **Firestore**: Real-time database for habits, quotes, preferences
- **Security Rules**: User data isolation and access control

---

## 📚 Key Files for Viva Preparation

**Most Important Files to Study:**
1. `main.dart` - App initialization and provider setup
2. `habit_model.dart` - Core data structure and business logic
3. `habit_provider.dart` - State management and offline handling
4. `habit_service.dart` - Firebase operations and streak calculation
5. `home_screen.dart` - Main UI and user interaction
6. `design_system.dart` - UI components and theming

**Key Code Snippets to Remember:**

1. **Provider Setup (main.dart:43-49):**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider.value(value: _themeProvider),
    ChangeNotifierProvider(create: (context) => AuthProvider()),
    ChangeNotifierProvider(create: (context) => HabitProvider()),
    ChangeNotifierProvider(create: (context) => QuotesProvider()),
  ],
  child: Consumer<ThemeProvider>(...),
)
```

2. **Habit Completion with Streak Calculation (habit_service.dart:111-166):**
```dart
await _firestore.runTransaction((transaction) async {
  final doc = await transaction.get(habitRef);
  final habit = Habit.fromFirestore(doc);
  
  // Check for duplicates
  if (habit.isCompletedToday) {
    throw Exception('Habit already completed today!');
  }
  
  // Calculate new streak
  final updatedHistory = [...habit.completionHistory, DateTime.now()];
  int newStreak = _calculateStreak(updatedHistory, habit.frequency);
  
  // Update with transaction
  transaction.update(habitRef, updatedHabit.toFirestore());
});
```

3. **Offline-First Data Loading (habit_provider.dart:42-72):**
```dart
if (_connectivity.isOnline) {
  _habitsSubscription = _habitService.getUserHabits(userId).listen(
    (habits) {
      _habits = habits;
      _updateStats();
      _localStorage.cacheHabits(userId, habits); // Cache for offline
      notifyListeners();
    },
    onError: (error) {
      _loadCachedData(userId); // Fallback to cache
    },
  );
} else {
  _loadCachedData(userId); // Start with cached data
}
```

4. **Theme Toggle Cycle (theme_provider.dart:39-54):**
```dart
switch (_themeMode) {
  case ThemeMode.light:
    newMode = ThemeMode.dark;
    break;
  case ThemeMode.dark:
    newMode = ThemeMode.system;
    break;
  case ThemeMode.system:
    newMode = ThemeMode.light;
    break;
}
```

---

## 🧠 Critical Algorithms & Logic for Viva

### 1. Streak Calculation Algorithm
**Purpose:** Calculate consecutive completion days/weeks for habits

**Logic:**
- Sort completion history in descending order
- Start from today and work backwards
- For daily habits: Check each consecutive day
- For weekly habits: Check consecutive weeks with ≥1 completion
- Break on first gap in completion

**Code Location:** `habit_service.dart:205-248`

### 2. Offline-First Data Sync
**Purpose:** Ensure app works offline with automatic sync

**Logic Flow:**
1. Check connectivity status
2. If online: Listen to real-time Firestore updates → Cache locally
3. If offline: Load from cache immediately
4. On reconnection: Auto-sync and resolve conflicts
5. Always show cached data as fallback

**Code Location:** `habit_provider.dart:42-72`

### 3. Multi-API Fallback System
**Purpose:** Reliable quote fetching with multiple sources

**Logic:**
1. Try primary API (Quotable.io)
2. On failure, try secondary API (ZenQuotes.io)
3. If all APIs fail, use hardcoded fallback quotes
4. Rotate API preference for load balancing

**Code Location:** `quotes_service.dart:18-47`

### 4. Firebase Transaction Pattern
**Purpose:** Prevent race conditions in habit completion

**Why Needed:** Multiple users or rapid taps could create duplicate completions

**Solution:**
- Use Firestore transactions for atomic operations
- Read current state, validate, then write
- If validation fails, transaction aborts
- Prevents duplicate completions and maintains data integrity

**Code Location:** `habit_service.dart:111-166`

### 5. Context-Aware UI Theming
**Purpose:** Automatic theme adaptation based on system/user preference

**Implementation:**
- Functions take `BuildContext` parameter
- Use `Theme.of(context).brightness` for dark/light detection
- Return appropriate colors for current theme
- Consistent theming across all components

**Code Location:** `design_system.dart:23-64`

---

## 📝 Viva Preparation Checklist

✅ **Understand the architecture:** Provider pattern + Service layer + Firebase
✅ **Know the data flow:** UI → Provider → Service → Firebase → Cache
✅ **Memorize key algorithms:** Streak calculation, offline sync, API fallback
✅ **Practice explaining:** Why transactions? Why offline-first? Why multi-API?
✅ **Know the models:** Habit, Quote, User - their properties and methods
✅ **Understand Firebase:** Authentication, Firestore collections, real-time updates
✅ **Know the UI structure:** Screens, widgets, design system, animations

---

This comprehensive study guide with actual code implementations covers all aspects of the Habit Tracker application's lib folder. Focus on understanding the algorithms, data flow patterns, and architectural decisions for your viva examination.