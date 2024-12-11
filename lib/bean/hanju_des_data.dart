class HjDesData{


  String des;
  List<HjDesPlayData> playList = [];
  List<HjDesPlayPromotion> promotionList = [];

  HjDesData(this.des,this.playList,this.promotionList);

  @override
  String toString() {
    return 'HjDesData{des: $des, playList: $playList}';
  }
}

class HjDesPlayPromotion{
   final String title;
   final String url;
   final String logo;

   HjDesPlayPromotion(this.title, this.url, this.logo);
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