import 'package:drift/drift.dart';

QueryExecutor openPersistentConnection() {
  throw UnsupportedError(
    'No local SQLite executor is configured for this platform.',
  );
}

QueryExecutor openInMemoryConnection() {
  throw UnsupportedError(
    'No in-memory SQLite executor is configured for this platform.',
  );
}
