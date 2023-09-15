import 'dart:io';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_session.dart';
import 'package:ffmpeg_kit_flutter/log.dart';
import 'package:ffmpeg_kit_flutter/statistics.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_hls_parser/flutter_hls_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_sakura_anime/util/http_client.dart';

import 'base_export.dart';

class Download {
  List<String> downLoadUrl = [];

  static void _postDownloadError(String url) {
    Fluttertoast.showToast(
        msg: "$url 下载失败",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: ColorRes.pink600,
        fontSize: 12.0);
  }

  static Future<String> getDownFileDir(String url) async{
    var fileName = md5.convert(utf8.encode(url)).toString();
    var cacheDir = await getTemporaryDirectory();
    var tempDir = Directory("${cacheDir.path}/video/$fileName");
    return tempDir.path;
  }

  static void downFile(String url) async {
    var fileName = md5.convert(utf8.encode(url)).toString();
    var cacheDir = await getTemporaryDirectory();
    var tempDir = Directory("${cacheDir.path}/video/$fileName");
    if (!tempDir.existsSync()) {
      tempDir.createSync(recursive: true);
    }
    var m3u8File = File("${tempDir.path}/play.m3u8");
    if (!m3u8File.existsSync()) {
      var dio = HttpClient.get3();
      var response = await dio.download(url, m3u8File.path);
      if (response.statusCode != 200) {
        _postDownloadError(url);
        return;
      }
    }
    downM3u8(url, tempDir, m3u8File);
  }

  static void downM3u8(String url, Directory segmentsDir, File m3u8File) async {
    HlsPlaylist? playList;
    try {
      playList = await HlsPlaylistParser.create()
          .parse(Uri.parse(url), await m3u8File.readAsLines());
    } on ParserException catch (e) {
      debugPrint(e.message);
    }
    debugPrint("${playList}");
    try {
      if (playList != null && playList is HlsMasterPlaylist) {
        final mediaPlaylistUrls = playList.mediaPlaylistUrls;
        final value = mediaPlaylistUrls[0];
        String tsUrl = "$value";
        var valueFile = File("${segmentsDir.path}/mixed.m3u8");
        if(!valueFile.existsSync()){
          valueFile.createSync();
          var dio = HttpClient.get3();
          var response = await dio.download(tsUrl, valueFile.path);
          if (response.statusCode != 200) {
            _postDownloadError(url);
            return;
          }
        }
        downMix(tsUrl, segmentsDir, valueFile);
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  static void downMix(String url, Directory segmentsDir, File mixFile) async {
    HlsPlaylist? playList;
    debugPrint("mixurl ${url}");
    var host = url.substring(0, url.lastIndexOf("/"));
    try {
      playList = await HlsPlaylistParser.create()
          .parse(Uri.parse(url), await mixFile.readAsLines());
    } on ParserException catch (e) {
      debugPrint(e.message);
    }
    if (playList != null && playList is HlsMediaPlaylist) {
      final mediaPlaylistUrls = playList.segments.map((e) => e.url);
      await compute(
          computeDownload, ComputeData(host, segmentsDir, mediaPlaylistUrls));
      combineAll(segmentsDir);
    }
  }

  static void computeDownload(ComputeData data) async {
    for (var url in data.mediaPlaylistUrls) {
      var tls = "${data.host}/$url";
      debugPrint("tls = $tls");
      var tlsFile = File("${data.segmentsDir.path}/$url");
      if (!tlsFile.existsSync()) {
        await HttpClient.get3().download(tls, tlsFile.path);
      }
    }
  }

  static void combineAll(Directory segmentsDir) {
    var m3u8File = File("${segmentsDir.path}/mixed.m3u8");
    var playFile = File("${segmentsDir.path}/play.mp4");
    String cmd =
        '-allowed_extensions ALL -i ${m3u8File.path}  ${playFile.path}';
    FFmpegKit.executeAsync(cmd, (FFmpegSession session) {
      debugPrint(
          'DownloadUtil, FFmpegKit session completeCallback cmd=${session.getCommand()}');
    }, (Log log) {
      debugPrint('DownloadUtil, FFmpegKit log===${log.getMessage()}');
    }, (Statistics statistics) {
      debugPrint(
          'DownloadUtil, FFmpegKit statistics===${statistics.getTime()}');
    });
  }
}

class ComputeData {
  final String host;
  final Directory segmentsDir;
  final Iterable<String?> mediaPlaylistUrls;

  ComputeData(this.host, this.segmentsDir, this.mediaPlaylistUrls);
}
