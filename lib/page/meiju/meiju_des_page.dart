import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sakura_anime/bean/meiju_des_data.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';

class MjDesPage extends ConsumerStatefulWidget {
  final String logo;
  final String url;
  final String title;

  MjDesPage(this.logo, this.url, this.title);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MjDesPageState();
  }
}

class _MjDesPageState extends ConsumerState<MjDesPage> {
  late AutoDisposeFutureProvider<MjDesData> _desDataProvider;
  var controllerStore = <int, ScrollController>{};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _desDataProvider = FutureProvider.autoDispose((ref) async {
      var result = await MeiJuApi.getDesPage(widget.url);

      return result;
    });
  }

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
                                tag: widget.logo,
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
                              if (provider.value == null) {
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
                                      const Positioned(
                                          left: 10,
                                          child: Text(
                                            "10.0",
                                            style:
                                                TextStyle(color: Colors.white),
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
        debugPrint("data = $data");
        if (data == null) {
          return Container();
        } else {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: buildPlayList(data.playList));
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
            controller: controllerStore[parentIndex],
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
                        onPressed: () async {},
                        child: Text(element.chapterList[index].title)),
                  ),
                ],
              );
            }),
      ));
    }
    return child;
  }
}
