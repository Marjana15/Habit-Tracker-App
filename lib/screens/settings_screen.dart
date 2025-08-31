import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/design_system.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: AnimatedBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Appearance',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 600.ms),
              
              const SizedBox(height: 16),
              
              Card(
                child: Column(
                  children: [
                    Consumer2<ThemeProvider, AuthProvider>(
                      builder: (context, themeProvider, authProvider, child) {
                        return _SettingsTile(
                          icon: _getThemeIcon(themeProvider.themeMode),
                          title: 'Theme',
                          subtitle: _getThemeLabel(themeProvider.themeMode),
                          onTap: () => _showThemeDialog(context, themeProvider, authProvider),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.palette,
                      title: 'App Colors',
                      subtitle: 'Green theme (Default)',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Custom colors coming soon!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 32),
              
              Text(
                'Data & Privacy',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 1000.ms),
              
              const SizedBox(height: 16),
              
              Card(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.sync,
                      title: 'Data Sync',
                      subtitle: 'Automatically sync with cloud',
                      trailing: Consumer<AuthProvider>(
                        builder: (context, authProvider, child) {
                          return Switch(
                            value: authProvider.currentUser != null,
                            onChanged: authProvider.currentUser != null ? null : (value) {
                            },
                            activeColor: const Color(0xFF4CAF50),
                          );
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.download,
                      title: 'Export Data',
                      subtitle: 'Download your habits and progress',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data export coming soon!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.delete_forever,
                      title: 'Clear All Data',
                      subtitle: 'Remove all local data',
                      titleColor: Colors.red,
                      onTap: () => _showClearDataDialog(context),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 1200.ms).slideY(begin: 0.3),
              
              const SizedBox(height: 32),
              
              Text(
                'About',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 1400.ms),
              
              const SizedBox(height: 16),
              
              Card(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.info,
                      title: 'App Version',
                      subtitle: '1.0.0',
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.help,
                      title: 'Help & Support',
                      subtitle: 'Get help using the app',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Help center coming soon!'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    _SettingsTile(
                      icon: Icons.star,
                      title: 'Rate App',
                      subtitle: 'Help us improve',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Thank you for your support! 🌟'),
                            backgroundColor: Color(0xFF4CAF50),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 1600.ms).slideY(begin: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_brightness;
    }
  }

  String _getThemeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light Mode';
      case ThemeMode.dark:
        return 'Dark Mode';
      case ThemeMode.system:
        return 'System Default';
    }
  }

  void _showThemeDialog(BuildContext context, ThemeProvider themeProvider, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ThemeOption(
              icon: Icons.light_mode,
              title: 'Light Mode',
              isSelected: themeProvider.themeMode == ThemeMode.light,
              onTap: () {
                themeProvider.setThemeMode(
                  ThemeMode.light,
                  userId: authProvider.currentUser?.uid,
                );
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              isSelected: themeProvider.themeMode == ThemeMode.dark,
              onTap: () {
                themeProvider.setThemeMode(
                  ThemeMode.dark,
                  userId: authProvider.currentUser?.uid,
                );
                Navigator.pop(context);
              },
            ),
            _ThemeOption(
              icon: Icons.settings_brightness,
              title: 'System Default',
              isSelected: themeProvider.themeMode == ThemeMode.system,
              onTap: () {
                themeProvider.setThemeMode(
                  ThemeMode.system,
                  userId: authProvider.currentUser?.uid,
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will remove all your habits, progress, and settings from this device. '
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.warning_outlined, color: Colors.white),
                      SizedBox(width: AppSpacing.sm),
                      Text('Data clearing feature coming soon!'),
                    ],
                  ),
                  backgroundColor: AppColors.warning,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Clear Data', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w500,
          color: titleColor,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right)
              : null),
      onTap: onTap,
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyLarge?.color,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: Theme.of(context).colorScheme.primary,
            )
          : null,
      onTap: onTap,
    );
  }
}