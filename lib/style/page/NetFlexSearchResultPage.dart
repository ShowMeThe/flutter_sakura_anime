import 'dart:async';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:video_sniffing/video_sniffing_platform_interface.dart';
import '../router/AppRouter.gr.dart';

@RoutePage()
class NetFlexSearchResultPage extends ConsumerStatefulWidget {
  final String keyWord;

  const NetFlexSearchResultPage({required this.keyWord, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetFlexSearchResultPageState();
}

class _NetFlexSearchResultPageState
    extends ConsumerState<NetFlexSearchResultPage> {
  static const heroTag = "SearchPage";
  var _canLoadMore = true;
  var _isLoading = false;
  var nowPage = 1;
  late final ScrollController _controller = ScrollController();
  final _currentList = <FactoryTabListBean>[];
  late final _listDataProvider = FutureProvider.autoDispose((_) async {
    var result = await FactoryApi.getSearch(widget.keyWord, page: nowPage);
    return result;
  });

  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamSubscription =
        VideoSniffingPlatform.instance.watchCloudflareResult().listen((data) {
          if (data is bool) {
            if (data) {
              debugPrint("watchCloudflareResult refresh}");
              nowPage = 1;
              ref.invalidate(_listDataProvider);
            }
          }
        });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _streamSubscription.cancel();
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
          210) {
        if (!_isLoading && _canLoadMore) {
          nowPage++;
          ref.invalidate(_listDataProvider);
          _isLoading = true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var progressColor = theme.colorScheme.primary;
    return Scaffold(
      appBar: AppBar(
        title: const Text("搜索"),
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
      ),
      body: Consumer(builder: (context, ref, _) {
        var watchProvider = ref.watch(_listDataProvider);
        if (watchProvider.valueOrNull != null && !watchProvider.isRefreshing) {
          var newData = watchProvider.requireValue;
          if (nowPage == 1 && newData.list.isNotEmpty) {
            _currentList.clear();
          }
          if (!watchProvider.hasError) {
            _currentList.addAll(newData.list);
          }
          _canLoadMore = newData.loadMore;
          _isLoading = false;
        }
        if (watchProvider.isLoading && _currentList.isEmpty) {
          debugPrint("watchProvider error = ${watchProvider.error}");
          return  Center(
             child: SizedBox(
               width: 140,
               height: 140,
               child: BallClipRotatePulse(color: progressColor,)
             )
          );
        } else
        if ((watchProvider.hasError || watchProvider.valueOrNull == null) &&
            _currentList.isEmpty) {
          debugPrint("watchProvider error = ${watchProvider.error}");
          return SizedBox(
              width: double.infinity,
              height: 350,
              child: ErrorView(
                    () {
                  ref.invalidate(_listDataProvider);
                },
                textColor: Colors.white,
              ));
        } else if (_currentList.isEmpty) {
          return Center(
            child: Text("\"${widget.keyWord}\" 搜索不到结果"),
          );
        } else {
          debugPrint("watchProvider _buildList = ${_currentList.length}");
          return _buildList(context);
        }
      }),
    );
  }

  Widget _buildList(BuildContext context) {
    var theme = Theme.of(context);
    return NotificationListener<ScrollNotification>(
      onNotification: _handleLoadMoreScroll,
      child: RefreshIndicator(
        child: CustomScrollView(
          controller: _controller,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverGrid(
                delegate: SliverChildBuilderDelegate((context, index) {
                  var item = _currentList[index];
                  return Padding(
                    padding:
                    const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
                    child: GestureDetector(
                      onTap: () async {
                        context.router.push(NetflexDetailRoute(
                            source: item, heroTag: item.img + heroTag));
                      },
                      child: SizedBox(
                          width: 90,
                          height: double.infinity,
                          child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.all(Radius.circular(12.0))),
                            child: Stack(
                              children: [
                                Hero(
                                    tag: item.img + heroTag,
                                    child: showImage(
                                      context,
                                      item.img,
                                      double.infinity,
                                      150,
                                    )),
                                Positioned.fill(
                                    top: 130,
                                    child: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black.withAlpha(45)),
                                      child: Text(
                                        item.score,
                                        textAlign: TextAlign.right,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                    )),
                                Positioned.fill(
                                    left: 0,
                                    top: 150,
                                    child: ColorContainer(
                                        url: item.img,
                                        baseColor: theme.primaryColor,
                                        title: item.title))
                              ],
                            ),
                          )),
                    ),
                  );
                },
                    addAutomaticKeepAlives: false,
                    childCount: _currentList.length),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.55))
          ],
        ),
        onRefresh: () async {
          _canLoadMore = true;
          debugPrint("onRefresh");
          nowPage = 1;
          return ref.refresh(_listDataProvider);
        },
      ),
    );
  }
}
