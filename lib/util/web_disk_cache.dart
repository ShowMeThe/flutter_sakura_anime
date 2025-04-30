import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'package:flutter_disk_lru_cache/flutter_disk_lru_cache.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

import 'base_export.dart';

class WebCache {
  static DiskLruCache? diskLruCache;

  static init() async {
    Directory tempDirectory = await getTemporaryDirectory();
    diskLruCache ??= await DiskLruCache.open(tempDirectory,
        valueCount: 2, version: "1.0.0", maxSize: 50 * 1024 * 1024);
  }

  static final _diskCache = diskLruCache!;

  static void put(String url, String value) async {
    try {
      if(value.isEmpty) return;
      String key = md5.convert(utf8.encode(url)).toString();
      Editor? editor = await _diskCache.edit(key);
      if (editor == null) {
        return;
      }
      FaultHidingIOSink ioValue = editor.newOutputIOSink(0);
      await ioValue.write(value);
      await ioValue.flush();
      await ioValue.close();

      FaultHidingIOSink timeValue = editor.newOutputIOSink(1);
      await timeValue.write(DateTime.now().millisecondsSinceEpoch.toString());

      await timeValue.flush();
      await timeValue.close();
      await editor.commit(_diskCache);
      debugPrint("disk put value success");
    } catch (e) {
      debugPrint("disk put value error $e");
    }
  }

  static Future<String?> get(String url) async {
    try{
      String key = md5.convert(utf8.encode(url)).toString();
      Snapshot? snapshot = await _diskCache.get(key);
      if (snapshot == null) {
        return null;
      }

      RandomAccessFile timeFile = snapshot.getRandomAccessFile(1);
      Uint8List bytes = timeFile.readSync(snapshot.getLength(1));
      String time = utf8.decode(bytes);
      int lastTime = int.parse(time);
      debugPrint("last time is $lastTime");
      int currentTime = DateTime.now().millisecondsSinceEpoch;
      if (currentTime - lastTime >= 1 * 60 * 60 * 1000) {
        debugPrint("time is differ");
        return null;
      }
      RandomAccessFile valueFile = snapshot.getRandomAccessFile(0);
      String value = utf8.decode(valueFile.readSync(snapshot.getLength(0)));
      snapshot.close();
      return value;
    }catch(e){
      debugPrint("disk get value error $e");
    }
    return null;
  }
}
