import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/database/database_bootstrap.dart';
import 'core/theme/app_theme.dart';
import 'features/splash/presentation/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BubixoApp());

  // Keep the branded splash responsive while the local database is prepared.
  // Existing screens continue to work if database initialization fails; the
  // error is logged and the bootstrap can be retried by a future caller.
  if (DatabaseBootstrap.isSupportedPlatform) {
    unawaited(
      DatabaseBootstrap.initialize().then<void>(
        (_) {},
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('Bubixo database initialization failed: $error');
          debugPrintStack(stackTrace: stackTrace);
        },
      ),
    );
  }
}

class BubixoApp extends StatelessWidget {
  const BubixoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bubixo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const SplashScreen(),
    );
  }
}
