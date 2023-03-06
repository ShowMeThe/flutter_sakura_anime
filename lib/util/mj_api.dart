import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:gbk_codec_nohtml/gbk_codec.dart';
import '../bean/meiju_des_data.dart';
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
    //debugPrint("html $html");
    var document = parse(html);
    try{
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
            playList.add(MjDesPlayData(title,list));
          }
        }
      }
    }catch(e){
      debugPrint("e = ${e}");
    }
    return MjDesData(playList);
  }


  static Future<String> getPlayUrl(String url) async {
    var future = await (await HttpClient.get2().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(baseUrl + url)
        .catchError((err) {
      debugPrint("err $err");
    });
    String html = gbk_bytes.decode(future.data);
    debugPrint("html $html");
    return "";
  }

}
