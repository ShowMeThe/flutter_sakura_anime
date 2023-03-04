import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'base_export.dart';
import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalCollect {
  final String showUrl;
  final String logo;
  final String title;

  LocalCollect(this.showUrl, this.logo, this.title);
}

class LocalHistory {
  final String showUrl;
  final int chapter;
  final int position;

  LocalHistory(this.showUrl, this.chapter,this.position);
}

late Database _database;

void initDb() async {
  final db = sqlite3.open(await getDbDir());
  _database = db;

  db.execute(
      "create table if not exists LocalCollect(showUrl text not null primary key,logo text not null,title text not null)");
  db.execute(
      "create table if not exists LocalHistory(showUrl text not null primary key,chapter integer not null,position integer)");
}

Future<String> getDbDir() async {
  var future = await getApplicationDocumentsDirectory();
  var localFile = File("${future.path}/collect");
  if (!localFile.existsSync()) {
    localFile.createSync();
  }
  return localFile.path;
}

void updateHistory(String showUrl, int chapter,int position) {
  var result = _database
      .select('select * from LocalHistory where showUrl = ?', [showUrl]);
  if (result.isNotEmpty) {
    _database.execute("update LocalHistory set chapter = ? and position = ? where showUrl = ?",
        [chapter, position, showUrl]);
  } else {
    var stmt = _database
        .prepare("insert into LocalHistory(showUrl,chapter,position) values(?,?,?)");
    stmt.execute([showUrl, chapter, position]);
    stmt.dispose();
  }
}

LocalHistory? findLocalHistory(String showUrl) {
  var result = _database
      .select('select * from LocalHistory where showUrl = ?', [showUrl]);
  try {
    var element = result.single;
    return LocalHistory(element['showUrl'], element['chapter'],element['position']);
  } catch (e) {
    debugPrint("findLocalHistory = $e");
    return null;
  }
}

void unCollect(String showUrl) {
  _database.execute("delete from LocalCollect where showUrl = ?", [showUrl]);
}

void collect(String showUrl, String logo, String title) {
  var stmt = _database
      .prepare("insert into LocalCollect(showUrl,logo,title) values(?,?,?)");
  stmt.execute([showUrl, logo, title]);
  stmt.dispose();
}

LocalCollect? findCollect(String showUrl) {
  var result = _database
      .select('select * from LocalCollect where showUrl = ?', [showUrl]);
  try {
    var element = result.single;
    return LocalCollect(element['showUrl'], element['logo'], element['title']);
  } catch (e) {
    return null;
  }
}

List<LocalCollect> findAllCollect() {
  var result = _database.select('select * from LocalCollect');
  return result
      .map((e) => LocalCollect(e['showUrl'], e['logo'], e['title']))
      .toList();
}
