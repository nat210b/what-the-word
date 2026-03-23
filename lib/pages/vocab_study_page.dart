// lib/pages/vocab_study_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:toeic_apps/data/vocab_word.dart';
import 'package:toeic_apps/services/vocab_service.dart';

class VocabStudyPage extends StatefulWidget {
  const VocabStudyPage({super.key, required this.filter});
  final VocabFilter filter;

  @override
  State<VocabStudyPage> createState() => _VocabStudyPageState();
}

class _VocabStudyPageState extends State<VocabStudyPage>
    with SingleTickerProviderStateMixin {
  List<VocabWord> _words = [];
  bool _loading = true;
  String? _loadError;

  int _current = 0;
  String? _selectedType;
  bool _revealed = false;
  int _correct = 0;
  int _wrong = 0;
  bool _finished = false;

  late final AnimationController _revealCtrl;
  late final Animation<double> _revealScale;

  @override
  void initState() {
    super.initState();
    _revealCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350));
    _revealScale =
        CurvedAnimation(parent: _revealCtrl, curve: Curves.elasticOut);
    _loadWords();
  }

  @override
  void dispose() {
    _revealCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadWords() async {
    setState(() { _loading = true; _loadError = null; });
    try {
      final words = await VocabService.fetchWords(widget.filter);
      if (!mounted) return;
      setState(() {
        _words = words..shuffle(Random());
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loadError = e.toString(); _loading = false; });
    }
  }

  VocabWord get _w => _words[_current];

  // correctTypeKey: ถ้าคำมี dualType ใช้ dualType เป็นคำตอบที่ถูก
  String get _correctTypeKey => _w.dualType ?? _w.wordType;

  String _typeLabel(String t) {
    switch (t) {
      case 'conj':      return 'Conjunction';
      case 'prep':      return 'Preposition';
      case 'adv':       return 'Adverb';
      case 'conj_adv':  return 'Conj / Adv';
      case 'prep_adv':  return 'Prep / Adv';
      case 'conj_prep': return 'Conj / Prep';
      default:          return t;
    }
  }

  void _selectType(String type) {
    if (_revealed) return;
    setState(() {
      _selectedType = type;
      _revealed = true;
      if (type == _correctTypeKey) _correct++; else _wrong++;
    });
    _revealCtrl.forward(from: 0);
  }

  void _next() {
    if (_current + 1 >= _words.length) {
      setState(() => _finished = true);
    } else {
      setState(() {
        _current++;
        _selectedType = null;
        _revealed = false;
      });
      _revealCtrl.reset();
    }
  }

  void _restart() {
    setState(() {
      _words.shuffle(Random());
      _current = 0; _selectedType = null; _revealed = false;
      _correct = 0; _wrong = 0; _finished = false;
    });
    _revealCtrl.reset();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.filter.label),
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildError(cs)
              : _words.isEmpty
                  ? _buildEmpty(cs)
                  : _finished
                      ? _buildResult(cs)
                      : _buildStudy(cs),
    );
  }

  Widget _buildError(ColorScheme cs) => Center(
    child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.cloud_off_rounded, size: 48, color: cs.outline),
        const SizedBox(height: 16),
        Text('โหลดคำศัพท์ไม่สำเร็จ',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: cs.onSurface)),
        const SizedBox(height: 8),
        Text(_loadError ?? '', style: TextStyle(fontSize: 13, color: cs.outline),
            textAlign: TextAlign.center),
        const SizedBox(height: 24),
        FilledButton.icon(onPressed: _loadWords,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('ลองอีกครั้ง')),
      ]),
    ),
  );

  Widget _buildEmpty(ColorScheme cs) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.inbox_rounded, size: 48, color: cs.outline),
      const SizedBox(height: 16),
      Text('ยังไม่มีคำศัพท์ในหมวดนี้',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
              color: cs.onSurface)),
      const SizedBox(height: 8),
      Text('กรุณาเพิ่มข้อมูลใน Supabase table: vocab_words',
          style: TextStyle(fontSize: 14, color: cs.outline),
          textAlign: TextAlign.center),
    ]),
  );

  // ── Study UI ──────────────────────────────────────────────
  Widget _buildStudy(ColorScheme cs) {
    final progress = (_current + 1) / _words.length;
    final gradInts = _w.gradientInts;
    final c1 = Color(gradInts[0]);
    final c2 = Color(gradInts[1]);
    // typeChoices มาจาก filter — Part5 = ['conj','prep'] เท่านั้น
    final choices = widget.filter.typeChoices;

    return Column(children: [
      LinearProgressIndicator(
        value: progress,
        minHeight: 6,
        backgroundColor: cs.surfaceContainerHighest,
        valueColor: AlwaysStoppedAnimation<Color>(cs.secondary),
      ),
      Expanded(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            // Counter + score
            Row(children: [
              Text('คำที่ ${_current + 1} / ${_words.length}',
                  style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600, color: cs.outline)),
              const Spacer(),
              _ScoreBadge(correct: _correct, wrong: _wrong, cs: cs),
            ]),
            const SizedBox(height: 20),

            // ── Word card ──────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c1, c2],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(
                  color: c1.withValues(alpha: 0.25),
                  blurRadius: 24, offset: const Offset(0, 8),
                )],
              ),
              child: Column(children: [
                Text(
                  _w.word,
                  style: const TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Text(
                    _revealed ? _w.typeLabel : 'คำนี้คือประเภทใด?',
                    key: ValueKey(_revealed),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(
                          alpha: _revealed ? 0.95 : 0.65),
                    ),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            // ── Type choice buttons ────────────────────────
            // แสดงปุ่มตาม choices ที่ filter กำหนด
            // Part5 → ['conj', 'prep'] → 2 ปุ่มใหญ่แนวตั้ง
            // Reading → หลายปุ่ม wrap
            if (choices.length <= 2)
              Column(
                children: choices.map((type) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TypeButton(
                    label: _typeLabel(type),
                    typeKey: type,
                    selectedType: _selectedType,
                    correctTypeKey: _correctTypeKey,
                    revealed: _revealed,
                    onTap: () => _selectType(type),
                    cs: cs,
                  ),
                )).toList(),
              )
            else
              Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: choices.map((type) => _TypeChip(
                  label: _typeLabel(type),
                  typeKey: type,
                  selectedType: _selectedType,
                  correctTypeKey: _correctTypeKey,
                  revealed: _revealed,
                  onTap: () => _selectType(type),
                  cs: cs,
                )).toList(),
              ),

            // ── Reveal panel ───────────────────────────────
            if (_revealed) ...[
              const SizedBox(height: 20),
              ScaleTransition(
                scale: _revealScale,
                child: _RevealCard(word: _w, cs: cs),
              ),
              const SizedBox(height: 20),
              _GradientButton(
                label: _current + 1 >= _words.length
                    ? 'ดูผลลัพธ์'
                    : 'คำถัดไป',
                icon: _current + 1 >= _words.length
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
                colors: [c1, c2],
                onTap: _next,
              ),
            ],
          ],
        ),
      ),
    ]);
  }

  // ── Result screen ─────────────────────────────────────────
  Widget _buildResult(ColorScheme cs) {
    final total = _correct + _wrong;
    final pct = total > 0 ? _correct / total : 0.0;
    final isExcellent = pct >= 0.8;
    final isGood = pct >= 0.6;
    final emoji = isExcellent ? '🏆' : isGood ? '👍' : '📚';
    final message = isExcellent
        ? 'จำได้เยี่ยมมาก!'
        : isGood
            ? 'ทำได้ดี ทบทวนต่อนะ'
            : 'ลองทบทวนอีกครั้ง';
    final gradColors = isExcellent
        ? [const Color(0xFF006947), const Color(0xFF4CAF82)]
        : isGood
            ? [const Color(0xFF4647D3), const Color(0xFF9396FF)]
            : [const Color(0xFF6B5778), const Color(0xFFB39DC8)];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 140, height: 140,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: gradColors,
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                color: gradColors[0].withValues(alpha: 0.3),
                blurRadius: 32, offset: const Offset(0, 8),
              )],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(emoji, style: const TextStyle(fontSize: 36)),
              Text('$_correct/$total',
                  style: const TextStyle(fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -0.5)),
            ]),
          ),
          const SizedBox(height: 24),
          Text(message,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                  color: cs.onSurface, letterSpacing: -0.4)),
          const SizedBox(height: 8),
          Text('ถูก $_correct · ผิด $_wrong จากทั้งหมด $total คำ',
              style: TextStyle(fontSize: 14, color: cs.outline)),
          const SizedBox(height: 36),
          _GradientButton(
            label: 'ทบทวนอีกครั้ง',
            icon: Icons.replay_rounded,
            colors: gradColors,
            onTap: _restart,
          ),
          const SizedBox(height: 14),
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_rounded, color: cs.outline),
            label: Text('กลับ', style: TextStyle(color: cs.outline)),
          ),
        ]),
      ),
    );
  }
}

