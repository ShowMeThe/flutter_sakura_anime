import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sakura_anime/bean/meiju_des_data.dart';
import 'package:flutter_sakura_anime/page/play_page.dart';
import 'package:flutter_sakura_anime/page/play_page_2.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';
import 'package:flutter_sakura_anime/widget/error_view.dart';

import '../../util/download_dialog.dart';
import '../../widget/fold_text.dart';

// ignore: must_be_immutable
class MjDesPage extends ConsumerStatefulWidget {
  final String logo;
  final String url;
  final String title;
  String heroTag = "";

  MjDesPage(this.logo, this.url, this.title, {super.key, this.heroTag = ""});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MjDesPageState();
  }
}

class _MjDesPageState extends ConsumerState<MjDesPage> {
  late AutoDisposeFutureProvider<MjDesData> _desDataProvider;

  late AutoDisposeFutureProvider<LocalHistory?> _localHisFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _desDataProvider = FutureProvider.autoDispose((ref) async {
      var result = await MeiJuApi.getDesPage(widget.url);

      return result;
    });

    _localHisFuture = FutureProvider.autoDispose((_) async {
      var result = findLocalHistory(widget.url);
      debugPrint("result $result");
      if (result == null) {
        return null;
      }
      return result;
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
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
                image: ExtendedNetworkImageProvider(widget.logo,
                    cache: true),
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
                              if (provider.valueOrNull == null ||
                                  provider.hasError) {
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
                                            data.score,
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
                                            child: const Padding(
                                              padding:
                                                  EdgeInsets.only(right: 4.0),
                                              child: Text(
                                                "",
                                                style: TextStyle(
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
                      if (provider.valueOrNull != null) {
                        var data = provider.value;
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.only(
                              left: 8.0, right: 8.0, top: 0.0),
                          child: FoldTextView(
                            data?.des == null ? "" : data!.des,
                            4,
                            const TextStyle(
                                color: Colors.white, fontSize: 12.0),
                            320,
                            moreTxColor: ColorRes.pink400,
                          ),
                        ));
                      } else {
                        return Container();
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
        var provider = ref.watch(_desDataProvider);
        if (provider.isLoading) {
          return const SizedBox(
              width: double.infinity,
              height: 350,
              child: Center(
                child: CircularProgressIndicator(
                  color: ColorRes.pink200,
                ),
              ));
        } else if (provider.valueOrNull == null || provider.hasError) {
          return SizedBox(
              width: double.infinity,
              height: 350,
              child: ErrorView(() {
                ref.invalidate(_desDataProvider);
              }));
        } else {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildPlayList(provider.value!.playList));
        }
      },
    );
  }

  List<Widget> buildPlayList(List<MjDesPlayData> list) {
    List<Widget> child = [];
    for (var parentIndex = 0; parentIndex < list.length; parentIndex++) {
      var element = list[parentIndex];
      child.add(Padding(
        padding: const EdgeInsets.only(top: 25, left: 16),
        child: Text(
          element.title,
          style: const TextStyle(
              color: ColorRes.pink50,
              fontSize: 18,
              fontWeight: FontWeight.w500),
        ),
      ));
      child.add(SizedBox(
        height: 58.0,
        child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: element.chapterList.length,
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
                          debugPrint("url = ${element.chapterList[index].url}");
                          var title =
                              widget.title + element.chapterList[index].title;
                          updateHistory(widget.url, element.title,
                              element.chapterList[index].url);
                          ref.invalidate(_localHisFuture);
                          var cacheFile = getDownLoadFile(widget.url, element.chapterList[index].url);
                          if (cacheFile != null) {
                            Navigator.of(context).push(FadeRoute(NewPlayPage(
                              cacheFile.path,
                              title,
                              fromLocal: true,
                            )));
                            printLongText("video from local file");
                            return;
                          }
                          var playUrl = getPlayUrlsCache(widget.url, element.chapterList[index].url);
                          if (playUrl == null || playUrl.isEmpty) {
                            LoadingDialogHelper.showLoading(context);
                            playUrl = await MeiJuApi.getPlayUrl(
                                element.chapterList[index].url);
                            updateChapterPlayUrls(widget.url, element.chapterList[index].url, playUrl);
                            if (!mounted) return;
                            LoadingDialogHelper.dismissLoading(context);
                          }
                          if (!mounted) return;
                          Navigator.of(context)
                              .push(FadeRoute(NewPlayPage(playUrl, title)));
                        },
                        child: Text(element.chapterList[index].title)),
                  ),
                  Consumer(builder: (context, ref, _) {
                    var localHistory = ref.watch(_localHisFuture);
                    if (localHistory.value != null &&
                        (localHistory.value!.chapter) == element.title &&
                        localHistory.value!.chapterUrl ==
                            element.chapterList[index].url) {
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


  void _showDownLoadDialog(
      BuildContext context, WidgetRef ref, MjDesData? value) {
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
      showDownloadBottomModel(context, ref, MEI_JU_VIDEO_TYPE,downLoadBean);
    }
  }


}
