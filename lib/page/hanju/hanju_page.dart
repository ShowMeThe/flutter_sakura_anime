import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/page/hanju/hanju_des_page.dart';
import 'package:flutter_sakura_anime/page/hanju/hanju_search_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/hj_api.dart';
import 'package:flutter_sakura_anime/widget/error_view.dart';
import 'package:flutter_sakura_anime/widget/hidden_widget.dart';

import '../../bean/hanju_home_data.dart';
import '../../widget/color_container.dart';

class HanjuPage extends ConsumerStatefulWidget {
  const HanjuPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HanJuPageState();
}

class _HanJuPageState extends ConsumerState<HanjuPage>
    with AutomaticKeepAliveClientMixin {
  final endYear = DateTime.now().year;
  final yearState = StateProvider.autoDispose((ref) => DateTime.now().year);
  final typeState = StateProvider.autoDispose((ref) => 0);
  late AutoDisposeFutureProvider<HjHomeData> _futureProvider;
  var nowPage = 1;
  static const _HeroTag = "des";
  var _canLoadMore = true;
  var _isLoading = false;
  final List<HjHomeDataItem> _movies = [];
  late ScrollController _controller;

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
  void initState() {
    super.initState();
    _futureProvider = FutureProvider.autoDispose((ref) async {
      _isLoading = true;
      var year = ref.read(yearState);
      var result = await HjApi.getHomePage(
          year: year.toString(), page: nowPage, type: ref.read(typeState));

      _canLoadMore = result.loadMore;
      return result;
    });
    _controller = HiddenController.instant.newController(this);
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
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(FadeRoute(const HanjuSearchPage()));
        },
        backgroundColor: ColorRes.pink400,
        heroTag: "hanju",
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
      body: Material(
        child: NestedScrollView(
          controller: _controller,
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 120,
                collapsedHeight: 120,
                pinned: false,
                backgroundColor: Colors.white,
                flexibleSpace: Consumer(
                  builder: (context, ref, _) {
                    var endYearSelected = ref.watch(yearState);
                    var typeSelected = ref.watch(typeState);
                    return Column(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: MediaQuery.paddingOf(context).top),
                            child: ListView(
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              children: _buildTypeChip(typeSelected),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children: _buildChip(endYearSelected),
                          ),
                        )
                      ],
                    );
                  },
                ),
              ),
            ];
          },
          body: Consumer(
            builder: (context, ref, _) {
              var provider = ref.watch(_futureProvider);
              if (provider.isLoading && _movies.isEmpty) {
                return buildLoadingBody();
              } else if (provider.hasError && _movies.isEmpty) {
                return Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: 150,
                    child: ErrorView(() {
                      ref.invalidate(_futureProvider);
                    }));
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
                          return ref.refresh(_futureProvider);
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
                                              tag: _movies[index].logo +
                                                  _HeroTag,
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
                                              child: ColorContainer(
                                                  url: _movies[index].logo,
                                                  baseColor: ColorRes.mainColor,
                                                  title: _movies[index].title))
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
        ),
      ),
    );
  }

  List<Widget> _buildTypeChip(int selectedYear) {
    var list = <Widget>[];
    var title = ["韩剧", "日剧","电影"];
    for (int i = 0; i < title.length; i++) {
      var selected = selectedYear == i;
      list.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: ChoiceChip(
          selectedColor: ColorRes.pink300,
          selected: selected,
          label: Text(
            title[i],
            style: TextStyle(color: selected ? Colors.white : Colors.black),
          ),
          onSelected: (bool) {
            if (bool) {
              ref.refresh(typeState.notifier).update((state) => i);
              nowPage = 1;
              ref.invalidate(_futureProvider);
            }
          },
        ),
      ));
    }
    return list;
  }

  List<Widget> _buildChip(int selectedYear) {
    var list = <Widget>[];
    for (int i = endYear; i >= 2016; i--) {
      var selected = selectedYear == i;
      list.add(Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: ChoiceChip(
          selectedColor: ColorRes.pink300,
          selected: selected,
          label: Text(
            "$i",
            style: TextStyle(color: selected ? Colors.white : Colors.black),
          ),
          onSelected: (bool) {
            if (bool) {
              ref.refresh(yearState.notifier).update((state) => i);
              nowPage = 1;
              ref.invalidate(_futureProvider);
            }
          },
        ),
      ));
    }
    return list;
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
        itemCount: 10,
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

  @override
  bool get wantKeepAlive => true;
}
