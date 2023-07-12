import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_meedu_videoplayer/src/widgets/meedu_video_player.dart';
import 'package:flutter_meedu_videoplayer/src/controller.dart';
import 'package:flutter_meedu_videoplayer/src/helpers/data_source.dart';
import 'package:flutter_meedu_videoplayer/src/helpers/enabled_controls.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:video_player/video_player.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:device_display_brightness/device_display_brightness.dart';
import 'package:wakelock/wakelock.dart';

// ignore: must_be_immutable
class PlayPage extends ConsumerStatefulWidget {
  final String url;
  final String title;
  var fromLocal = false;

  PlayPage(this.url, this.title, {super.key, this.fromLocal = false});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayState();
}

class _PlayState extends ConsumerState<PlayPage> {
  var _totalDuration = 0;
  final _slideX = StateProvider.autoDispose<Duration>(
          (ref) => const Duration(milliseconds: 0));
  final _isShowSlideDialog = StateProvider.autoDispose<bool>((ref) => false);
  final _isShowBrightDialog = StateProvider.autoDispose<bool>((ref) => false);
  final _brightness = FutureProvider.autoDispose<double>((ref) async {
    return await DeviceDisplayBrightness.getBrightness();
  });
  var _slideValue = 0.0;
  var _downPosition = 0;
  var _downVolumeY = 0.0;
  var _downVolume = 0.0;
  var _downX = 0.0;
  var _downY = 0.0;
  var _downBrightness = 0.0;
  var _nextBrightness = 0.0;
  var _isSeeking = false;
  var _isSeekingChange = false;
  var _isVolume = false;
  var _isBrightness = false;
  var _disposed = false;
  VideoPlayerValue? _videoPlayerValue;
  late StreamSubscription<double> _subscription;

  final _meeduPlayerController = MeeduPlayerController(
    controlsStyle: ControlsStyle.primary,
  );

  final _bufferReady = AutoDisposeStateProvider((ref) => false);

