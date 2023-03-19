

import 'package:dio/dio.dart';
import 'package:flutter_sakura_anime/page/hanju/hanju_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';

import '../bean/hanju_home_data.dart';

class HjApi{
  static const String base = "https://3532.cc";
  static const String baseUrl = "https://3532.cc/search.html?searchtype=5&order=time&tid=1";


  static Future<HjHomeData> getSearchPage({String year = "",int page = 1}) async{
    String requestUrl = baseUrl;
    if(year.isNotEmpty){
      requestUrl += "$requestUrl&year=$year";
    }
    requestUrl += "$requestUrl&page=$page";

    var future = await (await HttpClient.get().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(requestUrl,options: Options(responseType: ResponseType.json))
        .catchError((err) {
      debugPrint("err $err");
    });
    var document = parse(future.data);
    var queryVod = document.getElementsByClassName("col-md-6 col-sm-4 col-xs-3");
    var list = <HjHomeDataItem>[];
    for (var element in queryVod) {
      var els = element.getElementsByClassName("myui-vodlist__thumb lazyload")[0];
      var href = base + els.attributes["href"]!;
      var logo = els.attributes["data-original"]!;
      var title = els.attributes["title"]!;
      var score = element.getElementsByClassName("pic-tag pic-tag-top")[0].text;
      score = score.substring(3,score.length - 1);
      list.add(HjHomeDataItem(title, logo, href, score));
    }

    var ul = document.querySelectorAll("ul.myui-page > li > a.btn").where((element) => element.text == "尾页");
    var canLoad = ul.isNotEmpty;

    return HjHomeData(canLoad,list);
  }
}