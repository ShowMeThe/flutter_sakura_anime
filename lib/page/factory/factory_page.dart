import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/page/play_page_2.dart';

import '../../bean/factory_tab.dart';
import '../../util/base_export.dart';
import '../../util/factory_api.dart';
import '../../widget/color_container.dart';
import '../../widget/error_view.dart';
import '../../widget/hidden_widget.dart';
import 'factory_des_page.dart';

class FactoryPage extends ConsumerStatefulWidget {
  const FactoryPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FactoryPageState();
}

class _FactoryPageState extends ConsumerState<FactoryPage>
    with AutomaticKeepAliveClientMixin {
  static const heroTag = "FactoryPage";
  var nowPage = 1;
  late ScrollController _controller;
  late AutoDisposeFutureProvider<List<FactoryTab>> _homeTabFutureProvider;
  final AutoDisposeStateProvider<String> _tabSelectProvider =
      StateProvider.autoDispose<String>((ref) => "");
  late AutoDisposeFutureProvider<FactoryTabList> _tabSelectFutureProvider;

  final List<FactoryTabListBean> _movies = [];
  var _canLoadMore = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = HiddenController.instant.newController(this);
    _homeTabFutureProvider =
        FutureProvider.autoDispose<List<FactoryTab>>((_) async {
      var result = await FactoryApi.getHomeTab();
      if (result.isNotEmpty) {
        ref.watch(_tabSelectProvider.notifier).update((cb) => result.first.url);
      }
      return result;
    });

    _tabSelectFutureProvider =
        FutureProvider.autoDispose<FactoryTabList>((_) async {
      var url = ref.watch(_tabSelectProvider);
      var result = await FactoryApi.getTagPageData(url, nowPage);
      debugPrint("run ${result.list.first.title}");
      return result;
    });
  }

  bool _handleLoadMoreScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      if (notification.metrics.maxScrollExtent - notification.metrics.pixels <
          210) {
        if (!_isLoading && _canLoadMore) {
          nowPage++;
          ref.invalidate(_tabSelectFutureProvider);
          _isLoading = true;
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    HiddenController.instant.removeController(this);
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer(builder: (context, ref, child) {
      var theme = Theme.of(context);
      var tabProvider = ref.watch(_homeTabFutureProvider);
      if (tabProvider.isLoading) {
        return buildEmptyLoadingBody();
      } else if (tabProvider.hasError || tabProvider.valueOrNull == null) {
        return SizedBox(
            width: double.infinity,
            height: 350,
            child: ErrorView(
              () {
                ref.invalidate(_homeTabFutureProvider);
              },
              textColor: Colors.white,
            ));
      } else {
        var tabs = tabProvider.requireValue;
        return Material(
          child: SafeArea(
            child: NestedScrollView(
                controller: _controller,
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Wrap(
                        children: _buildChip(tabs),
                      ),
                    )
                  ];
                },
                body: Consumer(builder: (context, ref, _) {
                  var provider = ref.watch(_tabSelectFutureProvider);
                  if (provider.isLoading && _movies.isEmpty) {
                    return buildLoadingBody();
                  } else if (provider.hasError && _movies.isEmpty) {
                    return Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: ErrorView(() {
                          ref.invalidate(_tabSelectFutureProvider);
                        }));
                  } else {
                    var bean = provider.requireValue;
                    if (!provider.isLoading) {
                      if (nowPage == 1) {
                        _movies.clear();
                      }
                      _movies.addAll(bean.list);
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
                              return ref.refresh(_tabSelectFutureProvider);
                            },
                          ),
                          SliverGrid(
                              delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(
                                      left: 2.0, top: 2.0, bottom: 2.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      var item = _movies[index];
                                      Navigator.of(context)
                                          .push(FadeRoute(FactoryDesPage(
                                        item.img,
                                        item.url,
                                        item.title,
                                        item.score,
                                        heroTag,
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
                                                  tag: _movies[index].img +
                                                      heroTag,
                                                  child: showImage(
                                                    _movies[index].img,
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
                                                      _movies[index].score,
                                                      textAlign:
                                                          TextAlign.right,
                                                      style: const TextStyle(
                                                          color: Colors.white),
                                                    ),
                                                  )),
                                              Positioned.fill(
                                                  left: 0,
                                                  top: 150,
                                                  child: ColorContainer(
                                                      url: _movies[index].img,
                                                      baseColor:
                                                          ColorRes.mainColor,
                                                      title:
                                                          _movies[index].title))
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
                })),
          ),
        );
      }
    });
  }

  Widget buildEmptyLoadingBody() {
    return SingleChildScrollView(
      child: SafeArea(
          child: Column(
        children: [buildLoadingWrapTab(), _buildLoadingList()],
      )),
    );
  }

  Widget buildLoadingWrapTab() {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      children: [
        _fakeTab(),
        _fakeTab(),
        _fakeTab(),
        _fakeTab(),
        _fakeTab(),
      ],
    );
  }

  Widget _fakeTab() {
    return const Padding(
      padding: EdgeInsets.only(left: 8.0, right: 8.0),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: FadeShimmer(
            height: 35,
            width: 65,
            radius: 0,
            millisecondsDelay: 50,
            fadeTheme: FadeTheme.light),
      ),
    );
  }

  Widget buildLoadingBody() {
    return SingleChildScrollView(
      child: SafeArea(child: _buildLoadingList()),
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

  List<Widget> _buildChip(List<FactoryTab> tabs) {
    var list = <Widget>[];
    for (var value in tabs) {
      list.add(Consumer(builder: (context, ref, _) {
        var watchValue = ref.watch(_tabSelectProvider);
        var selected = watchValue == value.url;
        return Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: ChoiceChip(
            showCheckmark: false,
            selected: selected,
            label: Text(
              value.title,
            ),
            onSelected: (bool) {
              if (bool) {
                ref
                    .refresh(_tabSelectProvider.notifier)
                    .update((state) => value.url);
                nowPage = 1;
                ref.invalidate(_tabSelectFutureProvider);
              }
            },
          ),
        );
      }));
    }

    return list;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
