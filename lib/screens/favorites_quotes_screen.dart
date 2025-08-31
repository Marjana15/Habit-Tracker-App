import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/quotes_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/quote_card.dart';
import '../widgets/design_system.dart';

class FavoriteQuotesScreen extends StatefulWidget {
  const FavoriteQuotesScreen({super.key});

  @override
  State<FavoriteQuotesScreen> createState() => _FavoriteQuotesScreenState();
}

class _FavoriteQuotesScreenState extends State<FavoriteQuotesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final quotesProvider = Provider.of<QuotesProvider>(context, listen: false);
      
      if (authProvider.currentUser != null) {
        quotesProvider.loadFavoriteQuotes(authProvider.currentUser!.uid);
        quotesProvider.startListeningToFavorites(authProvider.currentUser!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, QuotesProvider>(
      builder: (context, authProvider, quotesProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Favorite Quotes',
              style: AppTextStyles.headline3.copyWith(color: Colors.white),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              if (quotesProvider.favoriteQuotes.isNotEmpty) ...[
                IconButton(
                  onPressed: () => _showShareOptions(context, quotesProvider),
                  icon: const Icon(Icons.share, color: Colors.white),
                  tooltip: 'Share All Favorites',
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ],
          ),
          body: AnimatedBackground(
            child: RefreshIndicator(
              onRefresh: () async {
                if (authProvider.currentUser != null) {
                  await quotesProvider.loadFavoriteQuotes(authProvider.currentUser!.uid);
                }
              },
              color: Theme.of(context).colorScheme.primary,
              child: _buildBody(authProvider, quotesProvider),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(AuthProvider authProvider, QuotesProvider quotesProvider) {
    if (authProvider.currentUser == null) {
      return EmptyState(
        icon: Icons.person_outline,
        title: 'Login Required',
        subtitle: 'Please log in to view your favorite quotes',
      );
    }

    if (quotesProvider.isLoadingFavorites) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Loading your favorite quotes...',
              style: AppTextStyles.bodyMedium,
            ),
          ],
        ),
      );
    }

    if (quotesProvider.favoriteQuotes.isEmpty) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: EmptyState(
            icon: Icons.favorite_border,
            title: 'No Favorite Quotes Yet',
            subtitle: 'Start favoriting quotes from the home screen to see them here. '
                'Tap the heart icon on any quote to add it to your favorites!',
            actionText: 'Go to Home',
            onAction: () => Navigator.pop(context),
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: quotesProvider.favoriteQuotes.length + 1, // +1 for header
      itemBuilder: (context, index) {
        if (index == 0) {
          return Container(
            margin: const EdgeInsets.all(AppSpacing.lg),
            child: EnhancedCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${quotesProvider.favoriteQuotes.length} Favorite${quotesProvider.favoriteQuotes.length == 1 ? '' : 's'}',
                          style: AppTextStyles.headline3,
                        ),
                        Text(
                          'Tap heart to unfavorite',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms);
        }

        final quote = quotesProvider.favoriteQuotes[index - 1];
        return Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.xs,
          ),
          child: Stack(
            children: [
              EnhancedCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    QuoteCard(
                      quote: quote,
                      showActions: true,
                      onFavoriteChanged: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.heart_broken, color: Colors.white, size: 16),
                                const SizedBox(width: AppSpacing.sm),
                                const Expanded(
                                  child: Text('Quote removed from favorites'),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.error,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.schedule,
                        size: 12,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(quote.favoritedAt),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(duration: (600 + index * 100).ms).slideX(begin: 0.3),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference}d ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '${weeks}w ago';
    } else {
      final months = (difference / 30).floor();
      return '${months}mo ago';
    }
  }

  void _showShareOptions(BuildContext context, QuotesProvider quotesProvider) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Share Options',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.copy_all, color: Color(0xFF4CAF50)),
              title: const Text('Copy All Quotes'),
              subtitle: const Text('Copy all favorites to clipboard'),
              onTap: () async {
                Navigator.pop(context);
                await _copyAllQuotes(quotesProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('All quotes copied to clipboard!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_snippet, color: Color(0xFF4CAF50)),
              title: const Text('Export as Text'),
              subtitle: const Text('Coming soon'),
              enabled: false,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Future<void> _copyAllQuotes(QuotesProvider quotesProvider) async {
    final quotesText = quotesProvider.favoriteQuotes
        .map((quote) => '"${quote.content}" - ${quote.author}')
        .join('\n\n');
    
    await quotesProvider.copyQuoteToClipboard(quotesProvider.favoriteQuotes.first);
  }
}