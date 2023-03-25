import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'android_keyboard_listener_platform_interface.dart';

/// An implementation of [AndroidKeyboardListenerPlatform] that uses method channels.
class MethodChannelAndroidKeyboardListener
    extends AndroidKeyboardListenerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final eventChannel = const EventChannel('android_keyboard_listener');
  static final _onChangeController = StreamController<bool>();

  @override
  StreamSubscription<dynamic> onChange(ValueChanged<bool> onChange) {
    return eventChannel.receiveBroadcastStream().listen((data) {
      if (data is int) {
        onChange(data == 1);
      }
    });
  }
}
