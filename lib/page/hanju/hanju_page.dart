import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/page/hanju/hanju_des_page.dart';
import 'package:flutter_sakura_anime/page/hanju/hanju_search_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/hj_api.dart';

import '../../bean/hanju_home_data.dart';

class HanjuPage extends ConsumerStatefulWidget {
  const HanjuPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HanJuPageState();
}

class _HanJuPageState extends ConsumerState<HanjuPage>
    with AutomaticKeepAliveClientMixin {
  final endYear = DateTime.now().year;
  final yearState = StateProvider.autoDispose((ref) => DateTime.now().year);
  late AutoDisposeFutureProvider<HjHomeData> _futureProvider;
  var nowPage = 1;
  static const _HeroTag = "des";
  var _canLoadMore = true;
  var _isLoading = false;
  final List<HjHomeDataItem> _movies = [];

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
  void initState() {
    super.initState();
    _futureProvider = FutureProvider.autoDispose((ref) async {
      _isLoading = true;
      var year = ref.read(yearState);
      var result =
          await HjApi.getHomePage(year: year.toString(), page: nowPage)
              .catchError((onError) {
        debugPrint(onError);
      });
      _canLoadMore = result.loadMore;
      return result;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var paddingTop = MediaQuery.of(context).padding.top;
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
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 65,
                pinned: true,
                backgroundColor: Colors.white,
                flexibleSpace: Consumer(
                  builder: (context, ref, _) {
                    var endYearSelected = ref.watch(yearState);
                    return Padding(
                      padding: EdgeInsets.only(top: paddingTop),
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: _buildChip(endYearSelected),
                      ),
                    );
                  },
                ),
              ),
            ];
          },
          body: Consumer(
            builder: (context, ref, _) {
              var provider = ref.watch(_futureProvider);
              if (provider.value == null || provider.hasError) {
                return buildLoadingBody();
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
                                              child: Image(
                                                image:
                                                    ExtendedNetworkImageProvider(
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
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Center(
                                                    child: Text(
                                                      _movies[index].title!,
                                                      style: const TextStyle(
                                                        fontSize: 10.0,
                                                        overflow: TextOverflow
                                                            .ellipsis,
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
        ),
      ),
    );
  }

  List<Widget> _buildChip(int selectedYear) {
    var list = <Widget>[];
    for (int i = endYear; i >= 2016; i--) {
      var selected = selectedYear == i;
      list.add(Padding(
        padding: const EdgeInsets.all(8.0),
        child: ChoiceChip(
          selectedColor: ColorRes.pink300,
          selected: selected,
          label: Text(
            "$i",
            style: TextStyle(color: selected ? Colors.white : Colors.black),
          ),
          onSelected: (bool) {
            if (bool) {
              ref.read(yearState.notifier).update((state) => i);
              nowPage = 1;
              ref.refresh(_futureProvider);
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

  @override
  bool get wantKeepAlive => true;
}
