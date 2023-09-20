import 'package:flutter_sakura_anime/bean/PlayUrlsCache.dart';
import 'package:flutter_sakura_anime/util/download_dialog.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:sqlite3/open.dart';
import 'package:sqlite3/sqlite3.dart';
import '../bean/down_load_list_item.dart';
import 'base_export.dart';
import 'dart:ffi';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

class PlayHistory {
  final String showUrl;
  final int timeInMills;

  PlayHistory(this.showUrl, this.timeInMills);
}

PlayHistory? findLocalPlayHistory(String showUrl) {
  var result = _database
      .select('select * from PlayHistory where showUrl = ?', [showUrl]);
  try {
    var element = result.single;
    return PlayHistory(element['showUrl'], element['timeInMills']);
  } catch (e) {
    debugPrint("findLocalPlayHistory = $e");
    return null;
  }
}

void updatePlayHistory(String showUrl, int timeInMills) {
  try {
    var result = _database
        .select('select * from PlayHistory where showUrl = ?', [showUrl]);

    if (result.isNotEmpty) {
      _database.execute(
          "update PlayHistory set timeInMills = ? where showUrl = ?",
          [timeInMills, showUrl]);
    } else {
      var stmt = _database
          .prepare("insert into PlayHistory(showUrl,timeInMills) values(?,?)");
      stmt.execute([showUrl, timeInMills]);
      stmt.dispose();
    }
  } catch (e) {
    debugPrint("$e");
  }
}

class LocalCollect {
  final String showUrl;
  final String logo;
  final String title;

  LocalCollect(this.showUrl, this.logo, this.title);
}

class LocalHistory {
  String showUrl;
  String chapter;
  String chapterUrl;

  LocalHistory(this.showUrl, this.chapter, this.chapterUrl);

  @override
  String toString() {
    return 'LocalHistory{showUrl: $showUrl, chapter: $chapter, chapterIndex: $chapterUrl}';
  }
}

late Database _database;

void initDb() async {
  final db = sqlite3.open(await getDbDir());
  _database = db;

  db.execute(
      "create table if not exists LocalCollect(showUrl text not null primary key,logo text not null,title text not null)");
  db.execute(
      "create table if not exists LocalHistory(showUrl text not null primary key,chapter text not null,chapterUrl text not null)");
  db.execute(
      "create table if not exists PlayUrlHistory(showUrl text not null primary key,playUrls text not null)");
  db.execute(
      "create table if not exists PlayHistory(showUrl text not null primary key,timeInMills integer not null)");
  db.execute(
      "create table if not exists DownLoadHistory(showUrl text not null primary key,imageUrl text not null,title text not null,chapter text not null)");
}

Future<String> getDbDir() async {
  var future = await getApplicationDocumentsDirectory();
  var localFile = File("${future.path}/collect");
  if (!localFile.existsSync()) {
    localFile.createSync();
  }
  return localFile.path;
}

void updateDownLoadChapter(DownLoadBean downLoadBean) {
  try {
    var result = _database.select(
        "select * from DownLoadHistory where showUrl = ?",
        [downLoadBean.showUrl]);
    if (result.isNotEmpty) {
      var element = result.first;
      var chapterList = (jsonDecode(element["chapter"]) as List)
          .map((e) => DownloadChapter.fromJson(e))
          .toList();
      chapterList.clear();
      chapterList.addAll(downLoadBean.chapter);
      downLoadBean.chapter = chapterList;
      _insertOrUpdateChapters(downLoadBean, update: true);
    } else {
      _insertOrUpdateChapters(downLoadBean, update: false);
    }
  } catch (e) {
    debugPrint("$e");
  }
}

List<DownLoadListItem> getDownLoadHistory() {
  var list = <DownLoadListItem>[];
  try {
    var result = _database.select("select * from DownLoadHistory");
    if (result.isNotEmpty) {
      for (var element in result) {
        var imageUrl = element["imageUrl"];
        var title = element["title"];
        var showUrl = element["showUrl"];
        var chapterList = (jsonDecode(element["chapter"]) as List)
            .map((e) => DownloadChapter.fromJson(e))
            .where((element) => element.localCacheFileDir.isNotEmpty)
            .toList();
        for (var ele in chapterList) {
          var bean = DownLoadListItem(imageUrl, title, showUrl, ele.chapter,
              ele.url, ele.state, ele.localCacheFileDir);
          list.add(bean);
        }
      }
    }
  } catch (e) {
    debugPrint("$e");
  }
  return list;
}

void updateDownLoadChapterState(String showUrl, String downLoadUrl) {
  try {
    var result = _database
        .select("select * from DownLoadHistory where showUrl = ?", [showUrl]);
    if (result.isNotEmpty) {
      var element = result.first;
      var chapterList = (jsonDecode(element["chapter"]) as List)
          .map((e) => DownloadChapter.fromJson(e))
          .toList();

      chapterList.firstWhere((element) {
        return element.url == downLoadUrl;
      }).state = DownloadChapter.STATE_COMPLETE;
      var list = chapterList.map((e) => e.toJson()).toList();
      var chapterJson = json.encode(list);
      _database.execute(
          "update DownLoadHistory set chapter = ? where showUrl = ?",
          [chapterJson, showUrl]);
    }
  } catch (e) {
    debugPrint("exception $e");
  }
}

