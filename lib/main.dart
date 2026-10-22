import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/shell/presentation/bubixo_shell.dart';

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
      home: const BubixoShell(),
    );
  }
}
