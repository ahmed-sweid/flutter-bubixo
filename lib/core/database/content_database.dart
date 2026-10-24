import 'dart:convert';

import 'app_database.dart';
import 'database_bootstrap.dart';

/// Shared resolution for content repositories.
///
/// Bundled JSON remains the fallback source: platforms without the local
/// database, and reads that fail before the seeder has run, keep working from
/// the asset files instead of losing content.
Future<AppDatabase?> resolveContentDatabase(AppDatabase? injected) async {
  if (injected != null) return injected;
  if (!DatabaseBootstrap.isSupportedPlatform) return null;
  try {
    return await DatabaseBootstrap.initialize();
  } catch (_) {
    return null;
  }
}

/// Decodes a JSON array column of strings.
///
/// Malformed rows throw so the caller falls back to the bundled asset instead
/// of showing partial content.
List<String> decodeStringList(Object? raw) {
  if (raw is! String) {
    throw const FormatException('Expected a JSON encoded list column.');
  }
  final decoded = jsonDecode(raw);
  if (decoded is! List || !decoded.every((item) => item is String)) {
    throw const FormatException('Expected a JSON list of strings.');
  }
  return decoded.cast<String>();
}
