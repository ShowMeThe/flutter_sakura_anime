import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter_sakura_anime/bean/meiju_home_data.dart';
import 'package:flutter_sakura_anime/page/meiju/meiju_des_page.dart';
import 'package:flutter_sakura_anime/page/meiju/meiju_search_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';

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

  @override
  void initState() {
    super.initState();
    _homeProvider = FutureProvider.autoDispose<List<MjHomeData>>((ref) async {
      return MeiJuApi.getHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var paddingTop = MediaQuery.of(context).padding.top;
    return Consumer(
      builder: (context, ref, _) {
        var provider = ref.watch(_homeProvider);
        if (!(provider.isLoading || provider.hasError)) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.only(top: paddingTop),
              children: buildBody(provider.value),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(FadeRoute(const MjSearchPage()));
              },
              heroTag: "meiju",
              child: const Icon(
                Icons.search,
                color: Colors.white,
              ),
            ),
          );
        } else {
          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: paddingTop),
            children: buildLoadingBody(),
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

  List<Widget> buildBody(List<MjHomeData>? list) {
    List<Widget> widget = [];
    if (list != null) {
      for (var element in list) {
        var childList = element.list;
        widget.add(GestureDetector(
          onTap: () {
            Navigator.of(context)
                .push(FadeRoute(MjCategoryPage(element.url, element.title)));
          },
          child: Container(
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    element.title,
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const Icon(Icons.navigate_next)
              ],
            ),
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
              var item = childList[index];
              return Padding(
                padding:
                    const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        FadeRoute(MjDesPage(item.img, item.url, item.title,heroTag: _heroTag,)));
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
                                child: Image(
                                  image: ExtendedNetworkImageProvider(
                                      item.img,
                                      cache: true),
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.fitWidth,
                                )),
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
                                child: Container(
                                  color: ColorRes.mainColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        childList[index].title,
                                        style: const TextStyle(
                                          fontSize: 13.0,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                )),
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

  @override
  bool get wantKeepAlive => true;
}