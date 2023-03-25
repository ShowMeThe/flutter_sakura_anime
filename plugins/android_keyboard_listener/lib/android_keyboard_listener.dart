import 'dart:async';

import 'package:flutter/material.dart';

import 'android_keyboard_listener_platform_interface.dart';

class AndroidKeyboardListener {

  static StreamSubscription<dynamic> onChange(ValueChanged<bool> onChange) {
    return AndroidKeyboardListenerPlatform.instance.onChange(onChange);
  }
}
