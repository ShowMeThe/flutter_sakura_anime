

class MjHomeData{

  final String title;
  final String url;
  final List<MjHomeListData> list;

  MjHomeData(this.title, this.url,this.list);

  @override
  String toString() {
    return 'MjHomeData{title: $title, list: $list}';
  }
}



class MjHomeListData {
  String title = "";
  String img = "";
  String chapter = "";
  String url = "";


  MjHomeListData(this.title, this.url,this.img, this.chapter);

  @override
  String toString() {
    return 'MjHomeData{title: $title, img: $img, chapter: $chapter}';
  }
}