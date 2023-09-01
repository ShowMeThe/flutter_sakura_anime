import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/bean/hanju_home_data.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/hj_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widget/color_container.dart';
import '../../widget/search_app_bar.dart';
import 'hanju_des_page.dart';

class HanjuSearchPage extends ConsumerStatefulWidget {
  const HanjuSearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HanjuSearchState();
}

class _HanjuSearchState extends ConsumerState {
  var editController = TextEditingController(text: "");
  final String _HeroTag = "_HanjuSearchState";
  final _opacityProvider = StateProvider.autoDispose((ref) => 0.0);
  final _showEmpty = StateProvider.autoDispose<bool>((ref) => true);
  late FocusNode _focusNode;

  final List<HjHomeDataItem> _movies = [];
  var nowPage = 1;
  var _canLoadMore = true;
  var _isLoading = false;

  late AutoDisposeFutureProvider<HjHomeData?> _futureProvider;

  late AutoDisposeFutureProvider<List<String>> _hisSearchProvider;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const SEARCH_HIS = "SEARCH_HJ_HIS";
  var localList = <String>[];
  final _showHis = StateProvider.autoDispose<bool>((ref) => true);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _focusNode = FocusNode();
    _hisSearchProvider = FutureProvider.autoDispose<List<String>>((ref) async {
      localList = (await _prefs).getStringList(SEARCH_HIS) ?? <String>[];
      return localList;
    });

    _futureProvider = FutureProvider.autoDispose((ref) async {
      if (editController.text.isEmpty) {
        return null;
      }
      _isLoading = true;
      var result =
          await HjApi.getSearchPage(editController.text, page: nowPage);
      // _canLoadMore = result.loadMore;
      ref.refresh(_showEmpty.notifier).update((state) => false);
      ref.refresh(_showHis.notifier).state = false;
      return result;
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNode.dispose();
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    // if (notification is ScrollUpdateNotification) {
    //   if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
    //       210) {
    //     if (!_isLoading && _canLoadMore) {
    //       nowPage++;
    //     }
    //   }
    // }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: setSystemUi(),
        child: Scaffold(
          appBar: SearchAppBar(
              focusNode: _focusNode,
              paddingLeft: 15,
              appBarBackgroundColor: theme.colorScheme.background,
              textColor: theme.textTheme.displaySmall!.color,
              hintTextColor: Colors.grey,
              cursorColor: Colors.grey.withAlpha(125),
              controller: editController,
              onChange: (word) {
                ref
                    .refresh(_showHis.notifier)
                    .update((state) => word.isNotEmpty);
                if (word.isNotEmpty) {
                  ref.refresh(_opacityProvider.notifier).update((state) => 1.0);
                } else {
                  ref.refresh(_opacityProvider.notifier).update((state) => 0.0);
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
                        ref
                            .refresh(_opacityProvider.notifier)
                            .update((state) => 0.0);
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
              var provider = ref.watch(_futureProvider);
              var isEmpty = ref.watch(_showEmpty);
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
                            children: getHisWidget(searchList.reversed, theme),
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
                                Text("删除历史记录",
                                    style: theme.textTheme.titleSmall)
                              ],
                            ),
                          ),
                        )
                      ],
                    );
                  }
                });
              } else if (provider.value == null || isEmpty) {
                return Container();
              } else {
                var data = provider.value!;
                if (!provider.isLoading) {
                  if (nowPage == 1) {
                    _movies.clear();
                  }
                  _movies.addAll(data.list);
                  _isLoading = false;
                }
                return NotificationListener<ScrollNotification>(
                  onNotification: _handleLoadMoreScroll,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      CupertinoSliverRefreshControl(
                        onRefresh: () async {
                          // _canLoadMore = true;
                          // debugPrint("onRefresh");
                          // nowPage = 1;
                          // ref.refresh(_futureProvider);
                        },
                      ),
                      SliverGrid(
                          delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                  left: 2.0, top: 2.0, bottom: 2.0),
                              child: GestureDetector(
                                onTap: () {
                                  var item = _movies[index];
                                  Navigator.of(context)
                                      .push(FadeRoute(HjDesPage(
                                    item.logo,
                                    item.href,
                                    item.title,
                                    item.score,
                                    item.update,
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
                                      child: Stack(
                                        children: [
                                          Hero(
                                              tag:
                                                  "${_movies[index].logo}$_HeroTag$index",
                                              child: showImage(
                                                _movies[index].logo,
                                                double.infinity,
                                                150,
                                              )),
                                          Positioned.fill(
                                              top: 130,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withAlpha(45)),
                                                child: Text(
                                                  _movies[index].update,
                                                  textAlign: TextAlign.right,
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )),
                                          Positioned.fill(
                                              left: 0,
                                              top: 150,
                                              child: Container(
                                                color: ColorRes.mainColor,
                                                child: ColorContainer(
                                                  url: _movies[index].logo,
                                                  baseColor: ColorRes.mainColor,
                                                  title: _movies[index].title,
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
        ));
  }

  List<Widget> getHisWidget(Iterable<String> str, ThemeData theme) {
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
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
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
}
