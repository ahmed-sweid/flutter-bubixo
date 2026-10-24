import 'package:drift/drift.dart';

QueryExecutor openPersistentConnection() {
  throw UnsupportedError(
    'Bubixo web database is not enabled yet. Bundle the matching SQLite WASM '
    'and Drift worker assets before opening AppDatabase on the web.',
  );
}

QueryExecutor openInMemoryConnection() {
  throw UnsupportedError(
    'The native SQLite in-memory executor is not available on web.',
  );
}
