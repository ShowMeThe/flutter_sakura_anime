
class HjHomeData{

  var loadMore = false;
  var list = <HjHomeDataItem>[];

  HjHomeData(this.loadMore,this.list);

}

class HjHomeDataItem{
  String href;
  String title;
  String logo;
  String score;

  HjHomeDataItem(this.title,this.logo,this.href,this.score);
}