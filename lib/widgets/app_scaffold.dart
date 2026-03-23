import 'dart:ui';
import 'package:flutter/material.dart';

enum AppTab {
  home,
  me,
}

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    required this.currentTab,
    this.actions,
  });

  static const String homeRoute = '/';
  static const String meRoute = '/me';

  final String title;
  final Widget body;
  final AppTab currentTab;
  final List<Widget>? actions;

  void onTabTapped(BuildContext context, int index) {
    final selected = AppTab.values[index];
    if (selected == currentTab) return;

    final routeName = switch (selected) {
      AppTab.home => homeRoute,
      AppTab.me => meRoute,
    };

    Navigator.of(context).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        title: Text(title),
        actions: actions,
        backgroundColor: cs.surface.withValues(alpha: 0.85),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: const SizedBox.expand(),
          ),
        ),
      ),
      body: body,
      bottomNavigationBar: _GlassNavBar(
        currentIndex: currentTab.index,
        onTap: (index) => onTabTapped(context, index),
      ),
    );
  }
}

class _GlassNavBar extends StatelessWidget {
  const _GlassNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
      (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Me'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: cs.surface.withValues(alpha: 0.80),
        border: Border(
          top: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            child: SizedBox(
              height: 64,
              child: Row(
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final isSelected = i == currentIndex;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeOut,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 4),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? cs.primaryContainer.withValues(alpha: 0.5)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Icon(
                                isSelected ? item.activeIcon : item.icon,
                                color: isSelected ? cs.primary : cs.outline,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected ? cs.primary : cs.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
