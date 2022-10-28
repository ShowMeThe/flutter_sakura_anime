

class HomeData{

  late List<HomeTimeTable> homeTimeTable;

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
