// lib/services/vocab_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toeic_apps/data/vocab_word.dart';

class VocabService {
  VocabService._();

  static final _db = Supabase.instance.client;

  /// Fetch words based on VocabFilter.fetchMode
  static Future<List<VocabWord>> fetchWords(VocabFilter filter) async {
    switch (filter.fetchMode) {
      case 'part5_all':
        // conj + prep ทั้งหมดใน part5
        final rows = await _db
            .from('vocab_words')
            .select()
            .eq('part_scope', VocabScope.part5)
            .order('word');
        return _toList(rows);

      case 'reading_all':
        // reading ทั้งหมดที่ dual_type เป็น null (ประเภทเดียว)
        final rows = await _db
            .from('vocab_words')
            .select()
            .eq('part_scope', VocabScope.reading)
            .isFilter('dual_type', null)
            .order('word');
        return _toList(rows);

      case 'reading_dual':
        // reading ที่ dual_type ตรงกับค่าที่กำหนด
        final rows = await _db
            .from('vocab_words')
            .select()
            .eq('part_scope', VocabScope.reading)
            .eq('dual_type', filter.dualType!)
            .order('word');
        return _toList(rows);

      default:
        return [];
    }
  }

  /// Fetch count for a filter (used by VocabularyPage cards)
  static Future<int> fetchWordCount(VocabFilter filter) async {
    switch (filter.fetchMode) {
      case 'part5_all':
        final rows = await _db
            .from('vocab_words')
            .select('id')
            .eq('part_scope', VocabScope.part5);
        return (rows as List).length;

      case 'reading_all':
        final rows = await _db
            .from('vocab_words')
            .select('id')
            .eq('part_scope', VocabScope.reading)
            .isFilter('dual_type', null);
        return (rows as List).length;

      case 'reading_dual':
        final rows = await _db
            .from('vocab_words')
            .select('id')
            .eq('part_scope', VocabScope.reading)
            .eq('dual_type', filter.dualType!);
        return (rows as List).length;

      default:
        return 0;
    }
  }

  static List<VocabWord> _toList(dynamic rows) {
    return (rows as List)
        .map((r) => VocabWord.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}