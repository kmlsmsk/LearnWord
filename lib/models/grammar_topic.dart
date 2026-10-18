class GrammarExample {
  final String english;
  final String turkish;
  final String? examNote;

  const GrammarExample({
    required this.english,
    required this.turkish,
    this.examNote,
  });
}

class GrammarTopic {
  final String id;
  final String title;
  final String titleTr;
  final String category;
  final String formula;
  final String explanation;
  final List<String> osymTips;
  final List<GrammarExample> examples;
  final List<String> commonMistakes;

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.titleTr,
    required this.category,
    required this.formula,
    required this.explanation,
    required this.osymTips,
    required this.examples,
    this.commonMistakes = const [],
  });
}
