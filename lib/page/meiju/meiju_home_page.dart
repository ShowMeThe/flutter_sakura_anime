import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter_sakura_anime/bean/meiju_home_data.dart';
import 'package:flutter_sakura_anime/page/meiju/meiju_des_page.dart';
import 'package:flutter_sakura_anime/page/meiju/meiju_search_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';
import 'package:flutter_sakura_anime/widget/error_view.dart';
import 'package:flutter_sakura_anime/widget/color_container.dart';
import 'package:flutter_sakura_anime/widget/hidden_widget.dart';

import 'meiju_category_page.dart';

class MeijuHomePage extends ConsumerStatefulWidget {
  const MeijuHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MeiJuHomePageState();
  }
}

class _MeiJuHomePageState extends ConsumerState<MeijuHomePage>
    with AutomaticKeepAliveClientMixin {
  late AutoDisposeFutureProvider<List<MjHomeData>> _homeProvider;

  var _heroTag = "MeijuHomePage";
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _homeProvider = FutureProvider.autoDispose<List<MjHomeData>>((ref) async {
      return MeiJuApi.getHomeData();
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
    var theme = Theme.of(context);
    return Consumer(
      builder: (context, ref, _) {
        var provider = ref.watch(_homeProvider);
        if (provider.isLoading) {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
            children: buildLoadingBody(),
          );
        } else if (provider.hasError) {
          return Container(
              color: Colors.white,
              width: double.infinity,
              height: 150,
              child: ErrorView(() {
                ref.invalidate(_homeProvider);
              }));
        } else {
          return Scaffold(
            body: ListView(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: MediaQuery.paddingOf(context).top),
              children: buildBody(provider.value, theme),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(FadeRoute(const MjSearchPage()));
              },
              backgroundColor: theme.cardColor,
              heroTag: "meiju",
              child: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          );
        }
      },
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

  List<Widget> buildBody(List<MjHomeData>? list, ThemeData themeData) {
    List<Widget> widget = [];
    if (list != null) {
      for (var element in list) {
        var childList = element.list;
        widget.add(GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            Navigator.of(context)
                .push(FadeRoute(MjCategoryPage(element.url, element.title)));
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  element.title,
                  style: TextStyle(
                      fontSize: 20,
                      color: themeData.textTheme.titleSmall?.color),
                ),
              ),
              Icon(
                Icons.navigate_next,
                color: themeData.colorScheme.secondary,
              )
            ],
          ),
        ));
        widget.add(SizedBox(
          height: 250,
          child: CarouselView(
              itemExtent: 150,
              itemSnapping: true,
              shrinkExtent: 75,
              children: childList.map((item) {
                return Padding(
                  padding:
                      const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(FadeRoute(MjDesPage(
                        item.img,
                        item.url,
                        item.title,
                        heroTag: _heroTag,
                      )));
                    },
                    child: SizedBox(
                        width: 90,
                        height: double.infinity,
                        child: Card(
                          shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12.0))),
                          clipBehavior: Clip.antiAlias,
                          child: Stack(
                            children: [
                              Hero(
                                  tag: item.img + _heroTag,
                                  child: showImage(
                                      item.img, double.infinity, 150)),
                              Positioned.fill(
                                  top: 130,
                                  child: Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black.withAlpha(45)),
                                    child: Text(
                                      item.chapter,
                                      textAlign: TextAlign.right,
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  )),
                              Positioned.fill(
                                  left: 0,
                                  top: 150,
                                  child: ColorContainer(
                                    url: item.img,
                                    title: item.title,
                                    baseColor: ColorRes.mainColor,
                                  )),
                            ],
                          ),
                        )),
                  ),
                );
              }).toList()),
        ));

        /*  GridView.builder(
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
              var item = childList[index];
              return Padding(
                padding:
                const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(FadeRoute(MjDesPage(
                      item.img,
                      item.url,
                      item.title,
                      heroTag: _heroTag,
                    )));
                  },
                  child: SizedBox(
                      width: 90,
                      height: double.infinity,
                      child: Card(
                        shape: const RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.all(Radius.circular(12.0))),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            Hero(
                                tag: item.img + _heroTag,
                                child:
                                showImage(item.img, double.infinity, 150)),
                            Positioned.fill(
                                top: 130,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black.withAlpha(45)),
                                  child: Text(
                                    childList[index].chapter,
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                )),
                            Positioned.fill(
                                left: 0,
                                top: 150,
                                child: ColorContainer(
                                  url: childList[index].img,
                                  title: childList[index].title,
                                  baseColor: ColorRes.mainColor,
                                )),
                          ],
                        ),
                      )),
                ),
              );
            })*/
      }
    }
    return widget;
  }

  @override
  bool get wantKeepAlive => true;
}
