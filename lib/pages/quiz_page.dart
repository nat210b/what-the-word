// lib/pages/quiz_page.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toeic_apps/data/quiz_data.dart';
import 'package:toeic_apps/services/quiz_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key, required this.title, required this.scope});
  final String title;
  final String scope;

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage>
    with SingleTickerProviderStateMixin {
  List<QuizQuestion> _questions = [];
  bool _loading = true;
  String? _loadError;
  int _current = 0;
  int? _selectedIndex;
  bool _showExplanation = false;
  int _score = 0;
  bool _finished = false;
  bool _saving = false;
  bool _saved = false;

  late final AnimationController _feedbackCtrl;
  late final Animation<double> _feedbackScale;

  @override
  void initState() {
    super.initState();
    _feedbackCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _feedbackScale =
        CurvedAnimation(parent: _feedbackCtrl, curve: Curves.elasticOut);
    _loadQuestions();
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    setState(() { _loading = true; _loadError = null; });
    try {
      final qs = await QuizService.fetchQuestions(widget.scope);
      if (!mounted) return;
      setState(() { _questions = qs..shuffle(Random()); _loading = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loadError = e.toString(); _loading = false; });
    }
  }

  QuizQuestion get _q => _questions[_current];

  void _selectAnswer(int index) {
    if (_selectedIndex != null) return;
    setState(() {
      _selectedIndex = index;
      _showExplanation = true;
      if (index == _q.answerIndex) _score++;
    });
    _feedbackCtrl.forward(from: 0);
  }

  void _next() {
    if (_current + 1 >= _questions.length) {
      setState(() => _finished = true);
      _trySave();
    } else {
      setState(() {
        _current++;
        _selectedIndex = null;
        _showExplanation = false;
      });
      _feedbackCtrl.reset();
    }
  }

  Future<void> _trySave() async {
    setState(() => _saving = true);
    try {
      await QuizService.saveResult(
        scope: widget.scope,
        title: widget.title,
        score: _score,
        total: _questions.length,
      );
      if (mounted) setState(() => _saved = true);
    } catch (_) {}
    finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _restart() {
    setState(() {
      _questions.shuffle(Random());
      _current = 0; _selectedIndex = null; _showExplanation = false;
      _score = 0; _finished = false; _saving = false; _saved = false;
    });
    _feedbackCtrl.reset();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildLoadError(cs)
              : _questions.isEmpty
                  ? _buildEmpty(cs)
                  : _finished
                      ? _buildResult(cs)
                      : _buildQuiz(cs),
    );
  }

  Widget _buildLoadError(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.cloud_off_rounded, size: 48, color: cs.outline),
          const SizedBox(height: 16),
          Text('โหลดข้อสอบไม่สำเร็จ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(_loadError ?? '',
              style: TextStyle(fontSize: 13, color: cs.outline),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadQuestions,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('ลองอีกครั้ง'),
          ),
        ]),
      ),
    );
  }

  Widget _buildEmpty(ColorScheme cs) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.inbox_rounded, size: 48, color: cs.outline),
        const SizedBox(height: 16),
        Text('ยังไม่มีข้อสอบในหมวดนี้',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: cs.onSurface)),
        const SizedBox(height: 8),
        Text('กรุณาเพิ่มข้อมูลใน Supabase table: quiz_questions',
            style: TextStyle(fontSize: 14, color: cs.outline),
            textAlign: TextAlign.center),
      ]),
    );
  }

  Widget _buildQuiz(ColorScheme cs) {
    final progress = (_current + 1) / _questions.length;
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
            Row(children: [
              Text('ข้อ ${_current + 1} / ${_questions.length}',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: cs.outline)),
              const Spacer(),
              if (_q.partTag.isNotEmpty) _PartBadge(label: _q.partTag, cs: cs),
            ]),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(
                  color: const Color(0xFF4647D3).withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                )],
              ),
              child: _buildSentenceText(cs),
            ),
            const SizedBox(height: 24),
            for (int i = 0; i < _q.choices.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ChoiceButton(
                  label: _q.choices[i],
                  index: i,
                  selectedIndex: _selectedIndex,
                  correctIndex: _q.answerIndex,
                  onTap: () => _selectAnswer(i),
                ),
              ),
            if (_showExplanation) ...[
              const SizedBox(height: 4),
              ScaleTransition(
                scale: _feedbackScale,
                child: _ExplanationCard(
                  isCorrect: _selectedIndex == _q.answerIndex,
                  correctWord: _q.choices[_q.answerIndex],
                  explanation: _q.explanation,
                  cs: cs,
                ),
              ),
              const SizedBox(height: 20),
              _GradientButton(
                label: _current + 1 >= _questions.length ? 'ดูผลลัพธ์' : 'ข้อถัดไป',
                icon: _current + 1 >= _questions.length
                    ? Icons.emoji_events_rounded
                    : Icons.arrow_forward_rounded,
                onTap: _next,
              ),
            ],
          ],
        ),
      ),
    ]);
  }

  Widget _buildSentenceText(ColorScheme cs) {
    final parts = _q.sentence.split('___');
    if (parts.length < 2) {
      return Text(_q.sentence,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,
              color: cs.onSurface, height: 1.7));
    }
    final answered = _selectedIndex != null;
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500,
            color: cs.onSurface, height: 1.7),
        children: [
          TextSpan(text: parts[0]),
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: answered ? 0.6 : 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: cs.primary.withValues(alpha: answered ? 0.5 : 0.2),
                  width: 1.5,
                ),
              ),
              child: Text(
                answered ? _q.choices[_q.answerIndex] : '  ?  ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: cs.primary),
              ),
            ),
          ),
          TextSpan(text: parts[1]),
        ],
      ),
    );
  }

  Widget _buildResult(ColorScheme cs) {
    final pct = _questions.isEmpty ? 0.0 : _score / _questions.length;
    final isExcellent = pct >= 0.8;
    final isGood = pct >= 0.6;
    final emoji = isExcellent ? '🏆' : isGood ? '👍' : '📚';
    final message = isExcellent ? 'ยอดเยี่ยมมาก!' : isGood ? 'ทำได้ดี ฝึกต่อไปนะ' : 'ลองทำใหม่อีกครั้ง';
    final gradColors = isExcellent
        ? const [Color(0xFF006947), Color(0xFF4CAF82)]
        : isGood
            ? const [Color(0xFF4647D3), Color(0xFF9396FF)]
            : const [Color(0xFF6B5778), Color(0xFFB39DC8)];
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;

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
              Text('$_score/${_questions.length}',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
                      color: Colors.white, letterSpacing: -0.5)),
            ]),
          ),
          const SizedBox(height: 24),
          Text(message, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800,
              color: cs.onSurface, letterSpacing: -0.4)),
          const SizedBox(height: 8),
          Text('คะแนน ${(pct * 100).round()}%  ·  ถูก $_score จาก ${_questions.length} ข้อ',
              style: TextStyle(fontSize: 14, color: cs.outline)),
          const SizedBox(height: 16),
          if (isLoggedIn)
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _saving
                  ? Row(key: const ValueKey('saving'), mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(width: 14, height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: cs.outline)),
                      const SizedBox(width: 8),
                      Text('กำลังบันทึกผล...', style: TextStyle(fontSize: 13, color: cs.outline)),
                    ])
                  : _saved
                      ? Row(key: const ValueKey('saved'), mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.cloud_done_rounded, size: 16, color: cs.secondary),
                          const SizedBox(width: 6),
                          Text('บันทึกผลแล้ว', style: TextStyle(fontSize: 13,
                              color: cs.secondary, fontWeight: FontWeight.w600)),
                        ])
                      : const SizedBox.shrink(key: ValueKey('idle')),
            )
          else
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.info_outline_rounded, size: 15, color: cs.outline),
              const SizedBox(width: 6),
              Text('ล็อกอินเพื่อบันทึกผลคะแนน',
                  style: TextStyle(fontSize: 13, color: cs.outline)),
            ]),
          const SizedBox(height: 36),
          _GradientButton(
            label: 'ทำใหม่อีกครั้ง',
            icon: Icons.replay_rounded,
            onTap: _restart,
            colors: gradColors,
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

// ── Shared Widgets ────────────────────────────────────────────────────

class _PartBadge extends StatelessWidget {
  const _PartBadge({required this.label, required this.cs});
  final String label;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: cs.primaryContainer.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cs.primary)),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    required this.isCorrect,
    required this.correctWord,
    required this.explanation,
    required this.cs,
  });
  final bool isCorrect;
  final String correctWord;
  final String explanation;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCorrect ? cs.secondaryContainer : cs.errorContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(
            isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isCorrect ? cs.secondary : cs.error,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isCorrect ? 'ถูกต้อง!' : 'ไม่ถูกต้อง — คำตอบที่ถูกคือ "$correctWord"',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isCorrect ? cs.onSecondaryContainer : cs.onErrorContainer,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Text(explanation,
            style: TextStyle(
              fontSize: 13,
              color: isCorrect ? cs.onSecondaryContainer : cs.onErrorContainer,
              height: 1.6,
            )),
      ]),
    );
  }
}

