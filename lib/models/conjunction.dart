import 'word.dart';

class Conjunction {
  final String id;
  final String conjunction;
  final String meaning;
  final String category;
  final String type; // "Bağlaç", "Prepositional Phrase", "Zarf / Transition"
  final String grammarRule; // e.g. "+ Cümle (S+V) alır" or "+ İsim / Ving alır"
  final List<String> synonyms;
  final List<ExampleSentence> examples;
  final String? examTip;

  const Conjunction({
    required this.id,
    required this.conjunction,
    required this.meaning,
    required this.category,
    required this.type,
    required this.grammarRule,
    required this.synonyms,
    required this.examples,
    this.examTip,
  });
}
