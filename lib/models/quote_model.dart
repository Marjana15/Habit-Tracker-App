import 'package:cloud_firestore/cloud_firestore.dart';

class Quote {
  final String id;
  final String content;
  final String author;
  final List<String> tags;
  final int length;

  Quote({
    required this.id,
    required this.content,
    required this.author,
    this.tags = const [],
    required this.length,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['_id'] ?? '',
      content: json['content'] ?? '',
      author: json['author'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      length: json['length'] ?? 0,
    );
  }

  factory Quote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Quote(
      id: data['id'] ?? doc.id,
      content: data['content'] ?? '',
      author: data['author'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      length: data['length'] ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'content': content,
      'author': author,
      'tags': tags,
      'length': length,
      'favoritedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'content': content,
      'author': author,
      'tags': tags,
      'length': length,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Quote && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Quote(id: $id, content: $content, author: $author)';
  }
}

class FavoriteQuote extends Quote {
  final DateTime favoritedAt;

  FavoriteQuote({
    required super.id,
    required super.content,
    required super.author,
    super.tags = const [],
    required super.length,
    required this.favoritedAt,
  });

  factory FavoriteQuote.fromQuote(Quote quote, DateTime favoritedAt) {
    return FavoriteQuote(
      id: quote.id,
      content: quote.content,
      author: quote.author,
      tags: quote.tags,
      length: quote.length,
      favoritedAt: favoritedAt,
    );
  }

  factory FavoriteQuote.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return FavoriteQuote(
      id: data['id'] ?? doc.id,
      content: data['content'] ?? '',
      author: data['author'] ?? '',
      tags: List<String>.from(data['tags'] ?? []),
      length: data['length'] ?? 0,
      favoritedAt: (data['favoritedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    final base = super.toFirestore();
    base['favoritedAt'] = Timestamp.fromDate(favoritedAt);
    return base;
  }
}