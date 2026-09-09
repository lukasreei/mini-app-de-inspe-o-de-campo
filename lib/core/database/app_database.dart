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

@DataClassName('LocalWorkOrder')
class CachedWorkOrders extends Table {
  TextColumn get id => text()();

  TextColumn get code => text()();

  TextColumn get title => text()();

  TextColumn get description => text()();

  TextColumn get address => text()();

  TextColumn get priority => text()();

  TextColumn get status => text()();

  RealColumn get latitude => real()();

  RealColumn get longitude => real()();

  DateTimeColumn get scheduledAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  TextColumn get notes => text().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [Inspections, CachedWorkOrders])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'field_inspections'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(cachedWorkOrders);
        }
      },
    );
  }
}
