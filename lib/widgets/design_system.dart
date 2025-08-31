import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppColors {
  static const primary = Color(0xFF4CAF50);
  static const primaryLight = Color(0xFF81C784);
  static const primaryDark = Color(0xFF2E7D32);
  static const secondary = Color(0xFF66BB6A);
  static const accent = Color(0xFFFF9800);
  static const error = Color(0xFFE53935);
  static const success = Color(0xFF43A047);
  static const warning = Color(0xFFFF9800);
  static const info = Color(0xFF2196F3);
  
  static const Color background = Color(0xFFF1F8E9);
  static const Color surface = Colors.white;
  static const Color onSurface = Color(0xFF2E7D32);
  static const Color onBackground = Color(0xFF1B5E20);
  static const Color textPrimary = Color(0xFF1B5E20);
  static const Color textSecondary = Color(0xFF4CAF50);
  static const Color textMuted = Color(0xFF81C784);
  
  static Color backgroundFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF121212) 
        : const Color(0xFFF1F8E9);
  }
  
  static Color surfaceFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF1E1E1E) 
        : Colors.white;
  }
  
  static Color onSurfaceFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF81C784) 
        : const Color(0xFF2E7D32);
  }
  
  static Color onBackgroundFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFFE8F5E8) 
        : const Color(0xFF1B5E20);
  }
  
  static Color textPrimaryFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFFE8F5E8) 
        : const Color(0xFF1B5E20);
  }
  
  static Color textSecondaryFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF81C784) 
        : const Color(0xFF4CAF50);
  }
  
  static Color textMutedFor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? const Color(0xFF66BB6A) 
        : const Color(0xFF81C784);
  }
}

class AppTextStyles {
  static const String fontFamily = 'System';
  
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMuted,
    height: 1.3,
  );
  
  static TextStyle headline1For(BuildContext context) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryFor(context),
    height: 1.2,
  );
  
  static TextStyle headline2For(BuildContext context) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryFor(context),
    height: 1.3,
  );
  
  static TextStyle headline3For(BuildContext context) => TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryFor(context),
    height: 1.3,
  );
  
  static TextStyle bodyLargeFor(BuildContext context) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimaryFor(context),
    height: 1.5,
  );
  
  static TextStyle bodyMediumFor(BuildContext context) => TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondaryFor(context),
    height: 1.4,
  );
  
  static TextStyle captionFor(BuildContext context) => TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textMutedFor(context),
    height: 1.3,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double pill = 100.0;
}

class AppShadows {
  static const BoxShadow soft = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 10,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow medium = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 15,
    offset: Offset(0, 4),
  );
  
  static const BoxShadow strong = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 20,
    offset: Offset(0, 8),
  );
  
  static BoxShadow softFor(BuildContext context) => BoxShadow(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0x1F000000)
        : const Color(0x0A000000),
    blurRadius: 10,
    offset: const Offset(0, 2),
  );
  
  static BoxShadow mediumFor(BuildContext context) => BoxShadow(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0x2F000000)
        : const Color(0x14000000),
    blurRadius: 15,
    offset: const Offset(0, 4),
  );
  
  static BoxShadow strongFor(BuildContext context) => BoxShadow(
    color: Theme.of(context).brightness == Brightness.dark
        ? const Color(0x3F000000)
        : const Color(0x1F000000),
    blurRadius: 20,
    offset: const Offset(0, 8),
  );
}

class EnhancedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final double? elevation;
  final BorderRadius? borderRadius;
  final bool showBorder;
  final Color? borderColor;

  const EnhancedCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.elevation,
    this.borderRadius,
    this.showBorder = false,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Material(
        elevation: elevation ?? 2,
        borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
        color: color ?? Theme.of(context).cardColor,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
          child: Container(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.lg),
              border: showBorder
                  ? Border.all(
                      color: borderColor ?? AppColors.primaryLight.withOpacity(0.3),
                    )
                  : null,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class EnhancedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ButtonStyle style;
  final bool isLoading;
  final bool isSecondary;
  final double? width;

  const EnhancedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
    ButtonStyle? style,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
  }) : style = style ?? const ButtonStyle();

  @override
  Widget build(BuildContext context) {
    final baseStyle = isSecondary
        ? OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary, width: 2),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          );

    Widget buttonChild = isLoading
        ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: AppSpacing.sm),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    Widget button = isSecondary
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: baseStyle.merge(style),
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: baseStyle.merge(style),
            child: buttonChild,
          );

    return width != null
        ? SizedBox(width: width, child: button)
        : button;
  }
}

class EnhancedTextField extends StatelessWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixTap;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;

  const EnhancedTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixTap,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Theme.of(context).hintColor,
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary)
                : null,
            suffixIcon: suffixIcon != null
                ? IconButton(
                    onPressed: onSuffixTap,
                    icon: Icon(suffixIcon, color: AppColors.primary),
                  )
                : null,
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.md,
            ),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final IconData? icon;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: AppSpacing.sm),
          ],
          Flexible(
            fit: FlexFit.loose,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                if (subtitle != null)
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          if (action != null) 
            Flexible(
              fit: FlexFit.loose,
              child: action!,
            ),
        ],
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String? subtitle;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return EnhancedCard(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: color),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: Center(
              child: EnhancedCard(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(message!, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
            ),
          ).animate().fadeIn(duration: 200.ms),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.primaryLight.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.primaryLight,
              ),
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            
            const SizedBox(height: AppSpacing.lg),
            
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 800.ms),
            
            const SizedBox(height: AppSpacing.sm),
            
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 1000.ms),
            
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              EnhancedButton(
                text: actionText!,
                onPressed: onAction,
                icon: Icons.add,
              ).animate().fadeIn(duration: 1200.ms).scale(begin: const Offset(0.8, 0.8)),
            ],
          ],
        ),
      ),
    );
  }
}

class ProfileImage extends StatelessWidget {
  final String? photoURL;
  final String displayName;
  final double size;
  final bool showBorder;

  const ProfileImage({
    super.key,
    this.photoURL,
    required this.displayName,
    this.size = 60,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder 
            ? Border.all(
                color: AppColors.primary,
                width: 2,
              ) 
            : null,
        gradient: photoURL == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryLight],
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ClipOval(
        child: photoURL != null
            ? Image.network(
                photoURL!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallbackAvatar();
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryLight.withOpacity(0.1),
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  );
                },
              )
            : _buildFallbackAvatar(),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryLight],
        ),
      ),
      child: Center(
        child: Text(
          _getInitials(displayName),
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final names = name.trim().split(' ');
    if (names.length == 1) {
      return names[0].isNotEmpty ? names[0][0].toUpperCase() : 'U';
    } else {
      return (names[0].isNotEmpty ? names[0][0] : '') + 
             (names[1].isNotEmpty ? names[1][0] : '');
    }
  }
}