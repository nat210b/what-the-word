import 'package:flutter/material.dart';
import 'package:toeic_apps/pages/mock_test_page.dart';
import 'package:toeic_apps/pages/practice_page.dart';
import 'package:toeic_apps/pages/vocabulary_page.dart';
import 'package:toeic_apps/widgets/app_scaffold.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final items = <_HomeMenuItem>[
      const _HomeMenuItem(
        title: 'Vocabulary',
        subtitle: 'เรียนคำศัพท์ TOEIC',
        icon: Icons.menu_book_rounded,
        routeName: VocabularyPage.routeName,
        gradientColors: [Color(0xFF4647D3), Color(0xFF9396FF)],
      ),
      const _HomeMenuItem(
        title: 'Practice',
        subtitle: 'ฝึกทำโจทย์',
        icon: Icons.quiz_rounded,
        routeName: PracticePage.routeName,
        gradientColors: [Color(0xFF006947), Color(0xFF4CAF82)],
      ),
      const _HomeMenuItem(
        title: 'Mock Test',
        subtitle: 'ทดสอบจำลอง',
        icon: Icons.fact_check_rounded,
        routeName: MockTestPage.routeName,
        gradientColors: [Color(0xFF6B5778), Color(0xFFB39DC8)],
      ),
    ];

    return AppScaffold(
      title: 'TOEIC Master',
      currentTab: AppTab.home,
      body: CustomScrollView(
        slivers: [
          // ── Hero Banner ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: _HeroBanner(cs: cs),
            ),
          ),

          // ── Section Label ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
              child: Text(
                'เลือกโหมดการเรียน',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.outline,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          // ── Cards Grid ───────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 1.05,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _HomeMenuCard(
                  item: item,
                  onTap: () =>
                      Navigator.of(context).pushNamed(item.routeName),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero Banner ────────────────────────────────────────────────────────
class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4647D3), Color(0xFF9396FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4647D3).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'พร้อมสอบ TOEIC',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'เริ่มเรียนวันนี้ เพื่อคะแนนที่ดีกว่า',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.85),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Data Model ────────────────────────────────────────────────────────
class _HomeMenuItem {
  const _HomeMenuItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.routeName,
    required this.gradientColors,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String routeName;
  final List<Color> gradientColors;
}

// ── Menu Card ─────────────────────────────────────────────────────────
class _HomeMenuCard extends StatefulWidget {
  const _HomeMenuCard({
    required this.item,
    required this.onTap,
  });

  final _HomeMenuItem item;
  final VoidCallback onTap;

  @override
  State<_HomeMenuCard> createState() => _HomeMenuCardState();
}

class _HomeMenuCardState extends State<_HomeMenuCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.03,
    );
    _scale = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final item = widget.item;

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4647D3).withValues(alpha: 0.07),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon badge
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: item.gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item.icon, color: Colors.white, size: 24),
              ),
              const Spacer(),
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF282F3B),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                item.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6E7587),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
