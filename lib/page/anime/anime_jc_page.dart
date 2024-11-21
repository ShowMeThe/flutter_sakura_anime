import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/bean/anime_movie_data.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/load_refresh_indicator.dart';

import '../../widget/color_container.dart';
import 'anime_desc_page.dart';

class AnimeJcPage extends ConsumerStatefulWidget {
  const AnimeJcPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimeJcPageState();
}

class _AnimeJcPageState extends ConsumerState<AnimeJcPage> {
  late AutoDisposeFutureProvider<AnimeMovieData> _futureProvider;
  static const _HeroTag = "des";
  var nowPage = 1;
  var maxPage = 0;
  var _canLoadMore = true;
  var _isLoading = false;
  final List<AnimeMovieListData> _movies = [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _futureProvider = FutureProvider.autoDispose((ref) async {
      _isLoading = true;
      debugPrint("nowPage $nowPage");
      var result = await Api.getJCAnimeList(nowPage: nowPage);
      maxPage = result.pageCount;
      return result;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
          210) {
        if (!_isLoading && _canLoadMore) {
          nowPage++;
          debugPrint("load more $nowPage");
          if (nowPage <= maxPage) {
            ref.invalidate(_futureProvider);
          } else {
            _canLoadMore = false;
          }
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text("OVA" ,style: theme.textTheme.displayMedium,),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          var provider = ref.watch(_futureProvider);
          if (provider.value == null) {
            return buildLoadingBody();
          } else {
            var data = provider.value!;
            if (!provider.isLoading) {
              if (nowPage == 1) {
                _movies.clear();
              }
              _movies.addAll(data.movies);
              debugPrint("${_movies.length}");
              _isLoading = false;
            }
            return NotificationListener<ScrollNotification>(
              onNotification: _handleLoadMoreScroll,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      _canLoadMore = true;
                      debugPrint("onRefresh");
                      nowPage = 1;
                      ref.invalidate(_futureProvider);
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
                              Navigator.of(context).push(FadeRoute(AnimeDesPage(
                                url!,
                                _movies[index].logo!,
                                heroTag: _HeroTag,
                              )));
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
                                          tag: _movies[index].logo! + _HeroTag,
                                          child: showImage(context,
                                            _movies[index].logo!,
                                            double.infinity,
                                            150,
                                          )),
                                      Expanded(
                                          child: ColorContainer(
                                        url: _movies[index].logo!,
                                        baseColor: ColorRes.mainColor,
                                        title: _movies[index].title!,
                                      ))
                                    ],
                                  ),
                                )),
                          ),
                        );
                      },
                          addAutomaticKeepAlives: false,
                          childCount: _movies.length),
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

  Widget buildLoadingBody() {
    return GridView.builder(
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.55),
        itemCount: 40,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
            child: SizedBox(
                width: 90,
                height: double.infinity,
                child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      const FadeShimmer(
                          height: 150,
                          width: double.infinity,
                          radius: 0,
                          millisecondsDelay: 50,
                          fadeTheme: FadeTheme.light),
                      Expanded(
                          child: Container(
                        color: ColorRes.mainColor,
                        child: const FadeShimmer(
                            height: double.infinity,
                            width: double.infinity,
                            radius: 0,
                            millisecondsDelay: 50,
                            fadeTheme: FadeTheme.light),
                      ))
                    ],
                  ),
                )),
          );
        });
  }
}
