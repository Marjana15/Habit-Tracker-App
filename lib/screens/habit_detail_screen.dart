import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../widgets/animated_background.dart';
import '../widgets/completion_animation.dart';
import 'edit_habit_screen.dart';
import 'habit_progress_screen.dart';

class HabitDetailScreen extends StatelessWidget {
  final Habit habit;

  const HabitDetailScreen({super.key, required this.habit});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(habit.title),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HabitProgressScreen(habit: habit),
                ),
              );
            },
            icon: const Icon(Icons.analytics),
            tooltip: 'View Progress Charts',
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditHabitScreen(habit: habit),
                ),
              );
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          border: Border.all(
                            color: const Color(0xFF4CAF50),
                            width: 3,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            habit.category.icon,
                            style: const TextStyle(fontSize: 36),
                          ),
                        ),
                      ).animate().scale(duration: 600.ms),
                      
                      const SizedBox(height: 16),
                      
                      Text(
                        habit.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ).animate().fadeIn(duration: 800.ms),
                      
                      const SizedBox(height: 8),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF4CAF50).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF4CAF50).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              habit.category.displayName,
                              style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF81C784).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFF81C784).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              habit.frequency.displayName,
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ).animate().fadeIn(duration: 1000.ms),
                      
                      const SizedBox(height: 20),
                      
                      Consumer2<AuthProvider, HabitProvider>(
                        builder: (context, authProvider, habitProvider, child) {
                          final currentHabit = habitProvider.getHabitById(habit.id) ?? habit;
                          final isCompleted = currentHabit.isCompletedToday;
                          
                          return GestureDetector(
                            onTap: () async {
                              final wasCompleted = isCompleted;
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
                                      'Awesome! Keep building that streak! 🔥'
                                    );
                                    
                                    if (updatedHabit.currentStreak > 1 && updatedHabit.currentStreak % 3 == 0) {
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
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isCompleted 
                                    ? const Color(0xFF4CAF50)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50),
                                  width: 2,
                                ),
                                boxShadow: isCompleted ? [
                                  BoxShadow(
                                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ] : null,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CompletionAnimation(
                                    isCompleted: isCompleted,
                                    onTap: () {}, // Empty since parent handles tap
                                    size: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isCompleted 
                                        ? 'Completed Today!'
                                        : 'Mark as Complete',
                                    style: TextStyle(
                                      color: isCompleted ? Colors.white : const Color(0xFF4CAF50),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).animate(
                            target: isCompleted ? 1 : 0,
                          ).scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.02, 1.02),
                            duration: 150.ms,
                          ).then().scale(
                            begin: const Offset(1.02, 1.02),
                            end: const Offset(1.0, 1.0),
                            duration: 200.ms,
                            curve: Curves.elasticOut,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
              
              const SizedBox(height: 20),
              
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HabitProgressScreen(habit: habit),
                          ),
                        );
                      },
                      icon: const Icon(Icons.analytics),
                      label: const Text('View Progress'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditHabitScreen(habit: habit),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Edit Habit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF4CAF50),
                        side: const BorderSide(color: Color(0xFF4CAF50)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(duration: 1300.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 20),
              
              Text(
                'Statistics',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 800.ms),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.local_fire_department,
                      title: 'Current Streak',
                      value: '${habit.currentStreak}',
                      subtitle: habit.frequency == HabitFrequency.daily ? 'Days' : 'Weeks',
                      color: Colors.orange,
                    ).animate().fadeIn(duration: 900.ms).slideX(begin: -0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.show_chart,
                      title: 'Success Rate',
                      value: '${(habit.completionRate * 100).round()}%',
                      subtitle: 'Overall',
                      color: const Color(0xFF4CAF50),
                    ).animate().fadeIn(duration: 1000.ms).slideX(begin: 0.3),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      icon: Icons.event_available,
                      title: 'Total Done',
                      value: '${habit.completionHistory.length}',
                      subtitle: 'Times',
                      color: const Color(0xFF2196F3),
                    ).animate().fadeIn(duration: 1100.ms).slideX(begin: -0.3),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      icon: Icons.calendar_today,
                      title: 'Days Since Start',
                      value: '${DateTime.now().difference(habit.createdAt).inDays + 1}',
                      subtitle: 'Days',
                      color: const Color(0xFF9C27B0),
                    ).animate().fadeIn(duration: 1200.ms).slideX(begin: 0.3),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              if (habit.frequency == HabitFrequency.weekly) ...[
                Text(
                  'This Week\'s Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 1300.ms),
                
                const SizedBox(height: 12),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Completed this week',
                              style: const TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '${habit.completionsThisWeek} / 1',
                              style: const TextStyle(
                                color: Color(0xFF4CAF50),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: habit.isCompletedThisWeek ? 1.0 : 0.0,
                          backgroundColor: const Color(0xFF81C784).withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 1400.ms).slideY(begin: 0.3),
                
                const SizedBox(height: 20),
              ],
              
              if (habit.notes != null && habit.notes!.isNotEmpty) ...[
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF2E7D32),
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(duration: 1400.ms),
                
                const SizedBox(height: 12),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      habit.notes!,
                      style: const TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 1500.ms).slideY(begin: 0.3),
                
                const SizedBox(height: 20),
              ],
              
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(duration: 1600.ms),
              
              const SizedBox(height: 12),
              
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: habit.completionHistory.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No completions yet!\nStart by marking today as complete.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF81C784),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        )
                      : Column(
                          children: [
                            ...habit.completionHistory
                                .take(10) // Show last 10 completions
                                .map((completion) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Color(0xFF4CAF50),
                                      size: 16,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Completed on ${completion.day}/${completion.month}/${completion.year}',
                                      style: const TextStyle(
                                        color: Color(0xFF2E7D32),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                            if (habit.completionHistory.length > 10)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(
                                  'And ${habit.completionHistory.length - 10} more...',
                                  style: const TextStyle(
                                    color: Color(0xFF81C784),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ).animate().fadeIn(duration: 1700.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String subtitle;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
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
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}