import 'dart:async';
import 'dart:math';

import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/util/api.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:video_player/video_player.dart';
import 'package:perfect_volume_control/perfect_volume_control.dart';
import 'package:device_display_brightness/device_display_brightness.dart';

class AnimePlayPage extends ConsumerStatefulWidget {
  final String url;
  final String title;

  const AnimePlayPage(this.url, this.title, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimePlayState();
}

class _AnimePlayState extends ConsumerState<AnimePlayPage> {
  late AutoDisposeFutureProvider<String> _playNowUrlProvider;
  final AutoDisposeStateProvider<FlickManager?> _initProvider =
      StateProvider.autoDispose<FlickManager?>((ref) => null);
  VideoPlayerController? _controller;
  FlickManager? flickManager;
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
  VideoPlayerValue? _videoPlayerValue;
  late StreamSubscription<double> _subscription;

  @override
  void initState() {
    super.initState();
    _playNowUrlProvider = FutureProvider.autoDispose<String>((ref) async {
      var playerUrl = await Api.getAnimePlayUrl(widget.url);
      refreshController(playerUrl);
      return playerUrl;
    });
    ref.refresh(_playNowUrlProvider);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

    DeviceDisplayBrightness.getBrightness().then((value) {});
    _subscription = PerfectVolumeControl.stream.listen((value) {});
    PerfectVolumeControl.hideUI = false;
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    DeviceDisplayBrightness.resetBrightness();
    _subscription.cancel();
    flickManager?.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  void refreshController(String playerUrl) async {
    if (_controller != null) {
      _controller?.dispose();
    }
    var controller = VideoPlayerController.network(playerUrl);
    await controller.initialize();
    _controller = controller;

    flickManager = FlickManager(videoPlayerController: controller);
    await flickManager?.flickControlManager?.play();
    flickManager?.flickDisplayManager?.hidePlayerControls();

    _videoPlayerValue = flickManager?.flickVideoManager?.videoPlayerValue;

    _totalDuration = _videoPlayerValue?.duration.inMilliseconds ?? 0;

    ref.read(_initProvider.state).state = flickManager;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      var watch = ref.watch(_playNowUrlProvider);
      var controller = ref.watch(_initProvider);
      var media = MediaQuery.of(context);
      var sizeHeight = (media.size.width - media.padding.top) / 2.0;
      var sizeWidth = media.size.height;
      if (watch.isRefreshing || controller == null) {
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
              Positioned(
                  left: 65.0,
                  top: 0,
                  bottom: 0,
                  right: 65,
                  child: FlickVideoPlayer(
                    flickManager: controller,
                    systemUIOverlayFullscreen: const [],
                    systemUIOverlay: const [],
                    preferredDeviceOrientation: const [
                      DeviceOrientation.landscapeLeft
                    ],
                  )),
              Positioned(
                  left: 55,
                  right: sizeHeight + 55,
                  top: 85,
                  bottom: 85,
                  child: GestureDetector(
                    onTap: () {
                      var isShow = flickManager
                              ?.flickDisplayManager?.showPlayerControls ??
                          false;
                      if (!isShow) {
                        flickManager?.flickDisplayManager
                            ?.handleShowPlayerControls();
                      }
                    },
                    onPanEnd: (details) {
                      _isBrightness = false;
                      ref
                          .watch(_isShowBrightDialog.state)
                          .update((state) => false);
                    },
                    onPanDown: (detail) async {
                      _downY = detail.globalPosition.dy;
                      _downBrightness =
                          await DeviceDisplayBrightness.getBrightness();
                    },
                    onPanUpdate: (details) async {
                      if (!_isBrightness) {
                        ref
                            .watch(_isShowBrightDialog.state)
                            .update((state) => true);
                      }
                      var dy = details.globalPosition.dy;
                      var offsetY = (_downY - dy) / sizeWidth;
                      _nextBrightness =
                          min(max(0.0, _downBrightness + offsetY * 0.5), 1.0);
                      DeviceDisplayBrightness.setBrightness(_nextBrightness);
                      ref.refresh(_brightness);
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
                    _downPosition = controller.flickVideoManager
                            ?.videoPlayerValue?.position.inMilliseconds ??
                        0;
                    ref.read(_slideX.state).update(
                        (state) => Duration(milliseconds: _downPosition));
                  },
                  onTap: () {
                    var isShow =
                        flickManager?.flickDisplayManager?.showPlayerControls ??
                            false;
                    if (!isShow) {
                      flickManager?.flickDisplayManager
                          ?.handleShowPlayerControls();
                    }
                  },
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
                            .read(_isShowSlideDialog.state)
                            .update((state) => true);
                        var offset = 60 * 1000 * _slideValue ~/ sizeHeight;
                        var nextValue = (_downPosition + offset);
                        if (nextValue >= _totalDuration) {
                          nextValue = _totalDuration;
                        } else if (nextValue <= 0) {
                          nextValue = 0;
                        }
                        ref.read(_slideX.state).update(
                            (state) => Duration(milliseconds: nextValue));
                      }
                    } else if (_isVolume) {
                     var offset =  _downVolumeY - details.globalPosition.dy;
                      var nextVolume = _downVolume + offset / sizeWidth;
                      debugPrint("onPanUpdate $nextVolume");
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
                          .read(_isShowSlideDialog.state)
                          .update((state) => false);
                      controller.flickControlManager
                          ?.seekTo(ref.watch(_slideX));
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
                        "${getTimeInDuration(ref.watch(_slideX))}/${getTimeInDuration(Duration(milliseconds: _totalDuration))}",
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
                        "${((ref.watch(_brightness).value ?? 0) * 100).toInt()}%",
                        style: const TextStyle(
                            fontSize: 30.0, color:ColorRes.pink100),
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
