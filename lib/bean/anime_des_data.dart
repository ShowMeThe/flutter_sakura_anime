

import 'anime_drams_data.dart';

class AnimeDesData{

  String? title;
  String? url;
  String? des;
  String? score;
  String? logo;
  String? updateTime;
  List<Tags> tags = [];
  AnimePlayListData? playListData;

  @override
  String toString() {
    return 'AnimeDesData{title: $title, url: $url, des: $des, score: $score, logo: $logo, updateTime: $updateTime, tags: $tags, playListData: $playListData}';
  }
}

class Tags{

  final String title;
  final String? url;

  Tags(this.title, this.url);

  @override
  String toString() {
    return 'Tags{title: $title, url: $url}';
  }
}

