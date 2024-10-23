import 'dart:async';
import 'dart:collection';

import 'package:dio/dio.dart';
import 'package:flutter_sakura_anime/page/anime/anime_category.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:html/dom.dart' as dom;
import 'package:video_sniffing/video_sniffing.dart';

AsyncError getException(Object? error, StackTrace stackTrace) {
  debugPrint("$error");
  if (error is DioException) {
    return AsyncError("${error.message}", stackTrace);
  }
  return AsyncError("$error", stackTrace);
}

class Api {
  static const String baseImgHead = "";
  static const String baseUrl = "http://www.iyinghua.io/";
  static const String movieUrl = "$baseUrl/37/";
  static const String jcUrl = "$baseUrl/36/";

  static const String newBaseRefer = "image.oume.cc";
  static const String newBaseUrl = "https://www.yinhuadm.cc";
  static const String newSearch = "https://www.yinhuadm.cc/vch";

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
        .onError((error, stackTrace) => Future.error("$error", stackTrace));
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
        item.url = baseUrl + info[1].attributes["href"]!;
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
        var url = baseUrl + query1.attributes["href"]!;
        var query0 = els[i].querySelectorAll("a")[0];
        var episode = query0.text;
        var episodeUrl = query0.attributes["href"];
        week.add(TimeTableData(title, url, episode, episodeUrl));
      }
    }
    return week;
  }

  static Future<AnimeDesData> getAnimeDes(String url) async {
    debugPrint("getAnimeDes = $url");
    if (url.contains(baseUrl)) {
      return getAnimeDesOld(url);
    } else {
      return getAnimeDesNew(url);
    }
  }

  static Future<AnimeDesData> getAnimeDesNew(String url) async {
    var requestUrl = url;
    var future = await (await HttpClient.get()).get(requestUrl);
    var document = parse(future.data);
    AnimeDesData data = AnimeDesData();
    var baseElement = document.getElementsByClassName("module-info-main")[0];
    var title = baseElement.querySelector("div.module-info-heading > h1")!.text;
    List<Tags> tags = [];
    var tagsElement =
        baseElement.getElementsByClassName("module-info-tag-link");
    tags.addAll(tagsElement.map((e) {
      var a = e.querySelector("a")!;
      return Tags(a.text.trim(), a.attributes["href"]);
    }));
    var des = baseElement
        .getElementsByClassName("module-info-introduction-content")[0]
        .querySelector("p")!
        .text
        .trim();
    var logo = document
        .getElementsByClassName("module-item-pic")[0]
        .querySelector("img")!
        .attributes["data-original"];
    var updateTime = baseElement
            .getElementsByClassName("module-info-item-content")
            .lastOrNull
            ?.text
            .trim() ??
        "";
    data
      ..url = requestUrl
      ..title = title
      ..tags = tags
      ..des = des
      ..score = "5.0"
      ..updateTime = updateTime
      ..logo = logo
      ..playListData = getAnimePlayListNew(document);
    return data;
  }

  static Future<AnimeDesData> getAnimeDesOld(String url) async {
    var requestUrl = url;
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
      ..playListData = getAnimePlayListOld(document)
      ..tags = tags;
    return data;
  }

  static AnimePlayListData getAnimePlayList(String url, dom.Document document) {
    if (url.contains(baseUrl)) {
      return getAnimePlayListOld(document);
    } else {
      return getAnimePlayListNew(document);
    }
  }

  static AnimePlayListData getAnimePlayListOld(dom.Document document) {
    var animaPlay = AnimePlayListData();
    List<AnimeDramasData> dramasList = [];
    var elements = document.querySelectorAll("div.movurl > ul");
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
            var url = baseUrl + element.querySelector("a")!.attributes["href"]!;
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
        var url =
            baseUrl + element.querySelector("p.tname > a")!.attributes["href"]!;
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
        var url =
            baseUrl + element.querySelector("h2 > a")!.attributes["href"]!;
        recommends.add(AnimeRecommendData(title, logo, url));
      }
      animaPlay.animeRecommend = recommends;
    }
    return animaPlay;
  }

  static AnimePlayListData getAnimePlayListNew(dom.Document document) {
    var animaPlay = AnimePlayListData();
    List<AnimeDramasData> dramasList = [];
    var module = document
        .getElementsByClassName("module-tab-items-box hisSwiper")[0]
        .querySelectorAll("div");
    var panel1 = document
        .getElementsByClassName("module-list sort-list tab-list his-tab-list");
    debugPrint("panel1 = $panel1");
    var playMap = <int, List<AnimeDramasDetailsData>>{};
    for (int index = 0; index < panel1.length; index++) {
      var element = panel1[index];
      var listLine = element.getElementsByClassName("module-play-list-link");
      var list = <AnimeDramasDetailsData>[];
      for (var element in listLine) {
        var title = element.querySelector("span")!.text;
        var url = newBaseUrl + element.attributes["href"]!;
        list.add(AnimeDramasDetailsData(title, url));
      }
      playMap[index] = list;
    }
    for (int index = 0; index < module.length; index++) {
      var element = module[index];
      var listTile = element.attributes["data-dropdown-value"];
      animaPlay.animeDramas.add(AnimeDramasData()
        ..listTitle = listTile
        ..list = playMap[index] ?? []);
    }
    return animaPlay;
  }

  static Future<String> getAnimePlayUrl(String url) async {
    if(url.contains(baseUrl)){
      return getAnimePlayUrlOld(url);
    }else{
      return getAnimePlayUrlNew(url);
    }
  }

  static Future<String> getAnimePlayUrlNew(String url) async{
    String? playUrl = "";
    printLongText("url = $url");
    try{
      var html = await VideoSniffing.getCustomData(url,"MacPlayer.Html");
      if(html != null){
        var document = parse(html);
        var innerSrc = document.querySelector("iframe")!.attributes["src"];
        if(innerSrc != null){
          playUrl = await VideoSniffing.getResourcesUrl(innerSrc,"index.m3u8");
        }
      }
    }catch(e){
      printLongText("$e");
    }
    return playUrl ??"";
  }
  static Future<String> getAnimePlayUrlOld(String url) async{
    var requestUrl = url;
    var html = await VideoSniffing.getRawHtml(requestUrl);
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
    var moveData = await _getAnimeList(requestUrl, nowPage: nowPage);
    // if (nowPage == 1) {
    //   moveData.movies.insertAll(0, await _getAnimeListByNew(word, nowPage, []));
    // }
    return moveData;
  }

  static Future<AnimeMovieData> _getAnimeList(String url,
      {int nowPage = 1}) async {
    var future = await (await HttpClient.get()).get(url).onError(
        (error, stackTrace) => Future.error(getException(error, stackTrace)));

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
      var url = baseUrl + element.querySelector("h2 > a")!.attributes["href"]!;
      var logo =
          baseImgHead + (element.querySelector("img")!.attributes["src"] ?? "");
      movies.add(AnimeMovieListData(title, logo, url, false));
    }
    return AnimeMovieData(nowPage, pageCount, movies);
  }

  static Future<List<AnimeMovieListData>> _getAnimeListByNew(
      String word, int page, List<AnimeMovieListData> lastList) async {
    var url = "$newSearch$word/page/$page.html";
    var future = await (await HttpClient.get()).get(url).onError(
        (error, stackTrace) => Future.error(getException(error, stackTrace)));

    var document = parse(future.data);
    var itemList =
        document.getElementsByClassName("module-card-item module-item");
    for (var element in itemList) {
      var elesA = element.querySelector("a");
      var hrefUrl = elesA!.attributes["href"];
      var url = newBaseUrl + hrefUrl!;
      var imgEles = elesA
          .getElementsByClassName("module-item-pic")[0]
          .querySelector("img")!;
      var logo = imgEles.attributes["data-original"];
      var title = imgEles.attributes["alt"];
      lastList.add(AnimeMovieListData(title, logo, url, true));
    }

    var pageDiv = document.getElementById("page");
    debugPrint("pageDiv = $pageDiv");
    if (pageDiv != null) {
      var pageDivNext = pageDiv.querySelectorAll("a");
      if (pageDivNext.isNotEmpty) {
        var nextPage = pageDivNext[3];
        var nextHref = nextPage.attributes["href"]!;
        var indexStart = nextHref.lastIndexOf("/") + 1;
        var htmlPage =
            int.parse(nextHref.substring(indexStart, nextHref.length - 5));
        if (htmlPage != page) {
          return _getAnimeListByNew(word, htmlPage, lastList);
        }
      }
    }
    return lastList;
  }

  static Future<AnimeMovieData> getCategory(Pair queryKey,
      {int nowPage = 1}) async {
    var requestUrl = "$baseUrl/";
    requestUrl += _queryName[queryKey.key]![queryKey.index];
    if (nowPage >= 2) {
      requestUrl += "/$nowPage.html";
    }
    return _getAnimeList(requestUrl, nowPage: nowPage);
  }
}
