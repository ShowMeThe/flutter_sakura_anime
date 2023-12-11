


class AnimeMovieData{

  final int page;
  final int pageCount;
  final List<AnimeMovieListData> movies;

  AnimeMovieData(this.page, this.pageCount, this.movies);
}


class AnimeMovieListData{
  String? title;
  String? logo;
  String? url;
  bool isNew = false;

  AnimeMovieListData(this.title, this.logo, this.url,this.isNew);

  @override
  String toString() {
    return 'AnimeMovieListData{title: $title, logo: $logo, url: $url, isNew: $isNew}';
  }
}