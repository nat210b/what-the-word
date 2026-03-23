// lib/services/quiz_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toeic_apps/data/quiz_data.dart';

//
// Table: quiz_questions
//   id           uuid primary key default gen_random_uuid()
//   sentence     text not null
//   choice_a     text not null
//   choice_b     text not null
//   choice_c     text not null
//   choice_d     text not null
//   answer_index int2 not null  (0=A 1=B 2=C 3=D)
//   explanation  text not null
//   part_tag     text not null  ('Part 5' | 'Part 6' | 'Part 7')
//   category     text not null  ('conj' | 'prep' | 'adv' | 'connector')
//   scope        text not null  ('part5_conj' | 'part5_prep' | 'all_connector')
//   created_at   timestamptz default now()
//
// RLS: alter table quiz_questions enable row level security;
//      create policy "public read" on quiz_questions for select using (true);
//
// Table: quiz_results
//   id         uuid primary key default gen_random_uuid()
//   user_id    uuid references auth.users not null
//   scope      text not null
//   title      text not null
//   score      int2 not null
//   total      int2 not null
//   percent    int2 not null
//   created_at timestamptz default now()
//
// RLS: alter table quiz_results enable row level security;
//      create policy "owner" on quiz_results
//        using (auth.uid() = user_id)
//        with check (auth.uid() = user_id);

class QuizService {
  QuizService._();

  static final _db = Supabase.instance.client;

  // Fetch all questions for a given scope
  static Future<List<QuizQuestion>> fetchQuestions(String scope) async {
    final rows = await _db
        .from('quiz_questions')
        .select()
        .eq('scope', scope)
        .order('created_at');
    return (rows as List)
        .map((row) => QuizQuestion.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  // Fetch only the count (used by PracticePage cards)
  static Future<int> fetchQuestionCount(String scope) async {
    final rows = await _db
        .from('quiz_questions')
        .select('id')
        .eq('scope', scope);
    return (rows as List).length;
  }

  // Save result — silently skips when user is not logged in
  static Future<void> saveResult({
    required String scope,
    required String title,
    required int score,
    required int total,
  }) async {
    final user = _db.auth.currentUser;
    if (user == null) return;
    final percent = total > 0 ? (score / total * 100).round() : 0;
    await _db.from('quiz_results').insert({
      'user_id': user.id,
      'scope': scope,
      'title': title,
      'score': score,
      'total': total,
      'percent': percent,
    });
  }

  // Fetch recent results for current user
  static Future<List<QuizResult>> fetchMyResults({int limit = 20}) async {
    final user = _db.auth.currentUser;
    if (user == null) return [];
    final rows = await _db
        .from('quiz_results')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false)
        .limit(limit);
    return (rows as List)
        .map((row) => QuizResult.fromJson(row as Map<String, dynamic>))
        .toList();
  }
}

class QuizResult {
  const QuizResult({
    required this.id,
    required this.scope,
    required this.title,
    required this.score,
    required this.total,
    required this.percent,
    required this.createdAt,
  });

  final String id;
  final String scope;
  final String title;
  final int score;
  final int total;
  final int percent;
  final DateTime createdAt;

  factory QuizResult.fromJson(Map<String, dynamic> row) {
    return QuizResult(
      id: row['id'] as String,
      scope: row['scope'] as String,
      title: row['title'] as String,
      score: row['score'] as int,
      total: row['total'] as int,
      percent: row['percent'] as int,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }
}
