// lib/pages/practice_page.dart
import 'package:flutter/material.dart';
import 'package:toeic_apps/data/quiz_data.dart';
import 'package:toeic_apps/pages/quiz_page.dart';
import 'package:toeic_apps/services/quiz_service.dart';

class _Mode {
  const _Mode({
    required this.sectionLabel,
    required this.title,
    required this.subtitle,
    required this.scope,
    required this.badgeText,
    required this.icon,
    required this.gradientColors,
  });
  final String sectionLabel;
  final String title;
  final String subtitle;
  final String scope;
  final String badgeText;
  final IconData icon;
  final List<Color> gradientColors;
}

const _kModes = [
  _Mode(
    sectionLabel: 'PART 5 เฉพาะส่วน',
    title: 'คำเชื่อม (Conjunctions)',
    subtitle: 'because, although, however, therefore...',
    scope: QuizScope.part5Conj,
    badgeText: 'Part 5',
    icon: Icons.link_rounded,
    gradientColors: [Color(0xFF4647D3), Color(0xFF9396FF)],
  ),
  _Mode(
    sectionLabel: '',
    title: 'คำบุพบท (Prepositions)',
    subtitle: 'in, on, at, by, for, with, despite...',
    scope: QuizScope.part5Prep,
    badgeText: 'Part 5',
    icon: Icons.swap_horiz_rounded,
    gradientColors: [Color(0xFF006947), Color(0xFF4CAF82)],
  ),
  _Mode(
    sectionLabel: 'PART 5 · 6 · 7 ผสม',
    title: 'คำเชื่อม ครบทุก Part',
    subtitle: 'Conj · Prep · Adv ที่ทำหน้าที่เชื่อมประโยคทั้ง 3 Part',
    scope: QuizScope.allConnector,
    badgeText: 'Part 5·6·7',
    icon: Icons.account_tree_rounded,
    gradientColors: [Color(0xFF6B5778), Color(0xFFB39DC8)],
  ),
];

// ── PracticePage ───────────────────────────────────────────────────────
class PracticePage extends StatefulWidget {
  const PracticePage({super.key});
  static const String routeName = '/practice';

  @override
  State<PracticePage> createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  final Map<String, int> _counts = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait(
        _kModes.map((m) => QuizService.fetchQuestionCount(m.scope)),
      );
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < _kModes.length; i++) {
          _counts[_kModes[i].scope] = results[i];
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _startQuiz(_Mode m) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuizPage(title: m.title, scope: m.scope),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Practice'),
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError(cs)
              : _buildBody(cs),
    );
  }

  Widget _buildError(ColorScheme cs) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: cs.outline),
            const SizedBox(height: 16),
            Text(
              'โหลดข้อมูลไม่สำเร็จ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? '',
              style: TextStyle(fontSize: 13, color: cs.outline),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _loadCounts,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('ลองอีกครั้ง'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Text(
          'เลือกโหมดที่ต้องการฝึก',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: cs.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'โหลดข้อมูลจาก Supabase · พร้อมเริ่มได้เลย',
          style: TextStyle(fontSize: 14, color: cs.outline),
        ),
        const SizedBox(height: 28),
        for (int i = 0; i < _kModes.length; i++) ...[
          if (_kModes[i].sectionLabel.isNotEmpty) ...[
            if (i > 0) const SizedBox(height: 32),
            Text(
              _kModes[i].sectionLabel,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.outline,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 14),
          _ModeCard(
            mode: _kModes[i],
            questionCount: _counts[_kModes[i].scope] ?? 0,
            onTap: () => _startQuiz(_kModes[i]),
          ),
        ],
      ],
    );
  }
}

// ── Mode Card ──────────────────────────────────────────────────────────
class _ModeCard extends StatefulWidget {
  const _ModeCard({
    required this.mode,
    required this.questionCount,
    required this.onTap,
  });
  final _Mode mode;
  final int questionCount;
  final VoidCallback onTap;

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
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
    final m = widget.mode;
    final hasData = widget.questionCount > 0;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: hasData ? (_) => _ctrl.forward() : null,
        onTapUp: hasData
            ? (_) {
                _ctrl.reverse();
                widget.onTap();
              }
            : null,
        onTapCancel: hasData ? () => _ctrl.reverse() : null,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: m.gradientColors[0].withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: hasData
                        ? m.gradientColors
                        : [cs.surfaceContainerHighest, cs.surfaceContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  m.icon,
                  color: hasData ? Colors.white : cs.outline,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            m.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: hasData ? cs.onSurface : cs.outline,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: m.gradientColors[0]
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            m.badgeText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: m.gradientColors[0],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      m.subtitle,
                      style: TextStyle(fontSize: 12, color: cs.outline),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.quiz_rounded,
                            size: 13, color: cs.outline),
                        const SizedBox(width: 4),
                        Text(
                          hasData
                              ? '${widget.questionCount} ข้อ'
                              : 'ยังไม่มีข้อมูล',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: cs.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded,
                  color: cs.outline, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────