

class AnimePlayListData{

  List<AnimeRecommendData> animeSeasons =[];
  List<AnimeRecommendData> animeRecommend =[];
  List<AnimeDramasData> animeDramas = [];

}



class AnimeRecommendData {
  String? title;
  String? logo;
  String? url;

  AnimeRecommendData(this.title, this.logo, this.url);
}

class AnimeDramasData {
  String? listTitle;
  List<AnimeDramasDetailsData> list = [];
}

class AnimeDramasDetailsData {
  String? title;
  String? url;

  AnimeDramasDetailsData(this.title, this.url);
}
