import 'dart:async';

import 'package:android_keyboard_listener/android_keyboard_listener.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/bean/hanju_home_data.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/hj_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  late StreamSubscription<dynamic> sub;

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
      debugPrint("nowPage $nowPage");
      var result =
      await HjApi.getSearchPage(editController.text, page: nowPage);
      _canLoadMore = result.loadMore;
      ref.refresh(_showEmpty.notifier).update((state) => false);
      ref.refresh(_showHis.notifier).state = false;
      return result;
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

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    sub.cancel();
    _focusNode.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
          210) {
        if (!_isLoading && _canLoadMore) {
          nowPage++;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SearchAppBar(
          focusNode: _focusNode,
          paddingLeft: 15,
          appBarBackgroundColor: Colors.white,
          textColor: Colors.black,
          hintTextColor: Colors.grey,
          cursorColor: Colors.grey.withAlpha(125),
          controller: editController,
          onChange: (word) {
            ref.refresh(_showHis.notifier).update((state) => word.isNotEmpty);
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
            child: const Padding(
              padding: EdgeInsets.only(left: 12.0),
              child: Icon(
                Icons.arrow_back,
                color: Colors.black,
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
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
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
              ref.refresh(_showEmpty.notifier).state = true;
              if (localList.isNotEmpty) {
                ref.refresh(_showHis.notifier).state = true;
              }
            }
          }),
      body:Consumer(
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
                              var item = _movies[index];
                              Navigator.of(context)
                                  .push(FadeRoute(HjDesPage(item.logo,item.href,item.title,item.score,item.update,heroTag: _HeroTag,)));
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
                                          tag: _movies[index].logo + _HeroTag,
                                          child: Image(
                                            image: ExtendedNetworkImageProvider(
                                              _movies[index].logo,
                                              cache: true,
                                            ),
                                            width: double.infinity,
                                            height: 150,
                                            fit: BoxFit.fitWidth,
                                          )),
                                      Positioned.fill(
                                          top: 130,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.black.withAlpha(45)),
                                            child: Text(
                                              _movies[index].update,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          )),
                                      Positioned.fill(
                                          left: 0,
                                          top: 150,
                                          child: Container(
                                            color: ColorRes.mainColor,
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Center(
                                                child: Text(
                                                  _movies[index].title,
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

  List<Widget> getHisWidget(Iterable<String> str) {
    var list = <Widget>[];
    for (var element in str) {
      list.add(Padding(
        padding: const EdgeInsets.all(5.0),
        child: GestureDetector(
          onTap: () {
            _focusNode.unfocus();
            editController.text = element;
            ref.refresh(_futureProvider);
            ref.refresh(_opacityProvider.notifier).update((state) => 1.0);
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
}
