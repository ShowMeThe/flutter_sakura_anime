import 'dart:async';

import 'package:drift/drift.dart';

import 'PlayUrlHistory.dart';

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

  static Future<int?> insertSearchHistory(String title) async {
    return await _database.into(_database.searchHistoryTable)
        .insert(SearchHistory(title: title, time: DateTime.now().millisecondsSinceEpoch),mode: InsertMode.insertOrReplace);
  }

  static Stream<List<SearchHistory>> getSearchHistoryFlow() {
    return _database.select(_database.searchHistoryTable)
        .watch();
  }

  static Future<bool> deleteSearchHistory(SearchHistory history) async {
    return await _database.searchHistoryTable.deleteOne(history);
  }

  static Future<int> deleteAllSearchHistory() async {
    return await _database.searchHistoryTable.deleteAll();
  }

}
