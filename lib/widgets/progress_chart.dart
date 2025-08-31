import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/habit_model.dart';

class HabitProgressChart extends StatelessWidget {
  final Habit habit;
  final int days;
  final String title;

  const HabitProgressChart({
    super.key,
    required this.habit,
    this.days = 7,
    this.title = 'Last 7 Days',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final chartData = _generateChartData();
    
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 1,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (group) => const Color(0xFF4CAF50),
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final date = DateTime.now().subtract(Duration(days: days - 1 - group.x.toInt()));
              final isCompleted = rod.toY == 1;
              return BarTooltipItem(
                '${DateFormat('MMM d').format(date)}\n${isCompleted ? 'Completed' : 'Not done'}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final date = DateTime.now().subtract(Duration(days: days - 1 - value.toInt()));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('E').format(date).substring(0, 1),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF81C784),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: chartData,
      ),
    );
  }

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

  bool _isCompletedOnDate(DateTime date) {
    return habit.completionHistory.any((completionDate) =>
        completionDate.year == date.year &&
        completionDate.month == date.month &&
        completionDate.day == date.day);
  }
}

class WeeklyProgressChart extends StatelessWidget {
  final List<Habit> habits;
  final int weeks;

  const WeeklyProgressChart({
    super.key,
    required this.habits,
    this.weeks = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Progress',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildLineChart(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart() {
    final chartData = _generateWeeklyData();
    
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final weekStart = DateTime.now().subtract(Duration(days: (weeks - 1 - value.toInt()) * 7));
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('M/d').format(weekStart),
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF81C784),
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${(value * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF81C784),
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        minX: 0,
        maxX: weeks.toDouble() - 1,
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
            spots: chartData,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF81C784),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: const Color(0xFF4CAF50),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4CAF50).withOpacity(0.3),
                  const Color(0xFF4CAF50).withOpacity(0.1),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateWeeklyData() {
    final data = <FlSpot>[];
    final now = DateTime.now();
    
    for (int i = 0; i < weeks; i++) {
      final weekStart = now.subtract(Duration(days: (weeks - 1 - i) * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      
      double totalCompletionRate = 0;
      int validHabits = 0;
      
      for (final habit in habits) {
        if (habit.createdAt.isBefore(weekEnd)) {
          final weekCompletions = habit.completionHistory.where((date) =>
              date.isAfter(weekStart.subtract(const Duration(days: 1))) &&
              date.isBefore(weekEnd.add(const Duration(days: 1)))).length;
          
          final expectedCompletions = habit.frequency == HabitFrequency.daily ? 7 : 1;
          final completionRate = (weekCompletions / expectedCompletions).clamp(0.0, 1.0);
          
          totalCompletionRate += completionRate;
          validHabits++;
        }
      }
      
      final avgCompletionRate = validHabits > 0 ? totalCompletionRate / validHabits : 0.0;
      data.add(FlSpot(i.toDouble(), avgCompletionRate));
    }
    
    return data;
  }
}

class HabitCompletionMatrix extends StatelessWidget {
  final Habit habit;
  final int days;

  const HabitCompletionMatrix({
    super.key,
    required this.habit,
    this.days = 30,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Completion Matrix (${days} days)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            _buildMatrix(),
          ],
        ),
      ),
    );
  }

  Widget _buildMatrix() {
    final now = DateTime.now();
    const cellSize = 16.0;
    const cellSpacing = 2.0;
    const itemsPerRow = 7;
    
    final rows = (days / itemsPerRow).ceil();
    
    return Column(
      children: List.generate(rows, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.only(bottom: cellSpacing),
          child: Row(
            children: List.generate(itemsPerRow, (colIndex) {
              final dayIndex = rowIndex * itemsPerRow + colIndex;
              if (dayIndex >= days) return const SizedBox.shrink();
              
              final date = now.subtract(Duration(days: days - 1 - dayIndex));
              final isCompleted = _isCompletedOnDate(date);
              final isFuture = date.isAfter(now);
              
              return Container(
                margin: const EdgeInsets.only(right: cellSpacing),
                width: cellSize,
                height: cellSize,
                decoration: BoxDecoration(
                  color: isFuture
                      ? Colors.grey.shade200
                      : isCompleted
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: isFuture
                    ? null
                    : isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 10,
                            color: Colors.white,
                          )
                        : null,
              );
            }),
          ),
        );
      }),
    );
  }

  bool _isCompletedOnDate(DateTime date) {
    return habit.completionHistory.any((completionDate) =>
        completionDate.year == date.year &&
        completionDate.month == date.month &&
        completionDate.day == date.day);
  }
}

class ProgressStats extends StatelessWidget {
  final Habit habit;

  const ProgressStats({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final thisWeekStart = now.subtract(Duration(days: now.weekday - 1));
    final thisMonthStart = DateTime(now.year, now.month, 1);
    
    final thisWeekCompletions = habit.completionHistory
        .where((date) => date.isAfter(thisWeekStart.subtract(const Duration(days: 1))))
        .length;
    
    final thisMonthCompletions = habit.completionHistory
        .where((date) => date.isAfter(thisMonthStart.subtract(const Duration(days: 1))))
        .length;
    
    final completionRate = (habit.completionRate * 100).round();
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Current Streak',
                    value: '${habit.currentStreak}',
                    subtitle: habit.frequency == HabitFrequency.daily ? 'days' : 'weeks',
                    icon: Icons.local_fire_department,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'This Week',
                    value: '$thisWeekCompletions',
                    subtitle: 'completions',
                    icon: Icons.calendar_today,
                    color: const Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'This Month',
                    value: '$thisMonthCompletions',
                    subtitle: 'completions',
                    icon: Icons.calendar_month,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Success Rate',
                    value: '$completionRate%',
                    subtitle: 'overall',
                    icon: Icons.trending_up,
                    color: const Color(0xFF9C27B0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
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
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
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
    );
  }
}