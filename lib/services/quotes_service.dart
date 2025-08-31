import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import '../models/quote_model.dart';

class QuotesService {
  static const String _quotableBaseUrl = 'https://api.quotable.io';
  static const String _zenQuotesBaseUrl = 'https://zenquotes.io/api';
  
  final Random _random = Random();
  final http.Client _httpClient = http.Client();
  
  int _currentApiIndex = 0;
  final List<String> _apiSources = ['quotable', 'zenquotes'];

  Future<List<Quote>> fetchRandomQuotes({int limit = 10}) async {
    for (int attempt = 0; attempt < _apiSources.length; attempt++) {
      try {
        final apiSource = _apiSources[(_currentApiIndex + attempt) % _apiSources.length];
        List<Quote> quotes;
        
        switch (apiSource) {
          case 'quotable':
            quotes = await _fetchFromQuotable(limit);
            break;
          case 'zenquotes':
            quotes = await _fetchFromZenQuotes(limit);
            break;
          default:
            quotes = _getFallbackQuotes().take(limit).toList();
        }
        
        if (quotes.isNotEmpty) {
          _currentApiIndex = (_currentApiIndex + attempt) % _apiSources.length;
          debugPrint('Successfully fetched ${quotes.length} quotes from $apiSource');
          return quotes;
        }
      } catch (e) {
        debugPrint('Failed to fetch from ${_apiSources[(_currentApiIndex + attempt) % _apiSources.length]}: $e');
      }
    }
    
    debugPrint('All APIs failed, using fallback quotes');
    return _getFallbackQuotes().take(limit).toList();
  }

  Future<Quote> fetchRandomQuote() async {
    final quotes = await fetchRandomQuotes(limit: 1);
    return quotes.first;
  }

  Future<List<Quote>> _fetchFromQuotable(int limit) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_quotableBaseUrl/quotes?limit=$limit'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final List<dynamic> quotesJson = data['results'] ?? [];
        
