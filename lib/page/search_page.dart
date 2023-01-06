import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/SearchAppBar.dart';

import '../bean/anime_movie_data.dart';
import 'anime_desc_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  var editController = TextEditingController(text: "");
  static const _HeroTag = "des";
  final _opacityProvider = StateProvider.autoDispose((ref) => 0.0);
  late AutoDisposeFutureProvider<AnimeMovieData?> _futureProvider;
  bool _isLoading = false;
  var nowPage = 1;
  var lastPage = 1;
  var maxPage = 0;
  final List<AnimeMovieListData> _movies = [];
  final _showEmpty = StateProvider.autoDispose<bool>((ref) => true);

  @override
  void initState() {
    super.initState();
    _futureProvider = FutureProvider.autoDispose((ref) async {
      if(editController.text.isEmpty){
        ref.read(_showEmpty.state).state = true;
        return null;
      }
      _isLoading = true;
      var result =
          await Api.getSearchAnimeList(editController.text, nowPage: nowPage);
      maxPage = result.pageCount;
      _isLoading = false;
      ref.read(_showEmpty.state).state = false;
      lastPage = nowPage;
      return result;
    });
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent > notification.metrics.pixels &&
          notification.metrics.maxScrollExtent - notification.metrics.pixels <=
              notification.metrics.maxScrollExtent * 1 / 3) {
        if (!_isLoading) {
          _isLoading = true;
          nowPage++;
          lastPage = nowPage;
          if (nowPage <= maxPage) {
            ref.refresh(_futureProvider);
          }
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    editController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
          paddingLeft: 15,
          controller: editController,
          onChange: (word) {
            if (word.isNotEmpty) {
              ref.read(_opacityProvider.state).update((state) => 1.0);
            } else {
              ref.read(_opacityProvider.state).update((state) => 0.0);
            }
          },
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
          suffix: Consumer(
            builder: (context, ref, _) {
              var opacity = ref.watch(_opacityProvider);
              return GestureDetector(
                onTap: () {
                  if (opacity != 0.0) {
                    editController.clear();
                    ref.read(_opacityProvider.state).update((state) => 0.0);
                    ref.read(_showEmpty.state).state = true;
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: opacity,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          (word) {
            if (word.isNotEmpty) {
              ref.refresh(_futureProvider);
            } else {
              ref.read(_showEmpty.state).state = true;
            }
          }),
      body: Consumer(
        builder: (context, ref, _) {
          var showEmpty = ref.watch(_showEmpty);
          var provider = ref.watch(_futureProvider);
          if (provider.value == null || showEmpty) {
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
                      if (nowPage != lastPage) {
                        ref.refresh(_futureProvider);
                      }
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
                                          child: Image(
                                            image: ExtendedNetworkImageProvider(
                                              _movies[index].logo!,
                                              cache: true,
                                            ),
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
}
