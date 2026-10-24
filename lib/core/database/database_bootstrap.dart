import 'package:flutter/foundation.dart';

import 'app_database.dart';
import 'content_seeder.dart';

/// Opens the app-wide database and ensures bundled content is available.
///
/// The future is cached so concurrent callers share one connection and one
/// seed operation. If initialization fails, the connection is closed and a
/// later call may retry instead of reusing a failed future.
class DatabaseBootstrap {
  DatabaseBootstrap._();

  static Future<AppDatabase>? _initialization;

  static Future<AppDatabase> initialize() {
    return _initialization ??= _initialize();
  }

  static Future<AppDatabase> _initialize() async {
    final database = AppDatabase.open();
    try {
      await ContentSeeder(database).seedIfNeeded();
      return database;
    } catch (error, stackTrace) {
      await database.close();
      _initialization = null;
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Web remains on the existing JSON-backed flow until its Drift WASM assets
  /// are bundled. Native platforms use the persistent SQLite database.
  static bool get isSupportedPlatform => !kIsWeb;
}
