import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/habit_model.dart';
import '../providers/habit_provider.dart';
import '../widgets/progress_chart.dart';
import '../widgets/animated_background.dart';

class HabitProgressScreen extends StatefulWidget {
  final Habit habit;

  const HabitProgressScreen({
    super.key,
    required this.habit,
  });

  @override
  State<HabitProgressScreen> createState() => _HabitProgressScreenState();
}

class _HabitProgressScreenState extends State<HabitProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedDays = 7;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final currentHabit = habitProvider.getHabitById(widget.habit.id) ?? widget.habit;
        
        return Scaffold(
          body: AnimatedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              currentHabit.category.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                currentHabit.title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              Text(
                                '${currentHabit.category.displayName} • ${currentHabit.frequency.displayName}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF81C784),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [7, 14, 30, 60, 90].map((days) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text('${days}D'),
                              selected: _selectedDays == days,
                              onSelected: (_) {
                                setState(() => _selectedDays = days);
                              },
                              selectedColor: const Color(0xFF4CAF50).withOpacity(0.2),
                              checkmarkColor: const Color(0xFF4CAF50),
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide(
                                color: _selectedDays == days 
                                    ? const Color(0xFF4CAF50) 
                                    : Colors.grey.shade300,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ).animate().fadeIn(duration: 800.ms),

                  const SizedBox(height: 16),

                  TabBar(
                    controller: _tabController,
                    labelColor: const Color(0xFF4CAF50),
                    unselectedLabelColor: const Color(0xFF81C784),
                    indicatorColor: const Color(0xFF4CAF50),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Charts'),
                      Tab(text: 'Matrix'),
                      Tab(text: 'Stats'),
                    ],
                  ).animate().fadeIn(duration: 1000.ms),

                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _ChartsTab(habit: currentHabit, days: _selectedDays),
                        _MatrixTab(habit: currentHabit, days: _selectedDays),
                        _StatsTab(habit: currentHabit),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChartsTab extends StatelessWidget {
  final Habit habit;
  final int days;

  const _ChartsTab({
    required this.habit,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          HabitProgressChart(
            habit: habit,
            days: days,
            title: 'Progress ($days days)',
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 16),
          
          if (days >= 14)
            Consumer<HabitProvider>(
              builder: (context, habitProvider, child) {
                return WeeklyProgressChart(
                  habits: [habit],
                  weeks: (days / 7).ceil().clamp(2, 8),
                ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3);
              },
            ),
        ],
      ),
    );
  }
}

class _MatrixTab extends StatelessWidget {
  final Habit habit;
  final int days;

  const _MatrixTab({
    required this.habit,
    required this.days,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          HabitCompletionMatrix(
            habit: habit,
            days: days,
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
          
          const SizedBox(height: 16),
          
          _buildMatrixLegend(),
        ],
      ),
    );
  }

  Widget _buildMatrixLegend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) => Text(
                'Legend',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _LegendItem(
                  color: const Color(0xFF4CAF50),
                  label: 'Completed',
                  icon: Icons.check,
                ),
                const SizedBox(width: 16),
                _LegendItem(
                  color: const Color(0xFFE0E0E0),
                  label: 'Missed',
                ),
                const SizedBox(width: 16),
                _LegendItem(
                  color: Colors.grey.shade200,
                  label: 'Future',
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms);
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final IconData? icon;

  const _LegendItem({
    required this.color,
    required this.label,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
          child: icon != null
              ? Icon(icon, size: 10, color: Colors.white)
              : null,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF81C784),
          ),
        ),
      ],
    );
  }
}

class _StatsTab extends StatelessWidget {
  final Habit habit;

  const _StatsTab({
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          ProgressStats(habit: habit)
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.3),
          
          const SizedBox(height: 16),
          
          _buildAdditionalStats(),
        ],
      ),
    );
  }

  Widget _buildAdditionalStats() {
    final now = DateTime.now();
    final daysSinceCreation = now.difference(habit.createdAt).inDays + 1;
    final longestStreak = _calculateLongestStreak();
    final averagePerWeek = _calculateAveragePerWeek();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Builder(
              builder: (context) => Text(
                'Additional Statistics',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _InfoRow(
              icon: Icons.calendar_today,
              label: 'Days since creation',
              value: '$daysSinceCreation days',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.star,
              label: 'Longest streak',
              value: '$longestStreak ${habit.frequency == HabitFrequency.daily ? 'days' : 'weeks'}',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.trending_up,
              label: 'Average per week',
              value: '${averagePerWeek.toStringAsFixed(1)} completions',
            ),
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.event_available,
              label: 'Total completions',
              value: '${habit.completionHistory.length}',
            ),
            if (habit.notes != null && habit.notes!.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Builder(
                builder: (context) => Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E7D32),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                habit.notes!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF81C784),
                ),
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3);
  }

  int _calculateLongestStreak() {
    if (habit.completionHistory.isEmpty) return 0;
    
    final sortedDates = List<DateTime>.from(habit.completionHistory)
      ..sort((a, b) => a.compareTo(b));
    
    int longestStreak = 1;
    int currentStreak = 1;
    
    for (int i = 1; i < sortedDates.length; i++) {
      final daysBetween = sortedDates[i].difference(sortedDates[i - 1]).inDays;
      final expectedGap = habit.frequency == HabitFrequency.daily ? 1 : 7;
      
      if (daysBetween <= expectedGap) {
        currentStreak++;
      } else {
        longestStreak = currentStreak > longestStreak ? currentStreak : longestStreak;
        currentStreak = 1;
      }
    }
    
    return currentStreak > longestStreak ? currentStreak : longestStreak;
  }

  double _calculateAveragePerWeek() {
    if (habit.completionHistory.isEmpty) return 0.0;
    
    final now = DateTime.now();
    final weeksSinceCreation = now.difference(habit.createdAt).inDays / 7;
    
    return habit.completionHistory.length / weeksSinceCreation;
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF2E7D32),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }
}