import 'package:flutter_sakura_anime/bean/anime_movie_data.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:html/dom.dart' as dom;

import '../bean/anime_drams_data.dart';

class Api {
  static const String baseUrl = "http://www.yinghuacd.com";
  static const String movieUrl = "$baseUrl/movie/";
  static const String jcUrl = "$baseUrl/37/";

  static HomeData? homeData;

  static Future<HomeData> getHomeData() async {
    var future = await HttpClient.get().get(baseUrl);
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
      listData.title = titleChild
          .querySelector("h2 > a")
          ?.text ?? "";
      listData.moreUrl =
          titleChild
              .querySelector("h2 > a")
              ?.attributes["href"] ?? "";

      var animes = data[i].querySelectorAll("ul > li");
      for (var anime in animes) {
        HomeListItem item = HomeListItem();
        var info = anime.querySelectorAll("a");
        item.title = info[1].text;
        item.url = info[1].attributes["href"];
        item.img = info[0]
            .querySelector("img")
            ?.attributes["src"];
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
      if (els[i]
          .querySelectorAll("a")
          .length > 1) {
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
      ..title = document
          .querySelector("h1")
          ?.text
      ..des = document
          .querySelector("div.info")
          ?.text
          .replaceAll("\n", "")
      ..score = document
          .querySelector("div.score > em")
          ?.text
      ..logo = document
          .querySelector("div.thumb > img")
          ?.attributes["src"]
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
        var title = element
            .querySelector("a")
            ?.text;
        var url = element
            .querySelector("a")
            ?.attributes["href"];
        details.add(AnimeDramasDetailsData(title, url));
      }
      animeDramas.list = details;
      dramasList.add(animeDramas);
      animaPlay.animeDramas = dramasList;

      var seasonElements = document.querySelectorAll("div.img > ul > li");
      if (seasonElements.isNotEmpty) {
        List<AnimeRecommendData> seasons = [];
        for (var element in seasonElements) {
          var title = element
              .querySelector("p.tname > a")
              ?.text;
          var logo = element
              .querySelector("img")
              ?.attributes["src"];
          var url = element
              .querySelector("p.tname > a")
              ?.attributes["href"];
          seasons.add(AnimeRecommendData(title, logo, url));
        }
        animaPlay.animeSeasons = seasons;
      }

      var recommendElements = document.querySelectorAll("div.pics > ul > li");
      if (recommendElements.isNotEmpty) {
        List<AnimeRecommendData> recommends = [];
        for (var element in recommendElements) {
          var title = element
              .querySelector("h2 > a")
              ?.text;
          var logo = element
              .querySelector("img")
              ?.attributes["src"];
          var url = element
              .querySelector("h2 > a")
              ?.attributes["href"];
          recommends.add(AnimeRecommendData(title, logo, url));
        }
        animaPlay.animeRecommend = recommends;
      }
    }
    return animaPlay;
  }

  static Future<String> getAnimePlayUrl(String url) async {
    var requestUrl = baseUrl + url;
    debugPrint("url = $requestUrl");
    var future = await HttpClient.get().get(requestUrl);
    var document = parse(future.data);
    debugPrint("future = $future");
    var element = document.getElementById("play_1");
    if (element != null) {
      var onClickUrl = element.attributes["onclick"];
      var playUrl = onClickUrl!
          .replaceAll("changeplay('", "")
          .replaceAll("');", "")
          .replaceAll("\$mp4", "");
      debugPrint("playUrl = $playUrl");
      return playUrl;
    }
    return "";
  }


  static Future<AnimeMovieData> getJCAnimeList({int nowPage = 1}) async {
    return _getAnimeList(jcUrl, false, nowPage: nowPage);
  }

  static Future<AnimeMovieData> getMovieAnimeList({int nowPage = 1}) async {
    return _getAnimeList(movieUrl, true, nowPage: nowPage);
  }

  static Future<AnimeMovieData> _getAnimeList(String url, bool isMovie,
      {int nowPage = 1}) async {
    var requestUrl = url;
    if (nowPage > 1) {
      requestUrl = "$requestUrl/$nowPage.html";
    }
    var future = await HttpClient.get().get(requestUrl);
    var document = parse(future.data);
    var pageCount = int.parse(document
        .getElementById("lastn")
        ?.text ?? "0");

    List<AnimeMovieListData> movies = [];
    if (isMovie) {
      var query = document.querySelectorAll("div.imgs > ul > li");
      for (var element in query) {
        var elementChild = element.querySelector("p > a");
        if (elementChild != null) {
          var title = elementChild.text;
          var url = elementChild.attributes["href"];
          var logo = element.querySelector("img")!.attributes["src"];
          movies.add(AnimeMovieListData(title, logo, url));
        }
      }
    } else {
      var query = document.querySelectorAll("div.lpic > ul > li");
      for (var element in query) {
        var title = element.querySelector("h2")!.text;
        var url = element.querySelector("h2 > a")!.attributes["href"];
        var logo = element.querySelector("img")!.attributes["src"];
        movies.add(AnimeMovieListData(title, logo, url));
      }
    }
    return AnimeMovieData(nowPage, pageCount, movies);
  }
}
