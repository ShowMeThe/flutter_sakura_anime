import 'dart:collection';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
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

typedef DownloadCallbackBack = Function(String chapterUrl, double progress);

class _Progress {
  String chapterUrl;
  double progress;

  _Progress(this.chapterUrl, this.progress);
}

class Download {
  static final HashMap<String, String> _downLoadUrls = HashMap();

  static void addDownLoadCall(String showUrl, String chapterUrl) {
    _downLoadUrls[chapterUrl] = showUrl;
  }

  static DownloadCallbackBack? _downFunction;

  static addDownFunction(DownloadCallbackBack downFunction) {
    _downFunction = downFunction;
  }

  static removeDownFunction() {
    _downFunction = null;
  }

  static bool inDownLoadCall(String chapterUrl) {
    return _downLoadUrls.containsKey(chapterUrl);
  }

  static void _postDownloadError(String url) {
    Fluttertoast.showToast(
        msg: "$url 下载失败",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: ColorRes.pink600,
        fontSize: 12.0);
  }

  static Future<String> getDownFileDir(String url) async {
    var fileName = md5.convert(utf8.encode(url)).toString();
    var cacheDir = await getTemporaryDirectory();
    var tempDir = Directory("${cacheDir.path}/video/$fileName");
    return tempDir.path;
  }

  static void downFile(String chapterUrl, String url) async {
    var fileName = md5.convert(utf8.encode(url)).toString();
    var cacheDir = await getTemporaryDirectory();
    var tempDir = Directory("${cacheDir.path}/video/$fileName");
    var mp4File = File("${tempDir.path}/play.mp4");
    if (mp4File.existsSync()) {
      var showUrl = _downLoadUrls[chapterUrl];
      if (showUrl != null) {
        updateDownLoadChapterState(showUrl, chapterUrl);
        _downLoadUrls.remove(chapterUrl);
      }
      return;
    }
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
    downM3u8(chapterUrl, url, tempDir, m3u8File);
  }

  static void downM3u8(String chapterUrl, String url, Directory segmentsDir,
      File m3u8File) async {
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
        if (!valueFile.existsSync()) {
          valueFile.createSync();
          var dio = HttpClient.get3();
          var response = await dio.download(tsUrl, valueFile.path);
          if (response.statusCode != 200) {
            _postDownloadError(url);
            return;
          }
        }
        downMix(chapterUrl, tsUrl, segmentsDir, valueFile);
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  static void downMix(String chapterUrl, String url, Directory segmentsDir,
      File mixFile) async {
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
      var receiverPort = ReceivePort();
      var args = <dynamic>[];
      args.add(receiverPort.sendPort);
      args.add(ComputeData(chapterUrl, host, segmentsDir, mediaPlaylistUrls));
      receiverPort.listen((message) {
        if (_downFunction != null && message is _Progress) {
          _downFunction!(message.chapterUrl, message.progress);
        }
      });
      await compute(computeDownload, args);
      receiverPort.close();
      combineAll(chapterUrl, segmentsDir, mediaPlaylistUrls);
    }
  }

  static void computeDownload(List<dynamic> args) async {
    ComputeData data = args[1];
    SendPort sendPort = args[0];
    var index = 0;
    var length = data.mediaPlaylistUrls.length + 1;
    for (var url in data.mediaPlaylistUrls) {
      var httpIndex = url?.indexOf("http") ?? -1;
      var tls = "";
      if (httpIndex == -1) {
        tls = "${data.host}/$url";
      } else {
        tls = url?.substring(httpIndex) ?? "";
      }
      debugPrint("tls = $tls");
      index++;
      sendPort.send(_Progress(data.chapterUrl, index / length));
      if (tls.isEmpty) return;
      var tlsFile = File("${data.segmentsDir.path}/$url");
      if (!tlsFile.existsSync()) {
        int tryCount = 0;
        while (true) {
          try {
            await HttpClient.get3().download(tls, tlsFile.path);
            break;
          } catch (e) {
            printLongText("$e");
            if (tryCount < 5) {
              tryCount++;
              break;
            }
          }
        }
      }
    }
  }

  static void combineAll(
    String chapterUrl,
    Directory segmentsDir,
    Iterable<String?> list,
  ) {
    String text = "concat:";
    var playFile = File("${segmentsDir.path}/play.mp4");
    var tlsFiles = <File>[];
    for (String? url in list) {
      var tlsFile = File("${segmentsDir.path}/$url");
      if (tlsFile.existsSync()) {
        tlsFiles.add(tlsFile);
        text += "${tlsFile.path}|";
      }
    }
    String cmd = "-i ${text} -c copy ${playFile.path}";
    FFmpegKit.executeAsync(cmd, (FFmpegSession session) async {
      debugPrint(
          'DownloadUtil, FFmpegKit session completeCallback cmd=${session.getCommand()}');
      var code = await session.getReturnCode();
      if (code?.isValueSuccess() == true) {
        for (var element in tlsFiles) {
          element.delete();
        }
        var showUrl = _downLoadUrls[chapterUrl];
        if (showUrl != null) {
          updateDownLoadChapterState(showUrl, chapterUrl);
          if (_downFunction != null) {
            _downFunction!(chapterUrl, 1);
          }
        }
      }
    }, (Log log) {
      debugPrint('DownloadUtil, FFmpegKit log===${log.getMessage()}');
    }, (Statistics statistics) {
      debugPrint(
          'DownloadUtil, FFmpegKit statistics===${statistics.getTime()}');
    });
  }
}

class ComputeData {
  final String chapterUrl;
  final String host;
  final Directory segmentsDir;
  final Iterable<String?> mediaPlaylistUrls;

  ComputeData(
      this.chapterUrl, this.host, this.segmentsDir, this.mediaPlaylistUrls);
}
