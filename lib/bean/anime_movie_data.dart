


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

  AnimeMovieListData(this.title, this.logo, this.url);

  @override
  String toString() {
    return 'AnimeMovieListData{title: $title, logo: $logo, url: $url}';
  }
}