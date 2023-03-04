import 'dart:collection';

import 'package:flutter_sakura_anime/bean/anime_movie_data.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:html/dom.dart' as dom;
import 'package:video_sniffing/video_sniffing.dart';

import '../bean/anime_drams_data.dart';

class Api {
  static const String baseImgHead = "https:";
  static const String baseUrl = "https://www.yhpdm.com";
  static const String movieUrl = "$baseUrl/list/?genre=剧场版";
  static const String jcUrl = "$baseUrl/list/?gere=OVA";
  static const String searchUrl = "$baseUrl/s_all?";
  static const String categoryUrl = "$baseUrl/list/";

  static HomeData? homeData;
  static HashMap<String, List<String>> map = HashMap();
  static HashMap<String, String> _queryName = HashMap();

  static void initMap() {
    if (map.isEmpty) {
      map["地域"] = ["全部", "日本", "美国", "欧美"];
      map["年份"] = [
        "全部",
        "2023",
        "2022",
        "2021",
        "2020",
        "2019",
        "2018",
        "2017",
        "2016"
      ];
      map["季度"] = ["全部", "1", "4", "7", "10"];
      map["类型"] = [
        "全部",
        "搞笑",
        "运动",
        "励志",
        "热血",
        "战斗",
        "竞技",
        "校园",
        "青春",
        "爱情",
        "冒险",
        "后宫",
        "百合",
        "治愈",
        "萝莉",
        "魔法",
        "悬疑",
        "推理",
        "奇幻",
        "科幻",
        "游戏",
        "神魔",
        "恐怖",
        "血腥",
        "机战",
        "战争",
        "犯罪",
        "历史",
        "社会",
        "职场",
        "剧情",
        "伪娘",
        "耽美",
        "童年",
        "教育",
        "亲子",
        "真人",
        "歌舞",
        "肉番",
        "美少女",
        "轻小说",
        "吸血鬼",
        "女性向",
        "泡面番",
        "欢乐向"
      ];

      _queryName["地域"] = "region";
      _queryName["年份"] = "year";
      _queryName["季度"] = "season";
      _queryName["类型"] = "label";
    }
  }

  static Future<HomeData> getHomeData() async {
    var future = await (await HttpClient.get().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(baseUrl)
        .catchError((err) {
      debugPrint("err $err");
    });
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
    for(int i = 0; i<tabs.length; i++){
      var tabName = tabs[i].text;
      if(tabName.isNotEmpty && tabName != '下载列表'){
        List<AnimeDramasDetailsData> details = [];
        var elementChild = elements[i].querySelectorAll("li");
        if(elementChild.isNotEmpty){
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
          var logo = baseImgHead + (element.querySelector("img")?.attributes["src"]??"");
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
          var logo = baseImgHead + (element.querySelector("img")?.attributes["src"]??"");
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
    var document = parse(html);
    var iFrame = document.getElementById("m_yh_playfram");
    if (iFrame != null) {
      var playerUrl = iFrame.attributes["src"]!;
      playerUrl = baseUrl + playerUrl;
      var reg = RegExp("[?&]+url=([^&]*)");
      var matcherUrl = reg
          .stringMatch(playerUrl)!
          .replaceAll(RegExp("/[+]{1}/g"), " ")
          .replaceAll("&url=", "");
      var dvpt = DateTime.now().millisecond / 1000 / 1800;
      matcherUrl = Uri.decodeComponent(matcherUrl);
      var host = "www.yhpdm.com".codeUnits;
      var hostAndDvpt = "";
      for (int i = 0; i < host.length; i++) {
        hostAndDvpt = hostAndDvpt + host[i].toString();
      }
      var dvptStr = dvpt.toString() + hostAndDvpt;
      var xup = "&";
      if (!matcherUrl.contains("?")) {
        xup = "?";
      }
      matcherUrl = "$matcherUrl${xup}dvpt=$dvptStr";
      return matcherUrl;
    }
    return "";
  }

  static Future<AnimeMovieData> getJCAnimeList({int nowPage = 1}) async {
    var page = nowPage - 1;
    var requestUrl = "$movieUrl&pagesize=24&pageindex=${page}";
    return _getAnimeList(requestUrl, false, nowPage: nowPage);
  }

  static Future<AnimeMovieData> getMovieAnimeList({int nowPage = 1}) async {
    var page = nowPage - 1;
    var requestUrl = "$jcUrl&pagesize=24&pageindex=${page}";
    return _getAnimeList(requestUrl, false, nowPage: page);
  }

  static Future<AnimeMovieData> getSearchAnimeList(String word,
      {int nowPage = 1}) async {
    var page = nowPage - 1;
    var requestUrl = "${searchUrl}kw=$word&pagesize=24&pageindex=$page";
    return _getAnimeList(requestUrl, true, nowPage: nowPage);
  }

  static Future<AnimeMovieData> _getAnimeList(String url, bool isSearch,
      {int nowPage = 1}) async {
    var future = await (await HttpClient.get()).get(url).catchError((onError) {
      debugPrint("$onError");
    });
    //debugPrint("future = ${future}");
    var document = parse(future.data);
    var pageQuery = document.querySelectorAll("div.pages > a");
    var pageCount = 1;

    if (pageQuery.isNotEmpty) {
      var pageCountUrl = pageQuery.last.attributes["href"];
      if (pageCountUrl != null) {
        var searchText = "pageindex=";
        var charIndex = pageCountUrl.lastIndexOf(searchText);
        var page = pageCountUrl.substring(
            charIndex + searchText.length, pageCountUrl.length);
        pageCount = int.parse(page) + 1;
      }
    }

    List<AnimeMovieListData> movies = [];
    var query = document.querySelectorAll("div.lpic > ul > li");
    debugPrint("le = ${query.length}");
    for (var element in query) {
      var title = element.querySelector("h2")!.text.trimLeft();
      debugPrint("get title ${title}");
      var url = element.querySelector("h2 > a")!.attributes["href"];
      var logo =
          baseImgHead + (element.querySelector("img")!.attributes["src"] ?? "");
      movies.add(AnimeMovieListData(title, logo, url));
    }

    return AnimeMovieData(nowPage, pageCount, movies);
  }

  static Future<AnimeMovieData> getCategory(HashMap<String, String> queryMap,
      {int nowPage = 1}) async {
    var requestUrl = "$categoryUrl?";
    var queryEnd = "";
    for (var element in queryMap.entries) {
      if (element.value != "全部") {
        queryEnd += "${_queryName[element.key]}=${element.value}&";
      }
    }
    requestUrl = "$requestUrl${queryEnd}pagesize=24&pageindex=${nowPage - 1}";
    debugPrint("requestUrl = $requestUrl");
    var future =
        await (await HttpClient.get()).get(requestUrl).catchError((onError) {
      debugPrint("$onError");
    });
    var document = parse(future.data);
    var pageQuery = document.querySelectorAll("div.pages > a");
    var pageCount = 1;

    if (pageQuery.isNotEmpty) {
      var pageCountUrl = pageQuery.last.attributes["href"];
      if (pageCountUrl != null) {
        var searchText = "pageindex=";
        var charIndex = pageCountUrl.lastIndexOf(searchText);
        var page = pageCountUrl.substring(
            charIndex + searchText.length, pageCountUrl.length);
        pageCount = int.parse(page) + 1;
      }
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
}
