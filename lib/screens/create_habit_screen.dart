import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/habit_provider.dart';
import '../models/habit_model.dart';
import '../widgets/animated_background.dart';

class CreateHabitScreen extends StatefulWidget {
  const CreateHabitScreen({super.key});

  @override
  State<CreateHabitScreen> createState() => _CreateHabitScreenState();
}

class _CreateHabitScreenState extends State<CreateHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  
  HabitCategory? _selectedCategory;
  HabitFrequency _selectedFrequency = HabitFrequency.daily;
  DateTime? _selectedStartDate;

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF4CAF50),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedStartDate) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _createHabit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    final success = await habitProvider.createHabit(
      userId: authProvider.currentUser!.uid,
      title: _titleController.text.trim(),
      category: _selectedCategory!,
      frequency: _selectedFrequency,
      startDate: _selectedStartDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Habit created successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(habitProvider.errorMessage ?? 'Failed to create habit'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Habit'),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  
                  Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.add_task,
                        size: 40,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ).animate().scale(duration: 600.ms),
                  
                  const SizedBox(height: 30),

                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Habit Title *',
                      prefixIcon: Icon(Icons.title),
                      hintText: 'e.g., Drink 8 glasses of water',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a habit title';
                      }
                      if (value.trim().length < 3) {
                        return 'Title must be at least 3 characters';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.sentences,
                  ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Category *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: HabitCategory.values.map((category) {
                          final isSelected = _selectedCategory == category;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedCategory = category;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF4CAF50)
                                    : Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFF4CAF50)
                                      : const Color(0xFF81C784),
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    category.icon,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    category.displayName,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF2E7D32),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.3),
                  
                  const SizedBox(height: 20),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequency *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: HabitFrequency.values.map((frequency) {
                          final isSelected = _selectedFrequency == frequency;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedFrequency = frequency;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF4CAF50)
                                      : Colors.white,
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF81C784),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      frequency == HabitFrequency.daily
                                          ? Icons.today
                                          : Icons.date_range,
                                      color: isSelected
                                          ? Colors.white
                                          : const Color(0xFF4CAF50),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      frequency.displayName,
                                      style: TextStyle(
                                        color: isSelected
                                            ? Colors.white
                                            : const Color(0xFF2E7D32),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ).animate().fadeIn(duration: 900.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: 20),

                  InkWell(
                    onTap: _selectStartDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Start Date (Optional)',
                        prefixIcon: Icon(Icons.calendar_today),
                        suffixIcon: Icon(Icons.arrow_drop_down),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedStartDate == null
                                ? 'Select start date'
                                : '${_selectedStartDate!.day}/${_selectedStartDate!.month}/${_selectedStartDate!.year}',
                            style: _selectedStartDate == null
                                ? const TextStyle(color: Colors.grey)
                                : null,
                          ),
                          if (_selectedStartDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedStartDate = null;
                                });
                              },
                              color: Colors.grey,
                            ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 1000.ms).slideX(begin: 0.3),
                  
                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes/Description (Optional)',
                      prefixIcon: Icon(Icons.note),
                      hintText: 'Add any additional details...',
                    ),
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    textCapitalization: TextCapitalization.sentences,
                  ).animate().fadeIn(duration: 1100.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: 40),

                  Consumer<HabitProvider>(
                    builder: (context, habitProvider, child) {
                      return ElevatedButton.icon(
                        onPressed: habitProvider.isLoading ? null : _createHabit,
                        icon: habitProvider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.add),
                        label: Text(
                          habitProvider.isLoading ? 'Creating...' : 'Create Habit',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.8, 0.8)),
                  
                  const SizedBox(height: 20),

                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Color(0xFF4CAF50),
                        fontSize: 16,
                      ),
                    ),
                  ).animate().fadeIn(duration: 1300.ms),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}