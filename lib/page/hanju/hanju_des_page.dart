import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sakura_anime/bean/meiju_des_data.dart';
import 'package:flutter_sakura_anime/page/play_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/download_dialog.dart';
import 'package:flutter_sakura_anime/util/hj_api.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';
import 'package:flutter_sakura_anime/widget/error_view.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../bean/hanju_des_data.dart';
import '../../util/download.dart';
import '../../widget/fold_text.dart';

class HjDesPage extends ConsumerStatefulWidget {
  final String logo;
  final String url;
  final String title;
  final String score;
  final String update;
  String heroTag = "";

  HjDesPage(this.logo, this.url, this.title, this.score, this.update,
      {super.key, this.heroTag = ""});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _HjDesPageState();
  }
}

class _HjDesPageState extends ConsumerState<HjDesPage> {
  late AutoDisposeFutureProvider<HjDesData> _desDataProvider;
  final AutoDisposeStateProvider<int> tabSelect =
      StateProvider.autoDispose((ref) => 0);
  late AutoDisposeFutureProvider<LocalHistory?> _localHisFuture;
  final AutoDisposeStateProvider<bool> downLoadState =
      StateProvider.autoDispose((ref) => false);
  final ScrollController _tabScroller = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _desDataProvider = FutureProvider.autoDispose((ref) async {
      debugPrint("_desDataProvider getData");
      var result = await HjApi.getHjDes(widget.url);
      await Future.delayed(const Duration(milliseconds: 400));
      return result;
    });

    _localHisFuture = FutureProvider.autoDispose((_) async {
      var result = findLocalHistory(widget.url);
      debugPrint("localHistory = $result");
      if (result != null) {
        var chapter = result.chapter;
        var desData = ref.watch(_desDataProvider).value;
        if (desData != null) {
          var findIndex = desData.playList
              .indexWhere((element) => element.title == chapter);
          if (findIndex != -1) {
            _scrollToRealPosition(_tabScroller, () {
              ref.watch(tabSelect.notifier).update((state) => findIndex);
              _tabScroller.animateTo(findIndex * 75.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            });
          }
        }
      }
      if (result == null) {
        return null;
      }
      return result;
    });
  }

  void _scrollToRealPosition(
      ScrollController controller, VoidCallback callback) async {
    try {
      while (!controller.position.hasContentDimensions) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      callback();
    } catch (e) {
      debugPrint("scrollToRealPosition exception : $e");
    }
  }

