import 'dart:collection';

import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'anime_desc_page.dart';

class AnimeCategoryPage extends ConsumerStatefulWidget {
  const AnimeCategoryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AnimeCategoryPageState();
}

class AnimeCategoryPageState extends ConsumerState<AnimeCategoryPage> {
  var maxWidth = 0.0;
  var queryMap = HashMap<String, String>();
  var providerMap = HashMap<String, AutoDisposeStateProvider<String>>();
  late AutoDisposeFutureProvider<AnimeMovieData> _futureProvider;
  final List<AnimeMovieListData> _movies = [];
  static const _HeroTag = "des";
  var nowPage = 1;
  var maxPage = 0;
  var _canLoadMore = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    Api.initMap();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _futureProvider = FutureProvider.autoDispose((ref) async {
      _isLoading = true;
      debugPrint("nowPage $nowPage");
      var result = await Api.getCategory(queryMap,nowPage: nowPage);
      maxPage = result.pageCount;
      return result;
    });
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
      if (notification is ScrollUpdateNotification) {
        if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
            210) {
          if (!_isLoading && _canLoadMore) {
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    providerMap.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (maxWidth == 0) {
      maxWidth = MediaQuery.of(context).size.width;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("分类"),
        actions: [
          GestureDetector(
              onTap: () {
                _showBottomModel();
              },
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.search),
              ))
        ],
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

  void _showBottomModel() {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15.0),
                topRight: Radius.circular(15.0))),
        builder: (context) {
          return _buildFilter(context);
        });
  }

  Widget _buildFilter(BuildContext context) {
    return SizedBox(
      height: 550,
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: MaterialButton(
              onPressed: () {
                Navigator.pop(context);
                _canLoadMore = true;
                nowPage = 1;
                ref.refresh(_futureProvider);
              },
              child: const Text(
                "搜索",
                style: TextStyle(fontSize: 18, color: ColorRes.pink400),
              ),
            ),
          ),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: ListView(
              children: buildPairs(Api.map),
            ),
          ))
        ],
      ),
    );
  }

  List<Widget> buildPairs(HashMap<String, List<String>> pair) {
    List<Widget> widgets = [];
    for (var element in pair.entries) {
      widgets
        ..add(Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Text(element.key, style: const TextStyle(fontSize: 21)),
        ))
        ..add(const Divider(
          color: Colors.grey,
          height: 3,
        ))
        ..add(Padding(
          padding: const EdgeInsets.only(top: 18.0),
          child: _buildWrap(element.key, element.value ?? []),
        ));
    }
    return widgets;
  }

  Widget _buildWrap(String key, List<String> list) {
    var provider = providerMap[key];
    if (provider == null) {
      provider = StateProvider.autoDispose((ref) => queryMap[key] ?? "全部");
      providerMap[key] = provider;
    }
    return Consumer(builder: (context, ref, _) {
      ref.watch(provider!);
      return Wrap(
        spacing: 12.0,
        children: _buildChips(key, list, provider),
      );
    });
  }

  List<Widget> _buildChips(String key, List<String> list,
      AutoDisposeStateProvider<String> provider) {
    List<Widget> widgets = [];
    var value = queryMap[key];
    if (value == null) {
      value = "全部";
      queryMap[key] = value;
    }
    for (int index = 0, size = list.length; index < size; index++) {
      var content = list[index];
      var check = value == content;
      widgets.add(ChoiceChip(
        selectedColor: ColorRes.pink300,
        selected: check,
        label: Text(
          content,
          style: TextStyle(color: check ? Colors.white : Colors.black),
        ),
        onSelected: (bool) {
         if(bool){
           queryMap[key] = content;
           ref.watch(provider.notifier).update((state) => content);
         }
        },
      ));
    }
    return widgets;
  }
}
