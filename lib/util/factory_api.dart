import 'package:dio/dio.dart';

import '../bean/factory_tab.dart';
import 'http_client.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';

class FactoryApi {
  static const String baseUrl = "https://www.czzy77.com";
  static const String movieUrl = "zuixindianying";

  static Future<List<FactoryTab>> getHomeTab() async {
    var future = await (await HttpClient.get())
        .get(baseUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));
    var document = parse(future.data);
    var submenumi = document.querySelectorAll("ul.submenu_mi");
    var liChild = submenumi.first.querySelectorAll("li");
    var tabs = <FactoryTab>[];
    for (var li in liChild) {
      var elementA = li.querySelector("a");
      var text = li.text;
      var href = elementA?.attributes["href"] ?? "";
      if (!href.startsWith("http") && !href.contains("/gonggao") &&
          !href.contains("/wangzhanliuyan")) {
        tabs.add(FactoryTab(href, text));
      }
    }
    return tabs;
  }


  static Future<FactoryTabList> getTagPageData(String url, int page) async {
    var requestUrl = baseUrl + url;
    var future = await (await HttpClient.get())
        .get(requestUrl, options: Options(responseType: ResponseType.json))
        .onError((error, stackTrace) => Future.error("$error", stackTrace));
    var document = parse(future.data);
    var mainRowList = document
        .getElementsByClassName("bt_img mi_ne_kd mrb")
        .first;
    var liRowList = mainRowList.querySelectorAll("ul > li");
    var canLoadMore = true;
    var list = <FactoryTabListBean>[];
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
    var divPage = mainRowList.querySelector("div.pagenavi_txt")?.querySelectorAll("a");
    var lastIndex = divPage?.lastOrNull?.attributes["title"];
    canLoadMore = lastIndex  == "跳转到最后一页";
    return FactoryTabList(canLoadMore, list);
  }

}