// ── Full-width Type Button (used for Part5: 2 choices) ────────────────
class _TypeButton extends StatefulWidget {
  const _TypeButton({
    required this.label,
    required this.typeKey,
    required this.selectedType,
    required this.correctTypeKey,
    required this.revealed,
    required this.onTap,
    required this.cs,
  });
  final String label;
  final String typeKey;
  final String? selectedType;
  final String correctTypeKey;
  final bool revealed;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  State<_TypeButton> createState() => _TypeButtonState();
}

class _TypeButtonState extends State<_TypeButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final isSelected = widget.selectedType == widget.typeKey;
    final isCorrect  = widget.typeKey == widget.correctTypeKey;

    final Color bg;
    final Color border;
    final Color textColor;
    Widget? trailingIcon;

    if (!widget.revealed) {
      bg = cs.surfaceContainerLowest;
      border = cs.outlineVariant.withValues(alpha: 0.35);
      textColor = cs.onSurface;
    } else if (isCorrect) {
      bg = cs.secondaryContainer;
      border = cs.secondary;
      textColor = cs.onSecondaryContainer;
      trailingIcon = Icon(Icons.check_circle_rounded,
          color: cs.secondary, size: 22);
    } else if (isSelected) {
      bg = cs.errorContainer;
      border = cs.error;
      textColor = cs.onErrorContainer;
      trailingIcon = Icon(Icons.cancel_rounded, color: cs.error, size: 22);
    } else {
      bg = cs.surfaceContainerLowest;
      border = cs.outlineVariant.withValues(alpha: 0.15);
      textColor = cs.outline;
    }

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.revealed ? null : (_) => _ctrl.forward(),
        onTapUp: widget.revealed
            ? null
            : (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: widget.revealed ? null : () => _ctrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 1.5),
            boxShadow: [BoxShadow(
              color: const Color(0xFF4647D3).withValues(alpha: 0.05),
              blurRadius: 12, offset: const Offset(0, 4),
            )],
          ),
          child: Row(children: [
            Expanded(
              child: Text(widget.label,
                  style: TextStyle(fontSize: 16,
                      fontWeight: FontWeight.w700, color: textColor)),
            ),
            if (trailingIcon != null) trailingIcon,
          ]),
        ),
      ),
    );
  }
}

