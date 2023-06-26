import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_sakura_anime/page/hanju/hanju_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_sniffing/video_sniffing.dart';

import '../bean/hanju_des_data.dart';
import '../bean/hanju_home_data.dart';

class HjApi {
  static const String base = "https://3532.cc";
  static const String baseUrl =
      "https://3532.cc/search.html?searchtype=5&order=time&tid=1";
  static const String baseUrl2 = "https://3532.cc/search.html?searchtype=5&order=time&tid=2";
  static const String searchUrl = "https://3532.cc/search.html?";

  static Future<HjHomeData> getHomePage(
      {String year = "", int page = 1,int type = 0}) async {
    String requestUrl = baseUrl;
    if(type == 1){
      requestUrl = baseUrl2;
    }
    if (year.isNotEmpty) {
      requestUrl += "$requestUrl&year=$year";
    }
    requestUrl += "$requestUrl&page=$page";

    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error",stackTrace));

    var document = parse(future.data);
    var queryVod =
        document.getElementsByClassName("col-md-6 col-sm-4 col-xs-3");
    var list = <HjHomeDataItem>[];
    for (var element in queryVod) {
      var els =
          element.getElementsByClassName("myui-vodlist__thumb lazyload")[0];
      var href = base + els.attributes["href"]!;
      var logo = els.attributes["data-original"]!;
      logo = formatLogoUrl(logo);
      var title = els.attributes["title"]!;
      var score = element.getElementsByClassName("pic-tag pic-tag-top")[0].text;
      score = score.substring(3, score.length - 1);
      var update = els.getElementsByClassName("pic-text text-right")[0].text;
      list.add(HjHomeDataItem(title, logo, href, score, update));
    }

    var ul = document
        .querySelectorAll("ul.myui-page > li > a.btn")
        .where((element) => element.text == "尾页");
    var canLoad = ul.isNotEmpty;

    return HjHomeData(canLoad, list);
  }

  static Future<HjDesData> getHjDes(String href) async {
    var future = await (await HttpClient.get())
        .get(href, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error",stackTrace));

    var document = parse(future.data);
    var des = document.getElementsByClassName("desc hidden-xs")[0].text;
    var nav = document
        .getElementsByClassName("nav nav-tabs active")[0]
        .querySelectorAll("li > a");

    var names = <String, String>{};
    for (var element in nav) {
      var id = element.attributes["href"]!.substring(1);
      var name = element.text;
      names[name] = id;
    }

    var plays = document.getElementsByClassName("tab-content myui-panel_bd")[0];
    var query = plays
        .querySelectorAll("div")
        .where((element) => names.values.contains(element.id))
        .toList();
    var list = <HjDesPlayData>[];
    var nameKeys = names.keys.toList();
    for (int i = 0; i < query.length; i++) {
      var els = query[i].querySelectorAll("ul > li > a");
      var playList = <HjDesPlayChapter>[];
      for (var element in els) {
        var title = element.attributes["title"]!;
        var url = base + element.attributes["href"]!;
        playList.add(HjDesPlayChapter(title, url));
      }
      list.add(HjDesPlayData(nameKeys[i], playList));
    }
    return HjDesData(des, list.where((element) => !element.title.contains("主线")).toList());
  }

  static Future<String> getPlayUrl(String url) async {
    var future = await (await HttpClient.get())
        .get(url, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) =>Future.error("$error",stackTrace));
    var document = parse(future.data);
    var iframe = document
        .getElementsByClassName(
            "embed-responsive embed-responsive-16by9 clearfix")[0]
        .querySelector("iframe");
    var src = iframe!.attributes["src"]!;
    printLongText("src = $src");
    var playUrl = await VideoSniffing.getCustomData(src, "player._hls.url");
    printLongText("playUrl = $playUrl");
    return playUrl ?? "";
  }

  static Future<HjHomeData> getSearchPage(String word, {int page = 1}) async {
    String requestUrl = searchUrl;
    if (word.isNotEmpty) {
      requestUrl += "searchword=$word";
    }
    if (page > 1) {
      requestUrl += "$requestUrl&page=$page";
    }

    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error",stackTrace));

    var document = parse(future.data);
    var list = <HjHomeDataItem>[];
    var query =
        document.getElementsByClassName("myui-vodlist__media clearfix")[0];
    var eli = query.querySelectorAll("li");
    for (var element in eli) {
      var thumb = element.querySelector("div.thumb > a")!;
      var href = base + thumb.attributes["href"]!;
      var logo = thumb.attributes["data-original"]!;
      logo = formatLogoUrl(logo);
      var title = thumb.attributes["title"]!;
      var score = thumb.getElementsByClassName("pic-tag pic-tag-top")[0].text;
      score = score.substring(3, score.length - 1);
      var updateLine = thumb.getElementsByClassName("pic-text text-right");
      var update = "";
      if (updateLine.isNotEmpty) {
        update = updateLine[0].text;
      }
      list.add(HjHomeDataItem(title, logo, href, score, update));
    }

    var ul = document
        .querySelectorAll("ul.myui-page > li > a.btn")
        .where((element) => element.text == "尾页");
    var canLoad = ul.isNotEmpty;

    return HjHomeData(canLoad, list);
  }

  static String formatLogoUrl(String logo) {
    if (!logo.startsWith("http") && !logo.startsWith("//")) {
      logo = base + logo;
    } else {
      logo = "https:$logo";
    }
    return logo;
  }
}