  @override
  void initState() {
    _disposed = false;
    super.initState();
    Wakelock.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });


    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);


    DeviceDisplayBrightness.getBrightness().then((value) {});
    _subscription = PerfectVolumeControl.stream.listen((value) {});
    PerfectVolumeControl.hideUI = false;
  }

  void _init() async {
    if (widget.fromLocal) {
      _meeduPlayerController.setDataSource(
        DataSource(
          type: DataSourceType.file,
          source: widget.url,
        ),
        autoplay: true,
      );
    } else {
      _meeduPlayerController.setDataSource(
        DataSource(
          type: DataSourceType.network,
          source: widget.url,
        ),
        autoplay: true,
      );
    }

    _meeduPlayerController.bufferedPercent.stream.listen((event) {
      var position = event;
      var state = ref.watch(_bufferReady);
      if (!state && position > 0) {
        ref
            .watch(_bufferReady.notifier)
            .state = true;
        var playHistory = findLocalPlayHistory(widget.url);
        if (playHistory != null) {
          var duration = Duration(milliseconds: playHistory.timeInMills);
          _meeduPlayerController
              .seekTo(duration);
          ref.watch(_slideX.notifier).update((state) => duration);
        }
        _meeduPlayerController
          ..videoFit.value = BoxFit.contain
          ..fullscreen.value = true;
        ;
      }
    });

    _delayToMarkSlide();
  }

  /// 最高两秒误差
  void _delayToMarkSlide() async {
    while (!_disposed) {
      await Future.delayed(const Duration(seconds: 2));
      updatePlayHistory(widget.url,
          _meeduPlayerController.sliderPosition.value.inMilliseconds);
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _meeduPlayerController.dispose();
    _subscription.cancel();

    super.dispose();

    DeviceDisplayBrightness.resetBrightness();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      var media = MediaQuery.sizeOf(context);
      var padding = MediaQuery.paddingOf(context);
      var sizeHeight = (media.width - padding.top) / 2.0;
      var sizeWidth = media.height;
      if (!ref.watch(_bufferReady)) {
        return Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: const Center(
            child: CircularProgressIndicator(
              color: ColorRes.pink400,
            ),
          ),
        );
      } else {
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              Positioned.fill(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: MeeduVideoPlayer(
                    controller: _meeduPlayerController,
                  ),
                ),
              ),
              Positioned(
                  left: 55,
                  right: sizeHeight + 55,
                  top: 85,
                  bottom: 85,
                  child: GestureDetector(
                    onTap: () {},
                    onPanEnd: (details) {
                      _isBrightness = false;
                      ref
                          .watch(_isShowBrightDialog.notifier)
                          .update((state) => false);
                    },
                    onPanDown: (detail) async {
                      _downY = detail.globalPosition.dy;
                      _downBrightness =
                      await DeviceDisplayBrightness.getBrightness();
                      debugPrint("_downBrightness $_downBrightness");
                    },
                    onPanUpdate: (details) async {
                      if (!_isBrightness) {
                        ref
                            .watch(_isShowBrightDialog.notifier)
                            .update((state) => true);
                      }
                      var dy = details.globalPosition.dy;
                      var offsetY = (_downY - dy) / sizeWidth;
                      _nextBrightness =
                          min(max(0.0, _downBrightness + offsetY * 0.5), 1.0);
                      DeviceDisplayBrightness.setBrightness(_nextBrightness);

                      ref.invalidate(_brightness);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(),
                  )),
              Positioned(
                left: sizeHeight + 55,
                right: 55,
                top: 105,
                bottom: 105,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (details) async {
                    _downVolumeY = details.globalPosition.dy;
                    _downVolume = await PerfectVolumeControl.getVolume();
                    _slideValue = 0;
                    _downX = details.globalPosition.dy;
                    _downY = details.globalPosition.dx;

                    var duration = _meeduPlayerController
                        .sliderPosition.value;
                    _downPosition = duration.inMilliseconds;
                    ref.watch(_slideX.notifier).update((state) => duration);
                  },
                  onTap: () {},
                  onPanUpdate: (details) async {
                    var dx = details.delta.dx;

                    var nextX = details.globalPosition.dy - _downX;
                    var nextY = details.globalPosition.dx - _downY;

                    if (nextX.abs() < 6 && nextY.abs() < 6) return;

                    if (!_isSeeking && !_isBrightness) {
                      if (nextX.abs() > nextY.abs()) {
                        _isVolume = true;
                      } else {
                        _isSeeking = true;
                      }
                    }

                    if (_isSeeking) {
                      _slideValue += dx;
                      if (_slideValue.abs() > 45.0) {
                        _isSeekingChange = true;
                        ref
                            .read(_isShowSlideDialog.notifier)
                            .update((state) => true);
                        var offset = 60 * 1000 * _slideValue ~/ sizeHeight;
                        var nextValue = (_downPosition + offset);
                        if (_totalDuration == 0) {
                          _totalDuration = _meeduPlayerController
                              .duration.value.inMilliseconds;
                        }
                        if (nextValue >= _totalDuration) {
                          nextValue = _totalDuration;
                        } else if (nextValue <= 0) {
                          nextValue = 0;
                        }
                        ref.watch(_slideX.notifier).update(
                                (state) => Duration(milliseconds: nextValue));
                      }
                    } else if (_isVolume) {
                      var offset = _downVolumeY - details.globalPosition.dy;
                      var nextVolume = _downVolume + offset / sizeWidth;
                      if (nextVolume >= 1) {
                        nextVolume = 1.0;
                      } else if (nextVolume <= 0) {
                        nextVolume = 0;
                      }
                      PerfectVolumeControl.setVolume(nextVolume);
                    }
                  },
                  onPanEnd: (details) {
                    if (_isSeeking && _isSeekingChange) {
                      ref
                          .watch(_isShowSlideDialog.notifier)
                          .update((state) => false);
                      _meeduPlayerController.seekTo(ref.read(_slideX));
                    }
                    _isSeekingChange = false;
                    _isSeeking = false;
                  },
                  child: Container(),
                ),
              ),
              IgnorePointer(
                ignoring: true,
                child: Align(
                  child: Consumer(builder: (context, ref, _) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: ref.watch(_isShowSlideDialog) ? 1.0 : 0.0,
                      child: Text(
                        "${getTimeInDuration(
                            ref.watch(_slideX))}/${getTimeInDuration(
                            Duration(milliseconds: _totalDuration))}",
                        style: const TextStyle(
                            fontSize: 30.0, color: ColorRes.pink100),
                      ),
                    );
                  }),
                ),
              ),
              IgnorePointer(
                ignoring: true,
                child: Align(
                  child: Consumer(builder: (context, ref, _) {
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: ref.watch(_isShowBrightDialog) ? 1.0 : 0.0,
                      child: Text(
                        "${((ref
                            .watch(_brightness)
                            .value ?? 0) * 100).toInt()}%",
                        style: const TextStyle(
                            fontSize: 30.0, color: ColorRes.pink100),
                      ),
                    );
                  }),
                ),
              )
            ],
          ),
        );
      }
    });
  }

  String getTimeInDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes =
    duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    String seconds =
    duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours == "0") {
      return "$minutes:$seconds";
    } else {
      return "$hours:$minutes:$seconds";
    }
  }
}
