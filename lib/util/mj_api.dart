import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:gbk_codec_nohtml/gbk_codec.dart';
import '../bean/meiju_home_data.dart';
import 'http_client.dart';

class MeiJuApi {
  static const String baseUrl = "https://wap.meijutt.tv";

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

  static Future<void> getDesPage(String url) async {
    var future = await (await HttpClient.get2().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(baseUrl + url)
        .catchError((err) {
      debugPrint("err $err");
    });
    String html = gbk_bytes.decode(future.data);
    debugPrint("html $html");
  }
}
