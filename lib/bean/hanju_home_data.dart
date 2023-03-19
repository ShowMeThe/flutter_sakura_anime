
class HjHomeData{

  var loadMore = false;
  var list = <HjHomeDataItem>[];

  HjHomeData(this.loadMore,this.list);

  @override
  String toString() {
    return 'HjHomeData{loadMore: $loadMore, list: $list}';
  }
}

class HjHomeDataItem{
  String href;
  String title;
  String logo;
  String score;
  String update;

  HjHomeDataItem(this.title,this.logo,this.href,this.score,this.update);

  @override
  String toString() {
    return 'HjHomeDataItem{href: $href, title: $title, logo: $logo, score: $score, update: $update}';
  }
}