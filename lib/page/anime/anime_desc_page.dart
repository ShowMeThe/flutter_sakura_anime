import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter_sakura_anime/page/play_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/ErrorView.dart';
import 'package:flutter_sakura_anime/widget/fold_text.dart';

import '../../widget/color_container.dart';

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

  late AutoDisposeFutureProvider<AnimePlayListData> _playDataProvider;
  late AutoDisposeStateProvider<String> _logoProvider;

  late AutoDisposeFutureProvider<LocalCollect?> _isCollectFuture;

  late AutoDisposeFutureProvider<LocalHistory?> _localHisFuture;

  var controllerStore = <String, ScrollController>{};

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controllerStore.forEach((key, value) {
      value.dispose();
    });
    controllerStore.clear();
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _logoProvider = StateProvider.autoDispose((ref) {
      return widget.logo;
    });

    _desDataProvider = FutureProvider.autoDispose<AnimeDesData>((_) async {
      var result = await Api.getAnimeDes(widget.animeShowUrl);
      //ref.refresh(_playDataProvider);
      ref.read(_logoProvider.notifier).update((state) => result.logo!);
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

    _localHisFuture = FutureProvider.autoDispose((_) async {
      var result = findLocalHistory(widget.animeShowUrl);
      debugPrint("result $result");
      if (result == null) {
        return null;
      }
      var chapter = result.chapter;
      var playData = ref.watch(_playDataProvider).value;
      if (playData != null) {
        var index = playData.animeDramas
            .indexWhere((element) => element.listTitle == chapter);
        if (index != -1) {
          var firstController = controllerStore[result.chapter];
          if (firstController != null) {
            _scrollToRealPosition(firstController, () {
              var chapterIndex = playData.animeDramas[index].list
                  .indexWhere((element) => element.url == result.chapterUrl);
              firstController.animateTo(chapterIndex * 93.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            });
          }
        }
      }
      return result;
    });
  }

  void _scrollToRealPosition(
      ScrollController controller, VoidCallback callback) async {
    try {
      while (!controller.position.hasContentDimensions) {
        await Future.delayed(const Duration(milliseconds: 500));
      }
      callback();
    } catch (e) {
      debugPrint("scrollToRealPosition exception : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
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
                                    ref.invalidate(_isCollectFuture);
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
                                    if (widget.animeShowUrl.isNotEmpty &&
                                        logo.isNotEmpty) {
                                      collect(
                                          widget.animeShowUrl,
                                          logo,
                                          ref
                                                  .watch(_desDataProvider)
                                                  .value
                                                  ?.title ??
                                              "");
                                      ref.invalidate(_isCollectFuture);
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
                        width: MediaQuery.sizeOf(context).width / 3,
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
                              if (provider.valueOrNull == null || provider.hasError) {
                                return Container();
                              } else {
                                var data = provider.value!;
                                return SizedBox(
                                  width: MediaQuery.sizeOf(context).width / 3,
                                  height: 200,
                                  child: Stack(
                                    children: [
                                      Positioned(
                                          child: SizedBox(
                                        width: 55.0,
                                        height: 40.0,
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
                      if(provider.isLoading){
                        return const SizedBox(
                           height: 350,
                           child: Center(
                             child: CircularProgressIndicator(color: ColorRes.pink200,),
                           ),
                        );
                      }else if(provider.valueOrNull == null || provider.hasError){
                        return SizedBox(
                            width: double.infinity,
                            height: 350,
                            child: ErrorView(() {
                              ref.invalidate(_desDataProvider);
                            },textColor: Colors.white,));
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
                                320,
                                moreTxColor: ColorRes.pink400,
                              ),
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
    for (var parentIndex = 0; parentIndex < list.length; parentIndex++) {
      var element = list[parentIndex];
      var key = element.listTitle ?? "default";
      var finalController = ScrollController(keepScrollOffset: false);
      controllerStore[key] = finalController;
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
        height: 58.0,
        child: ListView.builder(
            controller: finalController,
            scrollDirection: Axis.horizontal,
            itemCount: element.list.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, top: 6.0, bottom: 6.0),
                    child: MaterialButton(
                        minWidth: 85,
                        height: double.infinity,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0)),
                        color: ColorRes.mainColor,
                        onPressed: () async {
                          var largeTitle =
                              ref.read(_desDataProvider).value?.title;
                          var title = largeTitle! + element.list[index].title!;

                          updateHistory(widget.animeShowUrl, element.listTitle!,
                              element.list[index].url!);
                          LoadingDialogHelper.showLoading(context);
                          var playUrl = await Api.getAnimePlayUrl(
                              element.list[index].url!);
                          ref.invalidate(_localHisFuture);

                          if (!mounted) return;
                          LoadingDialogHelper.dismissLoading(context);
                          Navigator.of(context)
                              .push(FadeRoute(PlayPage(playUrl, title)));
                        },
                        child: Text(element.list[index].title!)),
                  ),
                  Consumer(builder: (context, ref, _) {
                    var localHistory = ref.watch(_localHisFuture);
                    if (localHistory.value != null &&
                        (localHistory.value!.chapter) == element.listTitle &&
                        localHistory.value!.chapterUrl ==
                            element.list[index].url) {
                      return const Positioned(
                        bottom: 5,
                        left: 30,
                        child: Text(
                          "上次观看",
                          style:
                              TextStyle(color: ColorRes.pink400, fontSize: 10),
                        ),
                      );
                    } else {
                      return Container();
                    }
                  })
                ],
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
                        child: ColorContainer(
                          url: list[index].logo!,
                          baseColor: ColorRes.mainColor,
                          title: list[index].title!,
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
