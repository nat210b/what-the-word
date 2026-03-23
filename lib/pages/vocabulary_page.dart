// lib/pages/vocabulary_page.dart
import 'package:flutter/material.dart';
import 'package:toeic_apps/data/vocab_word.dart';
import 'package:toeic_apps/pages/vocab_study_page.dart';
import 'package:toeic_apps/services/vocab_service.dart';
import 'package:toeic_apps/widgets/app_scaffold.dart';

class VocabularyPage extends StatefulWidget {
  const VocabularyPage({super.key});
  static const String routeName = '/vocabulary';

  @override
  State<VocabularyPage> createState() => _VocabularyPageState();
}

class _VocabularyPageState extends State<VocabularyPage> {
  final Map<int, int> _counts = {};
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait(
        VocabFilter.all.map((f) => VocabService.fetchWordCount(f)),
      );
      if (!mounted) return;
      setState(() {
        for (int i = 0; i < results.length; i++) {
          _counts[i] = results[i];
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  void _startStudy(VocabFilter filter) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VocabStudyPage(filter: filter)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Vocabulary',
      currentTab: AppTab.home,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildBody(),
    );
  }

  Widget _buildError() {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: cs.outline),
          const SizedBox(height: 16),
          Text('โหลดข้อมูลไม่สำเร็จ',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700,
                  color: cs.onSurface)),
          const SizedBox(height: 8),
          Text(_error ?? '', style: TextStyle(fontSize: 13, color: cs.outline),
              textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadCounts,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('ลองอีกครั้ง'),
          ),
        ]),
      ),
    );
  }

  Widget _buildBody() {
    final cs = Theme.of(context).colorScheme;
    final filters = VocabFilter.all;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
      children: [
        Text('เลือกหมวดคำศัพท์',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800,
                color: cs.onSurface, letterSpacing: -0.4)),
        const SizedBox(height: 6),
        Text('ศึกษาคำศัพท์พร้อมความหมายและตัวอย่าง',
            style: TextStyle(fontSize: 14, color: cs.outline)),
        const SizedBox(height: 28),

        for (int i = 0; i < filters.length; i++) ...[
          if (filters[i].sectionLabel.isNotEmpty) ...[
            if (i > 0) const SizedBox(height: 32),
            Text(filters[i].sectionLabel,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                    color: cs.outline, letterSpacing: 1.2)),
            const SizedBox(height: 12),
          ] else
            const SizedBox(height: 14),
          _VocabCard(
            filter: filters[i],
            wordCount: _counts[i] ?? 0,
            onTap: () => _startStudy(filters[i]),
          ),
        ],
      ],
    );
  }
}

// ── Vocab Card ────────────────────────────────────────────────────────
class _VocabCard extends StatefulWidget {
  const _VocabCard({
    required this.filter,
    required this.wordCount,
    required this.onTap,
  });
  final VocabFilter filter;
  final int wordCount;
  final VoidCallback onTap;

  @override
  State<_VocabCard> createState() => _VocabCardState();
}

class _VocabCardState extends State<_VocabCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this,
        duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final f = widget.filter;
    final hasData = widget.wordCount > 0;
    final c1 = Color(f.gradientColors[0]);
    final c2 = Color(f.gradientColors[1]);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: hasData ? (_) => _ctrl.forward() : null,
        onTapUp: hasData ? (_) { _ctrl.reverse(); widget.onTap(); } : null,
        onTapCancel: hasData ? () => _ctrl.reverse() : null,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(
              color: c1.withValues(alpha: 0.08),
              blurRadius: 20, offset: const Offset(0, 6),
            )],
          ),
          child: Row(children: [
            // Icon badge
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: hasData
                      ? [c1, c2]
                      : [cs.surfaceContainerHighest, cs.surfaceContainer],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                f.fetchMode == 'part5_all'
                    ? Icons.shuffle_rounded
                    : Icons.auto_stories_rounded,
                color: hasData ? Colors.white : cs.outline,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(children: [
                  Expanded(
                    child: Text(f.label,
                        style: TextStyle(fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: hasData ? cs.onSurface : cs.outline,
                            letterSpacing: -0.2)),
                  ),
                  // Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: c1.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      f.fetchMode == 'part5_all' ? 'Part 5' : 'Reading',
                      style: TextStyle(fontSize: 10,
                          fontWeight: FontWeight.w700, color: c1),
                    ),
                  ),
                ]),
                const SizedBox(height: 4),
                Text(f.subtitle,
                    style: TextStyle(fontSize: 12, color: cs.outline),
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.menu_book_rounded, size: 13, color: cs.outline),
                  const SizedBox(width: 4),
                  Text(
                    hasData ? '${widget.wordCount} คำ' : 'ยังไม่มีข้อมูล',
                    style: TextStyle(fontSize: 12,
                        fontWeight: FontWeight.w500, color: cs.outline),
                  ),
                ]),
              ]),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, color: cs.outline, size: 22),
          ]),
        ),
      ),
    );
  }
}