        return quotesJson.map((json) {
          return Quote(
            id: json['_id'] ?? _generateRandomId(),
            content: json['content'] ?? '',
            author: json['author'] ?? 'Unknown',
            tags: List<String>.from(json['tags'] ?? []),
            length: (json['content'] ?? '').length,
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch from Quotable: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Quotable API error: $e');
      rethrow;
    }
  }

  Future<List<Quote>> _fetchFromZenQuotes(int limit) async {
    try {
      final response = await _httpClient.get(
        Uri.parse('$_zenQuotesBaseUrl/quotes'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> quotesJson = json.decode(response.body);
        
        final shuffled = List<dynamic>.from(quotesJson);
        shuffled.shuffle(_random);
        
        return shuffled.take(limit).map((json) {
          final content = (json['q'] ?? '').toString();
          return Quote(
            id: _generateRandomId(),
            content: content,
            author: json['a'] ?? 'Unknown',
            tags: _extractTagsFromContent(content),
            length: content.length,
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch from ZenQuotes: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('ZenQuotes API error: $e');
      rethrow;
    }
  }

  String _generateRandomId() {
    return 'quote_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(1000)}';
  }

  List<String> _extractTagsFromContent(String content) {
    final lowercaseContent = content.toLowerCase();
    final List<String> tags = [];
    
    final Map<String, List<String>> tagKeywords = {
      'motivational': ['success', 'achieve', 'goal', 'dream', 'motivat'],
      'inspirational': ['inspire', 'hope', 'believe', 'faith', 'courage'],
      'wisdom': ['wise', 'learn', 'know', 'understand', 'wisdom'],
      'life': ['life', 'live', 'exist', 'being'],
      'happiness': ['happy', 'joy', 'smile', 'laugh', 'glad'],
      'love': ['love', 'heart', 'care', 'affection'],
      'friendship': ['friend', 'companion', 'buddy'],
      'work': ['work', 'job', 'career', 'profession'],
    };
    
    for (final entry in tagKeywords.entries) {
      for (final keyword in entry.value) {
        if (lowercaseContent.contains(keyword)) {
          tags.add(entry.key);
          break;
        }
      }
    }
    
    return tags.isEmpty ? ['general'] : tags;
  }

  List<Quote> _getFallbackQuotes() {
    final fallbackQuotes = [
      {
        "_id": "quote1",
        "content": "The only way to do great work is to love what you do.",
        "author": "Steve Jobs",
        "tags": ["motivational", "work"],
        "length": 49
      },
      {
        "_id": "quote2",
        "content": "Success is not final, failure is not fatal: it is the courage to continue that counts.",
        "author": "Winston Churchill",
        "tags": ["success", "courage"],
        "length": 82
      },
      {
        "_id": "quote3",
        "content": "The future belongs to those who believe in the beauty of their dreams.",
        "author": "Eleanor Roosevelt",
        "tags": ["dreams", "future"],
        "length": 69
      },
      {
        "_id": "quote4",
        "content": "It is during our darkest moments that we must focus to see the light.",
        "author": "Aristotle",
        "tags": ["inspirational", "perseverance"],
        "length": 67
      },
      {
        "_id": "quote5",
        "content": "Your time is limited, don't waste it living someone else's life.",
        "author": "Steve Jobs",
        "tags": ["life", "time"],
        "length": 61
      },
      {
        "_id": "quote6",
        "content": "The way to get started is to quit talking and begin doing.",
        "author": "Walt Disney",
        "tags": ["action", "motivation"],
        "length": 56
      },
      {
        "_id": "quote7",
        "content": "Don't let yesterday take up too much of today.",
        "author": "Will Rogers",
        "tags": ["present", "mindfulness"],
        "length": 43
      },
      {
        "_id": "quote8",
        "content": "You learn more from failure than from success. Don't let it stop you. Failure builds character.",
        "author": "Unknown",
        "tags": ["failure", "learning"],
        "length": 94
      },
      {
        "_id": "quote9",
        "content": "If you are working on something that you really care about, you don't have to be pushed. The vision pulls you.",
        "author": "Steve Jobs",
        "tags": ["passion", "vision"],
        "length": 113
      },
      {
        "_id": "quote10",
        "content": "People who are crazy enough to think they can change the world, are the ones who do.",
        "author": "Rob Siltanen",
        "tags": ["change", "impact"],
        "length": 80
      },
      {
        "_id": "quote11",
        "content": "We don't make mistakes, just happy little accidents.",
        "author": "Bob Ross",
        "tags": ["positivity", "mistakes"],
        "length": 50
      },
      {
        "_id": "quote12",
        "content": "Whether you think you can or you think you can't, you're right.",
        "author": "Henry Ford",
        "tags": ["mindset", "belief"],
        "length": 62
      },
      {
        "_id": "quote13",
        "content": "The only impossible journey is the one you never begin.",
        "author": "Tony Robbins",
        "tags": ["journey", "beginning"],
        "length": 54
      },
      {
        "_id": "quote14",
        "content": "In the middle of difficulty lies opportunity.",
        "author": "Albert Einstein",
        "tags": ["opportunity", "challenges"],
        "length": 43
      },
      {
        "_id": "quote15",
        "content": "It does not matter how slowly you go as long as you do not stop.",
        "author": "Confucius",
        "tags": ["persistence", "progress"],
        "length": 63
      },
      {
        "_id": "quote16",
        "content": "Everything you've ever wanted is on the other side of fear.",
        "author": "George Addair",
        "tags": ["fear", "courage"],
        "length": 57
      },
      {
        "_id": "quote17",
        "content": "Believe you can and you're halfway there.",
        "author": "Theodore Roosevelt",
        "tags": ["belief", "confidence"],
        "length": 39
      },
      {
        "_id": "quote18",
        "content": "The best time to plant a tree was 20 years ago. The second best time is now.",
        "author": "Chinese Proverb",
        "tags": ["action", "timing"],
        "length": 75
      },
      {
        "_id": "quote19",
        "content": "Your limitation—it's only your imagination.",
        "author": "Unknown",
        "tags": ["limitations", "imagination"],
        "length": 42
      },
      {
        "_id": "quote20",
        "content": "Great things never come from comfort zones.",
        "author": "Unknown",
        "tags": ["comfort zone", "growth"],
        "length": 41
      }
    ];

    final shuffled = List<Map<String, dynamic>>.from(fallbackQuotes);
    shuffled.shuffle(_random);

    return shuffled.map((json) => Quote.fromJson(json)).toList();
  }

  Future<void> favoriteQuote(String userId, Quote quote) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('items')
          .doc(quote.id)
          .set(quote.toFirestore());
    } catch (e) {
      debugPrint('Error favoriting quote: $e');
      rethrow;
    }
  }

  Future<void> unfavoriteQuote(String userId, String quoteId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('items')
          .doc(quoteId)
          .delete();
    } catch (e) {
      debugPrint('Error unfavoriting quote: $e');
      rethrow;
    }
  }

  Future<List<FavoriteQuote>> getFavoriteQuotes(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('items')
          .orderBy('favoritedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => FavoriteQuote.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error fetching favorite quotes: $e');
      return [];
    }
  }

  Stream<List<FavoriteQuote>> getFavoriteQuotesStream(String userId) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .doc('quotes')
        .collection('items')
        .orderBy('favoritedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => FavoriteQuote.fromFirestore(doc))
            .toList());
  }

  Future<bool> isQuoteFavorited(String userId, String quoteId) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('items')
          .doc(quoteId)
          .get();

      return doc.exists;
    } catch (e) {
      debugPrint('Error checking if quote is favorited: $e');
      return false;
    }
  }

  Future<Set<String>> getFavoriteQuoteIds(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc('quotes')
          .collection('items')
          .get();

      return snapshot.docs.map((doc) => doc.id).toSet();
    } catch (e) {
      debugPrint('Error fetching favorite quote IDs: $e');
      return <String>{};
    }
  }

  Future<List<Quote>> getQuotesFromDifferentSource({int limit = 10}) async {
    _currentApiIndex = (_currentApiIndex + 1) % _apiSources.length;
    return fetchRandomQuotes(limit: limit);
  }

  Future<List<Quote>> getQuotesFromSource(String source, {int limit = 10}) async {
    try {
      switch (source.toLowerCase()) {
        case 'quotable':
          return await _fetchFromQuotable(limit);
        case 'zenquotes':
          return await _fetchFromZenQuotes(limit);
        default:
          return _getFallbackQuotes().take(limit).toList();
      }
    } catch (e) {
      debugPrint('Failed to fetch from specific source $source: $e');
      return _getFallbackQuotes().take(limit).toList();
    }
  }

  String getCurrentApiSource() {
    return _apiSources[_currentApiIndex];
  }

  void dispose() {
    _httpClient.close();
  }
}