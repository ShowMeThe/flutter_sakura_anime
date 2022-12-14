import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/page/anime_jc_page.dart';
import 'package:flutter_sakura_anime/page/anime_movie_page.dart';
import 'package:flutter_sakura_anime/page/search_page.dart';
import 'package:flutter_sakura_anime/page/time_table_page.dart';
import 'package:flutter_sakura_anime/util/api.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/fade_route.dart';

import 'anime_desc_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

@override
class _HomePageState extends ConsumerState<HomePage> {
  late ScrollController _controller;
  late AutoDisposeFutureProvider<HomeData> _disposeFutureProvider;

  @override
  void initState() {
    super.initState();

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
    var top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(FadeRoute(const SearchPage()));
        },
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
      body: Material(
          child: Column(
        children: [
          Container(
            height: top,
            color: Colors.white,
          ),
          Expanded(
              child: NestedScrollView(
            controller: _controller,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: Colors.white,
                  flexibleSpace: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: buildIcon(0),
                      ),
                      Center(
                        child: buildIcon(1),
                      ),
                      Center(
                        child: buildIcon(2),
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
        child: Material(
          child: Ink(
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                border: Border.all(width: 1, color: ColorRes.pink600)),
            child: InkResponse(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              highlightShape: BoxShape.rectangle,
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
        ),
      ),
    );
  }

  void onTap(int index) {
    if (index == 0) {
      /**
       * ????????????
       */
      if (Api.homeData != null) {
        Navigator.of(context).push(FadeRoute(const TimeTablePage()));
      }
    } else if (index == 1) {
      /**
       * ??????
       */
      Navigator.of(context).push(FadeRoute(const AnimeMoviePage()));
    } else if (index == 2) {
      /**
       * ??????
       */
      Navigator.of(context).push(FadeRoute(const AnimeJcPage()));
    } else {}
  }

  String getImageIndex(int index) {
    if (index == 0) {
      return A.assets_ic_time_table;
    } else if (index == 1) {
      return A.assets_ic_sakura_movie;
    } else if (index == 2) {
      return A.assets_ic_sakura_tv;
    } else {
      return "";
    }
  }

  String getTextIndex(int index) {
    if (index == 0) {
      return "?????????";
    } else if (index == 1) {
      return "??????";
    } else if (index == 2) {
      return "?????????";
    } else {
      return "";
    }
  }
}
