import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('LocalInspection')
class Inspections extends Table {
  TextColumn get clientId => text()();

  TextColumn get workOrderId => text()();

  TextColumn get observation => text().nullable()();

  TextColumn get condition => text().nullable()();

  TextColumn get photoPath => text().nullable()();

  RealColumn get latitude => real().nullable()();

  RealColumn get longitude => real().nullable()();

  DateTimeColumn get capturedAt => dateTime().nullable()();

  TextColumn get syncStatus => text().withDefault(const Constant('draft'))();

  TextColumn get serverId => text().nullable()();

  TextColumn get errorMessage => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  DateTimeColumn get syncedAt => dateTime().nullable()();

  IntColumn get syncAttempts => integer().withDefault(const Constant(0))();

  DateTimeColumn get lastSyncAttemptAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {clientId};
}

@DriftDatabase(tables: [Inspections])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'field_inspections'));

  @override
  int get schemaVersion => 1;
}
