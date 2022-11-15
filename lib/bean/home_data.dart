class HomeData {
  late List<HomeTimeTable> homeTimeTable;
  late List<HomeListData> homeList;
}

class HomeListData {
  String title = "";
  String moreUrl = "";
  List<HomeListItem> data = [];

  @override
  String toString() {
    return 'HomeListData{title: $title, moreUrl: $moreUrl, data: $data}';
  }
}

class HomeListItem {
  String? title;
  String? img;
  String? url;
  String? episodes;

  @override
  String toString() {
    return 'HomeListItem{title: $title, img: $img, url: $url, episodes: $episodes}';
  }
}

class HomeTimeTable {
  String week = "";
  List<TimeTableData> timeData = [];
}

class TimeTableData {
  String title;
  String? url;
  String episode;

  String? episodeUrl;

  TimeTableData(this.title, this.url, this.episode, this.episodeUrl);
}
