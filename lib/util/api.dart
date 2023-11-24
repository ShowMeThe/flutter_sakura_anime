import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter_sakura_anime/page/anime/anime_category.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:html/dom.dart' as dom;
import 'package:video_sniffing/video_sniffing.dart';

AsyncError getException(Object? error,StackTrace stackTrace) {
  debugPrint("$error");
  if (error is DioException) {
    return AsyncError("${error.message}",stackTrace);
  }
  return AsyncError("$error",stackTrace);
}

class Api {
  static const String baseImgHead = "";
  static const String baseUrl = "http://www.iyinghua.io/";
  static const String movieUrl = "$baseUrl/37/";
  static const String jcUrl = "$baseUrl/36/";

  static HomeData? homeData;
  static HashMap<String, List<String>> map = HashMap();
  static final HashMap<String, List<String>> _queryName = HashMap();

  static const String AREA = "地域";
  static const String YEAR = "年份";

  static List<String> _getYears() {
    var years = <String>[];
    for (int i = DateTime.now().year; i >= 2014; i--) {
      years.add("$i");
    }
    return years;
  }

  static void initMap() {
    if (map.isEmpty) {
      map[AREA] = ["日本", "中国", "美国"];
      _queryName[AREA] = ["japan", "china", "america"];
      map[YEAR] = _getYears();
      _queryName[YEAR] = map[YEAR]!;
    }
  }


  static Future<HomeData> getHomeData() async {
    var future = await (await HttpClient.get())
        .get(baseUrl)
        .onError((error, stackTrace) => Future.error("$error",stackTrace));
    homeData = HomeData();
    var document = parse(future.data);
    var element = document.querySelectorAll("div.tlist > ul");
    if (element.isNotEmpty) {
      homeData?.homeTimeTable = [];
      for (int i = 0, size = element.length; i < size; i++) {
        var homeTimeTable = HomeTimeTable();
        var elementChild = element[i];
        var weekElement = elementChild.querySelectorAll("li");
        if (weekElement.isNotEmpty) {
          homeTimeTable.week = Static.WEEK[i];
          homeTimeTable.timeData = parseWeek(weekElement);
          homeData!.homeTimeTable.add(homeTimeTable);
        }
      }
    }
    homeData!.homeList = [];
    var titles = document.querySelectorAll("div.firs > div.dtit");
    var data = document.querySelectorAll("div.firs > div.img");
    for (int i = 0, size = titles.length; i < size; i++) {
      var titleChild = titles[i];
      HomeListData listData = HomeListData();
      listData.title = titleChild.querySelector("h2 > a")?.text ?? "";
      listData.moreUrl =
          titleChild.querySelector("h2 > a")?.attributes["href"] ?? "";

      var animes = data[i].querySelectorAll("ul > li");
      for (var anime in animes) {
        HomeListItem item = HomeListItem();
        var info = anime.querySelectorAll("a");
        item.title = info[1].text;
        item.url = info[1].attributes["href"];
        item.img = baseImgHead +
            (info[0].querySelector("img")?.attributes["src"] ?? "");
        item.episodes = info.length == 3 ? info[2].text : "";
        listData.data.add(item);
      }
      homeData!.homeList.add(listData);
    }
    return homeData!;
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
    var future = await (await HttpClient.get()).get(requestUrl);
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
      ..logo = baseImgHead +
          (document.querySelector("div.thumb > img")?.attributes["src"] ?? "")
      ..tags = tags;
    debugPrint("data = $data");
    return data;
  }

