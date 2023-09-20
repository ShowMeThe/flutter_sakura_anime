import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_sakura_anime/bean/down_load_list_item.dart';
import 'package:flutter_sakura_anime/page/play_page.dart';
import 'package:flutter_sakura_anime/util/download.dart';
import 'package:flutter_sakura_anime/util/download_dialog.dart';

import '../../util/base_export.dart';
import '../../util/hj_api.dart';
import '../../widget/color_size_box.dart';

class DownLoadPage extends ConsumerStatefulWidget {
  const DownLoadPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return DownLoadPageState();
  }
}

class DownLoadPageState extends ConsumerState<DownLoadPage> {
  late AutoDisposeFutureProvider<List<DownLoadListItem>> _provider;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _provider = FutureProvider.autoDispose((ref) async {
      return getDownLoadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "下载",
          style: TextStyle(color: theme.textTheme.titleSmall!.color),
        ),
      ),
      body: Consumer(builder: (context, ref, _) {
        var value = ref
            .watch(_provider)
            .valueOrNull;
        return RefreshIndicator(
            onRefresh: () async {
              return ref.refresh(_provider);
            },
            child: buildList(value, theme));
      }),
    );
  }

  Widget buildList(List<DownLoadListItem>? value, ThemeData theme) {
    if (value == null || value.isEmpty) {
      return Center(
        child: Text(
          "下载列表为空",
          style: theme.textTheme.titleSmall,
        ),
      );
    } else {
      var list = value;
      return ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, index) {
            var item = list[index];
            return;
          })
    }
  }

  Widget buildBody(DownLoadListItem item) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                content:
                Text("是否删除${item.title}-${item.chapter}?"),
                actions: [
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      "否",
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      deleteDownChapter(item.showUrl, item.url);
                      ref.invalidate(_provider);
                    },
                    child: const Text("是",
                        style: TextStyle(
                            fontSize: 13, color: Colors.green)),
                  )
                ],
              );
            });
      },
      onTap: () {
        var mp4File =
        File("${item.localCacheFileDir}/play.mp4");
        if (mp4File.existsSync()) {
          Navigator.of(context).push(FadeRoute(PlayPage(
            mp4File.path,
            item.chapter,
            fromLocal: true,
          )));
        }
      },
      child: ColorSizeBox(
        url: item.imageUrl,
        width: double.infinity,
        height: 180,
        callback: (isBlack) {},
        shape: const RoundedRectangleBorder(
            borderRadius:
            BorderRadius.all(Radius.circular(12.0))),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: showImage(
                  item.imageUrl, 150, double.infinity),
            ),
            Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: 12.0, right: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            item.title,
                            style: TextStyle(
                                fontSize: item.title.length > 20
                                    ? 12
                                    : 15),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            item.chapter,
                            style: TextStyle(
                                fontSize: item.title.length > 20
                                    ? 12
                                    : 15),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            getShowContent(item.state),
                            style: TextStyle(
                                fontSize: item.title.length > 20
                                    ? 12
                                    : 15),
                          )),
                      Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Align(
                              alignment: Alignment.centerRight,
                              child: showDownLoadButton(item))),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  Widget showDownLoadButton(DownLoadListItem item) {
    if (item.state == DownloadChapter.STATE_DOWNLOAD) {
      return GestureDetector(
          onTap: () async {
            var inCall = Download.inDownLoadCall(item.url);
            printLongText("click = $inCall");
            if (!inCall) {
              var playUrl = getPlayUrlsCache(item.showUrl, item.url);
              if (playUrl != null) {
                Download.addDownLoadCall(item.showUrl, item.url);
                Download.downFile(item.url, playUrl);
              }
            }
          },
          child: const Icon(
            Icons.download,
            size: 40,
            color: Colors.white,
          ));
    } else {
      return Container();
    }
  }

  String getShowContent(int state) {
    if (state == DownloadChapter.STATE_DOWNLOAD) {
      return "下载中";
    } else {
      return "已下载";
    }
  }
}
