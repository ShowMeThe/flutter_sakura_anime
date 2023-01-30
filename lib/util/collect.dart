import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import 'base_export.dart';
import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

late Database _database;

void initDb() async {
  final db = sqlite3.open(await getDbDir());
  _database = db;

  db.execute(
      "create table if not exists LocalCollect(showUrl text not null primary key,logo text not null)");
}

Future<String> getDbDir() async {
  var future = await getApplicationDocumentsDirectory();
  var localFile = File("${future.path}/collect");
  if(!localFile.existsSync()){
    localFile.createSync();
  }
  return localFile.path;
}

void unCollect(String showUrl){
  _database.execute("delete from LocalCollect where showUrl = ?",[showUrl]);
}

void collect(String showUrl, String logo) {
  var stmt = _database.prepare(
      "insert into LocalCollect(showUrl,logo) values(?,?)");
  stmt.execute([showUrl, logo]);
  stmt.dispose();
}

class LocalCollect {
  final String showUrl;
  final String logo;

  LocalCollect(this.showUrl, this.logo);
}

LocalCollect? findCollect(String showUrl) {
  var result = _database
      .select('select * from LocalCollect where showUrl = ?', [showUrl]);
  try {
    var element = result.single;
    return LocalCollect(element['showUrl'], element['logo']);
  } catch (e) {
    return null;
  }
}
