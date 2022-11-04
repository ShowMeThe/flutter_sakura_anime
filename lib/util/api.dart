import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:html/dom.dart' as dom;

class Api {
  static const String baseUrl = "http://www.yinghuacd.com";

  static late HomeData homeData;

  static Future<HomeData> getHomeData() async {
    homeData = HomeData();
    var future = await HttpClient.get().get(baseUrl);
    var document = parse(future.data);
    var element = document.querySelectorAll("div.tlist > ul");
    if (element.isNotEmpty) {
      homeData.homeTimeTable = [];
      for (int i = 0, size = element.length; i < size; i++) {
        var homeTimeTable = HomeTimeTable();
        var elementChild = element[i];
        var weekElement = elementChild.querySelectorAll("li");
        if (weekElement.isNotEmpty) {
          homeTimeTable.week = Static.WEEK[i];
          homeTimeTable.timeData = parseWeek(weekElement);
          homeData.homeTimeTable.add(homeTimeTable);
        }
      }
    }
    return homeData;
  }

  static List<TimeTableData> parseWeek(List<dom.Element> els) {
    List<TimeTableData> week = [];
    for (int i = 0, size = els.length; i < size; i++) {
      if (els[i].querySelectorAll("a").length > 1) {
        var query1 = els[i].querySelectorAll("a")[1];
        var title = query1.text;
        var url = query1.attributes["href"];
        var query0 = els[i].querySelectorAll("a")[0];
        var episode = query0.text;
        var episodeUrl = query0.attributes["href"];
        week.add(TimeTableData(title, url, episode, episodeUrl));
      }
    }
    return week;
  }

  static Future<dynamic> getAnimeDes(String url) async {
    var requestUrl = baseUrl + url;
    var future = await HttpClient.get().get(requestUrl);
    var document = parse(future.data);
    AnimeDesData data = AnimeDesData();
    List<dom.Element> elements = [];
    var selector = document.querySelectorAll("div.sinfo > span");
    elements.addAll(selector[0].querySelectorAll("a"));
    elements.addAll(selector[1].querySelectorAll("a"));
    elements.addAll(selector[2].querySelectorAll("a"));
    elements.addAll(selector[4].querySelectorAll("a"));
    List<Tags> tags = [];
    for (var element in elements) {
      tags.add(Tags(element.text.toUpperCase(), element.attributes["href"]));
    }
    data
      ..url = url
      ..title = document.querySelector("h1")?.text
      ..des = document.querySelector("div.info")?.text
      ..score = document.querySelector("div.score > em")?.text
      ..logo = document.querySelector("div.thumb > img")?.attributes["src"]
      ..tags = tags;
    debugPrint("data = $data");
    return data;
  }
}
