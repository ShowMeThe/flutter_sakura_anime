

import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
part 'PlayUrlHistory.g.dart';

@DataClassName('PlayUrlHistory')
class PlayUrlHistoryTable extends Table{

  TextColumn get title => text().withLength(min: 1,max: 255)();

  TextColumn get playUrl => text().withLength(min: 1,max: 2000)();

  @override
   Set<Column> get primaryKey => {title};

}

@DriftDatabase(tables: [PlayUrlHistoryTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase():super(_openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'sakura_base');
  }
  @override
  int get schemaVersion => 1;
}