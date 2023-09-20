import 'dart:ui';
import 'package:flutter_sakura_anime/util/download.dart';
import 'package:json_annotation/json_annotation.dart';
import 'base_export.dart';
import 'hj_api.dart';

part 'download_dialog.g.dart';

class DownLoadBean {
  String imageUrl;
  String title;
  String showUrl;
  List<DownloadChapter> chapter;

  DownLoadBean(this.imageUrl, this.title, this.showUrl, this.chapter);

  @override
  String toString() {
    return 'DownLoadBean{imageUrl: $imageUrl, title: $title, chapter: $chapter}';
  }
}


@JsonSerializable()
class DownloadChapter {

  static int STATE_DOWNLOAD = 1;
  static int STATE_COMPLETE = 2;

  String chapter;
  String url;
  int state = STATE_DOWNLOAD;
  String localCacheFileDir = "";

  DownloadChapter(this.chapter, this.url, this.localCacheFileDir);


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadChapter &&
          runtimeType == other.runtimeType &&
          chapter == other.chapter &&
          url == other.url &&
          state == other.state &&
          localCacheFileDir == other.localCacheFileDir;

  @override
  int get hashCode =>
      chapter.hashCode ^
      url.hashCode ^
      state.hashCode ^
      localCacheFileDir.hashCode;


  @override
  String toString() {
    return 'DownloadChapter{chapter: $chapter, url: $url, state: $state, localCacheFileDir: $localCacheFileDir}';
  }

  factory DownloadChapter.fromJson(Map<String, dynamic> json) =>
      _$DownloadChapterFromJson(json);

  Map<String, dynamic> toJson() => _$DownloadChapterToJson(this);
}

void showDownloadBottomModel(
    BuildContext context, WidgetRef ref, DownLoadBean downLoadBean) {
  var onDownLoadProvider = StateProvider.autoDispose((ref) => downLoadBean
      .chapter
      .where((element) => element.localCacheFileDir.isNotEmpty)
      .toList());

  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))),
      builder: (context) {
        return SizedBox(
          width: double.infinity,
          height: 450,
          child: Stack(
            children: [
              ExtendedImage.network(
                downLoadBean.imageUrl,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                child: Container(),
              ),
              GridView.count(
                crossAxisCount: 4,
                shrinkWrap: true,
                childAspectRatio: 1.5,
                children: buildChild(downLoadBean.chapter, onDownLoadProvider,
                    (chapter) async {
                  _addBackMission(context, downLoadBean.showUrl, chapter,
                      (newChapter) {
                    var value = ref.read(onDownLoadProvider);
                    value.add(newChapter);
                    ref.refresh(onDownLoadProvider.notifier).state = value;


                    var index = downLoadBean.chapter.indexWhere(
                        (element) => element.chapter == newChapter.chapter);
                    if (index != -1) {
                      downLoadBean.chapter[index] = newChapter;
                      updateDownLoadChapter(downLoadBean);
                    }
                  });
                }),
              )
            ],
          ),
        );
      });
}

void _addBackMission(BuildContext context, String showUrl,
    DownloadChapter chapter, CacheFileUpdateCallbackBack callbackBack) async {
  var playUrl = getPlayUrlsCache(showUrl, chapter.url);
  if (playUrl == null) {
    LoadingDialogHelper.showLoading(context);
    playUrl = await HjApi.getPlayUrl(chapter.url);
    updateChapterPlayUrls(showUrl, chapter.url, playUrl);
    if (!context.mounted) return;
    LoadingDialogHelper.dismissLoading(context);
  }
  var filePath = await Download.getDownFileDir(playUrl);
  chapter.localCacheFileDir = filePath;
  callbackBack(chapter);
  debugPrint("start downLoad");
  Download.addDownLoadCall(showUrl, chapter.url);
  Download.downFile(chapter.url,playUrl);

}

typedef UrlCallbackBack = Function(DownloadChapter chapter);

typedef CacheFileUpdateCallbackBack = Function(DownloadChapter newChapter);

List<Widget> buildChild(
    List<DownloadChapter> chapters,
    AutoDisposeStateProvider<List<DownloadChapter>> provider,
    UrlCallbackBack callbackBack) {
  return chapters.map((e) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Consumer(
        builder: (context, ref, _) {
          var showIcon = ref.watch(provider).contains(e);
          return Stack(
            children: [
              MaterialButton(
                  height: double.infinity,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0)),
                  color: ColorRes.mainColor,
                  onPressed: () {
                    if (!showIcon) {

                    }
                    callbackBack(e);
                  },
                  child: Text(e.chapter)),
              showDownIcon(showIcon)
            ],
          );
        },
      ),
    );
  }).toList();
}

Widget showDownIcon(bool show) {
  if (show) {
    return const Align(
      alignment: Alignment.bottomRight,
      child: Icon(
        Icons.download,
        color: Colors.green,
      ),
    );
  } else {
    return Container();
  }
}
