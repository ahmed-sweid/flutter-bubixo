import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Provides a fresh filesystem location for Drift's native test database.
Future<Directory> configureTestDatabaseDirectory() async {
  final directory = await Directory.systemTemp.createTemp('bubixo-test-db-');
  const channel = MethodChannel('plugins.flutter.io/path_provider');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    switch (call.method) {
      case 'getApplicationSupportDirectory':
      case 'getTemporaryDirectory':
      case 'getApplicationDocumentsDirectory':
        return directory.path;
      default:
        return directory.path;
    }
  });

  return directory;
}
