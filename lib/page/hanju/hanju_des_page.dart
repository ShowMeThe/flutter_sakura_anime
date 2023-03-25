import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sakura_anime/bean/meiju_des_data.dart';
import 'package:flutter_sakura_anime/page/play_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/hj_api.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';

import '../../bean/hanju_des_data.dart';
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


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _desDataProvider = FutureProvider.autoDispose((ref) async {
      var result = await HjApi.getHjDes(widget.url);

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
    var size = MediaQuery.of(context).size;
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
                        ],
                      ),
                    ),
                    Center(
                      child: SizedBox(
                        width: size.width / 3,
                        child: Stack(
                          children: [
                            Hero(
                                tag: widget.logo + widget.heroTag,
                                child: Image(
                                  image: ExtendedNetworkImageProvider(
                                      widget.logo,
                                      cache: true),
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  height: 200,
                                )),
                            Consumer(builder: (context, ref, _) {
                              var provider = ref.watch(_desDataProvider);
                              if (provider.value == null || provider.hasError) {
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
                      if (provider.value != null) {
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
                              320),
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
        var data = ref.watch(_desDataProvider).value;
        if (data == null) {
          return Container();
        } else {
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
      child: Consumer(
        builder: (context, ref, _) {
          var selectedIndex = ref.watch(tabSelect);
          return ListView.builder(
              itemCount: list.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                var item = list[index];
                return TextButton(
                    child: Text(
                      item.title,
                      style: TextStyle(
                          fontSize: 18,
                          color: selectedIndex == index
                              ? ColorRes.pink300
                              : ColorRes.pink100),
                    ),
                    onPressed: () {
                      ref.refresh(tabSelect.state).update((state) => index);
                    });
              });
        },
      ),
    );
  }

  // List<Widget> buildPlayList(List<HjDesPlayData> list){
  //    return
  // }

  Widget buildPlayList(List<HjDesPlayData> list) {
    return Consumer(builder: (context, ref, _) {
      var parentIndex = ref.watch(tabSelect);
      var element = list[parentIndex];
      return Wrap(
        children: buildChild(element,parentIndex),
      );
    });
  }

  List<Widget> buildChild(HjDesPlayData data,int parentIndex) {
    var list = <Widget>[];
    for(int index = 0; index < data.chapterList.length;index++){
      var element = data.chapterList[index];
      list.add(
        SizedBox(
          width: 90.0,
          height: 45.0,
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
                      LoadingDialogHelper.showLoading(context);
                      var title = widget.title + element.title;
                      updateHistory(
                          widget.url, parentIndex, index);
                      ref.refresh(_localHisFuture);
                      var url = await HjApi.getPlayUrl(element.url);
                      debugPrint("url = $url");
                      if (!mounted) return;
                      LoadingDialogHelper.dismissLoading(context);
                      Navigator.of(context).push(FadeRoute(PlayPage(
                        url,
                        title,
                        fromLocal: true,
                      )));
                    },
                    child: Text(element.title)),
              ),
              Consumer(builder: (context, ref, _) {
                var localHistory = ref.watch(_localHisFuture);
                if (localHistory.value != null &&
                    (localHistory.value!.chapterIndex) == index &&
                    localHistory.value!.chapter == parentIndex) {
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
          ),
        ),
      );
    }
    return list;
  }

}
