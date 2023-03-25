import 'dart:async';

import 'package:flutter/material.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'android_keyboard_listener_method_channel.dart';

abstract class AndroidKeyboardListenerPlatform extends PlatformInterface {
  /// Constructs a AndroidKeyboardListenerPlatform.
  AndroidKeyboardListenerPlatform() : super(token: _token);

  static final Object _token = Object();

  static AndroidKeyboardListenerPlatform _instance =
      MethodChannelAndroidKeyboardListener();

  static AndroidKeyboardListenerPlatform get instance => _instance;

  static set instance(AndroidKeyboardListenerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  StreamSubscription<dynamic> onChange(ValueChanged<bool> onChange) {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
