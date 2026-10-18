class ReadingPassage {
  final String id;
  final String title;
  final String category; // "ÖSYM Fen", "ÖSYM Sağlık", "ÖSYM Sosyal", "Kendi Metnim"
  final String content;
  final String turkishTranslation;
  final List<String> keyWords;
  final bool isCustom;
  final DateTime createdAt;

  ReadingPassage({
    required this.id,
    required this.title,
    required this.category,
    required this.content,
    required this.turkishTranslation,
    this.keyWords = const [],
    this.isCustom = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category,
    'content': content,
    'turkishTranslation': turkishTranslation,
    'keyWords': keyWords,
    'isCustom': isCustom,
    'createdAt': createdAt.toIso8601String(),
  };

  factory ReadingPassage.fromJson(Map<String, dynamic> json) => ReadingPassage(
    id: json['id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    content: json['content'] as String,
    turkishTranslation: json['turkishTranslation'] as String? ?? '',
    keyWords: (json['keyWords'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    isCustom: json['isCustom'] as bool? ?? false,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'] as String) : DateTime.now(),
  );
}
