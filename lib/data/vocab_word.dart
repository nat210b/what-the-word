// lib/data/vocab_word.dart

class VocabWord {
  const VocabWord({
    required this.id,
    required this.word,
    required this.wordType,
    this.dualType,
    required this.meaningTh,
    required this.meaningEn,
    required this.example1,
    required this.example2,
    required this.partScope,
  });

  final String id;
  final String word;
  final String wordType;   // 'conj' | 'prep' | 'adv'
  final String? dualType;  // 'conj_adv' | 'prep_adv' | 'conj_prep' | null
  final String meaningTh;
  final String meaningEn;
  final String example1;
  final String example2;
  final String partScope;  // 'part5' | 'reading'

  factory VocabWord.fromJson(Map<String, dynamic> row) {
    return VocabWord(
      id: row['id'] as String? ?? '',
      word: row['word'] as String,
      wordType: row['word_type'] as String,
      dualType: row['dual_type'] as String?,
      meaningTh: row['meaning_th'] as String,
      meaningEn: row['meaning_en'] as String,
      example1: row['example_1'] as String,
      example2: row['example_2'] as String,
      partScope: row['part_scope'] as String,
    );
  }

  /// Label แสดงประเภทคำ
  String get typeLabel {
    if (dualType != null) {
      switch (dualType) {
        case 'conj_adv':  return 'Conj / Adv';
        case 'prep_adv':  return 'Prep / Adv';
        case 'conj_prep': return 'Conj / Prep';
      }
    }
    switch (wordType) {
      case 'conj': return 'Conjunction';
      case 'prep': return 'Preposition';
      case 'adv':  return 'Adverb';
      default:     return wordType;
    }
  }

  static const Map<String, List<int>> typeGradients = {
    'conj':      [0xFF4647D3, 0xFF9396FF],
    'prep':      [0xFF006947, 0xFF4CAF82],
    'adv':       [0xFF6B5778, 0xFFB39DC8],
    'conj_adv':  [0xFF4647D3, 0xFF4CAF82],
    'prep_adv':  [0xFF006947, 0xFFB39DC8],
    'conj_prep': [0xFF4647D3, 0xFF006947],
  };

  List<int> get gradientInts {
    final key = dualType ?? wordType;
    return typeGradients[key] ?? [0xFF4647D3, 0xFF9396FF];
  }
}

// ── Scope constants ───────────────────────────────────────────────────
class VocabScope {
  VocabScope._();
  static const String part5   = 'part5';
  static const String reading = 'reading';
}

// ── VocabFilter ───────────────────────────────────────────────────────
// fetchMode controls how VocabService queries Supabase:
//   'part5_all'    → part_scope='part5', no type filter (conj+prep mixed)
//   'reading_all'  → part_scope='reading', no type filter
//   'reading_dual' → part_scope='reading', filter by dual_type value

class VocabFilter {
  const VocabFilter({
    required this.label,
    required this.subtitle,
    required this.fetchMode,
    this.dualType,
    required this.gradientColors,
    required this.sectionLabel,
    required this.typeChoices, // choices shown to user during quiz
  });

  final String label;
  final String subtitle;
  final String fetchMode;       // 'part5_all' | 'reading_all' | 'reading_dual'
  final String? dualType;       // used when fetchMode = 'reading_dual'
  final List<int> gradientColors;
  final String sectionLabel;
  final List<String> typeChoices; // e.g. ['conj','prep'] or ['conj','prep','adv',...]

  static const List<VocabFilter> all = [
    // ── Part 5: conj + prep รวมกัน สุ่มถามทั้งสองประเภท ──
    VocabFilter(
      sectionLabel: 'PART 5',
      label: 'Part 5 — Conjunction & Preposition',
      subtitle: 'สุ่มคำ Conj และ Prep มาถามประเภท',
      fetchMode: 'part5_all',
      dualType: null,
      gradientColors: [0xFF4647D3, 0xFF9396FF],
      typeChoices: ['conj', 'prep'],
    ),
    // ── Reading ──
    VocabFilter(
      sectionLabel: 'READING (Part 5 · 6 · 7)',
      label: 'Conj · Prep · Adv (แยกชัด)',
      subtitle: 'คำที่มีประเภทเดียว ถามว่า Conj / Prep / Adv',
      fetchMode: 'reading_all',
      dualType: null,
      gradientColors: [0xFF6B5778, 0xFFB39DC8],
      typeChoices: ['conj', 'prep', 'adv'],
    ),
    VocabFilter(
      sectionLabel: '',
      label: 'Conj / Adv',
      subtitle: 'ใช้ได้ทั้ง Conjunction และ Adverb เช่น however, therefore',
      fetchMode: 'reading_dual',
      dualType: 'conj_adv',
      gradientColors: [0xFF4647D3, 0xFF4CAF82],
      typeChoices: ['conj', 'adv', 'conj_adv'],
    ),
    VocabFilter(
      sectionLabel: '',
      label: 'Prep / Adv',
      subtitle: 'ใช้ได้ทั้ง Preposition และ Adverb เช่น since, before',
      fetchMode: 'reading_dual',
      dualType: 'prep_adv',
      gradientColors: [0xFF006947, 0xFFB39DC8],
      typeChoices: ['prep', 'adv', 'prep_adv'],
    ),
    VocabFilter(
      sectionLabel: '',
      label: 'Conj / Prep',
      subtitle: 'ใช้ได้ทั้ง Conjunction และ Preposition เช่น after, until',
      fetchMode: 'reading_dual',
      dualType: 'conj_prep',
      gradientColors: [0xFF4647D3, 0xFF006947],
      typeChoices: ['conj', 'prep', 'conj_prep'],
    ),
  ];
}