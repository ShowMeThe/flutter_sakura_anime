export 'dart:math';
import 'package:flutter/cupertino.dart';
export 'package:auto_route/auto_route.dart';
export 'package:flutter_sakura_anime/widget/hidden_widget.dart';
import 'base_export.dart';
export 'package:elegant_spring_animation/elegant_spring_animation.dart';
export 'package:flutter_sakura_anime/util/http_client.dart';
export 'package:flutter/material.dart';
export 'package:html/parser.dart' show parse;
export 'package:flutter_riverpod/flutter_riverpod.dart';
export 'package:flutter_sakura_anime/util/static.dart';
export 'package:flutter_sakura_anime/gen_a/A.dart';
export 'package:flutter_sakura_anime/widget/score_shape_border.dart';
export 'package:extended_image/extended_image.dart';
export 'package:flutter/services.dart';
export 'package:flutter_sakura_anime/util/base_widget_function.dart';
export 'package:flutter_sakura_anime/util/style.dart';
export 'package:flutter_sakura_anime/style/database/DatabaseManager.dart';
export 'package:flutter_sakura_anime/widget/fold_text.dart';
export 'package:flutter_sakura_anime/bean/bean_export.dart';
export 'loading_dialog_helper.dart';
export 'package:flutter_sakura_anime/widget/error_view.dart';
export 'package:flutter_sakura_anime/widget/color_container.dart';
export 'package:flutter_sakura_anime/widget/search_app_bar.dart';
export 'package:flutter_sakura_anime/util/factory_api.dart';
export 'package:auto_size_text/auto_size_text.dart';
export 'package:flutter_sakura_anime/widget/shimmer_placeholder.dart';
export 'package:flutter_sakura_anime/widget/ball_cliprotate_pulse.dart';


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