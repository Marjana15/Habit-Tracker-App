import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/animated_background.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _heightController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _displayNameController.text = user.displayName;
      _selectedGender = user.gender;
      _selectedDateOfBirth = user.dateOfBirth;
      if (user.height != null) {
        _heightController.text = user.height!.toInt().toString();
      }
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
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
    if (picked != null && picked != _selectedDateOfBirth) {
      setState(() {
        _selectedDateOfBirth = picked;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.updateProfile(
      displayName: _displayNameController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDateOfBirth,
      height: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
    );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Color(0xFF4CAF50),
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authProvider.errorMessage ?? 'Failed to update profile'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF4CAF50).withOpacity(0.1),
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ).animate().scale(duration: 600.ms),
                  
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: _displayNameController,
                    decoration: const InputDecoration(
                      labelText: 'Display Name *',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: Validators.validateDisplayName,
                    textInputAction: TextInputAction.next,
                  ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: 20),

                  Consumer<AuthProvider>(
                    builder: (context, authProvider, child) {
                      return TextFormField(
                        initialValue: authProvider.currentUser?.email ?? '',
                        decoration: const InputDecoration(
                          labelText: 'Email (cannot be changed)',
                          prefixIcon: Icon(Icons.email),
                          enabled: false,
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.3),
                  
                  const SizedBox(height: 20),

                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    decoration: const InputDecoration(
                      labelText: 'Gender (Optional)',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Male', child: Text('Male')),
                      DropdownMenuItem(value: 'Female', child: Text('Female')),
                      DropdownMenuItem(value: 'Other', child: Text('Other')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ).animate().fadeIn(duration: 900.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: 20),

                  InkWell(
                    onTap: _selectDateOfBirth,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date of Birth (Optional)',
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _selectedDateOfBirth == null
                                ? 'Select Date'
                                : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
                            style: _selectedDateOfBirth == null
                                ? const TextStyle(color: Colors.grey)
                                : null,
                          ),
                          if (_selectedDateOfBirth != null)
                            IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                setState(() {
                                  _selectedDateOfBirth = null;
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
                    controller: _heightController,
                    decoration: const InputDecoration(
                      labelText: 'Height (cm) - Optional',
                      prefixIcon: Icon(Icons.height),
                    ),
                    keyboardType: TextInputType.number,
                    validator: Validators.validateHeight,
                    textInputAction: TextInputAction.done,
                  ).animate().fadeIn(duration: 1100.ms).slideX(begin: -0.3),
                  
                  const SizedBox(height: 40),

                  ElevatedButton(
                    onPressed: _isLoading ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Update Profile',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
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