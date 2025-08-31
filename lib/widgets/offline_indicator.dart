import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class OfflineIndicator extends StatelessWidget {
  final bool isOffline;
  final VoidCallback? onRetry;

  const OfflineIndicator({
    super.key,
    required this.isOffline,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isOffline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.orange.shade100,
      child: Row(
        children: [
          Icon(
            Icons.cloud_off,
            color: Colors.orange.shade700,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline. Showing cached data.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              child: Text(
                'Retry',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    ).animate().slideY(begin: -1, duration: 300.ms);
  }
}

class ConnectivityBanner extends StatelessWidget {
  final bool isOnline;
  final String? message;

  const ConnectivityBanner({
    super.key,
    required this.isOnline,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isOnline
          ? const SizedBox.shrink()
          : Container(
              key: const ValueKey('offline_banner'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade600,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    const Icon(
                      Icons.cloud_off,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        message ?? 'No internet connection',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'OFFLINE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
              .animate()
              .slideY(begin: -1, duration: 300.ms)
              .fadeIn(duration: 200.ms),
    );
  }
}

class DataStatusChip extends StatelessWidget {
  final bool isOnline;
  final DateTime? lastSync;
  final bool isLoading;

  const DataStatusChip({
    super.key,
    required this.isOnline,
    this.lastSync,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
              ),
            )
          else
            Icon(
              _getStatusIcon(),
              size: 12,
              color: _getStatusColor(),
            ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: TextStyle(
              fontSize: 10,
              color: _getStatusColor(),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    if (isLoading) return Colors.blue;
    return isOnline ? Colors.green : Colors.orange;
  }

  IconData _getStatusIcon() {
    if (isOnline) return Icons.cloud_done;
    return Icons.cloud_off;
  }

  String _getStatusText() {
    if (isLoading) return 'Syncing...';
    if (isOnline) return 'Online';
    
    if (lastSync != null) {
      final timeDiff = DateTime.now().difference(lastSync!);
      if (timeDiff.inHours < 1) {
        return 'Cached (${timeDiff.inMinutes}m)';
      } else if (timeDiff.inDays < 1) {
        return 'Cached (${timeDiff.inHours}h)';
      } else {
        return 'Cached (${timeDiff.inDays}d)';
      }
    }
    
    return 'Offline';
  }
}