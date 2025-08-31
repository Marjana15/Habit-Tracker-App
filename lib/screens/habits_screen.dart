import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../widgets/animated_background.dart';
import '../widgets/completion_animation.dart';
import '../widgets/design_system.dart';
import 'create_habit_screen.dart';
import 'edit_habit_screen.dart';
import 'habit_detail_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        habitProvider.startListening(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    if (mounted) {
      final habitProvider = Provider.of<HabitProvider>(context, listen: false);
      habitProvider.stopListening();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.md),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppColors.primary, AppColors.primaryLight],
                            ),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: [AppShadows.softFor(context)],
                          ),
                          child: const Icon(
                            Icons.track_changes,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Habit Tracker',
                                style: AppTextStyles.headline2For(context).copyWith(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Consumer<HabitProvider>(
                                builder: (context, habitProvider, child) {
                                  final completedToday = habitProvider.habitsCompletedToday.length;
                                  final totalHabits = habitProvider.habits.length;
                                  return Text(
                                    totalHabits > 0 
                                      ? '$completedToday of $totalHabits completed today'
                                      : 'Start building better habits',
                                    style: AppTextStyles.bodyMediumFor(context).copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceFor(context),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: [AppShadows.softFor(context)],
                          ),
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CreateHabitScreen(),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.add_rounded,
                              color: AppColors.primary,
                              size: 28,
                            ),
                            iconSize: 28,
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Consumer<HabitProvider>(
                      builder: (context, habitProvider, child) {
                        final completedToday = habitProvider.habitsCompletedToday.length;
                        final totalHabits = habitProvider.habits.length;
                        final progress = totalHabits > 0 ? completedToday / totalHabits : 0.0;
                        
                        return Container(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceFor(context),
                            borderRadius: BorderRadius.circular(AppRadius.lg),
                            boxShadow: [AppShadows.softFor(context)],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Today\'s Progress',
                                          style: AppTextStyles.bodyMediumFor(context).copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          '${(progress * 100).round()}%',
                                          style: AppTextStyles.bodyMediumFor(context).copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: AppColors.primaryLight.withOpacity(0.2),
                                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
              
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.surfaceFor(context),
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [AppShadows.softFor(context)],
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textMutedFor(context),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    gradient: LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: const EdgeInsets.all(4),
                  dividerColor: Colors.transparent,
                  labelStyle: AppTextStyles.bodyMediumFor(context).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  unselectedLabelStyle: AppTextStyles.bodyMediumFor(context),
                  tabs: [
                    Tab(
                      height: 48,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.today_rounded, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            Text('Today'),
                          ],
                        ),
                      ),
                    ),
                    Tab(
                      height: 48,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.list_rounded, size: 18),
                            const SizedBox(width: AppSpacing.xs),
                            Text('All Habits'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms),
              
              const SizedBox(height: AppSpacing.md),
              
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    const TodayHabitsTab(),
                    const AllHabitsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TodayHabitsTab extends StatelessWidget {
  const TodayHabitsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        if (habitProvider.habits.isEmpty) {
          return EmptyState(
            icon: Icons.track_changes,
            title: 'No habits yet!',
            subtitle: 'Create your first habit to get started on your journey',
            actionText: 'Create Habit',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateHabitScreen(),
                ),
              );
            },
          );
        }

        final completedHabits = habitProvider.habitsCompletedToday;
        final pendingHabits = habitProvider.pendingHabits;

        return RefreshIndicator(
          onRefresh: () async {
            final authProvider = Provider.of<AuthProvider>(context, listen: false);
            if (authProvider.currentUser != null) {
              await habitProvider.refreshHabits(authProvider.currentUser!.uid);
            }
          },
          color: AppColors.primary,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              EnhancedCard(
                child: Column(
                  children: [
                    SectionHeader(
                      title: 'Today\'s Progress',
                      icon: Icons.today,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: StatCard(
                            title: 'Completed',
                            value: '${completedHabits.length}',
                            icon: Icons.check_circle,
                            color: AppColors.success,
                            subtitle: 'of ${habitProvider.habits.length}',
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: StatCard(
                            title: 'Remaining',
                            value: '${pendingHabits.length}',
                            icon: Icons.pending,
                            color: AppColors.warning,
                            subtitle: 'to complete',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 600.ms),
              
              const SizedBox(height: 20),
              
              if (pendingHabits.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SectionHeader(
                    title: 'Pending',
                    subtitle: '${pendingHabits.length} habits to complete',
                    icon: Icons.pending_actions,
                  ),
                ).animate().fadeIn(duration: 800.ms),
                const SizedBox(height: AppSpacing.sm),
                ...pendingHabits.asMap().entries.map((entry) {
                  final index = entry.key;
                  final habit = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: HabitCard(
                      habit: habit,
                      onToggle: () => _toggleHabit(context, habit),
                      onEdit: () => _editHabit(context, habit),
                      onDelete: () => _deleteHabit(context, habit),
                    ),
                  ).animate().fadeIn(duration: (900 + index * 100).ms).slideX(begin: -0.3);
                }),
                const SizedBox(height: 20),
              ],
              
              if (completedHabits.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: SectionHeader(
                    title: 'Completed',
                    subtitle: '${completedHabits.length} habits done today',
                    icon: Icons.check_circle,
                  ),
                ).animate().fadeIn(duration: 1000.ms),
                const SizedBox(height: AppSpacing.sm),
                ...completedHabits.asMap().entries.map((entry) {
                  final index = entry.key;
                  final habit = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.xs,
                    ),
                    child: HabitCard(
                      habit: habit,
                      onToggle: () => _toggleHabit(context, habit),
                      onEdit: () => _editHabit(context, habit),
                      onDelete: () => _deleteHabit(context, habit),
                    ),
                  ).animate().fadeIn(duration: (1100 + index * 100).ms).slideX(begin: 0.3);
                }),
              ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _toggleHabit(BuildContext context, Habit habit) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    final wasCompleted = habit.isCompletedToday;
    final success = await habitProvider.toggleHabitCompletion(
      authProvider.currentUser!.uid,
      habit.id,
    );
    
    if (success) {
      if (!wasCompleted) {
        final updatedHabit = habitProvider.getHabitById(habit.id);
        if (updatedHabit != null) {
          HabitCompletionFeedback.showSuccess(
            context, 
            'Great job! ${habit.title} completed 🎉'
          );
          
          if (updatedHabit.currentStreak > 1 && updatedHabit.currentStreak % 5 == 0) {
            Future.delayed(const Duration(milliseconds: 500), () {
              HabitCompletionFeedback.showStreak(
                context, 
                updatedHabit.currentStreak, 
                habit.title
              );
            });
          }
        }
      }
    } else if (habitProvider.errorMessage != null) {
      HabitCompletionFeedback.showError(context, habitProvider.errorMessage!);
    }
  }

  void _editHabit(BuildContext context, Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHabitScreen(habit: habit),
      ),
    );
  }

  void _deleteHabit(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Delete Habit', style: AppTextStyles.headline3For(context)),
        content: Text('Are you sure you want to delete "${habit.title}"?', style: AppTextStyles.bodyMediumFor(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final habitProvider = Provider.of<HabitProvider>(context, listen: false);
              
              final success = await habitProvider.deleteHabit(
                authProvider.currentUser!.uid,
                habit.id,
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Habit deleted successfully', style: const TextStyle(color: Colors.white)),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(habitProvider.errorMessage ?? 'Failed to delete habit', style: const TextStyle(color: Colors.white)),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class AllHabitsTab extends StatefulWidget {
  const AllHabitsTab({super.key});

  @override
  State<AllHabitsTab> createState() => _AllHabitsTabState();
}

class _AllHabitsTabState extends State<AllHabitsTab> {
  HabitCategory? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final allHabits = habitProvider.habits;
        final habits = _selectedCategory == null 
            ? allHabits 
            : allHabits.where((h) => h.category == _selectedCategory).toList();
        
        if (habits.isEmpty) {
          return EmptyState(
            icon: _selectedCategory?.icon != null 
                ? Icons.category 
                : Icons.track_changes,
            title: _selectedCategory == null 
                ? 'No habits yet!' 
                : 'No ${_selectedCategory!.displayName.toLowerCase()} habits',
            subtitle: _selectedCategory == null
                ? 'Create your first habit to get started'
                : 'Try selecting a different category or create a new habit',
            actionText: 'Create Habit',
            onAction: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateHabitScreen(),
                ),
              );
            },
          );
        }

        return Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _CategoryChip(
                      category: null,
                      isSelected: _selectedCategory == null,
                      onSelected: () => setState(() => _selectedCategory = null),
                      count: allHabits.length,
                    ),
                    const SizedBox(width: 8),
                    ...HabitCategory.values.map((category) {
                      final count = allHabits.where((h) => h.category == category).length;
                      if (count == 0) return const SizedBox.shrink();
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _CategoryChip(
                          category: category,
                          isSelected: _selectedCategory == category,
                          onSelected: () => setState(() => _selectedCategory = category),
                          count: count,
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ).animate().fadeIn(duration: 500.ms),
            
            Expanded(
              child: habits.isEmpty 
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _selectedCategory?.icon != null 
                                ? Icons.category 
                                : Icons.track_changes,
                            size: 60,
                            color: AppColors.textMutedFor(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _selectedCategory == null 
                                ? 'No habits yet!' 
                                : 'No ${_selectedCategory!.displayName.toLowerCase()} habits',
                            style: AppTextStyles.headline3For(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedCategory == null
                                ? 'Create your first habit to get started'
                                : 'Try selecting a different category or create a new habit',
                            style: AppTextStyles.bodyMediumFor(context),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                      itemCount: habits.length,
                      itemBuilder: (context, index) {
                        final habit = habits[index];
                        return HabitCard(
                          habit: habit,
                          showStats: true,
                          onToggle: () => _toggleHabit(context, habit),
                          onEdit: () => _editHabit(context, habit),
                          onDelete: () => _deleteHabit(context, habit),
                        ).animate().fadeIn(duration: (600 + index * 100).ms).slideY(begin: 0.3);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  void _toggleHabit(BuildContext context, Habit habit) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    final wasCompleted = habit.isCompletedToday;
    final success = await habitProvider.toggleHabitCompletion(
      authProvider.currentUser!.uid,
      habit.id,
    );
    
    if (success) {
      if (!wasCompleted) {
        final updatedHabit = habitProvider.getHabitById(habit.id);
        if (updatedHabit != null) {
          HabitCompletionFeedback.showSuccess(
            context, 
            'Great job! ${habit.title} completed 🎉'
          );
          
          if (updatedHabit.currentStreak > 1 && updatedHabit.currentStreak % 5 == 0) {
            Future.delayed(const Duration(milliseconds: 500), () {
              HabitCompletionFeedback.showStreak(
                context, 
                updatedHabit.currentStreak, 
                habit.title
              );
            });
          }
        }
      }
    } else if (habitProvider.errorMessage != null) {
      HabitCompletionFeedback.showError(context, habitProvider.errorMessage!);
    }
  }

  void _editHabit(BuildContext context, Habit habit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditHabitScreen(habit: habit),
      ),
    );
  }

  void _deleteHabit(BuildContext context, Habit habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text('Delete Habit', style: AppTextStyles.headline3For(context)),
        content: Text('Are you sure you want to delete "${habit.title}"?', style: AppTextStyles.bodyMediumFor(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final authProvider = Provider.of<AuthProvider>(context, listen: false);
              final habitProvider = Provider.of<HabitProvider>(context, listen: false);
              
              final success = await habitProvider.deleteHabit(
                authProvider.currentUser!.uid,
                habit.id,
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Habit deleted successfully', style: const TextStyle(color: Colors.white)),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(habitProvider.errorMessage ?? 'Failed to delete habit', style: const TextStyle(color: Colors.white)),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final int count;
  final int total;
  final IconData icon;
  final Color color;

  const _ProgressCard({
    required this.title,
    required this.count,
    required this.total,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = total > 0 ? (count / total * 100).round() : 0;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            '$percentage%',
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class HabitCard extends StatelessWidget {
  final Habit habit;
  final bool showStats;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    this.showStats = false,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceFor(context),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [AppShadows.softFor(context)],
        border: isCompleted 
            ? Border.all(color: AppColors.success.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HabitDetailScreen(habit: habit),
              ),
            );
          },
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isCompleted 
                              ? [AppColors.success.withOpacity(0.8), AppColors.success]
                              : [AppColors.primary.withOpacity(0.8), AppColors.primary],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (isCompleted ? AppColors.success : AppColors.primary).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          habit.category.icon,
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            habit.title,
                            style: AppTextStyles.headline3For(context).copyWith(
                              fontSize: 18,
                              decoration: isCompleted 
                                  ? TextDecoration.lineThrough 
                                  : null,
                              color: isCompleted 
                                  ? AppColors.textMutedFor(context)
                                  : AppColors.textPrimaryFor(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, 
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  habit.category.displayName,
                                  style: AppTextStyles.captionFor(context).copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: AppColors.textMutedFor(context),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                habit.frequency.displayName,
                                style: AppTextStyles.captionFor(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onToggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isCompleted ? AppColors.success : Colors.transparent,
                              border: Border.all(
                                color: isCompleted ? AppColors.success : AppColors.textMutedFor(context),
                                width: 2,
                              ),
                              boxShadow: isCompleted ? [
                                BoxShadow(
                                  color: AppColors.success.withOpacity(0.3),
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                ),
                              ] : null,
                            ),
                            child: isCompleted
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'edit':
                                onEdit();
                                break;
                              case 'delete':
                                onDelete();
                                break;
                            }
                          },
                          icon: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.textMutedFor(context).withOpacity(0.1),
                            ),
                            child: Icon(
                              Icons.more_vert_rounded,
                              color: AppColors.textMutedFor(context),
                              size: 20,
                            ),
                          ),
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_rounded, size: 18, color: AppColors.textPrimaryFor(context)),
                                  const SizedBox(width: 12),
                                  Text('Edit', style: AppTextStyles.bodyMediumFor(context)),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_rounded, size: 18, color: Colors.red),
                                  const SizedBox(width: 12),
                                  Text('Delete', style: AppTextStyles.bodyMediumFor(context).copyWith(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: habit.currentStreak > 0 
                              ? Colors.orange.withOpacity(0.1)
                              : AppColors.textMutedFor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: habit.currentStreak > 0 
                                ? Colors.orange.withOpacity(0.3)
                                : AppColors.textMutedFor(context).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_fire_department_rounded,
                              size: 16,
                              color: habit.currentStreak > 0 ? Colors.orange : AppColors.textMutedFor(context),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${habit.currentStreak} ${habit.frequency == HabitFrequency.daily ? 'day' : 'week'} streak',
                              style: AppTextStyles.captionFor(context).copyWith(
                                fontWeight: FontWeight.w600,
                                color: habit.currentStreak > 0 ? Colors.orange : AppColors.textMutedFor(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    if (showStats) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Text(
                          '${(habit.completionRate * 100).round()}%',
                          style: AppTextStyles.captionFor(context).copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.textMutedFor(context).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.touch_app_rounded,
                              size: 12,
                              color: AppColors.textMutedFor(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Tap for details',
                              style: AppTextStyles.captionFor(context).copyWith(
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95));
  }
}

class _CategoryChip extends StatelessWidget {
  final HabitCategory? category;
  final bool isSelected;
  final VoidCallback onSelected;
  final int count;

  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onSelected,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = category?.displayName ?? 'All';
    final icon = category?.icon ?? '📋';
    
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            icon,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            '$displayName ($count)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      backgroundColor: Theme.of(context).brightness == Brightness.dark 
          ? Colors.grey.shade800 
          : Colors.grey.shade100,
      side: BorderSide(
        color: isSelected 
            ? AppColors.primary 
            : Theme.of(context).brightness == Brightness.dark 
                ? Colors.grey.shade600
                : Colors.grey.shade300,
        width: isSelected ? 2 : 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool prominent;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
    this.prominent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: prominent ? 12 : 8,
        vertical: prominent ? 6 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(prominent ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(prominent ? 16 : 12),
        border: Border.all(
          color: color.withOpacity(prominent ? 0.4 : 0.3),
          width: prominent ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon, 
            size: prominent ? 16 : 12, 
            color: color,
          ),
          SizedBox(width: prominent ? 6 : 4),
          Text(
            label,
            style: TextStyle(
              fontSize: prominent ? 12 : 10,
              color: color,
              fontWeight: prominent ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}