// ── Chip Button (used for Reading: 3+ choices) ────────────────────────
class _TypeChip extends StatefulWidget {
  const _TypeChip({
    required this.label,
    required this.typeKey,
    required this.selectedType,
    required this.correctTypeKey,
    required this.revealed,
    required this.onTap,
    required this.cs,
  });
  final String label;
  final String typeKey;
  final String? selectedType;
  final String correctTypeKey;
  final bool revealed;
  final VoidCallback onTap;
  final ColorScheme cs;

  @override
  State<_TypeChip> createState() => _TypeChipState();
}

class _TypeChipState extends State<_TypeChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.95)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = widget.cs;
    final isSelected = widget.selectedType == widget.typeKey;
    final isCorrect  = widget.typeKey == widget.correctTypeKey;

    final Color bg;
    final Color border;
    final Color textColor;

    if (!widget.revealed) {
      bg = cs.surfaceContainerLowest;
      border = cs.outlineVariant.withValues(alpha: 0.4);
      textColor = cs.onSurface;
    } else if (isCorrect) {
      bg = cs.secondaryContainer;
      border = cs.secondary;
      textColor = cs.onSecondaryContainer;
    } else if (isSelected) {
      bg = cs.errorContainer;
      border = cs.error;
      textColor = cs.onErrorContainer;
    } else {
      bg = cs.surfaceContainerLowest;
      border = cs.outlineVariant.withValues(alpha: 0.2);
      textColor = cs.outline;
    }

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: widget.revealed ? null : (_) => _ctrl.forward(),
        onTapUp: widget.revealed
            ? null
            : (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: widget.revealed ? null : () => _ctrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(100),
            border: Border.all(color: border, width: 1.5),
            boxShadow: [BoxShadow(
              color: const Color(0xFF4647D3).withValues(alpha: 0.05),
              blurRadius: 8, offset: const Offset(0, 3),
            )],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (widget.revealed && isCorrect)
              Icon(Icons.check_circle_rounded, size: 15, color: cs.secondary),
            if (widget.revealed && isSelected && !isCorrect)
              Icon(Icons.cancel_rounded, size: 15, color: cs.error),
            if (widget.revealed &&
                (isCorrect || (isSelected && !isCorrect)))
              const SizedBox(width: 5),
            Text(widget.label,
                style: TextStyle(fontSize: 14,
                    fontWeight: FontWeight.w600, color: textColor)),
          ]),
        ),
      ),
    );
  }
}

