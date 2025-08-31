import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../providers/quotes_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/quote_card.dart';
import '../widgets/offline_indicator.dart';
import '../widgets/design_system.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'habits_screen.dart';
import 'create_habit_screen.dart';
import 'favorites_quotes_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const DashboardTab(),
    const HabitsTab(),
    const QuotesTab(),
    const ProfileTab(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    
    if (authProvider.currentUser == null) {
      return const LoginScreen();
    }

    return Scaffold(
      body: AnimatedBackground(
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Theme.of(context).colorScheme.surface,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.track_changes),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_quote),
            label: 'Quotes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      final quotesProvider = Provider.of<QuotesProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        habitProvider.startListening(authProvider.currentUser!.uid);
        quotesProvider.loadFavoriteQuoteIds(authProvider.currentUser!.uid);
      }
      
      quotesProvider.loadQuotes();
    });
  }

  IconData _getThemeIcon(ThemeMode themeMode) {
    switch (themeMode) {
      case ThemeMode.light:
        return Icons.wb_sunny_rounded;
      case ThemeMode.dark:
        return Icons.dark_mode_rounded;
      case ThemeMode.system:
        return Icons.brightness_auto_rounded;
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? AppColors.textMutedFor(context);
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: buttonColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Icon(
            icon,
            color: buttonColor,
            size: 16,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, HabitProvider, QuotesProvider>(
        builder: (context, authProvider, habitProvider, quotesProvider, child) {
          final user = authProvider.currentUser;
          final stats = habitProvider.stats;

          return SafeArea(
            child: Column(
              children: [
                ConnectivityBanner(
                  isOnline: !habitProvider.isOffline && !quotesProvider.isOffline,
                  message: 'Working offline - some features may be limited',
                ),
                
                Expanded(
                  child: RefreshIndicator(
                  onRefresh: () async {
                    await quotesProvider.refreshQuotes(
                      userId: authProvider.currentUser?.uid,
                    );
                    if (authProvider.currentUser != null) {
                      await habitProvider.refreshHabits(authProvider.currentUser!.uid);
                    }
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        EnhancedCard(
                          child: Row(
                            children: [
                              ProfileImage(
                                photoURL: user?.photoURL,
                                displayName: user?.displayName ?? 'User',
                                size: 60,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back!',
                                      style: AppTextStyles.bodyMediumFor(context),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user?.displayName ?? 'User',
                                      style: AppTextStyles.headline2For(context),
                                    ),
                                  ],
                                ),
                              ),
                              Consumer<ThemeProvider>(
                                builder: (context, themeProvider, child) {
                                  return GestureDetector(
                                    onTap: () async {
                                      final authProvider = Provider.of<AuthProvider>(context, listen: false);
                                      await themeProvider.toggleTheme(
                                        userId: authProvider.currentUser?.uid,
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(AppRadius.lg),
                                      ),
                                      child: AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 300),
                                        child: Icon(
                                          _getThemeIcon(themeProvider.themeMode),
                                          key: ValueKey(themeProvider.themeMode),
                                          color: AppColors.primary,
                                          size: 28,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
                
                const SizedBox(height: 20),
                
                if (habitProvider.habits.isNotEmpty) ...[
                  EnhancedCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: 'Today\'s Progress',
                          icon: Icons.today_rounded,
                        ),
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: habitProvider.habits.isNotEmpty 
                                          ? stats['completedToday']! / habitProvider.habits.length 
                                          : 0.0,
                                      backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      minHeight: 8,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${stats['completedToday']} of ${habitProvider.habits.length} habits completed',
                                    style: AppTextStyles.bodyMediumFor(context),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                ),
                                boxShadow: [AppShadows.softFor(context)],
                              ),
                              child: Center(
                                child: Text(
                                  '${((stats['completedToday']! / habitProvider.habits.length) * 100).round()}%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: 20),
                  
                  if (habitProvider.pendingHabits.isNotEmpty) ...[
                    EnhancedCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              SectionHeader(
                                title: 'Today\'s Tasks',
                                subtitle: '${habitProvider.pendingHabits.length} remaining',
                                icon: Icons.task_alt_rounded,
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HabitsScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'View All',
                                  style: AppTextStyles.bodyMediumFor(context).copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          
                          ...habitProvider.pendingHabits.take(3).map((habit) => _buildQuickTaskItem(context, habit, habitProvider, authProvider)).toList(),
                          
                          if (habitProvider.pendingHabits.length > 3) ...[
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HabitsScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  '+ ${habitProvider.pendingHabits.length - 3} more tasks',
                                  style: AppTextStyles.captionFor(context).copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(duration: 900.ms).slideX(begin: 0.3),
                    const SizedBox(height: 20),
                  ],
                ],
                
                Container(
                  margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withOpacity(0.05),
                        AppColors.primaryLight.withOpacity(0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.primary, AppColors.primaryLight],
                                ),
                                borderRadius: BorderRadius.circular(AppRadius.md),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Daily Inspiration',
                                    style: AppTextStyles.headline2For(context).copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Fuel your motivation with inspiring quotes',
                                    style: AppTextStyles.bodyMediumFor(context).copyWith(
                                      color: AppColors.textSecondaryFor(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (quotesProvider.isOffline)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(AppRadius.lg),
                                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.cloud_off_rounded,
                                          size: 14,
                                          color: Colors.orange.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Offline',
                                          style: AppTextStyles.captionFor(context).copyWith(
                                            color: Colors.orange.shade700,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (quotesProvider.isOffline) const SizedBox(width: AppSpacing.sm),
                                if (user != null)
                                  _buildActionButton(
                                    icon: Icons.favorite_rounded,
                                    color: Colors.red,
                                    tooltip: 'View Favorite Quotes',
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => const FavoriteQuotesScreen(),
                                        ),
                                      );
                                    },
                                  ),
                                const SizedBox(width: AppSpacing.xs),
                                _buildActionButton(
                                  icon: Icons.refresh_rounded,
                                  color: AppColors.primary,
                                  tooltip: 'Get Fresh Quotes',
                                  onPressed: () {
                                    quotesProvider.refreshQuotes(
                                      userId: user?.uid,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        if (quotesProvider.isLoading)
                          Container(
                            height: 160,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'Loading inspiration...',
                                    style: AppTextStyles.bodyMediumFor(context).copyWith(
                                      color: AppColors.textSecondaryFor(context),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else if (quotesProvider.quotes.isNotEmpty)
                          Container(
                            height: 160,
                            child: PageView.builder(
                              itemCount: quotesProvider.quotes.take(5).length,
                              itemBuilder: (context, index) {
                                final quote = quotesProvider.quotes[index];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  child: Stack(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Colors.white.withOpacity(0.9),
                                              AppColors.primary.withOpacity(0.05),
                                            ],
                                          ),
                                          borderRadius: BorderRadius.circular(AppRadius.lg),
                                          border: Border.all(
                                            color: AppColors.primary.withOpacity(0.15),
                                            width: 1,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary.withOpacity(0.08),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Icon(
                                              Icons.format_quote,
                                              color: AppColors.primary.withOpacity(0.6),
                                              size: 28,
                                            ),
                                            const SizedBox(height: 8),
                                            Expanded(
                                              child: Text(
                                                quote.content,
                                                style: AppTextStyles.bodyLargeFor(context).copyWith(
                                                  fontStyle: FontStyle.italic,
                                                  fontWeight: FontWeight.w500,
                                                  height: 1.4,
                                                ),
                                                maxLines: 3,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    '— ${quote.author}',
                                                    style: AppTextStyles.bodyMediumFor(context).copyWith(
                                                      fontWeight: FontWeight.w700,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    _buildQuickActionButton(
                                                      icon: Icons.copy_rounded,
                                                      onPressed: () async {
                                                        await quotesProvider.copyQuoteToClipboard(quote);
                                                        ScaffoldMessenger.of(context).showSnackBar(
                                                          SnackBar(
                                                            content: const Text('Quote copied to clipboard!'),
                                                            backgroundColor: AppColors.success,
                                                            behavior: SnackBarBehavior.floating,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.circular(AppRadius.md),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                    const SizedBox(width: 8),
                                                    if (user != null)
                                                      _buildQuickActionButton(
                                                        icon: quotesProvider.isQuoteFavorited(quote.id) 
                                                            ? Icons.favorite_rounded 
                                                            : Icons.favorite_border_rounded,
                                                        color: quotesProvider.isQuoteFavorited(quote.id) 
                                                            ? Colors.red 
                                                            : AppColors.textMutedFor(context),
                                                        onPressed: () async {
                                                          await quotesProvider.toggleFavorite(user!.uid, quote);
                                                        },
                                                      ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (quotesProvider.quotes.length > 1)
                                        Positioned(
                                          bottom: 8,
                                          left: 0,
                                          right: 0,
                                          child: Center(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withOpacity(0.1),
                                                borderRadius: BorderRadius.circular(AppRadius.lg),
                                              ),
                                              child: Text(
                                                '${index + 1} of ${quotesProvider.quotes.take(5).length}',
                                                style: AppTextStyles.captionFor(context).copyWith(
                                                  fontWeight: FontWeight.w600, color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          Container(
                            height: 160,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppColors.primary.withOpacity(0.1),
                                          AppColors.primaryLight.withOpacity(0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_outlined,
                                      size: 32,
                                      color: AppColors.primary.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.md),
                                  Text(
                                    'No quotes available',
                                    style: AppTextStyles.headline3For(context).copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    'Pull down to refresh and discover inspiration',
                                    style: AppTextStyles.bodyMediumFor(context).copyWith(
                                      color: AppColors.textSecondaryFor(context),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 1100.ms).slideX(begin: -0.3),
                
                const SizedBox(height: 20),
                
                SectionHeader(
                  title: 'Your Progress',
                  icon: Icons.trending_up_rounded,
                ).animate().fadeIn(duration: 1200.ms),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.emoji_events,
                        title: 'Total Habits',
                        value: '${stats['totalHabits']}',
                        color: AppColors.primary,
                        subtitle: 'created',
                      ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.8, 0.8)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: Icons.local_fire_department,
                        title: 'Max Streak',
                        value: '${stats['maxStreak']}',
                        color: Colors.orange,
                        subtitle: 'days',
                      ).animate().fadeIn(duration: 1400.ms).scale(begin: const Offset(0.8, 0.8)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.check_circle,
                        title: 'Today',
                        value: '${stats['completedToday']}',
                        color: AppColors.success,
                        subtitle: 'completed',
                      ).animate().fadeIn(duration: 1600.ms).scale(begin: const Offset(0.8, 0.8)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: StatCard(
                        icon: Icons.trending_up,
                        title: 'All Time',
                        value: '${stats['totalCompletions']}',
                        color: AppColors.info,
                        subtitle: 'total',
                      ).animate().fadeIn(duration: 1800.ms).scale(begin: const Offset(0.8, 0.8)),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateHabitScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(
                      habitProvider.habits.isEmpty 
                          ? 'Create Your First Habit'
                          : 'Add New Habit',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(duration: 2000.ms).slideY(begin: 0.3),
                    ],
                    ),
                  ),
                ),
                ),
              ],
            ),
          );
        },
      );
  }

  Widget _buildQuickTaskItem(BuildContext context, habit, HabitProvider habitProvider, AuthProvider authProvider) {
    final isCompleted = habit.isCompletedToday;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundFor(context),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isCompleted 
              ? AppColors.success.withOpacity(0.3) 
              : AppColors.primaryLight.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted 
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.2),
            ),
            child: Center(
              child: Text(
                habit.category.icon,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: AppTextStyles.bodyMediumFor(context).copyWith(
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted 
                        ? AppColors.textMutedFor(context)
                        : AppColors.textPrimaryFor(context),
                  ),
                ),
                Text(
                  habit.category.displayName,
                  style: AppTextStyles.captionFor(context),
                ),
              ],
            ),
          ),
          
          GestureDetector(
            onTap: () async {
              final success = await habitProvider.toggleHabitCompletion(
                authProvider.currentUser!.uid,
                habit.id,
              );
              
              if (success && !habit.isCompletedToday) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${habit.title} completed! 🎉',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: AppColors.success,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                );
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? AppColors.success : Colors.transparent,
                border: Border.all(
                  color: isCompleted ? AppColors.success : AppColors.textMutedFor(context),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(user) {
    return EnhancedCard(
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              ),
              boxShadow: [AppShadows.soft],
            ),
            child: const Icon(
              Icons.person,
              size: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  user?.displayName ?? 'User',
                  style: AppTextStyles.headline3,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: const Icon(
              Icons.wb_sunny,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayProgress(Map<String, int> stats, int totalHabits) {
    final progress = totalHabits > 0 ? stats['completedToday']! / totalHabits : 0.0;
    
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'Today\'s Progress',
            icon: Icons.today,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.primaryLight.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 8,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${stats['completedToday']} of $totalHabits habits completed',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.1),
                  border: Border.all(color: AppColors.primary, width: 2),
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).round()}%',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesSection(quotesProvider, user) {
    return EnhancedCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SectionHeader(
                title: 'Daily Inspiration',
                icon: Icons.format_quote,
              ),
              Row(
                children: [
                  DataStatusChip(
                    isOnline: !quotesProvider.isOffline,
                    isLoading: quotesProvider.isLoading,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (user != null)
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FavoriteQuotesScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 20,
                      ),
                      tooltip: 'View Favorites',
                    ),
                  IconButton(
                    onPressed: () {
                      quotesProvider.refreshQuotes(
                        userId: user?.uid,
                      );
                    },
                    icon: const Icon(
                      Icons.refresh,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    tooltip: 'Refresh Quotes',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (quotesProvider.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            )
          else if (quotesProvider.quotes.isNotEmpty)
            QuoteCarousel(
              quotes: quotesProvider.quotes.take(5).toList(),
              showActions: true,
            )
          else
            EmptyState(
              icon: Icons.format_quote,
              title: 'No Quotes Available',
              subtitle: 'Pull down to refresh and load inspiring quotes!',
            ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Your Progress',
          icon: Icons.trending_up,
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Total Habits',
                value: '${stats['totalHabits']}',
                icon: Icons.emoji_events,
                color: AppColors.primary,
                subtitle: 'created',
              ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.8, 0.8)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'Max Streak',
                value: '${stats['maxStreak']}',
                icon: Icons.local_fire_department,
                color: Colors.orange,
                subtitle: 'days',
              ).animate().fadeIn(duration: 1400.ms).scale(begin: const Offset(0.8, 0.8)),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'Today',
                value: '${stats['completedToday']}',
                icon: Icons.check_circle,
                color: AppColors.success,
                subtitle: 'completed',
              ).animate().fadeIn(duration: 1600.ms).scale(begin: const Offset(0.8, 0.8)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: StatCard(
                title: 'All Time',
                value: '${stats['totalCompletions']}',
                icon: Icons.timeline,
                color: AppColors.info,
                subtitle: 'total',
              ).animate().fadeIn(duration: 1800.ms).scale(begin: const Offset(0.8, 0.8)),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HabitsTab extends StatelessWidget {
  const HabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const HabitsScreen();
  }
}

class QuotesTab extends StatelessWidget {
  const QuotesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<AuthProvider, QuotesProvider>(
        builder: (context, authProvider, quotesProvider, child) {
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.format_quote,
                      color: Theme.of(context).colorScheme.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Inspiration',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Motivational quotes to inspire your journey',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        DataStatusChip(
                          isOnline: !quotesProvider.isOffline,
                          isLoading: quotesProvider.isLoading,
                        ),
                        const SizedBox(width: 8),
                        if (authProvider.currentUser != null)
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const FavoriteQuotesScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.favorite, color: Colors.red),
                            tooltip: 'Favorites',
                          ),
                        IconButton(
                          onPressed: () {
                            quotesProvider.refreshQuotes(
                              userId: authProvider.currentUser?.uid,
                            );
                          },
                          icon: Icon(
                            Icons.refresh,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          tooltip: 'Refresh',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    await quotesProvider.refreshQuotes(
                      userId: authProvider.currentUser?.uid,
                    );
                  },
                  child: quotesProvider.isLoading && quotesProvider.quotes.isEmpty
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : quotesProvider.quotes.isNotEmpty
                          ? ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: quotesProvider.quotes.length,
                              itemBuilder: (context, index) {
                                return QuoteCard(
                                  quote: quotesProvider.quotes[index],
                                  showActions: true,
                                );
                              },
                            )
                          : Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.format_quote,
                                    size: 64,
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No quotes available',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Pull down to refresh and load inspiring quotes!',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ProfileScreen();
  }
}