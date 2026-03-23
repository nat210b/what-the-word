import 'package:flutter/material.dart';

class MockTestPage extends StatelessWidget {
  const MockTestPage({super.key});

  static const String routeName = '/mock-test';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Mock Test'),
        backgroundColor: cs.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: const Center(
        child: Text('TODO: Mock test page'),
      ),
    );
  }
}