// ── Reveal Card ───────────────────────────────────────────────────────
class _RevealCard extends StatelessWidget {
  const _RevealCard({required this.word, required this.cs});
  final VocabWord word;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(
          color: const Color(0xFF4647D3).withValues(alpha: 0.06),
          blurRadius: 20, offset: const Offset(0, 6),
        )],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Meaning
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.translate_rounded, size: 18, color: cs.primary),
          ),
          const SizedBox(width: 10),
          Text('ความหมาย',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: cs.outline, letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 12),
        Text(word.meaningTh,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                color: cs.onSurface, height: 1.4)),
        const SizedBox(height: 4),
        Text(word.meaningEn,
            style: TextStyle(fontSize: 14, color: cs.outline, height: 1.4)),

        const SizedBox(height: 20),
        Divider(color: cs.outlineVariant.withValues(alpha: 0.2), height: 1),
        const SizedBox(height: 20),

        // Examples
        Row(children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.format_quote_rounded,
                size: 18, color: cs.secondary),
          ),
          const SizedBox(width: 10),
          Text('ตัวอย่างการใช้งาน',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
                  color: cs.outline, letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 14),
        _ExampleRow(number: 1, sentence: word.example1, cs: cs),
        const SizedBox(height: 12),
        _ExampleRow(number: 2, sentence: word.example2, cs: cs),
      ]),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow(
      {required this.number, required this.sentence, required this.cs});
  final int number;
  final String sentence;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 22, height: 22,
        decoration: BoxDecoration(
          color: cs.primaryContainer.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text('$number',
            style: TextStyle(fontSize: 11,
                fontWeight: FontWeight.w800, color: cs.primary))),
      ),
      const SizedBox(width: 10),
      Expanded(child: Text(sentence,
          style: TextStyle(fontSize: 14,
              color: cs.onSurface, height: 1.6))),
    ]);
  }
}

// ── Score Badge ───────────────────────────────────────────────────────
class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge(
      {required this.correct, required this.wrong, required this.cs});
  final int correct;
  final int wrong;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.check_circle_rounded, size: 14, color: cs.secondary),
      const SizedBox(width: 3),
      Text('$correct',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: cs.secondary)),
      const SizedBox(width: 10),
      Icon(Icons.cancel_rounded, size: 14, color: cs.error),
      const SizedBox(width: 3),
      Text('$wrong',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700,
              color: cs.error)),
    ]);
  }
}

// ── Gradient Button ───────────────────────────────────────────────────
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity, height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors,
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [BoxShadow(
            color: colors[0].withValues(alpha: 0.3),
            blurRadius: 16, offset: const Offset(0, 6),
          )],
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(label,
              style: const TextStyle(fontSize: 16,
                  fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 20),
        ]),
      ),
    );
  }
}