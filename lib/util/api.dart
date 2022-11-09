import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:html/dom.dart' as dom;

import '../bean/anime_drams_data.dart';

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

  static Future<AnimeDesData> getAnimeDes(String url) async {
    var requestUrl = baseUrl + url;
    var future = await HttpClient.get().get(requestUrl);
    var document = parse(future.data);
    AnimeDesData data = AnimeDesData();
    var sinInfo = document.querySelectorAll("div.sinfo > p");
    if (sinInfo.length > 1) {
      var time = sinInfo[1].text;
      if (time.isEmpty) {
        data.updateTime = "尚未更新";
      } else {
        data.updateTime = time;
      }
    } else if (sinInfo.isNotEmpty) {
      var time = sinInfo[0].text;
      if (time.isEmpty) {
        data.updateTime = "尚未更新";
      } else {
        data.updateTime = time;
      }
    } else {
      data.updateTime = "尚未更新";
    }
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
      ..des = document.querySelector("div.info")?.text.replaceAll("\n", "")
      ..score = document.querySelector("div.score > em")?.text
      ..logo = document.querySelector("div.thumb > img")?.attributes["src"]
      ..tags = tags;
    debugPrint("data = $data");
    return data;
  }

  static Future<AnimePlayListData> getAnimePlayList(String url) async {
    var animaPlay = AnimePlayListData();
    var requestUrl = baseUrl + url;
    var future = await HttpClient.get().get(requestUrl);
    var document = parse(future.data);
    List<AnimeDramasData> dramasList = [];
    var elements = document.querySelectorAll("div.movurl > ul > li");
    var animeDramas = AnimeDramasData();
    animeDramas.listTitle = "默认播放列表";
    if (elements.isNotEmpty) {
      List<AnimeDramasDetailsData> details = [];
      for (var element in elements) {
        var title = element.querySelector("a")?.text;
        var url = element.querySelector("a")?.attributes["href"];
        details.add(AnimeDramasDetailsData(title, url));
      }
      animeDramas.list = details;
      dramasList.add(animeDramas);
      animaPlay.animeDramas = dramasList;

      var seasonElements = document.querySelectorAll("div.img > ul > li");
      if (seasonElements.isNotEmpty) {
        List<AnimeRecommendData> seasons = [];
        for (var element in seasonElements) {
          var title = element.querySelector("p.tname > a")?.text;
          var logo = element.querySelector("img")?.attributes["src"];
          var url = element.querySelector("p.tname > a")?.attributes["href"];
          seasons.add(AnimeRecommendData(title, logo, url));
        }
        animaPlay.animeSeasons = seasons;
      }

      var recommendElements = document.querySelectorAll("div.pics > ul > li");
      if (recommendElements.isNotEmpty) {
        List<AnimeRecommendData> recommends = [];
        for (var element in recommendElements) {
          var title = element.querySelector("h2 > a")?.text;
          var logo = element.querySelector("img")?.attributes["src"];
          var url = element.querySelector("h2 > a")?.attributes["href"];
          recommends.add(AnimeRecommendData(title, logo, url));
        }
        animaPlay.animeRecommend = recommends;
      }
    }
    return animaPlay;
  }
}
