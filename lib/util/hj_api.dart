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
  static const String base = "https://www.tvn.cc";
  static const String year_place = "year_place";
  static const String page_place = "page_place";
  static const String id_place = "id_place";
  static const String baseUrl =
      "https://www.tvn.cc/index.php?s=/list-select-id-id_place-type--area--year-year_place--star--state--order-addtime-p-page_place.html";
  static const String searchUrl = "https://www.tvn.cc/index.php?s=vod-search&wd=";

  static Future<HjHomeData> getHomePage(
      {String year = "", int page = 1, int type = 0}) async {
    String requestUrl = baseUrl
        .replaceAll(year_place, year)
        .replaceAll(page_place, page.toString()).replaceAll(id_place, "${type + 1}");

    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));
    var document = parse(future.data);
    var list = <HjHomeDataItem>[];
    var listBox = document.querySelectorAll("ul.listbox > li > a");

    for (var element in listBox) {
      var href = base + (element.attributes["href"] ?? "");
      var title = element.attributes["title"] ?? "";
      var imgEls = element.getElementsByClassName("item-lazy")[0];
      var logo = "https:${imgEls.attributes["data-echo"] ?? ""}";
      var score = element.getElementsByClassName("listbox-score")[0].text;
      var update = element.getElementsByClassName("listbox-remarks")[0].text;
      list.add(HjHomeDataItem(title, logo, href, score, update));
    }

    var canLoad = false;
    var pageBox = document.querySelectorAll("li.page-item");
    var endPage = pageBox.lastOrNull;
    if (endPage != null) {
      var text = endPage.querySelector("a")?.text;
      if (text == "»") {
        canLoad = true;
      }
    }
    return HjHomeData(canLoad, list);
  }

  static Future<HjDesData> getHjDes(String href) async {
    var future = await (await HttpClient.get())
        .get(href, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));

    var document = parse(future.data);
    var des = document.getElementById("detail-desc")?.text ?? "";

    var nav = document.getElementsByClassName("choosepisodes-list")[0];
    var list = <HjDesPlayData>[];
    var chapter = <HjDesPlayChapter>[];
    var elements =  nav.querySelectorAll("li > a");
    for (var element in elements) {
      var url = base + (element.attributes["href"]??"");
      var title = element.attributes["title"]??"";
      chapter.add(HjDesPlayChapter(title, url));
    }
    list.add(HjDesPlayData("主线", chapter));
    return HjDesData(des, list);
  }

  static Future<String> getPlayUrl(String url) async {
    var playUrl = await VideoSniffing.getCustomData(url, "cms_player.url");
    printLongText("playUrl = $playUrl");
    return playUrl ?? "";
  }

  static Future<HjHomeData> getSearchPage(String word, {int page = 1}) async {
    String requestUrl = searchUrl;
    if (word.isNotEmpty) {
      requestUrl += " $word";
    }
    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));

    printLongText("${future.data}");

    var document = parse(future.data);
    var list = <HjHomeDataItem>[];
    var listBox = document.querySelectorAll("ul.listbox > li > a");

    for (var element in listBox) {
      var href = base + (element.attributes["href"] ?? "");
      var title = element.attributes["title"] ?? "";
      var imgEls = element.getElementsByClassName("item-lazy")[0];
      var logo = "https:${imgEls.attributes["data-echo"] ?? ""}";
      var score = element.getElementsByClassName("listbox-score")[0].text;
      var update = element.getElementsByClassName("listbox-remarks")[0].text;
      list.add(HjHomeDataItem(title, logo, href, score, update));
    }

    // var canLoad = false;
    // var pageBox = document.querySelectorAll("li.page-item");
    // var endPage = pageBox.lastOrNull;
    // if (endPage != null) {
    //   var text = endPage.querySelector("a")?.text;
    //   if (text == "»") {
    //     canLoad = true;
    //   }
    // }

    return HjHomeData(false, list);
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
