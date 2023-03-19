class HjDesData{


  String des;
  List<HjDesPlayData> playList = [];

  HjDesData(this.des,this.playList);

  @override
  String toString() {
    return 'HjDesData{des: $des, playList: $playList}';
  }
}

class HjDesPlayData{

  final String title;
  List<HjDesPlayChapter> chapterList = [];

  HjDesPlayData(this.title, this.chapterList);

  @override
  String toString() {
    return 'HjDesPlayData{title: $title, chapterList: $chapterList}';
  }
}

class HjDesPlayChapter{
  String title;
  String url;

  HjDesPlayChapter(this.title, this.url);

  @override
  String toString() {
    return 'HjDesPlayChapter{title: $title, url: $url}';
  }
}