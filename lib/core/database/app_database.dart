import 'package:drift/drift.dart';
import 'database_schema.dart';
import 'database_connection.dart' as connection;

/// App-wide local SQLite database, managed through Drift.
///
/// The first migration stage uses Drift's supported custom SQL API so that the
/// existing app can move from SharedPreferences/JSON incrementally. Once the
/// repositories are migrated, frequently-used tables can be converted to
/// generated Drift table APIs without changing the persisted schema names.
class AppDatabase extends GeneratedDatabase {
  AppDatabase._(QueryExecutor executor) : super(executor);

  /// Opens the persistent database in the platform's application-support area.
  ///
  /// Web needs the additional wasm + worker assets before a persistent web
  /// connection can be enabled. Until then, callers should not open this
  /// native connection from a web build.
  factory AppDatabase.open() {
    return AppDatabase._(connection.openPersistentConnection());
  }

  /// Isolated, in-memory database for unit and migration tests.
  factory AppDatabase.inMemory() {
    return AppDatabase._(connection.openInMemoryConnection());
  }

  @override
  int get schemaVersion => currentDatabaseSchemaVersion;

  // The first step deliberately declares the persisted schema in SQL, rather
  // than generated TableInfo classes. This keeps creation/migration runnable
  // without a codegen bootstrap while repositories are migrated in stages.
  @override
  Iterable<TableInfo<Table, dynamic>> get allTables =>
      const <TableInfo<Table, dynamic>>[];

  @override
  Iterable<DatabaseSchemaEntity> get allSchemaEntities =>
      const <DatabaseSchemaEntity>[];

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (migrator) async {
          for (final statement in createDatabaseSchemaV1) {
            await customStatement(statement);
          }
        },
        onUpgrade: (migrator, from, to) async {
          // Never silently destructively upgrade an existing user's database.
          // When schemaVersion is increased, add an explicit from -> to
          // migration here and cover it with a migration test first.
          throw StateError(
            'Missing explicit Bubixo database migration from v$from to v$to.',
          );
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          final row = await customSelect('PRAGMA foreign_keys').getSingle();
          if (row.read<int>('foreign_keys') != 1) {
            throw StateError('SQLite foreign-key enforcement could not be enabled.');
          }
        },
      );
}
