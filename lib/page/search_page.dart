import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/search_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bean/anime_movie_data.dart';
import 'anime_desc_page.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  var editController = TextEditingController(text: "");
  static const _HeroTag = "search";
  static const SEARCH_HIS = "SEARCH_HIS";
  final _opacityProvider = StateProvider.autoDispose((ref) => 0.0);
  late AutoDisposeFutureProvider<AnimeMovieData?> _futureProvider;
  var _canLoadMore = true;
  var _isLoading = false;
  var nowPage = 1;
  var maxPage = 0;
  final List<AnimeMovieListData> _movies = [];
  final _showEmpty = StateProvider.autoDispose<bool>((ref) => true);
  final _showHis = StateProvider.autoDispose<bool>((ref) => true);
  late AutoDisposeFutureProvider<List<String>> _hisSearchProvider;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  var localList = <String>[];

  @override
  void initState() {
    super.initState();
    _futureProvider = FutureProvider.autoDispose((ref) async {
      if (editController.text.isEmpty) {
        ref
            .read(_showHis.state)
            .state = true;
        ref
            .read(_showEmpty.state)
            .state = false;
        return null;
      }
      _isLoading = true;
      var result =
      await Api.getSearchAnimeList(editController.text, nowPage: nowPage);
      maxPage = result.pageCount;
      ref
          .read(_showHis.state)
          .state = false;
      ref
          .read(_showEmpty.state)
          .state = false;
      return result;
    });

    _hisSearchProvider = FutureProvider.autoDispose<List<String>>((ref) async {
      localList = (await _prefs).getStringList(SEARCH_HIS) ?? <String>[];
      return localList;
    });
  }

  void saveToHist(String newKey) async {
    if (!localList.contains(newKey)) {
      localList.add(newKey);
      (await _prefs).setStringList(SEARCH_HIS, localList);
    }
  }

  void clearHist() async {
    localList.clear();
    ref.watch(_showHis.state).update((state) => false);
    (await _prefs).remove(SEARCH_HIS);
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
          210) {
        if (!_isLoading) {
          _isLoading = true;
          nowPage++;
          if (nowPage <= maxPage) {
            ref.refresh(_futureProvider);
          } else {
            _canLoadMore = false;
          }
        }
      }
    }
    return false;
  }

  List<Widget> getHisWidget(Iterable<String> str) {
    var list = <Widget>[];
    for (var element in str) {
      list.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: GestureDetector(
          onTap: () {
            editController.text = element;
            ref.refresh(_futureProvider);
            ref.read(_opacityProvider.state).update((state) => 1.0);
            editController.selection =
                TextSelection.collapsed(offset: element.length);
          },
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(color: ColorRes.pink400, width: 2.0)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  element,
                  style: const TextStyle(color: ColorRes.pink600),
                ),
              )),
        ),
      ));
    }
    return list;
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
              ref.read(_showHis.state).update((state) => false);
            } else {
              ref.read(_opacityProvider.state).update((state) => 0.0);
              ref.read(_showHis.state).update((state) => true);
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
                    ref
                        .read(_showEmpty.state)
                        .state = true;
                    if (localList.isNotEmpty) {
                      ref
                          .read(_showHis.state)
                          .state = true;
                    }
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
              saveToHist(word);
            } else {
              ref
                  .read(_showEmpty.state)
                  .state = true;
              if (localList.isNotEmpty) {
                ref
                    .read(_showHis.state)
                    .state = true;
              }
            }
          }),
      body: Consumer(
        builder: (context, ref, _) {
          var showEmpty = ref.watch(_showEmpty);
          var provider = ref.watch(_futureProvider);
          var showHis = ref.watch(_showHis);
          if (showHis) {
            return Consumer(builder: (context, ref, _) {
              var searchList = ref
                  .watch(_hisSearchProvider)
                  .value;
              if (searchList == null || searchList.isEmpty) {
                return Container();
              } else {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        "搜索历史",
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Wrap(
                        children: getHisWidget(searchList.reversed),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: () {
                          clearHist();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.delete,
                              color: Colors.pink,
                            ),
                            Text("删除历史记录")
                          ],
                        ),
                      ),
                    )
                  ],
                );
              }
            });
          } else if (provider.value == null || showEmpty) {
            return Container();
          } else {
            if (!provider.isLoading) {
              var data = provider.value!;
              if (nowPage == 1) {
                _movies.clear();
              }
              _movies.addAll(data.movies);
              _isLoading = false;
            }
            return NotificationListener<ScrollNotification>(
              onNotification: _handleLoadMoreScroll,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  CupertinoSliverRefreshControl(
                    onRefresh: () async {
                      nowPage = 1;
                      _canLoadMore = true;
                      ref.refresh(_futureProvider);
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
                                              padding: const EdgeInsets.all(
                                                  8.0),
                                              child: Center(
                                                child: Text(
                                                  _movies[index].title!,
                                                  style: const TextStyle(
                                                    fontSize: 10.0,
                                                    overflow: TextOverflow
                                                        .ellipsis,
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
