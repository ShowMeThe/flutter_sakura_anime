import 'package:flutter/cupertino.dart';

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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _focusNode = FocusNode();

    _futureProvider = FutureProvider.autoDispose((ref) async {
      if (editController.text.isEmpty) {
        return null;
      }
      _isLoading = true;
      debugPrint("nowPage $nowPage");
      var result =
          await MeiJuApi.getSearchPage(editController.text, page: nowPage);
      _canLoadMore = result.hasNextPage;
      ref.read(_showEmpty.state).update((state) => false);
      return result;
    });
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
          210) {
        if (!_isLoading && _canLoadMore) {
          nowPage++;
          ref.refresh(_futureProvider);
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
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
            } else {
              ref.read(_showEmpty.state).state = true;
            }
          }),
      body: Consumer(builder: (context, ref, _) {
        var provider = ref.watch(_futureProvider);
        var isEmpty = ref.watch(_showEmpty);
        if (provider.value == null || isEmpty) {
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
    );
  }

  Widget buildWidgetBody(List<MjCategoryItem> list) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      var item = list[index];
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
          child: SizedBox(
              width: double.infinity,
              height: 210,
              child: Card(
                color: ColorRes.mainColor,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0))),
                clipBehavior: Clip.antiAlias,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Hero(
                          tag: item.logo + heroTag,
                          child: Image(
                            image: ExtendedNetworkImageProvider(
                              item.logo,
                              cache: true,
                            ),
                            width: 150,
                            height: double.infinity,
                            fit: BoxFit.fitWidth,
                          )),
                    ),
                    Expanded(
                        child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                item.title,
                                style: TextStyle(
                                    fontSize: item.title.length > 20 ? 12 : 15),
                              )),
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                item.state,
                                style: TextStyle(
                                    fontSize: item.state.length > 20 ? 12 : 15),
                              )),
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                item.realName,
                                style: TextStyle(
                                    fontSize:
                                        item.realName.length > 20 ? 12 : 15),
                              )),
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(
                                item.time,
                                style: TextStyle(
                                    fontSize: item.time.length > 20 ? 12 : 15),
                              )),
                        ],
                      ),
                    ))
                  ],
                ),
              )),
        ),
      );
    }, childCount: list.length));
  }
}
