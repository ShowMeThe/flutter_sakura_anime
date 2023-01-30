import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_sakura_anime/page/anime_play_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/fold_text.dart';

import '../util/collect.dart';

class AnimeDesPage extends ConsumerStatefulWidget {
  final String animeShowUrl;
  final String logo;
  String heroTag = "";

  AnimeDesPage(this.animeShowUrl, this.logo, {super.key, this.heroTag = ""});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimeDesPageState();
}

class _AnimeDesPageState extends ConsumerState<AnimeDesPage> {
  static const _HeroTag = "des";

  late AutoDisposeFutureProvider<AnimeDesData> _desDataProvider;
  final ScrollController _scrollController = ScrollController();

  late AutoDisposeFutureProvider<AnimePlayListData> _playDataProvider;
  late AutoDisposeStateProvider<String> _logoProvider;

  late AutoDisposeFutureProvider<LocalCollect?> _isCollectFuture;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _logoProvider = StateProvider.autoDispose((ref) {
      return widget.logo;
    });

    _desDataProvider = FutureProvider.autoDispose<AnimeDesData>((_) async {
      var result = await Api.getAnimeDes(widget.animeShowUrl);
      //ref.refresh(_playDataProvider);
      ref.read(_logoProvider.state).update((state) => result.logo!);
      return result;
    });
    _playDataProvider =
        FutureProvider.autoDispose<AnimePlayListData>((_) async {
      var url = ref.watch(_desDataProvider).value?.url;
      var result = await Api.getAnimePlayList(url!);
      return result;
    });
    _isCollectFuture = FutureProvider.autoDispose((_) {
      return findCollect(widget.animeShowUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: ColorRes.mainColor,
      body: Material(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              Consumer(builder: (context, watch, _) {
                var logo = watch.watch(_logoProvider);
                if (logo.isEmpty) {
                  return Container();
                } else {
                  return Image(
                    image: ExtendedNetworkImageProvider(logo, cache: true),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  );
                }
              }),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(),
              ),
              Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                        Colors.black.withAlpha(15),
                        Colors.black.withAlpha(125),
                        Colors.black
                      ]))),
              SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    SafeArea(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              )),
                          Consumer(builder: (context, ref, _) {
                            var localCollect =
                                ref.watch(_isCollectFuture).value;
                            var logo = ref.watch(_logoProvider);
                            if (localCollect != null) {
                              return IconButton(
                                  onPressed: () {
                                    unCollect(widget.animeShowUrl);
                                    ref.refresh(_isCollectFuture);
                                  },
                                  icon: Image.asset(
                                    A.assets_ic_sakura_collected,
                                    color: ColorRes.pink400,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.fitWidth,
                                  ));
                            } else {
                              return IconButton(
                                  onPressed: () {
                                    if (widget.animeShowUrl.isNotEmpty && logo.isNotEmpty) {
                                      collect(
                                          widget.animeShowUrl, widget.logo);
                                      ref.refresh(_isCollectFuture);
                                    }
                                  },
                                  icon: Image.asset(
                                    A.assets_ic_sakura_collect,
                                    color: ColorRes.pink400,
                                    width: 30,
                                    height: 30,
                                    fit: BoxFit.fitWidth,
                                  ));
                            }
                          })
                        ],
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: size.width / 3,
                        child: Stack(
                          children: [
                            Consumer(builder: (context, watch, _) {
                              var logo = watch.watch(_logoProvider);
                              if (logo.isEmpty) {
                                return Container();
                              } else {
                                return Hero(
                                    tag: logo + widget.heroTag,
                                    child: Image(
                                      image: ExtendedNetworkImageProvider(logo,
                                          cache: true),
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      height: 200,
                                    ));
                              }
                            }),
                            Consumer(builder: (context, watch, _) {
                              var provider = watch.watch(_desDataProvider);
                              if (provider.isLoading) {
                                return Container();
                              } else {
                                var data = provider.value!;
                                return SizedBox(
                                  width: size.width / 3,
                                  height: 200,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                          child: SizedBox(
                                        width: 45.0,
                                        height: 35.0,
                                        child: CustomPaint(
                                          painter: ScoreShapeBorder(
                                              ColorRes.pink400.withAlpha(200)),
                                        ),
                                      )),
                                      Positioned(
                                          left: 10,
                                          child: Text(
                                            data.score!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          )),
                                      Positioned(
                                          left: 0,
                                          bottom: 0,
                                          right: 0,
                                          child: Container(
                                            alignment: Alignment.centerRight,
                                            width: double.infinity,
                                            height: 20,
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [
                                                  Colors.black12.withAlpha(30),
                                                  Colors.black12.withAlpha(125)
                                                ])),
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 4.0),
                                              child: Text(
                                                data.updateTime!,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0),
                                              ),
                                            ),
                                          ))
                                    ],
                                  ),
                                );
                              }
                            })
                          ],
                        ),
                      ),
                    ),
                    Consumer(builder: (context, watch, _) {
                      var provider = watch.watch(_desDataProvider);
                      if (provider.isLoading) {
                        return Container();
                      } else {
                        var data = provider.value!;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 12.0),
                              child: Center(
                                child: Text(
                                  data.title == null ? "" : data.title!,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 15.0),
                                ),
                              ),
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Wrap(
                                  spacing: 5.0,
                                  runSpacing: 5.0,
                                  alignment: WrapAlignment.start,
                                  children: buildTag(data),
                                ),
                              ),
                            ),
                            Center(
                                child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 8.0, right: 8.0, top: 0.0),
                              child: FoldTextView(
                                  data.des == null ? "" : data.des!,
                                  4,
                                  const TextStyle(
                                      color: Colors.white, fontSize: 12.0),
                                  320),
                            )),
                            SizedBox(
                              width: double.infinity,
                              child: buildDrams(),
                            )
                          ],
                        );
                      }
                    })
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildChild(AnimeDesData? data) {
    if (data == null) return Container();
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [],
    );
  }

  List<Widget> buildTag(AnimeDesData? data) {
    var list = <Widget>[];
    if (data != null) {
      for (var element in data.tags) {
        list.add(Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          color: ColorRes.pink50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(element.title,
                style: const TextStyle(color: Colors.white, fontSize: 12.0)),
          ),
        ));
      }
    }
    return list;
  }

  Widget buildDrams() {
    return Consumer(
      builder: (context, ref, _) {
        var data = ref.watch(_playDataProvider).value;
        if (data == null) {
          return Container();
        } else {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildPlayList(data.animeDramas)
                ..addAll(buildRecommend(data.animeRecommend)));
        }
      },
    );
  }

  List<Widget> buildPlayList(List<AnimeDramasData> list) {
    List<Widget> child = [];
    for (var element in list) {
      child.add(Padding(
        padding: const EdgeInsets.only(top: 25, left: 16),
        child: Text(
          element.listTitle!,
          style: const TextStyle(
              color: ColorRes.pink50,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ));
      child.add(SizedBox(
        width: double.infinity,
        height: 50.0,
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: element.list.length,
            itemBuilder: (context, index) {
              return Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, top: 6.0, bottom: 6.0),
                child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0)),
                    color: ColorRes.mainColor,
                    onPressed: () {
                      var largeTitle = ref.read(_desDataProvider).value?.title;
                      var title = largeTitle! + element.list[index].title!;
                      Navigator.of(context).push(FadeRoute(
                          AnimePlayPage(element.list[index].url!, title)));
                    },
                    child: Text(element.list[index].title!)),
              );
            }),
      ));
    }
    return child;
  }

  List<Widget> buildRecommend(List<AnimeRecommendData> list) {
    List<Widget> child = [];
    child.add(const Padding(
      padding: EdgeInsets.only(top: 25, left: 16),
      child: Text(
        "相关内容",
        style: TextStyle(
            color: ColorRes.pink50, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    ));
    child.add(SizedBox(
      width: double.infinity,
      height: 210.0,
      child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          itemCount: list.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 6.0, bottom: 6.0),
              child: GestureDetector(
                onTap: () {
                  var url = list[index].url;
                  Navigator.of(context).push(FadeRoute(AnimeDesPage(
                      url!, list[index].logo!,
                      heroTag: _HeroTag)));
                },
                child: SizedBox(
                  width: 90,
                  height: double.infinity,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(8.0),
                            topLeft: Radius.circular(8.0)),
                        child: Hero(
                          tag: list[index].logo! + _HeroTag,
                          child: Image(
                            image:
                                ExtendedNetworkImageProvider(list[index].logo!),
                            width: double.infinity,
                            height: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Expanded(
                          child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(8.0),
                            bottomRight: Radius.circular(8.0)),
                        child: Container(
                          color: ColorRes.mainColor,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Center(
                              child: Text(
                                list[index].title!,
                                style: const TextStyle(
                                  fontSize: 10.0,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                maxLines: 2,
                              ),
                            ),
                          ),
                        ),
                      ))
                    ],
                  ),
                ),
              ),
            );
          }),
    ));
    return child;
  }
}
