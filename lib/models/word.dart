enum WordType {
  noun,
  verb,
  adjective,
  adverb,
  phrasalVerb;

  String get labelTr {
    switch (this) {
      case WordType.noun:
        return 'İsim (Noun)';
      case WordType.verb:
        return 'Fiil (Verb)';
      case WordType.adjective:
        return 'Sıfat (Adjective)';
      case WordType.adverb:
        return 'Zarf (Adverb)';
      case WordType.phrasalVerb:
        return 'Deyimsel Fiil (Phrasal Verb)';
    }
  }

  String get shortLabel {
    switch (this) {
      case WordType.noun:
        return 'n.';
      case WordType.verb:
        return 'v.';
      case WordType.adjective:
        return 'adj.';
      case WordType.adverb:
        return 'adv.';
      case WordType.phrasalVerb:
        return 'phr. v.';
    }
  }

  static WordType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'verb':
      case 'v':
      case 'fiil':
        return WordType.verb;
      case 'noun':
      case 'n':
      case 'isim':
        return WordType.noun;
      case 'adjective':
      case 'adj':
      case 'sıfat':
        return WordType.adjective;
      case 'adverb':
      case 'adv':
      case 'zarf':
        return WordType.adverb;
      case 'phrasalverb':
      case 'phrasal_verb':
      case 'phr. v.':
        return WordType.phrasalVerb;
      default:
        return WordType.noun;
    }
  }
}

class WordRoot {
  final String rootWord;
  final String rootMeaning;
  final String explanation;

  const WordRoot({
    required this.rootWord,
    required this.rootMeaning,
    required this.explanation,
  });

  factory WordRoot.fromJson(Map<String, dynamic> json) => WordRoot(
    rootWord: json['rootWord']?.toString() ?? '',
    rootMeaning: json['rootMeaning']?.toString() ?? '',
    explanation: json['explanation']?.toString() ?? '',
  );
}

class WordDerivative {
  final String word;
  final String partOfSpeech; // e.g. "isim", "fiil", "sıfat", "zarf"
  final String meaning;
  final String? example;

  const WordDerivative({
    required this.word,
    required this.partOfSpeech,
    required this.meaning,
    this.example,
  });

  factory WordDerivative.fromJson(Map<String, dynamic> json) => WordDerivative(
    word: json['word']?.toString() ?? '',
    partOfSpeech: json['partOfSpeech']?.toString() ?? '',
    meaning: json['meaning']?.toString() ?? '',
    example: json['example']?.toString(),
  );
}

class ExampleSentence {
  final String english;
  final String turkish;

  const ExampleSentence({
    required this.english,
    required this.turkish,
  });

  factory ExampleSentence.fromJson(Map<String, dynamic> json) => ExampleSentence(
    english: json['english']?.toString() ?? '',
    turkish: json['turkish']?.toString() ?? '',
  );
}

class Word {
  final String id;
  final String word;
  final String? pronunciation; // e.g. "ebolış", "mitigeyt"
  final WordType type;
  final String level; // e.g. "YDS / YÖKDİL B2-C1"
  final List<String> tags; // ["YDS", "YÖKDİL Sosyal", "YÖKDİL Sağlık", "YÖKDİL Fen"]
  final String meaning;
  final String? detailedMeaning;
  final WordRoot root;
  final List<WordDerivative> derivatives;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<ExampleSentence> examples;
  final List<String> collocations;
  final String? examTip; // ÖSYM ipucu

  const Word({
    required this.id,
    required this.word,
    this.pronunciation,
    required this.type,
    required this.level,
    required this.tags,
    required this.meaning,
    this.detailedMeaning,
    required this.root,
    required this.derivatives,
    required this.synonyms,
    required this.antonyms,
    required this.examples,
    this.collocations = const [],
    this.examTip,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      pronunciation: json['pronunciation']?.toString(),
      type: WordType.fromString(json['type']?.toString() ?? 'noun'),
      level: json['level']?.toString() ?? 'YDS / YÖKDİL B2-C1',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      meaning: json['meaning']?.toString() ?? '',
      detailedMeaning: json['detailedMeaning']?.toString(),
      root: json['root'] != null ? WordRoot.fromJson(json['root']) : const WordRoot(rootWord: '', rootMeaning: '', explanation: ''),
      derivatives: (json['derivatives'] as List<dynamic>?)?.map((e) => WordDerivative.fromJson(e)).toList() ?? [],
      synonyms: (json['synonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      antonyms: (json['antonyms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      examples: (json['examples'] as List<dynamic>?)?.map((e) => ExampleSentence.fromJson(e)).toList() ?? [],
      collocations: (json['collocations'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      examTip: json['examTip']?.toString(),
    );
  }
}
