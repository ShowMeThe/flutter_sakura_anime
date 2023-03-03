import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/page/anime/time_table_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/fade_route.dart';

import 'anime_category.dart';
import 'anime_collect_page.dart';
import 'anime_desc_page.dart';
import 'anime_jc_page.dart';
import 'anime_movie_page.dart';
import 'anime_search_page.dart';


class AnimeHomePage extends ConsumerStatefulWidget  {
  const AnimeHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

@override
class _HomePageState extends ConsumerState<AnimeHomePage> with AutomaticKeepAliveClientMixin {
  late ScrollController _controller;
  late AutoDisposeFutureProvider<HomeData> _disposeFutureProvider;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _disposeFutureProvider = FutureProvider.autoDispose<HomeData>((_) async {
      var result = await Api.getHomeData();
      return result;
    });
    _controller = ScrollController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(FadeRoute(const AnimeSearchPage()));
        },
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
      body: Material(
          child: Column(
        children: [
          Expanded(
              child: NestedScrollView(
            controller: _controller,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 110,
                  collapsedHeight: 95,
                  pinned: true,
                  backgroundColor: Colors.white,
                  flexibleSpace: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: top + 15),
                        child: buildIcon(0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: top + 15),
                        child: buildIcon(1),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: top + 15),
                        child: buildIcon(2),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: top + 15),
                        child: buildIcon(3),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: top + 15),
                        child: buildIcon(4),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: Container(
              color: Colors.white,
              child: Consumer(
                builder: (context, ref, _) {
                  var provider = ref.watch(_disposeFutureProvider);
                  if (!(provider.isLoading || provider.hasError)) {
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 0),
                      children: buildBody(provider.value),
                    );
                  } else {
                    return ListView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.only(top: 0),
                      children: buildLoadingBody(),
                    );
                  }
                },
              ),
            ),
          ))
        ],
      )),
    );
  }

  List<Widget> buildLoadingBody() {
    List<Widget> widget = [];
    for (int index = 0, size = 4; index < size; index++) {
      widget.add(
        const Padding(
            padding: EdgeInsets.all(8.0),
            child: FadeShimmer(
                height: 20,
                width: 10,
                radius: 12,
                millisecondsDelay: 50,
                highlightColor: Color(0xffF9F9FB),
                baseColor: Color(0xffE6E8EB),
                fadeTheme: FadeTheme.light)),
      );
      widget.add(GridView.builder(
          padding: const EdgeInsets.only(top: 0),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 0.55),
          itemCount: 9,
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
          }));
    }
    return widget;
  }

  List<Widget> buildBody(HomeData? homeData) {
    List<Widget> widget = [];
    if (homeData != null) {
      var list = homeData.homeList;
      for (var element in list) {
        var childList = element.data;
        widget.add(Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            element.title,
            style: const TextStyle(fontSize: 20),
          ),
        ));
        widget.add(GridView.builder(
            padding: const EdgeInsets.only(top: 0),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                childAspectRatio: 0.55),
            itemCount: childList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
                child: GestureDetector(
                  onTap: () {
                    var url = childList[index].url;
                    Navigator.of(context).push(
                        FadeRoute(AnimeDesPage(url!, childList[index].img!)));
                  },
                  child: SizedBox(
                      width: 90,
                      height: double.infinity,
                      child: Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0))),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            Hero(
                                tag: childList[index].img!,
                                child: Image(
                                  image: ExtendedNetworkImageProvider(
                                      childList[index].img!,
                                      cache: true),
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.fitWidth,
                                )),
                            Expanded(
                                child: Container(
                              color: ColorRes.mainColor,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Text(
                                    childList[index].title!,
                                    style: const TextStyle(
                                      fontSize: 13.0,
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
            }));
      }
    }
    return widget;
  }

  Widget buildIcon(int index) {
    return GestureDetector(
      onTap: () {
        onTap(index);
      },
      child: SizedBox(
        width: 68,
        height: 68,
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              border: Border.all(width: 1, color: ColorRes.pink600)),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Center(
                  child: Image.asset(
                    getImageIndex(index),
                    color: ColorRes.pink400,
                    width: 30,
                    height: 30,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 6.0),
                child: Text(
                  getTextIndex(index),
                  style: const TextStyle(color: ColorRes.pink400),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void onTap(int index) {
    if (index == 0) {
      /**
       * 更新列表
       */
      if (Api.homeData != null) {
        Navigator.of(context).push(FadeRoute(const TimeTablePage()));
      }
    } else if (index == 1) {
      /**
       * 电影
       */
      Navigator.of(context).push(FadeRoute(const AnimeMoviePage()));
    } else if (index == 2) {
      /**
       * 剧场
       */
      Navigator.of(context).push(FadeRoute(const AnimeJcPage()));
    }else if (index == 3) {
      /**
       * 追番
       */
      Navigator.of(context).push(FadeRoute(const AnimeCollectPage()));
    }else if (index == 4) {
      /**
       * 分类
       */
      Navigator.of(context).push(FadeRoute(const AnimeCategoryPage()));
    } else {

    }
  }

  String getImageIndex(int index) {
    if (index == 0) {
      return A.assets_ic_time_table;
    } else if (index == 1) {
      return A.assets_ic_sakura_movie;
    } else if (index == 2) {
      return A.assets_ic_sakura_tv;
    } else if (index == 3)  {
      return A.assets_ic_sakura_collect;
    } else if (index == 4)  {
      return A.assets_ic_sakura_cagetory;
    }else {
      return "";
    }
  }

  String getTextIndex(int index) {
    if (index == 0) {
      return "时间表";
    } else if (index == 1) {
      return "剧场版";
    } else if (index == 2) {
      return "OVA";
    }  else if (index == 3) {
      return "追番";
    }  else if (index == 4) {
      return "分类";
    }else {
      return "";
    }
  }

  @override
  bool get wantKeepAlive => true;
}
