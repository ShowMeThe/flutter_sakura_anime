import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/style/router/AppRouter.gr.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/color_container.dart';
import 'package:flutter_sakura_anime/style/import/PageImport.dart';

import '../../bean/factory_tab.dart';
import '../../util/factory_api.dart';
import '../../widget/error_view.dart';
import '../../widget/shimmer_placeholder.dart';

class NetflexListPage extends ConsumerStatefulWidget {
  final String baseUrl;

  const NetflexListPage(this.baseUrl, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetflexListPageState();
}

class _NetflexListPageState extends ConsumerState<NetflexListPage> with AutomaticKeepAliveClientMixin{
  static const heroTag = "FactoryPage";
  var _canLoadMore = true;
  var _isLoading = false;
  var nowPage = 1;
  late ScrollController _controller;
  final _currentList = <FactoryTabListBean>[];
  late final _listDataProvider = FutureProvider.autoDispose((_) async {
    var result = await FactoryApi.getTagPageData(widget.baseUrl, nowPage);
    return result;
  });

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
          210) {
        if (!_isLoading && _canLoadMore) {
          nowPage++;
          ref.invalidate(_listDataProvider);
          debugPrint("load more");
          _isLoading = true;
        }
      }
    }
    return false;
  }

  @override
  void initState() {
    super.initState();
    _controller = HiddenController.instant.newController(this);
  }

  @override
  void dispose() {
    super.dispose();
    HiddenController.instant.removeController(this);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(builder: (context, ref, _) {
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
        return _buildLoadingList();
      } else if ((watchProvider.hasError ||
              watchProvider.valueOrNull == null) &&
          _currentList.isEmpty) {
        return SizedBox(
            width: double.infinity,
            height: 350,
            child: ErrorView(
              () {
                ref.invalidate(_listDataProvider);
              },
              textColor: Colors.white,
            ));
      } else {
        return _buildList(context);
      }
    });
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
                        context.router.push(NetflexDetailRoute(source: item, heroTag: item.img + heroTag));

                        // Navigator.of(context).push(FadeRoute(FactoryDesPage(
                        //   item.img,
                        //   item.url,
                        //   item.title,
                        //   item.score,
                        //   heroTag,
                        // )));
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

  Widget _buildLoadingList() {
    return GridView.builder(
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.55),
        itemCount: 12,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
            child: SizedBox(
                width: 90,
                height: double.infinity,
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  clipBehavior: Clip.antiAlias,
                  child: ShimmerPlaceholder(
                    height: double.infinity,
                    width: double.infinity,
                    radius: 0,
                    millisecondsDelay: 100,
                    shimmerTheme: ShimmerTheme.dark,
                  ),
                )),
          );
        });
  }

  @override
  bool get wantKeepAlive => true;
}
