import 'package:dio/dio.dart';
import 'package:flutter_sakura_anime/bean/hanju_des_data.dart';
import 'package:flutter_sakura_anime/util/web_disk_cache.dart';
import 'package:video_sniffing/video_sniffing.dart';

import '../bean/factory_tab.dart';
import 'http_client.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';

class FactoryApi {
  static const String baseUrl = "https://www.czzy77.com";
  static const String movieUrl = "zuixindianying";
  static const String searchUrl = "/daoyongjiekoshibushiy0ubing?q=";
  static const Map<String, String> videoHeader = {
    "origin": baseUrl,
    'User-Agent':
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0"
  };

  static Future<String?> getWebHtml(String html) async{
    var result =  await VideoSniffing.getRawHtml(html);
    return result;
  }

  static void putWebCache(String html,String? result){
    if(result != null){
      debugPrint("put value $result");
      WebCache.put(html,result);
    }
  }

  static Future<List<FactoryTab>> getHomeTab() async {
    // var future = await (await HttpClient.get())
    //     .get(baseUrl, options: Options(responseType: ResponseType.json))
    //     .onError((error, stackTrace) {
    //   debugPrint("getHomeTab error = $error");
    //   return Future.error("$error", stackTrace);
    // });
    var future = await WebCache.get(baseUrl) ?? await getWebHtml(baseUrl);
    var document = parse(future);
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
    putWebCache(baseUrl, future);
    return tabs;
  }

  static Future<FactoryTabList> getTagPageData(String url, int page) async {
    var requestUrl = baseUrl + url;
    if (page > 1) {
      requestUrl += "/page/$page";
    }
    debugPrint("getTagPageData url = $requestUrl");
    // var future = await (await HttpClient.get())
    //     .get(requestUrl, options: Options(responseType: ResponseType.json))
    //     .onError((error, stackTrace) {
    //   debugPrint("error = $error");
    //   return Future.error("$error", stackTrace);
    // });
    var future = await WebCache.get(requestUrl) ?? await getWebHtml(requestUrl);
    var canLoadMore = true;
    var list = <FactoryTabListBean>[];
    var document = parse(future);
    var mainRowList =
        document
            .getElementsByClassName("bt_img mi_ne_kd mrb")
            .first;
    var liRowList = mainRowList.querySelectorAll("ul > li");
    for (var li in liRowList) {
      var eleA = li.querySelector("a");
      if (eleA != null) {
        var url = eleA.attributes["href"] ?? "";
        var imgEle = eleA.querySelector("img");
        var img = imgEle?.attributes["data-original"] ?? "";
        var title = imgEle?.attributes["alt"] ?? "";
        var score = li
            .querySelector("div.rating")
            ?.text ?? "0.0";
        list.add(FactoryTabListBean(url, title, score, img));
      }
    }
    var divPage =
    mainRowList.querySelector("div.pagenavi_txt")?.querySelectorAll("a");
    var lastIndex = divPage?.lastOrNull?.attributes["title"];
    canLoadMore = lastIndex == "跳转到最后一页";
    debugPrint("page list = ${list.first.title}");
    putWebCache(requestUrl, future);
    return FactoryTabList(canLoadMore, page, list);
  }

  static Future<String> getPlayUrl(String playUrl) async {
    var videoUrl = "";
    videoUrl = await VideoSniffing.getResourcesUrl(playUrl, "mp4") ?? "";
    if (videoUrl.isNotEmpty) {
      debugPrint("getPlayUrl mp4 = $videoUrl");
    } else {
      debugPrint("getPlayUrl mp4 not found");
    }
    return videoUrl;
  }

  static Future<HjDesData> getDes(String requestUrl) async {
    // var future = await (await HttpClient.get())
    //     .get(requestUrl, options: Options(responseType: ResponseType.json))
    //     .onError((error, stackTrace) => Future.error("$error", stackTrace));
    var future = await WebCache.get(requestUrl) ?? await getWebHtml(requestUrl);
    List<HjDesPlayPromotion> promotionList = [];
    var document = parse(future);
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

      var interestItem =
          document
              .getElementsByClassName("bt_img mi_ne_kd")
              .firstOrNull;
      if (interestItem != null) {
        var ul = interestItem.querySelectorAll("ul > li");
        for (var a in ul) {
          var aItem = a.querySelector("a");
          if (aItem != null) {
            var title = aItem.attributes["title"] ?? "";
            var url = aItem.attributes["href"] ?? "";
            var logo =
                aItem
                    .querySelector("img")
                    ?.attributes["data-original"] ?? "";
            promotionList.add(HjDesPlayPromotion(title, url, logo));
          }
        }
      }
      playList.add(HjDesPlayData("在线播放", chapterList));
    }
    putWebCache(requestUrl, future);
    return HjDesData(des, playList, promotionList);
  }

  static Future<FactoryTabList> getSearch(String keyWord, {int page = 1}) async {
    var requestUrl = "$baseUrl$searchUrl$keyWord";
    if (page >= 2) {
      requestUrl += "&f=_all&p=$page";
    }
    requestUrl = Uri.encodeFull(requestUrl);
    debugPrint("getSearch url = $requestUrl");
    var future = await WebCache.get(requestUrl) ?? await getWebHtml(requestUrl);
    var document = parse(future);
    var searchDiv = document
        .getElementsByClassName("bt_img mi_ne_kd search_list")
        .firstOrNull;
    var searchList = <FactoryTabListBean>[];
    if (searchDiv != null) {
      var ul = searchDiv.querySelector("ul");
      if (ul != null) {
        var lis = ul.querySelectorAll("li");
        for (var element in lis) {
          var a = element.querySelector("a");
          var url = a?.attributes["href"]?? "";
          var imgDiv = element.querySelector("img");
          if (imgDiv == null) continue;
          var title = imgDiv.attributes["alt"] ?? "";
          var img = imgDiv.attributes["src"] ?? "";
          searchList.add(FactoryTabListBean(url, title, "", img));
        }
      }
    }

    var canLoadMore = false;
    var divPage = document.getElementsByClassName("pagenavi_txt").firstOrNull;
    var maxSize = divPage?.querySelectorAll("a").length ?? 1;
    debugPrint("maxSize = $maxSize");
    canLoadMore = page < maxSize;
    putWebCache(requestUrl, future);
    return FactoryTabList(canLoadMore,page,searchList);
  }
}
