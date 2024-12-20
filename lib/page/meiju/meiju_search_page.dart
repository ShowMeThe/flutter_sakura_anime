import 'dart:async';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/widget/color_size_box.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bean/meiju_category_data.dart';
import '../../util/base_export.dart';
import '../../util/mj_api.dart';
import '../../widget/search_app_bar.dart';
import 'meiju_des_page.dart';

class MjSearchPage extends ConsumerStatefulWidget {
  const MjSearchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MjSearchPageState();
  }
}

class _MjSearchPageState extends ConsumerState<MjSearchPage> {
  var editController = TextEditingController(text: "");
  String heroTag = "MjSearchPage";
  final _opacityProvider = StateProvider.autoDispose((ref) => 0.0);
  final _showEmpty = StateProvider.autoDispose<bool>((ref) => true);
  late FocusNode _focusNode;

  late AutoDisposeFutureProvider<MjCategoryData?> _futureProvider;
  var nowPage = 1;
  var _canLoadMore = true;
  var _isLoading = false;
  final List<MjCategoryItem> _movies = [];
  late AutoDisposeFutureProvider<List<String>> _hisSearchProvider;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  static const SEARCH_HIS = "SEARCH_MJ_HIS";
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
          await MeiJuApi.getSearchPage(editController.text, page: nowPage);
      _canLoadMore = result.hasNextPage;
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

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
          210) {
        if (!_isLoading && _canLoadMore) {
          nowPage++;
          ref.invalidate(_futureProvider);
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return AnnotatedRegion(value: setSystemUi(),child: Scaffold(
      appBar: SearchAppBar(
          focusNode: _focusNode,
          paddingLeft: 15,
          appBarBackgroundColor: theme.colorScheme.background,
          textColor: theme.textTheme.displaySmall!.color,
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
              ref.refresh(_futureProvider);
              saveToHist(word);
            } else {
              ref.refresh(_showEmpty.notifier).state = true;
              if (localList.isNotEmpty) {
                ref.refresh(_showHis.notifier).state = true;
              }
            }
          }),
      body: Consumer(builder: (context, ref, _) {
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
        } else if (provider.value == null || isEmpty) {
          return Container();
        } else {
          if (!provider.isLoading) {
            var data = provider.value!;
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
                    nowPage = 1;
                    _canLoadMore = true;
                    ref.refresh(_futureProvider);
                  },
                ),
                buildWidgetBody(_movies)
              ],
            ),
          );
        }
      }),
    ));
  }

  var providers = <int, AutoDisposeStateProvider<Color>>{};

  Widget buildWidgetBody(List<MjCategoryItem> list) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      var item = list[index];
      var colorProvider = providers[index];
      if (colorProvider == null) {
        colorProvider = StateProvider.autoDispose((ref) => Colors.black);
        providers[index] = colorProvider;
      }
      return Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context).push(FadeRoute(MjDesPage(
              item.logo,
              item.url,
              item.title,
              heroTag: heroTag,
            )));
          },
          child: ColorSizeBox(
            url: item.logo,
            width: double.infinity,
            height: 230,
            callback: (isBlack) {
              if (isBlack) {
                ref
                    .read(colorProvider!.notifier)
                    .update((state) => Colors.white);
              }
            },
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Hero(
                      tag: item.logo + heroTag,
                      child: showImage(context,item.logo, 150, double.infinity)),
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: AutoSizeText(
                            item.title,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 12),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: AutoSizeText(
                            item.state,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 12),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: AutoSizeText(
                            item.realName,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 12),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: AutoSizeText(
                            item.time,
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 12),
                          )),
                    ],
                  ),
                ))
              ],
            ),
          ),
        ),
      );
    }, childCount: list.length));
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
            ref.refresh(_futureProvider);
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
}
