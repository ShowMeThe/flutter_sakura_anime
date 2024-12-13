import 'dart:ffi';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'PlayUrlHistory.g.dart';

@DataClassName('PlayUrlHistory')
class PlayUrlHistoryTable extends Table {
  TextColumn get title => text().withLength(min: 1, max: 255)();

  TextColumn get playUrl => text().withLength(min: 1, max: 2000)();

  @override
  Set<Column> get primaryKey => {title};
}

@DriftDatabase(tables: [PlayUrlHistoryTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'sakura_base');
  }

  @override
  int get schemaVersion => 1;
}

class DatabaseManager {
  static final _database = AppDatabase();

  static Future<PlayUrlHistory?> getPlayHistory(String title) async {
    var queryResult = await (_database.select(_database.playUrlHistoryTable)
      ..where((filter) => filter.title.equals(title)))
      .getSingleOrNull();
    return queryResult;
  }

  static Future<int?> insertPlayHistory(String title,String playUrl) async {
    return await _database.into(_database.playUrlHistoryTable)
        .insert(PlayUrlHistory(title: title, playUrl: playUrl),mode: InsertMode.insertOrReplace);
  }

}
