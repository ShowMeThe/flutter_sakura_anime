

class FactoryTab{

  String url;
  String title;

  FactoryTab(this.url, this.title);
}

class FactoryTabList{

  bool loadMore;
  List<FactoryTabListBean> list;

  FactoryTabList(this.loadMore, this.list);

}



class FactoryTabListBean{

  String url;
  String title;
  String score;
  String img;

  FactoryTabListBean(this.url, this.title, this.score, this.img);
}