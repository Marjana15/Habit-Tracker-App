import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/quote_model.dart';
import '../providers/auth_provider.dart';
import '../providers/quotes_provider.dart';

class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool showActions;
  final VoidCallback? onFavoriteChanged;

  const QuoteCard({
    super.key,
    required this.quote,
    this.showActions = true,
    this.onFavoriteChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surface.withOpacity(0.8),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.format_quote,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quote.content,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 16,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '— ${quote.author}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                if (showActions) ...[
                  const SizedBox(width: 8),
                  _buildActionButtons(context),
                ],
              ],
            ),
            
            if (quote.tags.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: quote.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      '#$tag',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Consumer2<QuotesProvider, AuthProvider>(
      builder: (context, quotesProvider, authProvider, child) {
        final isFavorited = quotesProvider.isQuoteFavorited(quote.id);
        
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _copyQuote(context, quotesProvider),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    Icons.copy,
                    size: 20,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            
            const SizedBox(width: 8),
            
            if (authProvider.currentUser != null)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _toggleFavorite(context, quotesProvider, authProvider),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFavorited ? Icons.favorite : Icons.favorite_border,
                        key: ValueKey(isFavorited),
                        size: 20,
                        color: isFavorited
                            ? Colors.red
                            : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  ),
                ),
              )
                  .animate(
                    target: isFavorited ? 1 : 0,
                  )
                  .scale(
                    duration: 200.ms,
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                  )
                  .then()
                  .scale(
                    duration: 200.ms,
                    begin: const Offset(1.2, 1.2),
                    end: const Offset(1, 1),
                  ),
          ],
        );
      },
    );
  }

  Future<void> _copyQuote(BuildContext context, QuotesProvider quotesProvider) async {
    try {
      await quotesProvider.copyQuoteToClipboard(quote);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Quote copied to clipboard!'),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to copy quote'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    QuotesProvider quotesProvider,
    AuthProvider authProvider,
  ) async {
    final userId = authProvider.currentUser?.uid;
    if (userId == null) return;

    final success = await quotesProvider.toggleFavorite(userId, quote);
    
    if (context.mounted) {
      final isFavorited = quotesProvider.isQuoteFavorited(quote.id);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isFavorited
                      ? 'Quote added to favorites!'
                      : 'Quote removed from favorites',
                ),
              ],
            ),
            backgroundColor: isFavorited
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
        
        onFavoriteChanged?.call();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update favorite'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class QuoteCarousel extends StatefulWidget {
  final List<Quote> quotes;
  final bool showActions;

  const QuoteCarousel({
    super.key,
    required this.quotes,
    this.showActions = true,
  });

  @override
  State<QuoteCarousel> createState() => _QuoteCarouselState();
}

class _QuoteCarouselState extends State<QuoteCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.quotes.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.quotes.length,
            itemBuilder: (context, index) {
              return QuoteCard(
                quote: widget.quotes[index],
                showActions: widget.showActions,
              );
            },
          ),
        ),
        
        if (widget.quotes.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.quotes.length.clamp(0, 5), // Show max 5 dots
              (index) {
                final isActive = index == _currentPage % 5;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: isActive ? 12 : 8,
                  height: isActive ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}