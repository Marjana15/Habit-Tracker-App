import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/animated_background.dart';
import '../widgets/design_system.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _heightController = TextEditingController();
  
  String? _selectedGender;
  DateTime? _selectedDateOfBirth;
  bool _acceptedTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _selectDateOfBirth() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surfaceFor(context),
              onSurface: AppColors.textPrimaryFor(context),
              background: AppColors.backgroundFor(context),
              onBackground: AppColors.textPrimaryFor(context),
            ),
            textTheme: Theme.of(context).textTheme.copyWith(
              headlineSmall: TextStyle(
                color: AppColors.textPrimaryFor(context),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
              bodyLarge: TextStyle(
                color: AppColors.textPrimaryFor(context),
                fontSize: 16,
              ),
              bodyMedium: TextStyle(
                color: AppColors.textSecondaryFor(context),
                fontSize: 14,
              ),
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

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_outlined, color: Colors.white),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text('Please accept the Terms & Conditions'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      );
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _displayNameController.text.trim(),
      gender: _selectedGender,
      dateOfBirth: _selectedDateOfBirth,
      height: _heightController.text.isNotEmpty ? double.tryParse(_heightController.text) : null,
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
                child: Text(authProvider.errorMessage ?? 'Registration failed'),
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

  Future<void> _registerWithGoogle() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    final success = await authProvider.signInWithGoogle();

    if (success && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (mounted && authProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(authProvider.errorMessage ?? 'Google registration failed'),
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          body: LoadingOverlay(
            isLoading: authProvider.isLoading,
            message: 'Creating your account...',
            child: AnimatedBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height - MediaQuery.of(context).padding.top,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          _buildHeader(),
                          const SizedBox(height: AppSpacing.xl),
                          _buildRegistrationForm(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSocialLoginSection(),
                          const SizedBox(height: AppSpacing.lg),
                          _buildSignInPrompt(),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Hero(
          tag: 'app_logo',
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [AppShadows.medium],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/imgs/logo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary, AppColors.primaryLight],
                      ),
                    ),
                    child: const Icon(Icons.eco, size: 40, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: AppSpacing.md),
        
        Text(
          'Create Account',
          style: AppTextStyles.headline1.copyWith(fontSize: 26),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
        
        const SizedBox(height: AppSpacing.xs),
        
        Text(
          'Start your habit journey today',
          style: AppTextStyles.bodyMedium,
          textAlign: TextAlign.center,
        ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return EnhancedCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EnhancedTextField(
              label: 'Display Name',
              hint: 'Enter your display name',
              controller: _displayNameController,
              prefixIcon: Icons.person_outline,
              validator: Validators.validateDisplayName,
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
            
            const SizedBox(height: AppSpacing.md),
            
            EnhancedTextField(
              label: 'Email Address',
              hint: 'Enter your email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ).animate().fadeIn(duration: 700.ms).slideX(begin: 0.3),
            
            const SizedBox(height: AppSpacing.md),
            
            EnhancedTextField(
              label: 'Password',
              hint: 'Create a strong password',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
              onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
              obscureText: _obscurePassword,
              validator: Validators.validatePassword,
            ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),
            
            const SizedBox(height: AppSpacing.md),
            
            EnhancedTextField(
              label: 'Confirm Password',
              hint: 'Confirm your password',
              controller: _confirmPasswordController,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              onSuffixTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
              obscureText: _obscureConfirmPassword,
              validator: (value) => Validators.validateConfirmPassword(value, _passwordController.text),
            ).animate().fadeIn(duration: 900.ms).slideX(begin: 0.3),
            
            const SizedBox(height: AppSpacing.lg),
            
            SectionHeader(
              title: 'Optional Information',
              subtitle: 'Help us personalize your experience',
              icon: Icons.tune,
            ).animate().fadeIn(duration: 1000.ms),
            
            const SizedBox(height: AppSpacing.md),
            
            _buildOptionalFields(),
            
            const SizedBox(height: AppSpacing.lg),
            
            _buildTermsCheckbox().animate().fadeIn(duration: 1300.ms),
            
            const SizedBox(height: AppSpacing.lg),
            
            EnhancedButton(
              text: 'Create Account',
              onPressed: _register,
              icon: Icons.person_add,
              width: double.infinity,
            ).animate().fadeIn(duration: 1400.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionalFields() {
    return Column(
      children: [
        _buildGenderDropdown().animate().fadeIn(duration: 1000.ms).slideX(begin: -0.3),
        const SizedBox(height: AppSpacing.md),
        _buildDateOfBirthField().animate().fadeIn(duration: 1100.ms).slideX(begin: 0.3),
        const SizedBox(height: AppSpacing.md),
        EnhancedTextField(
          label: 'Height (cm) - Optional',
          hint: 'Enter your height',
          controller: _heightController,
          prefixIcon: Icons.height,
          keyboardType: TextInputType.number,
          validator: Validators.validateHeight,
        ).animate().fadeIn(duration: 1200.ms).slideX(begin: -0.3),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender (Optional)',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryFor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          dropdownColor: AppColors.surfaceFor(context),
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textPrimaryFor(context),
          ),
          decoration: InputDecoration(
            hintText: 'Select your gender',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMutedFor(context),
            ),
            prefixIcon: const Icon(Icons.person_outline, color: AppColors.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surfaceFor(context),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
          items: ['Male', 'Female', 'Other']
              .map((gender) => DropdownMenuItem(
                    value: gender,
                    child: Text(
                      gender,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimaryFor(context),
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedGender = value),
        ),
      ],
    );
  }

  Widget _buildDateOfBirthField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth (Optional)',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondaryFor(context),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        InkWell(
          onTap: _selectDateOfBirth,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: 'Select your date of birth',
              hintStyle: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMutedFor(context),
              ),
              prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: BorderSide(color: AppColors.primaryLight.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              filled: true,
              fillColor: AppColors.surfaceFor(context),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
            child: Text(
              _selectedDateOfBirth == null
                  ? 'Select Date'
                  : '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}',
              style: _selectedDateOfBirth == null
                  ? AppTextStyles.bodyMedium.copyWith(color: AppColors.textMutedFor(context))
                  : AppTextStyles.bodyLarge.copyWith(color: AppColors.textPrimaryFor(context)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) => setState(() => _acceptedTerms = value ?? false),
          activeColor: AppColors.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _acceptedTerms = !_acceptedTerms),
            child: Text(
              'I agree to the Terms & Conditions and Privacy Policy',
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignInPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Already have an account? ', style: AppTextStyles.bodyMedium),
        TextButton(
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
            );
          },
          child: Text(
            'Sign In',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 1500.ms);
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(color: AppColors.textMuted.withOpacity(0.3)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Or sign up with', style: AppTextStyles.caption),
            ),
            Expanded(
              child: Divider(color: AppColors.textMuted.withOpacity(0.3)),
            ),
          ],
        ).animate().fadeIn(duration: 1000.ms),
        
        const SizedBox(height: AppSpacing.lg),
        
        Row(
          children: [
            Expanded(
              child: _SocialSignUpButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                onPressed: _registerWithGoogle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SocialSignUpButton(
                icon: Icons.apple,
                label: 'Apple',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apple sign-up coming soon!'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
              ),
            ),
          ],
        ).animate().fadeIn(duration: 1100.ms).slideY(begin: 0.3),
      ],
    );
  }
}

class _SocialSignUpButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialSignUpButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedButton(
      text: label,
      onPressed: onPressed,
      icon: icon,
      isSecondary: true,
      width: double.infinity,
    );
  }
}