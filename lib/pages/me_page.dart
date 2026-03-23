import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:toeic_apps/pages/auth_page.dart';
import 'package:toeic_apps/pages/settings_page.dart';
import 'package:toeic_apps/widgets/app_scaffold.dart';

class MePage extends StatelessWidget {
  const MePage({super.key});

  static const String routeName = AppScaffold.meRoute;

  @override
  Widget build(BuildContext context) {
    final client = Supabase.instance.client;
    final user = client.auth.currentUser;
    final cs = Theme.of(context).colorScheme;

    return AppScaffold(
      title: 'Profile',
      currentTab: AppTab.me,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          // Profile Card
          Container(
            padding: const EdgeInsets.all(24),
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
            child: user == null
                ? _GuestProfile(cs: cs)
                : _UserProfile(
                    email: user.email ?? 'User',
                    userId: user.id,
                    cs: cs,
                  ),
          ),

          if (user == null) ...[
            const SizedBox(height: 20),
            _GradientButton(
              label: 'เข้าสู่ระบบ / สมัครสมาชิก',
              icon: Icons.login_rounded,
              onTap: () =>
                  Navigator.of(context).pushNamed(AuthPage.routeName),
            ),
          ],

          const SizedBox(height: 28),

          // Section label
          Text(
            'ตั้งค่า',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: cs.outline,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),

          // Settings card
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4647D3).withValues(alpha: 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.settings_rounded,
                  iconColor: const Color(0xFF4647D3),
                  label: 'Settings',
                  onTap: () => Navigator.of(context)
                      .pushNamed(SettingsPage.routeName),
                  showDivider: user != null,
                ),
                if (user != null)
                  _SettingsTile(
                    icon: Icons.logout_rounded,
                    iconColor: cs.error,
                    label: 'Sign out',
                    labelColor: cs.error,
                    onTap: () async => await client.auth.signOut(),
                    showDivider: false,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Guest profile
class _GuestProfile extends StatelessWidget {
  const _GuestProfile({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child:
              Icon(Icons.person_outline_rounded, color: cs.outline, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'ยังไม่ได้ล็อกอิน',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF282F3B),
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ล็อกอินเพื่อซิงก์ข้อมูลข้ามเครื่อง',
                style: TextStyle(fontSize: 13, color: cs.outline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Logged-in profile
class _UserProfile extends StatelessWidget {
  const _UserProfile({
    required this.email,
    required this.userId,
    required this.cs,
  });
  final String email;
  final String userId;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final initial = email.isNotEmpty ? email[0].toUpperCase() : '?';
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4647D3), Color(0xFF9396FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                email,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF282F3B),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                userId.length > 20 ? '${userId.substring(0, 20)}…' : userId,
                style: TextStyle(fontSize: 11, color: cs.outline),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// Gradient CTA button
class _GradientButton extends StatelessWidget {
  const _GradientButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4647D3), Color(0xFF9396FF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4647D3).withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Settings tile
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    required this.showDivider,
    this.labelColor,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final VoidCallback onTap;
  final bool showDivider;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: labelColor ?? cs.onSurface,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: cs.outline, size: 20),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.25),
            ),
          ),
      ],
    );
  }
}
