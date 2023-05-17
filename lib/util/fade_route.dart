import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FadeRoute extends CupertinoPageRoute {
  final Widget widget;

  FadeRoute(this.widget)
      : super(
          builder: (BuildContext context) {
            return widget;
          },
        );
}
