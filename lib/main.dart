import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const BubixoApp());
}

class BubixoApp extends StatelessWidget {
  const BubixoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubixo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const _ThemeIntegrationCheckPage(),
    );
  }
}

/// Temporary integration check until the actual Bubixo screens are connected.
/// It intentionally uses ThemeData defaults to verify the shared theme.
class _ThemeIntegrationCheckPage extends StatelessWidget {
  const _ThemeIntegrationCheckPage();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Bubixo')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Design system', style: textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            'Flutter theme connected successfully.',
            style: textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Typography', style: textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('Display / heading', style: textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Body text uses the shared type scale and color tokens.',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  const TextField(
                    decoration: InputDecoration(
                      labelText: 'Text field',
                      hintText: 'Input style preview',
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      ElevatedButton(
                        onPressed: null,
                        child: const Text('Primary button'),
                      ),
                      OutlinedButton(
                        onPressed: null,
                        child: const Text('Secondary button'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
