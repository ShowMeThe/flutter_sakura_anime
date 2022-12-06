import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/bean/anime_movie_data.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/load_refresh_indicator.dart';

import 'anime_desc_page.dart';

class AnimeMoviePage extends ConsumerStatefulWidget {
  const AnimeMoviePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimeMoviePageState();
}

class _AnimeMoviePageState extends ConsumerState<AnimeMoviePage> {
  late AutoDisposeFutureProvider<AnimeMovieData> _futureProvider;
  bool _isLoading = false;
  var nowPage = 1;
  var maxPage = 0;
  final List<AnimeMovieListData> _movies = [];

  @override
  void initState() {
    super.initState();
    _futureProvider = FutureProvider.autoDispose((ref) async {
      _isLoading = true;
      debugPrint("$nowPage");
      var result = await Api.getMovieList(nowPage: nowPage);
      maxPage = result.pageCount;
      _isLoading = false;
      return result;
    });
    ref.refresh(_futureProvider);
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent > notification.metrics.pixels &&
          notification.metrics.maxScrollExtent - notification.metrics.pixels <=
              notification.metrics.maxScrollExtent * 1 / 3) {
        if (!_isLoading) {
          _isLoading = true;
          nowPage++;
          if (nowPage <= maxPage) {
            ref.refresh(_futureProvider);
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("电影"),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          var provider = ref.watch(_futureProvider);
          if (provider.value == null) {
            return Container();
          } else {
            var data = provider.value!;
            if (nowPage == 1) {
              _movies.clear();
            }
            _movies.addAll(data.movies);
            return NotificationListener<ScrollNotification>(
              onNotification: _handleLoadMoreScroll,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      nowPage = 1;
                      return ref.refresh(_futureProvider);
                    },
                  ),
                  SliverGrid(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(
                              left: 2.0, top: 2.0, bottom: 2.0),
                          child: GestureDetector(
                            onTap: () {
                              var url = _movies[index].url;
                              Navigator.of(context).push(FadeRoute(
                                  AnimeDesPage(url!, _movies[index].logo!)));
                            },
                            child: SizedBox(
                                width: 90,
                                height: double.infinity,
                                child: Card(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(12.0))),
                                  clipBehavior: Clip.antiAlias,
                                  child: Column(
                                    children: [
                                      Hero(
                                          tag: _movies[index].logo!,
                                          child: Image(
                                            image: ExtendedNetworkImageProvider(
                                                _movies[index].logo!, cache:true,),
                                            width: double.infinity,
                                            height: 150,
                                            fit: BoxFit.fitWidth,
                                          )),
                                      Expanded(
                                          child: Container(
                                        color: ColorRes.mainColor,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Center(
                                            child: Text(
                                              _movies[index].title!,
                                              style: const TextStyle(
                                                fontSize: 10.0,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 2,
                                            ),
                                          ),
                                        ),
                                      ))
                                    ],
                                  ),
                                )),
                          ),
                        );
                      }, childCount: _movies.length),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 5,
                              mainAxisSpacing: 5,
                              childAspectRatio: 0.55))
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
