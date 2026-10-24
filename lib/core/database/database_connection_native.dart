import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

QueryExecutor openPersistentConnection() {
  return driftDatabase(
    name: 'bubixo',
    native: const DriftNativeOptions(
      databaseDirectory: getApplicationSupportDirectory,
      shareAcrossIsolates: true,
    ),
  );
}

QueryExecutor openInMemoryConnection() => NativeDatabase.memory();
