import 'package:dio/dio.dart';
import 'package:flutter_sakura_anime/bean/hanju_des_data.dart';
import 'package:video_sniffing/video_sniffing.dart';

import '../bean/factory_tab.dart';
import 'http_client.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';

class FactoryApi {
  static const String baseUrl = "https://www.czzy77.com";
  static const String movieUrl = "zuixindianying";
  static const Map<String, String> videoHeader = {
    "origin": "https://www.czzy77.com"
  };

  static Future<List<FactoryTab>> getHomeTab() async {
    var future = await (await HttpClient.get())
        .get(baseUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) {
      debugPrint("getHomeTab error = $error");
      return Future.error("$error", stackTrace);
    });
    var document = parse(future.data);
    var submenumi = document.querySelectorAll("ul.submenu_mi");
    var liChild = submenumi.first.querySelectorAll("li");
    var tabs = <FactoryTab>[];
    for (var li in liChild) {
      var elementA = li.querySelector("a");
      var text = li.text;
      var href = elementA?.attributes["href"] ?? "";
      if (!href.startsWith("http") &&
          !href.contains("/gonggao") &&
          !href.contains("/wangzhanliuyan")) {
        tabs.add(FactoryTab(href, text));
      }
    }
    return tabs;
  }

  static Future<FactoryTabList> getTagPageData(String url, int page) async {
    var requestUrl = baseUrl + url;
    if (page > 1) {
      requestUrl += "/page/$page";
    }
    debugPrint("page url = $requestUrl");
    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) {
      debugPrint("error = $error");
      return Future.error("$error", stackTrace);
    });
    debugPrint("get result = $requestUrl");
    var canLoadMore = true;
    var list = <FactoryTabListBean>[];
    var document = parse(future.data);
    var mainRowList =
        document.getElementsByClassName("bt_img mi_ne_kd mrb").first;
    var liRowList = mainRowList.querySelectorAll("ul > li");
    for (var li in liRowList) {
      var eleA = li.querySelector("a");
      if (eleA != null) {
        var url = eleA.attributes["href"] ?? "";
        var imgEle = eleA.querySelector("img");
        var img = imgEle?.attributes["data-original"] ?? "";
        var title = imgEle?.attributes["alt"] ?? "";
        var score = li.querySelector("div.rating")?.text ?? "0.0";
        list.add(FactoryTabListBean(url, title, score, img));
      }
    }
    var divPage =
        mainRowList.querySelector("div.pagenavi_txt")?.querySelectorAll("a");
    var lastIndex = divPage?.lastOrNull?.attributes["title"];
    canLoadMore = lastIndex == "跳转到最后一页";
    debugPrint("page list = ${list.first.title}");
    return FactoryTabList(canLoadMore, page, list);
  }

  static Future<String> getPlayUrl(String playUrl) async {
    var videoUrl = "";
    var data = await VideoSniffing.getRawHtml(playUrl);
    var document = parse(data);
    var iframe = document
        .getElementsByClassName("videoplay")
        .first
        .querySelector("iframe");
    var videoSrc = iframe?.attributes["src"] ?? "";
    debugPrint("videoSrc = ${videoSrc}");
    if (videoSrc.isNotEmpty) {
      videoUrl = await VideoSniffing.getResourcesUrl(videoSrc, "mp4") ?? "";
    }
    if (videoUrl.isEmpty) {
      videoUrl = await VideoSniffing.getResourcesUrl(playUrl, "m3u8") ?? "";
    }
    return videoUrl;
  }

  static Future<HjDesData> getDes(String requestUrl) async {
    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));
    List<HjDesPlayPromotion> promotionList = [];
    var document = parse(future.data);
    var des = document
            .getElementsByClassName("yp_context")
            .first
            .text
            .trim()
            .replaceAll("\t", "") ??
        "";
    var playListItem = document.querySelector("div.paly_list_btn");
    List<HjDesPlayData> playList = [];
    if (playListItem != null) {
      var playUrlList = playListItem.querySelectorAll("a");
      var chapterList = <HjDesPlayChapter>[];
      for (var a in playUrlList) {
        var title = a.text ?? "";
        var url = a.attributes["href"] ?? "";
        chapterList.add(HjDesPlayChapter(title, url));
      }

      var interestItem = document.getElementsByClassName("bt_img mi_ne_kd").firstOrNull;
      if(interestItem != null){
        var ul = interestItem.querySelectorAll("ul > li");
        for (var a in ul) {
          var aItem = a.querySelector("a");
          if(aItem != null){
            var title = aItem.attributes["title"] ?? "";
            var url = aItem.attributes["href"] ?? "";
            var logo = aItem.querySelector("img")?.attributes["data-original"] ?? "";
            promotionList.add(HjDesPlayPromotion(title, url, logo));
          }
        }
      }
      playList.add(HjDesPlayData("在线播放", chapterList));
    }
    return HjDesData(des, playList,promotionList);
  }
}