class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.colors = const [Color(0xFF4647D3), Color(0xFF9396FF)],
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
        width: double.infinity,
        height: 56,
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
          Text(label, style: const TextStyle(fontSize: 16,
              fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(width: 8),
          Icon(icon, color: Colors.white, size: 20),
        ]),
      ),
    );
  }
}

class _ChoiceButton extends StatefulWidget {
  const _ChoiceButton({
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.correctIndex,
    required this.onTap,
  });
  final String label;
  final int index;
  final int? selectedIndex;
  final int correctIndex;
  final VoidCallback onTap;

  @override
  State<_ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 80));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isAnswered = widget.selectedIndex != null;
    final isSelected = widget.selectedIndex == widget.index;
    final isCorrect = widget.index == widget.correctIndex;

    final Color bgColor;
    final Color borderColor;
    final Color textColor;
    Widget? trailingIcon;

    if (!isAnswered) {
      bgColor = cs.surfaceContainerLowest;
      borderColor = cs.outlineVariant.withValues(alpha: 0.3);
      textColor = cs.onSurface;
    } else if (isCorrect) {
      bgColor = cs.secondaryContainer;
      borderColor = cs.secondary;
      textColor = cs.onSecondaryContainer;
      trailingIcon = Icon(Icons.check_circle_rounded, color: cs.secondary, size: 20);
    } else if (isSelected) {
      bgColor = cs.errorContainer;
      borderColor = cs.error;
      textColor = cs.onErrorContainer;
      trailingIcon = Icon(Icons.cancel_rounded, color: cs.error, size: 20);
    } else {
      bgColor = cs.surfaceContainerLowest;
      borderColor = cs.outlineVariant.withValues(alpha: 0.15);
      textColor = cs.outline;
    }

    const labels = ['A', 'B', 'C', 'D'];

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: isAnswered ? null : (_) => _ctrl.forward(),
        onTapUp: isAnswered ? null : (_) { _ctrl.reverse(); widget.onTap(); },
        onTapCancel: isAnswered ? null : () => _ctrl.reverse(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [BoxShadow(
              color: const Color(0xFF4647D3).withValues(alpha: 0.04),
              blurRadius: 12, offset: const Offset(0, 4),
            )],
          ),
          child: Row(children: [
            Container(
              width: 30, height: 30,
              decoration: BoxDecoration(
                color: isAnswered && isCorrect
                    ? cs.secondary.withValues(alpha: 0.15)
                    : isAnswered && isSelected
                        ? cs.error.withValues(alpha: 0.15)
                        : cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Center(child: Text(labels[widget.index],
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                      color: isAnswered && isCorrect ? cs.secondary
                          : isAnswered && isSelected ? cs.error
                          : cs.outline))),
            ),
            const SizedBox(width: 14),
            Expanded(child: Text(widget.label,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textColor))),
            if (trailingIcon != null) ...[const SizedBox(width: 8), trailingIcon],
          ]),
        ),
      ),
    );
  }
}
