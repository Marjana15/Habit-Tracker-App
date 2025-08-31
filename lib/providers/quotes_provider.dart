import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/quote_model.dart';
import '../services/quotes_service.dart';
import '../services/local_storage_service.dart';
import '../services/connectivity_service.dart';

class QuotesProvider extends ChangeNotifier {
  final QuotesService _quotesService = QuotesService();
  final LocalStorageService _localStorage = LocalStorageService();
  final ConnectivityService _connectivity = ConnectivityService();
  
  List<Quote> _quotes = [];
  List<FavoriteQuote> _favoriteQuotes = [];
  Set<String> _favoriteQuoteIds = {};
  bool _isLoading = false;
  bool _isLoadingFavorites = false;
  bool _isOffline = false;
  String? _errorMessage;

  List<Quote> get quotes => _quotes;
  List<FavoriteQuote> get favoriteQuotes => _favoriteQuotes;
  Set<String> get favoriteQuoteIds => _favoriteQuoteIds;
  bool get isLoading => _isLoading;
  bool get isLoadingFavorites => _isLoadingFavorites;
  bool get isOffline => _isOffline;
  String? get errorMessage => _errorMessage;

  bool isQuoteFavorited(String quoteId) {
    return _favoriteQuoteIds.contains(quoteId);
  }

  Future<void> loadQuotes({bool refresh = false}) async {
    if (_isLoading) return;
    
    _isLoading = true;
    _errorMessage = null;
    _isOffline = !_connectivity.isOnline;
    notifyListeners();

    try {
      if (_connectivity.isOnline || refresh) {
        final quotes = await _quotesService.fetchRandomQuotes(limit: 15);
        _quotes = quotes;
        await _localStorage.cacheQuotes(quotes);
      } else {
        final cachedQuotes = await _localStorage.getCachedQuotes();
        if (cachedQuotes.isNotEmpty) {
          _quotes = cachedQuotes;
        } else {
          final quotes = await _quotesService.fetchRandomQuotes(limit: 15);
          _quotes = quotes;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load quotes: $e';
      try {
        final cachedQuotes = await _localStorage.getCachedQuotes();
        if (cachedQuotes.isNotEmpty) {
          _quotes = cachedQuotes;
          _errorMessage = null;
        }
      } catch (cacheError) {
        debugPrint('Failed to load cached quotes: $cacheError');
      }
      debugPrint(_errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoriteQuotes(String userId) async {
    if (_isLoadingFavorites) return;
    
    _isLoadingFavorites = true;
    notifyListeners();

    try {
      if (_connectivity.isOnline) {
        final favorites = await _quotesService.getFavoriteQuotes(userId);
        _favoriteQuotes = favorites;
        _favoriteQuoteIds = favorites.map((q) => q.id).toSet();
        await _localStorage.cacheFavoriteQuotes(userId, favorites);
      } else {
        final cachedFavorites = await _localStorage.getCachedFavoriteQuotes(userId);
        _favoriteQuotes = cachedFavorites;
        _favoriteQuoteIds = cachedFavorites.map((q) => q.id).toSet();
      }
    } catch (e) {
      try {
        final cachedFavorites = await _localStorage.getCachedFavoriteQuotes(userId);
        _favoriteQuotes = cachedFavorites;
        _favoriteQuoteIds = cachedFavorites.map((q) => q.id).toSet();
      } catch (cacheError) {
        debugPrint('Failed to load cached favorite quotes: $cacheError');
      }
      debugPrint('Failed to load favorite quotes: $e');
    } finally {
      _isLoadingFavorites = false;
      notifyListeners();
    }
  }

  Future<void> loadFavoriteQuoteIds(String userId) async {
    try {
      _favoriteQuoteIds = await _quotesService.getFavoriteQuoteIds(userId);
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load favorite quote IDs: $e');
    }
  }

  Future<bool> toggleFavorite(String userId, Quote quote) async {
    try {
      final isFavorited = _favoriteQuoteIds.contains(quote.id);
      
      if (isFavorited) {
        await _quotesService.unfavoriteQuote(userId, quote.id);
        _favoriteQuoteIds.remove(quote.id);
        _favoriteQuotes.removeWhere((fq) => fq.id == quote.id);
      } else {
        await _quotesService.favoriteQuote(userId, quote);
        _favoriteQuoteIds.add(quote.id);
        _favoriteQuotes.insert(0, FavoriteQuote.fromQuote(quote, DateTime.now()));
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  Future<void> copyQuoteToClipboard(Quote quote) async {
    try {
      final text = '"${quote.content}" - ${quote.author}';
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      debugPrint('Error copying quote to clipboard: $e');
      rethrow;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> refreshQuotes({String? userId}) async {
    await loadQuotes(refresh: true);
    if (userId != null) {
      await loadFavoriteQuoteIds(userId);
    }
  }

  void startListeningToFavorites(String userId) {
    _quotesService.getFavoriteQuotesStream(userId).listen((favorites) {
      _favoriteQuotes = favorites;
      _favoriteQuoteIds = favorites.map((q) => q.id).toSet();
      notifyListeners();
    });
  }
}