void _insertOrUpdateChapters(DownLoadBean bean, {bool update = false}) {
  var list = bean.chapter.map((e) => e.toJson()).toList();
  var chapterJson = json.encode(list);
  if (update) {
    _database.execute(
        "update DownLoadHistory set chapter = ? where showUrl = ?",
        [chapterJson, bean.showUrl]);
  } else {
    var stmt = _database.prepare(
        "insert into DownLoadHistory(showUrl,imageUrl,title,chapter) values(?,?,?,?)");
    stmt.execute([bean.showUrl, bean.imageUrl, bean.title, chapterJson]);
    stmt.dispose();
  }
}

List<DownloadChapter> getDownLoadChapters(String showUrl) {
  var list = <DownloadChapter>[];
  try {
    var result = _database
        .select("select * from DownLoadHistory where showUrl = ?", [showUrl]);
    if (result.isNotEmpty) {
      var element = result.first;
      list = (jsonDecode(element["chapter"]) as List)
          .map((e) => DownloadChapter.fromJson(e))
          .toList();
    }
  } catch (e) {
    debugPrint("$e");
  }
  return list;
}

void updateChapterPlayUrls(String showUrl, String chapterUrl, String playUrl) {
  try {
    var result = _database
        .select("select * from PlayUrlHistory where showUrl = ?", [showUrl]);
    if (result.isNotEmpty) {
      var element = result.single;
      var playUrls = element["playUrls"];
      debugPrint("updateChapterPlayUrls = $playUrls");
      var playUrlCache = (jsonDecode(playUrls) as List)
          .map((e) => PlayUrlsCache.fromJson(e))
          .toList();
      var index = playUrlCache
          .indexWhere((element) => element.chapterUrl == chapterUrl);
      if (index != -1) {
        playUrlCache[index].playUrl = playUrl;
      } else {
        playUrlCache.add(PlayUrlsCache(chapterUrl, playUrl));
      }
      _insertOrUpdateChapterPlayUrls(showUrl, playUrlCache, update: true);
    } else {
      var newList = <PlayUrlsCache>[];
      newList.add(PlayUrlsCache(chapterUrl, playUrl));
      _insertOrUpdateChapterPlayUrls(showUrl, newList);
    }
  } catch (e) {
    debugPrint("$e");
  }
}

void _insertOrUpdateChapterPlayUrls(String showUrl, List<PlayUrlsCache> playUrl,
    {bool update = false}) {
  var list = playUrl.map((e) => e.toJson()).toList();
  var jsonPlayUrls = json.encode(list);
  if (update) {
    _database.execute(
        "update PlayUrlHistory set showUrl = ? , playUrls = ? where showUrl = ?",
        [showUrl, jsonPlayUrls, showUrl]);
  } else {
    var stmt = _database
        .prepare("insert into PlayUrlHistory(showUrl,playUrls) values(?,?)");
    stmt.execute([showUrl, jsonPlayUrls]);
    stmt.dispose();
  }
}

String? getPlayUrlsCache(String showUrl, String chapterUrl) {
  try {
    var result = _database
        .select("select * from PlayUrlHistory where showUrl = ?", [showUrl]);
    //debugPrint("getPlayUrlsCache = $result");
    if (result.isEmpty) return null;
    var element = result.first;
    var playUrls = element["playUrls"];
    var playUrlCache = (jsonDecode(playUrls) as List)
        .map((e) => PlayUrlsCache.fromJson(e))
        .toList();
    if (playUrlCache.isEmpty) return null;
    String? cacheUrl;
    for (var element in playUrlCache) {
      if (element.chapterUrl == chapterUrl) {
        cacheUrl = element.playUrl;
        break;
      }
    }
    return cacheUrl;
  } catch (e) {
    debugPrint("$e");
  }
  return null;
}

void updateHistory(String showUrl, String chapter, String chapterUrl) {
  try {
    var result = _database
        .select('select * from LocalHistory where showUrl = ?', [showUrl]);

    if (result.isNotEmpty) {
      _database.execute(
          "update LocalHistory set chapter = ? , chapterUrl = ? where showUrl = ?",
          [chapter, chapterUrl, showUrl]);
      debugPrint(
          "updateHistory ${_database.select('select * from LocalHistory where showUrl = ?', [
            showUrl
          ])}");
    } else {
      var stmt = _database.prepare(
          "insert into LocalHistory(showUrl,chapter,chapterUrl) values(?,?,?)");
      stmt.execute([showUrl, chapter, chapterUrl]);
      stmt.dispose();
    }
  } catch (e) {
    debugPrint("$e");
  }
}

LocalHistory? findLocalHistory(String showUrl) {
  var result = _database
      .select('select * from LocalHistory where showUrl = ?', [showUrl]);
  try {
    var element = result.single;
    return LocalHistory(
        element['showUrl'], element['chapter'], element['chapterUrl']);
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
