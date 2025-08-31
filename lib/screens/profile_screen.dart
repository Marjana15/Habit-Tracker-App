import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/design_system.dart';
import 'login_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Consumer2<AuthProvider, ThemeProvider>(
        builder: (context, authProvider, themeProvider, child) {
          final user = authProvider.currentUser;
          
          if (user == null) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          ProfileImage(
                            photoURL: user.photoURL,
                            displayName: user.displayName,
                            size: 100,
                            showBorder: true,
                          ).animate().scale(duration: 600.ms),
                          
                          const SizedBox(height: 16),
                          
                          Text(
                            user.displayName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ).animate().fadeIn(duration: 800.ms),
                          
                          const SizedBox(height: 8),
                          
                          Text(
                            user.email,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: const Color(0xFF81C784),
                            ),
                          ).animate().fadeIn(duration: 1000.ms),
                          
                          const SizedBox(height: 20),
                          
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const EditProfileScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                            ),
                          ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.8, 0.8)),
                        ],
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.lg),
                
                if (user.gender != null || user.dateOfBirth != null || user.height != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: const Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (user.gender != null)
                            _InfoRow(
                              icon: Icons.person_outline,
                              label: 'Gender',
                              value: user.gender!,
                            ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),
                          
                          if (user.dateOfBirth != null)
                            _InfoRow(
                              icon: Icons.calendar_today,
                              label: 'Date of Birth',
                              value: '${user.dateOfBirth!.day}/${user.dateOfBirth!.month}/${user.dateOfBirth!.year}',
                            ).animate().fadeIn(duration: 1000.ms).slideX(begin: 0.3),
                          
                          if (user.height != null)
                            _InfoRow(
                              icon: Icons.height,
                              label: 'Height',
                              value: '${user.height!.toInt()} cm',
                            ).animate().fadeIn(duration: 1200.ms).slideX(begin: -0.3),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: AppSpacing.lg),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account Information',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _InfoRow(
                          icon: Icons.person,
                          label: 'Display Name',
                          value: user.displayName,
                        ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3),
                        
                        _InfoRow(
                          icon: Icons.email,
                          label: 'Email',
                          value: user.email,
                        ).animate().fadeIn(duration: 1000.ms).slideX(begin: 0.3),
                        
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Member Since',
                          value: '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}',
                        ).animate().fadeIn(duration: 1200.ms).slideX(begin: -0.3),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.palette,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Theme',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _ThemeOption(
                                icon: Icons.light_mode,
                                label: 'Light',
                                isSelected: themeProvider.isLightMode,
                                onTap: () => themeProvider.setThemeMode(
                                  ThemeMode.light,
                                  userId: user.uid,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ThemeOption(
                                icon: Icons.dark_mode,
                                label: 'Dark',
                                isSelected: themeProvider.isDarkMode,
                                onTap: () => themeProvider.setThemeMode(
                                  ThemeMode.dark,
                                  userId: user.uid,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ThemeOption(
                                icon: Icons.phone_android,
                                label: 'System',
                                isSelected: themeProvider.isSystemMode,
                                onTap: () => themeProvider.setThemeMode(
                                  ThemeMode.system,
                                  userId: user.uid,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 1300.ms).slideY(begin: 0.3),
                
                const SizedBox(height: AppSpacing.xl),
                
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.settings),
                    label: const Text(
                      'Settings',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF4CAF50),
                      side: const BorderSide(color: Color(0xFF4CAF50)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 1300.ms).slideY(begin: 0.3),
                
                const SizedBox(height: 16),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _signOut(context),
                    icon: const Icon(Icons.logout),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ).animate().fadeIn(duration: 1400.ms).slideY(begin: 0.3),
                
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF81C784),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4CAF50).withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF2E7D32) : Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}