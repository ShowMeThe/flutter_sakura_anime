import 'dart:convert';

import 'package:html/dom.dart' as dom;
import 'base_export.dart';
import 'http_client.dart';

class MeiJuApi {
  static const String baseUrl = "https://wap.meijutt.tv";

  static Future<void> getHomeData() async {
    var future = await (await HttpClient.get().catchError((onError) {
      debugPrint("onError $onError");
    }))
        .get(baseUrl)
        .catchError((err) {
      debugPrint("err $err");
    });
    debugPrint("future = ${future}");


  }
}