  @override
  void dispose() {
    _tabScroller.dispose();
    super.dispose();
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
              Image(
                image: ExtendedNetworkImageProvider(widget.logo, cache: true),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
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
                            var desData = ref.watch(_desDataProvider);
                            if (desData.valueOrNull != null &&
                                desData.valueOrNull?.playList.isNotEmpty ==
                                    true) {
                              return IconButton(
                                  onPressed: () {
                                    _showDownLoadDialog(
                                        context, ref, desData.value);
                                  },
                                  icon: const Icon(
                                    Icons.download,
                                    color: Colors.white,
                                  ));
                            } else {
                              return Container();
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
                            Hero(
                                tag: widget.logo + widget.heroTag,
                                child: showImage(
                                    widget.logo, double.infinity, 200,
                                    boxFit: BoxFit.cover)),
                            Consumer(builder: (context, ref, _) {
                              var provider = ref.watch(_desDataProvider);
                              if (provider.isLoading || provider.hasError) {
                                return const SizedBox();
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
                                            widget.score,
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
                                                widget.update,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12.0),
                                              ),
                                            ),
                                          )),
                                    ],
                                  ),
                                );
                              }
                            })
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, right: 8.0, top: 12.0),
                      child: Center(
                        child: Text(
                          widget.title,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15.0),
                        ),
                      ),
                    ),
                    Consumer(builder: (context, ref, _) {
                      var provider = ref.watch(_desDataProvider);
                      if (provider.valueOrNull == null) {
                        return const SizedBox();
                      } else {
                        var data = provider.value;
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 0.0),
                          child: FoldTextView(
                            data?.des == null ? "" : data!.des,
                            3,
                            const TextStyle(
                                color: Colors.white, fontSize: 12.0),
                            320,
                            moreTxColor: ColorRes.pink400,
                          ),
                        ));
                      }
                    }),
                    buildDrams()
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildDrams() {
    return Consumer(
      builder: (context, ref, _) {
        debugPrint("buildDrams build");
        var provider = ref.watch(_desDataProvider);
        if (provider.isLoading) {
          return const SizedBox(
            width: double.infinity,
            height: 350,
            child: Center(
              child: CircularProgressIndicator(
                color: ColorRes.pink200,
              ),
            ),
          );
        } else if (provider.hasError || provider.valueOrNull == null) {
          return SizedBox(
              width: double.infinity,
              height: 350,
              child: ErrorView(
                () {
                  ref.invalidate(_desDataProvider);
                },
                textColor: Colors.white,
              ));
        } else {
          var data = provider.value!;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTabs(data.playList),
                buildPlayList(data.playList)
              ]);
        }
      },
    );
  }

  Widget buildTabs(List<HjDesPlayData> list) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
          controller: _tabScroller,
          itemCount: list.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var item = list[index];
            return SizedBox(
              width: 75.0,
              child: Consumer(
                builder: (context, ref, _) {
                  return TextButton(
                      child: Text(
                        item.title,
                        style: TextStyle(
                            fontSize: 18,
                            color: ref.watch(tabSelect) == index
                                ? ColorRes.pink300
                                : ColorRes.pink100),
                      ),
                      onPressed: () {
                        ref.watch(tabSelect.notifier).update((state) => index);
                      });
                },
              ),
            );
          }),
    );
  }

  Widget buildPlayList(List<HjDesPlayData> list) {
    return Consumer(builder: (context, ref, _) {
      var parentIndex = ref.watch(tabSelect);
      if(list.isEmpty || parentIndex > list.length - 1){
        return Container();
      }
      var element = list[parentIndex];
      return Wrap(
        children: buildChild(element, element.title),
      );
    });
  }

  List<Widget> buildChild(HjDesPlayData data, String parentTitle) {
    var list = <Widget>[];
    for (int index = 0; index < data.chapterList.length; index++) {
      var element = data.chapterList[index];
      list.add(
        SizedBox(
          width: 100.0,
          height: 55.0,
          child: Stack(
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
                      var title = widget.title + element.title;
                      updateHistory(widget.url, parentTitle, element.url);
                      ref.invalidate(_localHisFuture);
                      var cacheFile = getDownLoadFile(widget.url, element.url);
                      if (cacheFile != null) {
                        Navigator.of(context).push(FadeRoute(PlayPage(
                          cacheFile.path,
                          title,
                          fromLocal: true,
                        )));
                        printLongText("video from local file");
                        return;
                      }
                      var playUrl = getPlayUrlsCache(widget.url, element.url);
                      if (playUrl == null || playUrl.isEmpty) {
                        LoadingDialogHelper.showLoading(context);
                        playUrl = await HjApi.getPlayUrl(element.url);
                        updateChapterPlayUrls(widget.url, element.url, playUrl);
                        if (!mounted) return;
                        LoadingDialogHelper.dismissLoading(context);
                      }
                      if (!mounted) return;
                      Navigator.of(context).push(FadeRoute(PlayPage(
                        playUrl,
                        title,
                        fromLocal: false,
                      )));
                    },
                    child: Text(element.title)),
              ),
              Consumer(builder: (context, ref, _) {
                var localHistory = ref.watch(_localHisFuture);
                if (localHistory.value != null &&
                    (localHistory.value!.chapter) == parentTitle &&
                    localHistory.value!.chapterUrl == element.url) {
                  return const Positioned(
                    bottom: 5,
                    left: 30,
                    child: Text(
                      "上次观看",
                      style: TextStyle(color: ColorRes.pink400, fontSize: 10),
                    ),
                  );
                } else {
                  return Container();
                }
              })
            ],
          ),
        ),
      );
    }
    return list;
  }

  void _showDownLoadDialog(
      BuildContext context, WidgetRef ref, HjDesData? value) {
    if (value != null) {
      var downLoadChapter = getDownLoadChapters(widget.url);
      var chapters = value.playList.first.chapterList
          .map((e) => DownloadChapter(
              e.title,
              e.url,
              downLoadChapter
                      .where((element) => element.url == e.url)
                      .firstOrNull
                      ?.localCacheFileDir ??
                  ""))
          .toList();
      var downLoadBean =
          DownLoadBean(widget.logo, widget.title, widget.url, chapters);
      debugPrint("$downLoadBean");
      showDownloadBottomModel(context, ref, HAN_JU_VIDEO_TYPE,downLoadBean);
    }
  }
}
