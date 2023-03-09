import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/bean/meiju_category_data.dart';
import 'package:flutter_sakura_anime/page/meiju/meiju_des_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';

class MjCategoryPage extends ConsumerStatefulWidget {
  final String url;
  final String title;
  final String heroTag = "MjCategoryPage";

  const MjCategoryPage(this.url, this.title, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MjCategoryState();
  }
}

class _MjCategoryState extends ConsumerState<MjCategoryPage> {
  late AutoDisposeFutureProvider<MjCategoryData> _futureProvider;
  var nowPage = 1;
  var _canLoadMore = true;
  var _isLoading = false;
  final List<MjCategoryItem> _movies = [];

  @override
  void initState() {
    super.initState();

    _futureProvider = FutureProvider.autoDispose((ref) async {
      _isLoading = true;
      debugPrint("nowPage $nowPage");
      var result = await MeiJuApi.getCategoryPage(widget.url, page: nowPage);
      _canLoadMore = result.hasNextPage;
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Consumer(builder: (context, ref, _) {
        var provider = ref.watch(_futureProvider);
        if (provider.value == null) {
          return buildLoadingBody();
        } else {
          var provider = ref.watch(_futureProvider);
          if (provider.value == null) {
            return buildLoadingBody();
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
        }
      }),
    );
  }

  Widget buildLoadingBody() {
    return ListView.builder(
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0),
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
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: FadeShimmer(
                            height: double.infinity,
                            width: 150,
                            radius: 12.0,
                            millisecondsDelay: 50,
                            fadeTheme: FadeTheme.light),
                      ),
                      Expanded(
                          child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                        child: Column(
                          children: const [
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: FadeShimmer(
                                  height: 15,
                                  width: double.infinity,
                                  radius: 5,
                                  millisecondsDelay: 150,
                                  fadeTheme: FadeTheme.light),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: FadeShimmer(
                                  height: 15,
                                  width: double.infinity,
                                  radius: 5,
                                  millisecondsDelay: 150,
                                  fadeTheme: FadeTheme.light),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: FadeShimmer(
                                  height: 15,
                                  width: double.infinity,
                                  radius: 5,
                                  millisecondsDelay: 150,
                                  fadeTheme: FadeTheme.light),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 15.0),
                              child: FadeShimmer(
                                  height: 15,
                                  width: double.infinity,
                                  radius: 5,
                                  millisecondsDelay: 150,
                                  fadeTheme: FadeTheme.light),
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                )),
          );
        });
  }

  Widget buildWidgetBody(List<MjCategoryItem> list) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      var item = list[index];
      return Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(FadeRoute(MjDesPage(item.logo, item.url, item.title,heroTag: widget.heroTag,)));
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
                          tag: item.logo + widget.heroTag,
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
                                item.title,style: TextStyle(fontSize: item.title.length > 20 ? 12 : 15),
                              )),
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(item.state,style: TextStyle(fontSize: item.state.length > 20 ? 12 : 15),)),
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(item.realName,style: TextStyle(fontSize: item.realName.length > 20 ? 12 : 15),)),
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text(item.time,style: TextStyle(fontSize: item.time.length > 20 ? 12 : 15),)),
                          Padding(
                              padding: const EdgeInsets.only(top: 15.0),
                              child: Text("评分:${item.score}",style: TextStyle(fontSize: 15))),
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
