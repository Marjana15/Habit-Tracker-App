import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/design_system.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: AppColors.backgroundFor(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.1),
              AppColors.primaryLight.withOpacity(0.05),
              AppColors.backgroundFor(context),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  child: Image.asset(
                    'assets/imgs/logo.png',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primary,
                              AppColors.primaryLight,
                            ],
                          ),
                        ),
                        child: const Icon(
                          Icons.psychology_rounded,
                          size: 60,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              )
                  .animate()
                  .scale(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: const Duration(milliseconds: 600)),
              
              const SizedBox(height: AppSpacing.xl),
              
              Text(
                'HabitTracker',
                style: AppTextStyles.headline1.copyWith(
                  color: AppColors.textPrimaryFor(context),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              )
                  .animate(delay: const Duration(milliseconds: 300))
                  .slideY(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: const Duration(milliseconds: 600)),
              
              const SizedBox(height: AppSpacing.sm),
              
              Text(
                'Build Better Habits Daily',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondaryFor(context),
                  letterSpacing: 0.5,
                ),
              )
                  .animate(delay: const Duration(milliseconds: 600))
                  .slideY(
                    begin: 0.3,
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOut,
                  )
                  .fadeIn(duration: const Duration(milliseconds: 600)),
              
              const SizedBox(height: AppSpacing.xxl),
              
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primary,
                  ),
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                ),
              )
                  .animate(delay: const Duration(milliseconds: 900))
                  .fadeIn(duration: const Duration(milliseconds: 400))
                  .scale(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOut,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}