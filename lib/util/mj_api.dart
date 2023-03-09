
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:gbk_codec_nohtml/gbk_codec.dart';
import 'package:video_sniffing/video_sniffing.dart';
import '../bean/meiju_category_data.dart';
import '../bean/meiju_des_data.dart';
import '../bean/meiju_home_data.dart';
import 'http_client.dart';

class MeiJuApi {
  static const String baseUrl = "https://wap.meijutt.tv";
  static const String searchUrl = "/sousuo/index.asp?";

  static Future<List<MjHomeData>> getHomeData() async {
    var future = await (await HttpClient.get2().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(baseUrl)
        .catchError((err) {
      debugPrint("err $err");
    });
    String html = gbk_bytes.decode(future.data);
    var list = <MjHomeData>[];
    var document = parse(html);
    var boxQuery = document.getElementsByClassName("box_3");
    for (var boxEle in boxQuery) {
      var divTitle = boxEle.querySelector("div.fn-clear > h4")?.text ?? "";
      var href = boxEle.querySelector("a")?.attributes["href"] ?? "";
      var child = <MjHomeListData>[];
      var li = boxEle.querySelectorAll("ul > li");
      for (var eli in li) {
        var title = eli.querySelector("a")?.attributes["title"] ?? "";
        var img = eli.querySelector("img")?.attributes["src"] ?? "";
        var href = eli.querySelector("a")?.attributes["href"] ?? "";
        var chapter = eli.querySelector("i")?.text ?? "";
        child.add(MjHomeListData(title, href, img, chapter));
      }
      list.add(MjHomeData(divTitle, href, child));
    }
    return list;
  }

  static Future<MjDesData> getDesPage(String url) async {
    var future = await (await HttpClient.get2().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(baseUrl + url)
        .catchError((err) {
      debugPrint("err $err");
    });
    String html = gbk_bytes.decode(future.data);
    var playList = <MjDesPlayData>[];
    debugPrint("html $html");
    var document = parse(html);
    var span = document.getElementsByTagName("span");
    var element = span.firstWhere((element) => element
        .getElementsByTagName("b")
        .any((element) => element.text == "剧情介绍："));
    var des = element.text.trim();
    var score = document.getElementsByClassName("ico-lx1")[0].text ?? "";
    try {
      var playGroup = document.querySelectorAll("div.arconix-toggle-title");
      if (playGroup.isNotEmpty) {
        var playEle =
            document.getElementsByClassName("arconix-toggle-content fn-clear ");
        for (int index = 0; index < playGroup.length; index++) {
          var yunbo = playGroup[index].getElementsByClassName("l bflb yunbo");
          if (yunbo.isNotEmpty) {
            var title = yunbo.first.text;
            var contentList = playEle[index];
            var eles = contentList.querySelectorAll("ul > li");
            var list = <MjDesPlayChapter>[];
            for (var element in eles) {
              var title = element.querySelector("a")?.text ?? "";
              var url = element.querySelector("a")?.attributes["href"] ?? "";
              list.add(MjDesPlayChapter(title, url));
            }
            playList.add(MjDesPlayData(title, list));
          }
        }
      }
    } catch (e) {
      debugPrint("e = ${e}");
    }
    if (playList.isEmpty) {
      playList.add(MjDesPlayData("暂无字幕组翻译", []));
    }
    return MjDesData(des, score, playList);
  }

  static Future<String?> getPlayUrl(
      String url, int parentIndex, int index) async {
    var requestUrl = baseUrl + url;
    var future = await (await HttpClient.get2().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(requestUrl)
        .catchError((err) {
      debugPrint("err $err");
    });
    var playerUrl = "";
    String html = gbk_bytes.decode(future.data);
    //debugPrint("html $html");
    var document = parse(html);
    var bofang = document.getElementById("bofang");
    var map = <int, List<String>>{};
    if (bofang != null) {
      var script = bofang.getElementsByTagName("script");
      for (var element in script) {
        var src = element.attributes["src"] ?? "";
        debugPrint("src $src");
        if (src.contains("playdata")) {
          var playdata = await (await HttpClient.get().catchError((onError) {
            debugPrint("onError $onError");
          }))
              .get(baseUrl + src)
              .catchError((err) {
            debugPrint("err $err");
          });
          String data = playdata.data;
          var firstIndex = data.indexOf("[");
          var endIndex = data.lastIndexOf("]");
          var json = data.substring(firstIndex, endIndex);
          var key = -1;
          json.split(",").forEach((element) {
            var text = element
                .replaceAll("[", "")
                .replaceAll('"', "")
                .replaceAll("]", "");
            if (text.length == 18) {
              key++;
            }
            if (text.contains("m3u8")) {
              var list = map[key] ?? [];
              var play = text.substring(0, text.length - 5) +
                  text.substring(text.length - 4, text.length);
              list.add(play);
              map[key] = list;
            }
          });
          break;
        }
      }
    }
    return map[parentIndex]?[index];
  }

  static Future<MjCategoryData> getCategoryPage(String url,
      {int page = 1}) async {
    var endUrl = url;
    if (page > 1) {
      endUrl =
          "${endUrl.substring(0, endUrl.length - 5)}_$page${endUrl.substring(endUrl.length - 5, endUrl.length)}";
    }
    var requestUrl = baseUrl + endUrl;
    var future = await (await HttpClient.get2().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(requestUrl)
        .catchError((err) {
      debugPrint("err $err");
    });
    String html = gbk_bytes.decode(future.data);
    //debugPrint("html $html");
    var document = parse(html);

    var pages = document
        .getElementsByClassName("box_1")[0]
        .querySelectorAll("div.list-page > a")
        .map((e) => e.text);
    var hasNextPage = pages.contains("下一页");
    List<MjCategoryItem> list = [];
    var query = document.querySelectorAll("li.book-li");
    for (var li in query) {
      var url = li.querySelector("a")?.attributes["href"] ?? "";
      var listimg = li.querySelector("div.listimg > img");
      var logo = listimg?.attributes["src"] ?? "";
      var title = listimg?.attributes["alt"] ?? "";
      if (logo.contains("nopic")) {
        logo = baseUrl + logo;
      }
      var bookCell = li.querySelector("div.book-cell > p");
      var des =
          bookCell?.text.trimLeft().trimRight().replaceAll("\n", "") ?? "";
      var state = des
          .substring(des.indexOf("状态"), des.indexOf("原名"))
          .trimLeft()
          .trimRight();
      var realName = des
          .substring(des.indexOf("原名"), des.indexOf("别名"))
          .trimLeft()
          .trimRight();
      var otherName = des
          .substring(des.indexOf("别名"), des.indexOf("电视台"))
          .trimLeft()
          .trimRight();
      var time =
          des.substring(des.indexOf("时间"), des.length).trimLeft().trimRight();

      var em = li.querySelector("div.book-cell > em")!;
      var score1 = em.querySelector("strong")?.text ?? "".trimRight();
      var score2 = em.querySelector("span")?.text ?? "".trimLeft();
      var score = score1 + score2;
      list.add(MjCategoryItem(
          url, logo, title, state, realName, otherName, time, score));
    }
    return MjCategoryData(list, hasNextPage);
  }

  static Future<MjCategoryData> getSearchPage(String keyword,
      {int page = 1}) async {
    var chars = gbk_bytes.encode(keyword);
    var word = "";
    for (var element in chars) {
      word += "%${element.toRadixString(16)}";
    }
    var requestUrl = "$baseUrl${searchUrl}page=$page&searchword=$word";
    debugPrint("requestUrl $requestUrl");
    var future = await (await HttpClient.get2().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(requestUrl)
        .catchError((err) {
      debugPrint("err $err");
    });
    String html = gbk_bytes.decode(future.data);
    debugPrint("html $html");
    var document = parse(html);
    var pages = document
        .getElementsByClassName("box_1")[0]
        .querySelectorAll("div.list-page > a")
        .map((e) => e.text);
    var hasNextPage = pages.contains("下一页");
    List<MjCategoryItem> list = [];
    var query = document.querySelectorAll("li.book-li");
    for (var li in query) {
      var url = li.querySelector("a")?.attributes["href"] ?? "";
      var listimg = li.querySelector("div.listimg > img");
      var logo = listimg?.attributes["src"] ?? "";
      var title = listimg?.attributes["alt"] ?? "";
      if (logo.contains("nopic")) {
        logo = baseUrl + logo;
      }
      var bookCell = li.querySelector("div.book-cell > p");
      var des =
          bookCell?.text.trimLeft().trimRight().replaceAll("\n", "") ?? "";
      var state = des
          .substring(des.indexOf("状态"), des.indexOf("原名"))
          .trimLeft()
          .trimRight();
      var realName = des
          .substring(des.indexOf("原名"), des.indexOf("别名"))
          .trimLeft()
          .trimRight();
      var otherName = des
          .substring(des.indexOf("别名"), des.indexOf("电视台"))
          .trimLeft()
          .trimRight();
      var time =
      des.substring(des.indexOf("时间"), des.length).trimLeft().trimRight();

      list.add(MjCategoryItem(
          url, logo, title, state, realName, otherName, time, ""));
    }
    return MjCategoryData(list, hasNextPage);
  }
}
