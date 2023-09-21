import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'base_export.dart';

export 'package:flutter_sakura_anime/util/http_client.dart';
export 'package:flutter/material.dart';
export 'package:html/parser.dart' show parse;
export 'package:flutter_sakura_anime/bean/anime_home_data.dart';
export 'package:flutter_sakura_anime/bean/anime_des_data.dart';
export 'package:flutter_sakura_anime/bean/anime_drams_data.dart';
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:flutter_sakura_anime/util/static.dart';
export 'package:flutter_sakura_anime/gen_a/A.dart';
export 'package:flutter_sakura_anime/util/fade_route.dart';
export 'package:flutter_sakura_anime/widget/score_shape_border.dart';
export 'package:extended_image/extended_image.dart';
export 'package:flutter_sakura_anime/util/api.dart';
export 'package:flutter/services.dart';
export 'package:flutter_sakura_anime/util/collect.dart';
export 'package:flutter_sakura_anime/bean/anime_movie_data.dart';
export 'package:flutter_sakura_anime/page/loading_dialog_helper.dart';
export 'package:flutter_sakura_anime/util/base_widget_function.dart';
export 'package:flutter_sakura_anime/util/style.dart';

void printLongText(String? msg) {
  if (msg == null) {
    debugPrint(msg);
    return;
  }
  int maxStrLength = 1000;
  while (msg!.length > maxStrLength) {
    debugPrint(msg.substring(0, maxStrLength));
    msg = msg.substring(maxStrLength);
  }
  debugPrint(msg);
}


void toast(String message) {
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.white,
      textColor: ColorRes.pink600,
      fontSize: 12.0);
}