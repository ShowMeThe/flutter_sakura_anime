import 'dart:async';

import 'package:android_keyboard_listener/android_keyboard_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/color_container.dart';
import 'package:flutter_sakura_anime/widget/search_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'anime_desc_page.dart';

class AnimeSearchPage extends ConsumerStatefulWidget {
  const AnimeSearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<AnimeSearchPage> {
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
  late FocusNode _focusNode;
  late StreamSubscription<dynamic> sub;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _focusNode = FocusNode();

    _futureProvider = FutureProvider.autoDispose((ref) async {
      _isLoading = true;
      if(editController.text.isEmpty) return null;
      var result =
          await Api.getSearchAnimeList(editController.text, nowPage: nowPage);

      maxPage = result.pageCount;
      ref.watch(_showHis.notifier).state = false;
      ref.watch(_showEmpty.notifier).state = false;
      return result;
    });

    _hisSearchProvider = FutureProvider.autoDispose<List<String>>((ref) async {
      localList = (await _prefs).getStringList(SEARCH_HIS) ?? <String>[];
      return localList;
    });

    sub = AndroidKeyboardListener.onChange((visible) async {
      if(!visible){
        await Future.delayed(const Duration(milliseconds: 350));
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
      }
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
    ref.watch(_showHis.notifier).update((state) => false);
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
            ref.invalidate(_futureProvider);
          } else {
            _canLoadMore = false;
          }
        }
      }
    }
    return false;
  }

  List<Widget> getHisWidget(Iterable<String> str,ThemeData theme) {
    var list = <Widget>[];
    for (var element in str) {
      list.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: GestureDetector(
          onTap: () {
            _focusNode.unfocus();
            editController.text = element;
            ref.invalidate(_futureProvider);
            ref.refresh(_opacityProvider.notifier).update((state) => 1.0);
            editController.selection =
                TextSelection.collapsed(offset: element.length);
          },
          child: Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(5.0)),
                  border: Border.all(color: theme.cardColor, width: 2.0)),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  element,
                  style: TextStyle(color: theme.cardColor),
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
    sub.cancel();
    _focusNode.dispose();
    editController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: SearchAppBar(
          focusNode: _focusNode,
          paddingLeft: 15,
          appBarBackgroundColor: theme.primaryColor,
          textColor: theme.textTheme.displaySmall!.color,
          hintTextColor: Colors.grey,
          cursorColor: Colors.grey.withAlpha(125),
          controller: editController,
          onChange: (word) {
            if (word.isNotEmpty) {
              ref.refresh(_opacityProvider.notifier).update((state) => 1.0);
              ref.refresh(_showHis.notifier).update((state) => false);
            } else {
              ref.refresh(_opacityProvider.notifier).update((state) => 0.0);
              ref.refresh(_showHis.notifier).update((state) => true);
            }
          },
          leading: GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Padding(
              padding: const EdgeInsets.only(left: 12.0),
              child: Icon(
                Icons.arrow_back,
                color: theme.cardColor,
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
                    ref.refresh(_opacityProvider.notifier).update((state) => 0.0);
                    ref.refresh(_showEmpty.notifier).state = true;
                    if (localList.isNotEmpty) {
                      ref.refresh(_showHis.notifier).state = true;
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: opacity,
                    child: Icon(
                      Icons.close,
                      color: theme.cardColor,
                    ),
                  ),
                ),
              );
            },
          ),
          (word) {
            if (word.isNotEmpty) {
              ref.invalidate(_futureProvider);
              saveToHist(word);
            } else {
              ref.refresh(_showEmpty.notifier).state = true;
              if (localList.isNotEmpty) {
                ref.refresh(_showHis.notifier).state = true;
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
              var searchList = ref.watch(_hisSearchProvider).value;
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
                        children: getHisWidget(searchList.reversed,theme),
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
                          children: [
                            Icon(
                              Icons.delete,
                              color: theme.cardColor,
                            ),
                            Text("删除历史记录",style: theme.textTheme.titleSmall,)
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
                                          child: showImage(
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
}
