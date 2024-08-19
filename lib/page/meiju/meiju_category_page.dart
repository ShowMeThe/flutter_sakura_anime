import 'package:auto_size_text/auto_size_text.dart';
import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/bean/meiju_category_data.dart';
import 'package:flutter_sakura_anime/page/meiju/meiju_des_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';
import 'package:flutter_sakura_anime/widget/color_size_box.dart';

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
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _futureProvider = FutureProvider.autoDispose((ref) async {
      _isLoading = true;
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
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title,style: theme.textTheme.displayMedium),
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
          return const Padding(
            padding: EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0),
            child: SizedBox(
                width: double.infinity,
                height: 210,
                child: Card(
                  color: ColorRes.mainColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  clipBehavior: Clip.antiAlias,
                  child: Row(
                    children: [
                      Padding(
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
                        padding: EdgeInsets.only(left: 12.0, right: 12.0),
                        child: Column(
                          children: [
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

  var providers = <int,AutoDisposeStateProvider<Color>>{};
  Widget buildWidgetBody(List<MjCategoryItem> list) {
    return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
      var item = list[index];
      var colorProvider = providers[index];
      if(colorProvider == null){
        colorProvider = StateProvider.autoDispose((ref) => Colors.black);
        providers[index] = colorProvider;
      }
      return Padding(
        padding: const EdgeInsets.only(left: 15.0, top: 15.0, right: 15.0),
        child: GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(FadeRoute(MjDesPage(item.logo, item.url, item.title,heroTag: widget.heroTag,)));
          },
          child: ColorSizeBox(
            url: item.logo,
            width: double.infinity,
            height: 240,
            callback: (isBlack){
              if(isBlack){
                ref.read(colorProvider!.notifier).update((state) => Colors.white);
              }
            },
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12.0))),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Hero(
                      tag: item.logo + widget.heroTag,
                      child: showImage(item.logo, 150, double.infinity)),
                ),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12.0, right: 12.0),
                      child: Consumer(
                        builder: (context,ref,_){
                          var textColor = ref.watch(colorProvider!);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: AutoSizeText(
                                    maxLines: 2,
                                    item.title,style: TextStyle(fontSize: 12,color: textColor),
                                  )),
                              Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: AutoSizeText(
                                    maxLines: 2,item.state,style: TextStyle(fontSize: 12,color: textColor),)),
                              Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: AutoSizeText(
                                    maxLines: 2,item.realName,style: TextStyle(fontSize: 12,color: textColor),)),
                              Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: AutoSizeText(
                                    maxLines: 2,item.time,style: TextStyle(fontSize: 12,color: textColor),)),
                              Padding(
                                  padding: const EdgeInsets.only(top: 15.0),
                                  child: AutoSizeText(
                                      maxLines: 2,"评分:${item.score}",style: TextStyle(fontSize: 12,color: textColor))),
                            ],
                          );
                        },
                      ),
                    ))
              ],
            ),
          ),
        ),
      );
    }, childCount: list.length));
  }
}
