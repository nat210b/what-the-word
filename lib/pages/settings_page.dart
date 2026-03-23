import 'package:flutter/material.dart';
import 'package:toeic_apps/widgets/app_scaffold.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const String routeName = '/settings';

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Settings',
      currentTab: AppTab.me,
      body: Center(
        child: Text('TODO: Settings'),
      ),
    );
  }
}
