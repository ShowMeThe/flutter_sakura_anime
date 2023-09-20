

import 'package:flutter_sakura_anime/util/download_dialog.dart';

class DownLoadListItem{

  String imageUrl;
  String title;
  String showUrl;
  String chapter;
  String url;
  int state = DownloadChapter.STATE_DOWNLOAD;
  String localCacheFileDir = "";

  DownLoadListItem(this.imageUrl, this.title, this.showUrl, this.chapter, this.url,
      this.state, this.localCacheFileDir);

  @override
  String toString() {
    return 'DownLoadListItem{imageUrl: $imageUrl, title: $title, showUrl: $showUrl, chapter: $chapter, url: $url, state: $state, localCacheFileDir: $localCacheFileDir}';
  }
}