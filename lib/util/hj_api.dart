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
  static const String searchUrl =
      "https://www.xcdyy.com/search/";
  static String errorPic = "https://www.xcdyy.com/public/tpl/zanpianadmin/no.jpg";

  static final Map<int,String> _typeMap = {0:"hanguoju",1:"ribenju"};

  static Future<HjHomeData> getHomePage(
      {String year = "", int page = 1, int type = 0}) async {
    String requestUrl = baseUrl
    .replaceAll(id_place, _typeMap[type]!)
        .replaceAll(year_place, year)
        .replaceAll(page_place, page.toString());

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
    var future = await (await HttpClient.get())
        .get(href, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));

    var document = parse(future.data);

    var des = document.getElementsByClassName("txt-hid txt-hid2 txt-hidden").firstOrNull?.text ?? "";
    var nav = document.getElementsByClassName("play-list")[0];
    var list = <HjDesPlayData>[];
    var chapter = <HjDesPlayChapter>[];
    var elements = nav.querySelectorAll("li > a");
    debugPrint("$elements");
    for (var element in elements) {
      var url = base + (element.attributes["href"] ?? "");
      var title = element.text ?? "";
      chapter.add(HjDesPlayChapter(title, url));
    }
    list.add(HjDesPlayData("主线", chapter));
    return HjDesData(des, list);
  }

  static Future<String> getPlayUrl(String url) async {
    var playUrl = await VideoSniffing.getCustomData(url, "zanpiancms_player.url ");
    printLongText("playUrl = $playUrl");
    return playUrl ?? "";
  }

  static Future<HjHomeData> getSearchPage(String word, {int page = 1}) async {
    String requestUrl = searchUrl;
    if (word.isNotEmpty) {
      requestUrl += "$word.html";
    }
    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));

    printLongText("${future.data}");

    var document = parse(future.data);
    var list = <HjHomeDataItem>[];
    var listBox = document.getElementsByClassName("col-xs-1 p-xs-0");

    try{
      for (var element in listBox) {
        var hrefElement = element.getElementsByClassName("col-lg-10 col-md-wide-2 col-sm-wide-2 col-xs-wide-3")[0];
        var aElement = hrefElement.querySelector("a.pic-img");
        if (aElement == null) continue;
        var href = base + (aElement.attributes["href"] ?? "");
         var imgEls = element.getElementsByClassName("lazyload")[0];
         var logo = formatLogoUrl(imgEls.attributes["data-original"] ?? "");
        var title = element.getElementsByClassName("col-lg-wide-9 col-md-wide-8 col-sm-wide-8 col-xs-wide-7 p-xs-10 font14")[0]
            .getElementsByClassName("font16 font-bold pt-xs-10")[0].querySelector("a")?.attributes["title"] ?? "";
        var score = "0";
        var update = element.getElementsByClassName("text-muted text-overflow txt-line32")[0].text;
        list.add(HjHomeDataItem(title, logo, href, score, update));
      }
    }catch(e){
      printLongText("${e}");
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
    if (logo.startsWith("/")) {
      logo = base + logo;
    }
    return logo;
  }
}
