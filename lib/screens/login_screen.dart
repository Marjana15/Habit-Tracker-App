import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/validators.dart';
import '../widgets/animated_background.dart';
import '../widgets/design_system.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

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

  Future<void> _loginWithGoogle() async {
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
                child: Text(authProvider.errorMessage ?? 'Google sign-in failed'),
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
            message: 'Signing you in...',
            child: AnimatedBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: size.height - MediaQuery.of(context).padding.top,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            const Spacer(flex: 1),
                            _buildHeader(),
                            const SizedBox(height: AppSpacing.xxl),
                            _buildLoginForm(),
                            const SizedBox(height: AppSpacing.xl),
                            _buildSocialLoginSection(),
                            const Spacer(flex: 2),
                            _buildSignUpPrompt(),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                        ),
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
            width: 100,
            height: 100,
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
                    child: const Icon(Icons.eco, size: 50, color: Colors.white),
                  );
                },
              ),
            ),
          ),
        ).animate().scale(duration: 800.ms, curve: Curves.elasticOut),
        
        const SizedBox(height: AppSpacing.lg),
        
        Column(
          children: [
            Text(
              'Welcome Back!',
              style: AppTextStyles.headline1.copyWith(fontSize: 28),
            ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              'Sign in to continue your habit journey',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return EnhancedCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EnhancedTextField(
              label: 'Email Address',
              hint: 'Enter your email',
              controller: _emailController,
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.validateEmail,
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.3),
            
            const SizedBox(height: AppSpacing.lg),
            
            EnhancedTextField(
              label: 'Password',
              hint: 'Enter your password',
              controller: _passwordController,
              prefixIcon: Icons.lock_outline,
              suffixIcon: _obscurePassword ? Icons.visibility : Icons.visibility_off,
              onSuffixTap: () => setState(() => _obscurePassword = !_obscurePassword),
              obscureText: _obscurePassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ).animate().fadeIn(duration: 700.ms).slideX(begin: 0.3),
            
            const SizedBox(height: AppSpacing.sm),
            
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password reset coming soon!'),
                      backgroundColor: AppColors.info,
                    ),
                  );
                },
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 800.ms),
            
            const SizedBox(height: AppSpacing.lg),
            
            EnhancedButton(
              text: 'Sign In',
              onPressed: _login,
              icon: Icons.login,
              width: double.infinity,
            ).animate().fadeIn(duration: 900.ms).slideY(begin: 0.3),
          ],
        ),
      ),
    );
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
              child: Text('Or continue with', style: AppTextStyles.caption),
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
              child: _SocialLoginButton(
                icon: Icons.g_mobiledata,
                label: 'Google',
                onPressed: _loginWithGoogle,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _SocialLoginButton(
                icon: Icons.apple,
                label: 'Apple',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Apple sign-in coming soon!'),
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

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Don\'t have an account? ', style: AppTextStyles.bodyMedium),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          },
          child: Text(
            'Sign Up',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 1200.ms);
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.textPrimary,
        side: BorderSide(color: AppColors.primaryLight.withOpacity(0.3)),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
    );
  }
}
