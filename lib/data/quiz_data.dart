// lib/data/quiz_data.dart

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.sentence,
    required this.choices,
    required this.answerIndex,
    required this.explanation,
    this.partTag = '',
    this.category = '',
    this.scope = '',
  });

  final String id;
  final String sentence;
  final List<String> choices; // [A, B, C, D]
  final int answerIndex;      // 0-3
  final String explanation;
  final String partTag;       // 'Part 5' | 'Part 6' | 'Part 7'
  final String category;      // 'conj' | 'prep' | 'adv' | 'connector'
  final String scope;

  factory QuizQuestion.fromJson(Map<String, dynamic> row) {
    return QuizQuestion(
      id: row['id'] as String? ?? '',
      sentence: row['sentence'] as String,
      choices: [
        row['choice_a'] as String,
        row['choice_b'] as String,
        row['choice_c'] as String,
        row['choice_d'] as String,
      ],
      answerIndex: row['answer_index'] as int,
      explanation: row['explanation'] as String,
      partTag: row['part_tag'] as String? ?? '',
      category: row['category'] as String? ?? '',
      scope: row['scope'] as String? ?? '',
    );
  }
}

class QuizScope {
  QuizScope._();
  static const String part5Conj    = 'part5_conj';
  static const String part5Prep    = 'part5_prep';
  static const String allConnector = 'all_connector';
}