  static Future<AnimePlayListData> getAnimePlayList(String url) async {
    var animaPlay = AnimePlayListData();
    var requestUrl = baseUrl + url;
    var future = await (await HttpClient.get()).get(requestUrl);
    var document = parse(future.data);
    List<AnimeDramasData> dramasList = [];
    var elements = document.querySelectorAll("div.movurl > ul");
    //debugPrint(future.data);
    var tabs = document.querySelectorAll("div.tabs > ul > li");
    for (int i = 0; i < tabs.length; i++) {
      var tabName = tabs[i].text;
      if (tabName.isNotEmpty && tabName != '下载列表') {
        List<AnimeDramasDetailsData> details = [];
        var elementChild = elements[i].querySelectorAll("li");
        if (elementChild.isNotEmpty) {
          var animeDramas = AnimeDramasData();
          for (var element in elementChild) {
            var title = element.querySelector("a")?.text;
            var url = element.querySelector("a")?.attributes["href"];
            details.add(AnimeDramasDetailsData(title, url));
          }
          animeDramas.listTitle = tabName;
          animeDramas.list = details;
          dramasList.add(animeDramas);
        }
      }
    }

    animaPlay.animeDramas = dramasList;

    var seasonElements = document.querySelectorAll("div.img > ul > li");
    if (seasonElements.isNotEmpty) {
      List<AnimeRecommendData> seasons = [];
      for (var element in seasonElements) {
        var title = element.querySelector("p.tname > a")?.text;
        var logo = baseImgHead +
            (element.querySelector("img")?.attributes["src"] ?? "");
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
        var logo = baseImgHead +
            (element.querySelector("img")?.attributes["src"] ?? "");
        var url = element.querySelector("h2 > a")?.attributes["href"];
        recommends.add(AnimeRecommendData(title, logo, url));
      }
      animaPlay.animeRecommend = recommends;
    }
    return animaPlay;
  }

  static Future<String> getAnimePlayUrl(String url) async {
    var requestUrl = baseUrl + url;
    var html = await VideoSniffing.getRawHtml(requestUrl);
    //printLongText("html ${html}");
    var document = parse(html);
    var iFrame = document.getElementById("playbox");
    debugPrint("iFrame ${iFrame}");
    var playerUrl = "";
    if (iFrame != null) {
      var dataVid = iFrame.attributes["data-vid"]!;
      playerUrl = dataVid.substring(0, dataVid.indexOf("\$"));
    }
    return playerUrl;
  }

  static Future<AnimeMovieData> getJCAnimeList({int nowPage = 1}) async {
    var page = nowPage;
    var requestUrl = jcUrl;
    if (page > 1) {
      requestUrl += "$page.html";
    }
    return _getAnimeList(requestUrl, nowPage: nowPage);
  }

  static Future<AnimeMovieData> getMovieAnimeList({int nowPage = 1}) async {
    var page = nowPage;
    var requestUrl = movieUrl;
    if (page >= 2) {
      requestUrl += "$page.html";
    }
    return _getAnimeList(requestUrl, nowPage: page);
  }

  static Future<AnimeMovieData> getSearchAnimeList(String word,
      {int nowPage = 1}) async {
    var page = nowPage;
    var requestUrl = "$baseUrl/search/$word";
    if (page >= 2) {
      requestUrl += "$page.html";
    }
    return _getAnimeList(requestUrl, nowPage: nowPage);
  }

  static Future<AnimeMovieData> _getAnimeList(String url,
      {int nowPage = 1}) async {
    var future = await (await HttpClient.get())
        .get(url)
        .onError((error, stackTrace) => Future.error(getException(error,stackTrace)));

    var document = parse(future.data);
    var pageQuery = document.querySelectorAll("div.pages > a");
    var pageCount = 1;

    if (pageQuery.isNotEmpty && pageQuery.length > 3) {
      var pageCountUrl = pageQuery[pageQuery.length - 2];
      pageCount = int.parse(pageCountUrl.text);
    }

    List<AnimeMovieListData> movies = [];
    var query = document.querySelectorAll("div.lpic > ul > li");
    for (var element in query) {
      var title = element.querySelector("h2")!.text.trimLeft();
      var url = element.querySelector("h2 > a")!.attributes["href"];
      var logo =
          baseImgHead + (element.querySelector("img")!.attributes["src"] ?? "");
      movies.add(AnimeMovieListData(title, logo, url));
    }

    return AnimeMovieData(nowPage, pageCount, movies);
  }

  static Future<AnimeMovieData> getCategory(Pair queryKey,
      {int nowPage = 1}) async {
    var requestUrl = "$baseUrl/";
    requestUrl += _queryName[queryKey.key]![queryKey.index];
    if (nowPage >= 2) {
      requestUrl += "/$nowPage.html";
    }
    debugPrint("getCategory = $requestUrl");
    return _getAnimeList(requestUrl, nowPage: nowPage);
  }
}
