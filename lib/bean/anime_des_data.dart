

class AnimeDesData{

  String? title;
  String? url;
  String? des;
  String? score;
  String? logo;
  List<Tags> tags = [];

  @override
  String toString() {
    return 'AnimeDesData{title: $title, url: $url, des: $des, score: $score, logo: $logo, tags: $tags}';
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