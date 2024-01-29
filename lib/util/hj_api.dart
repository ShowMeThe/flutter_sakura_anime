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
  static const String base = "https://www.xcdyy.com/";
  static const String year_place = "year_place";
  static const String page_place = "page_place";
  static const String id_place = "id_place";
  static const String baseUrl =
      "https://www.xcdyy.com/list/id_place___year_place___page_place.html";
  static const String searchUrl = "https://www.xcdyy.com/search/";
  static String errorPic =
      "https://www.xcdyy.com/public/tpl/zanpianadmin/no.jpg";
  static final Map<int, String> _typeMap = {
    0: "hanguoju",
    1: "ribenju",
    2: "dianying"
  };

  static const String base2 = "https://cc.kan.cc";
  static const String searchUrl2 = "https://cc.kan.cc/search.html?searchword=";

  static Future<HjHomeData> getHomePage(
      {String year = "", int page = 1, int type = 0}) async {

    String requestUrl;
    if(year == DateTime.now().year.toString()){
      requestUrl = "$base${_typeMap[type]!}/";
    }else{
      requestUrl = baseUrl
          .replaceAll(id_place, _typeMap[type]!)
          .replaceAll(year_place, year)
          .replaceAll(page_place, page.toString());
    }

    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));
    var document = parse(future.data);

    var list = <HjHomeDataItem>[];
    var listBox = document.getElementsByClassName(
        "col-lg-8 col-md-6 col-sm-4 col-xs-3  pic-list-hover");

    for (var element in listBox) {
      var aElement = element.querySelector("a");
      if (aElement == null) continue;
      var href = base + (aElement.attributes["href"] ?? "");
      var title = aElement.attributes["title"] ?? "";
      var imgEls = element.getElementsByClassName("lazyload")[0];
      var logo = imgEls.attributes["data-original"] ?? "";
      var score = element.getElementsByClassName("score")[0].text;
      var update = element.getElementsByClassName("titles")[0].text;
      list.add(HjHomeDataItem(title, logo, href, score, update));
    }

    var canLoad = true;
    var pageNext = document.getElementsByClassName("next");
    var pageNextDisable = document.getElementsByClassName("next disabled");
    if (pageNextDisable.isNotEmpty && pageNext.isEmpty) {
      canLoad = false;
    }
    return HjHomeData(canLoad, list);
  }

  static Future<HjDesData> getHjDes(String href) async {
    debugPrint("href = $href");
    HjDesData result;
    if (href.contains(base)) {
      debugPrint("getDesByXcdyy");
      result = await getDesByXcdyy(href);
    } else {
      debugPrint("getDesByCCkan");
      result = await getDesByCCkan(href);
    }
    return result;
  }

  static Future<HjDesData> getDesByXcdyy(String href) async {
    var future = await (await HttpClient.get())
        .get(href, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));

    var document = parse(future.data);

    var des = document
            .getElementsByClassName("txt-hid txt-hid2 txt-hidden")
            .firstOrNull
            ?.text ??
        "";
    var nav = document.getElementsByClassName("play-list")[0];
    var list = <HjDesPlayData>[];
    var chapter = <HjDesPlayChapter>[];
    var elements = nav.querySelectorAll("li > a");
    for (var element in elements) {
      var url = base + (element.attributes["href"] ?? "");
      var title = element.text ?? "";
      chapter.add(HjDesPlayChapter(title, url));
    }
    list.add(HjDesPlayData("主线", chapter));
    return HjDesData(des, list);
  }

  static Future<HjDesData> getDesByCCkan(String href) async {
    var des = "";
    var playList = <HjDesPlayData>[];
    try {
      var future = await (await HttpClient.get())
          .get(href, options: Options(responseType: ResponseType.json))
          .onError((error, stackTrace) => Future.error("$error", stackTrace));
      var document = parse(future.data);
      des = document
              .getElementsByClassName("col-pd text-collapse content")
              .firstOrNull
              ?.text ??
          "";
      var tabs = document
          .getElementsByClassName("nav nav-tabs active")
          .first
          .querySelectorAll("li");
      for (var element in tabs) {
        var tabName = element.text;
        var subIndex = tabName.indexOf("(");
        if(subIndex != -1){
          tabName = tabName.substring(0,subIndex);
        }
        var plays = <HjDesPlayChapter>[];
        var id =
            (element.querySelector("a")?.attributes["href"] ?? "").substring(1);
        var playListEle = document
            .getElementById(id)
            ?.getElementsByClassName(
                "myui-content__list scrollbar sort-list clearfix")
            .firstOrNull
            ?.querySelectorAll("li");
        if (playListEle != null) {
          for (var element in playListEle) {
            var title = element.text ?? "";
            if (title != "APP秒播") {
              var url = base2 +
                  (element.querySelector("a")?.attributes["href"] ?? "");
              plays.add(HjDesPlayChapter(title, url));
            }
          }
        }
        if(plays.isNotEmpty){
          playList.add(HjDesPlayData(tabName, plays));
        }
      }
    } catch (e) {
      debugPrint("${e}");
    }
    return HjDesData(des, playList);
  }

  static Future<String> getPlayUrl(String url) async {
    String? playUrl = "";
    if (url.contains(base)) {
      playUrl = await VideoSniffing.getCustomData(url, "zanpiancms_player.url");
    } else {
      playUrl = await getCckanPlayer(url);
    }
    printLongText("getPlayUrl = $playUrl");
    return playUrl ?? "";
  }

  static Future<String> getCckanPlayer(String url) async{
    String? playUrl = "";
    try{
      printLongText("getCckanPlayer url = $url");
      var src = await VideoSniffing.getCustomData(url, "document.querySelector('iframe')"
          ".contentDocument.body.firstElementChild.firstElementChild.src");
      if(src != null){
        playUrl = await VideoSniffing.getCustomData(src,"url");
      }
    }catch(e){
      printLongText("$e");
    }
    return playUrl??"";
  }

  static Future<HjHomeData> getSearchPage(String word, {int page = 1}) async {
    var list = <HjHomeDataItem>[];
    if (page <= 1) {
      await _searchByXcdyy(list, word);
    }
    var canLoadMore = await _searchByCCkan(list, word, page);
    return HjHomeData(canLoadMore, list);
  }

  static Future<void> _searchByXcdyy(
      List<HjHomeDataItem> list, String word) async {
    try {
      String requestUrl = searchUrl;
      if (word.isNotEmpty) {
        requestUrl += "$word.html";
      }
      var future = await (await HttpClient.get())
          .get(requestUrl, options: Options(responseType: ResponseType.json))
          .onError((error, stackTrace) => Future.error("$error", stackTrace));
      var document = parse(future.data);

      var listBox = document.getElementsByClassName("col-xs-1 p-xs-0");

      for (var element in listBox) {
        var hrefElement = element.getElementsByClassName(
            "col-lg-10 col-md-wide-2 col-sm-wide-2 col-xs-wide-3")[0];
        var aElement = hrefElement.querySelector("a.pic-img");
        if (aElement == null) continue;
        var href = base + (aElement.attributes["href"] ?? "");
        var imgEls = element.getElementsByClassName("lazyload")[0];
        var logo = formatLogoUrl(imgEls.attributes["data-original"] ?? "");
        var title = element
                .getElementsByClassName(
                    "col-lg-wide-9 col-md-wide-8 col-sm-wide-8 col-xs-wide-7 p-xs-10 font14")[0]
                .getElementsByClassName("font16 font-bold pt-xs-10")[0]
                .querySelector("a")
                ?.attributes["title"] ??
            "";
        var score = "0";
        var update = element
            .getElementsByClassName("text-muted text-overflow txt-line32")[0]
            .text;
        list.add(HjHomeDataItem(title, logo, href, score, update));
      }
    } catch (e) {
      printLongText("${e}");
    }
  }

  static Future<bool> _searchByCCkan(
      List<HjHomeDataItem> list, String word, int page) async {
    var canLoadMore = false;
    try {
      var requestUrl = "$searchUrl2${word}&page=${page}&submit=submit";
      var future = await (await HttpClient.get())
          .get(requestUrl, options: Options(responseType: ResponseType.json))
          .onError((error, stackTrace) => Future.error("$error", stackTrace));
      var document = parse(future.data);
      var col = document.getElementsByClassName("col-md-wide-7 col-xs-1");
      if (col.isNotEmpty) {
        var mediaEle = col.first.getElementsByClassName("myui-vodlist__media");
        if (mediaEle.isNotEmpty) {
          var elements = mediaEle.first.querySelectorAll("li.active");
          for (var element in elements) {
            var thumbElement = element.querySelector("a");
            if (thumbElement == null) continue;
            var href = base2 + (thumbElement.attributes["href"] ?? "");
            var logo = base2 + (thumbElement.attributes["data-original"] ?? "");
            var title = (thumbElement.attributes["title"] ?? "");
            var score = thumbElement
                    .getElementsByClassName("pic-tag pic-tag-top")
                    .firstOrNull
                    ?.text ??
                "";
            try {
              var index = score.indexOf("瓣");
              score = score.substring(index + 1, score.length - 1).trim();
            } catch (e) {
              printLongText("$e");
            }
            var update = thumbElement
                    .getElementsByClassName("pic-text")
                    .firstOrNull
                    ?.text ??
                "";
            list.add(HjHomeDataItem(title, logo, href, score, update));
          }
        }
      }

      var pageWrap = document.getElementsByClassName("myui-page").firstOrNull;
      var btnEles = pageWrap?.querySelectorAll("li > a.btn");
      if (btnEles != null) {
        for (var element in btnEles) {
          var btnText = element.text;
          if (btnText.contains("下一页")) {
            canLoadMore = true;
            break;
          }
        }
      }
    } catch (e) {
      printLongText("$e");
    }
    return canLoadMore;
  }

  static String formatLogoUrl(String logo) {
    if (logo.startsWith("/")) {
      logo = base + logo;
    }
    return logo;
  }
}
