

class MjDesData{


  List<MjDesPlayData> playList = [];

  MjDesData(this.playList);

}

class MjDesPlayData{
    String title;
    List<MjDesPlayChapter> chapterList;

    MjDesPlayData(this.title, this.chapterList);

    @override
  String toString() {
    return 'MjDesPlayData{title: $title, playList $chapterList}';
  }
}


class MjDesPlayChapter{
  String title;
  String url;

  MjDesPlayChapter(this.title, this.url);

  @override
  String toString() {
    return 'MjDesPlayItem{title: $title, url: $url}';
  }
}