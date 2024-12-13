import 'dart:async';

import 'package:chewie/chewie.dart';
import 'package:flutter_sakura_anime/util/factory_api.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'package:screen_brightness_platform_interface/screen_brightness_platform_interface.dart';

import '../../util/base_export.dart';

@RoutePage()
class NewPlayPage extends ConsumerStatefulWidget {
  final String url;
  final String title;
  final bool fromLocal;

  const NewPlayPage(this.url, this.title, this.fromLocal, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _NewPlayState();
}

class _NewPlayState extends ConsumerState<NewPlayPage> {
  late ChewieController _chewieController;
  late VideoPlayerController _controller;

  Future<bool> initPlayer() async {
    _chewieController = ChewieController(
      videoPlayerController: _controller,
      allowedScreenSleep: false,
      allowFullScreen: false,
    );
    await _controller.setLooping(true);
    await _controller.initialize();
    _controller.play();
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    debugPrint("NewPlayPage playUrl = ${widget.url}");
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.url),
      httpHeaders: FactoryApi.videoHeader,
    );

    Future.microtask(() async {
      try {
        _brightnessValue = await ScreenBrightnessPlatform.instance.application;
        ref
            .refresh(_brightnessValueProvider.notifier)
            .update((cb) => _brightnessValue);
        ScreenBrightnessPlatform.instance.onApplicationScreenBrightnessChanged
            .listen((value) {
          if (mounted) {
            _brightnessValue = value;
            ref
                .refresh(_brightnessValueProvider.notifier)
                .update((cb) => _brightnessValue);
          }
        });
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _chewieController.dispose();
    _controller.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: LayoutBuilder(
        builder: (context,bc){
          var viewW = bc.maxWidth;
          var viewH = bc.maxHeight;
          return FutureBuilder(
              future: initPlayer(),
              builder: (context, snapshot) {
                var state = snapshot.connectionState;
                if (state == ConnectionState.done) {
                  return AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: Stack(
                      children: [
                        Chewie(controller: _chewieController),
                        Positioned.fill(
                          left: 30.0,
                          top: 30.0,
                          right: viewW * 0.75,
                          bottom: 55.0,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onVerticalDragUpdate: (e) async {
                              final delta = e.delta.dy;
                              final Offset position = e.localPosition;
                              if (mounted) {
                                final brightness = _brightnessValue - delta / 100;
                                final result = brightness.clamp(0.0, 1.0);
                                setBrightness(result);
                              }
                            },
                            child: Container(),
                          ),
                        ),
                        IgnorePointer(child: Consumer(builder: (context, ref, _) {
                          var indicator = ref.watch(_brightnessIndicator);
                          var indicatorValue = ref.watch(_brightnessValueProvider);
                          var opacity = indicator ? indicatorValue : 0.0;
                          return AnimatedOpacity(
                            curve: Curves.easeInOut,
                            opacity: opacity,
                            duration: const Duration(milliseconds: 200),
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: const Color(0x88000000),
                                borderRadius: BorderRadius.circular(64.0),
                              ),
                              height: 52.0,
                              width: 108.0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    height: 52.0,
                                    width: 42.0,
                                    alignment: Alignment.centerRight,
                                    child: Icon(
                                      indicatorValue < 1.0 / 3.0
                                          ? Icons.brightness_low
                                          : indicatorValue < 2.0 / 3.0
                                          ? Icons.brightness_medium
                                          : Icons.brightness_high,
                                      color: const Color(0xFFFFFFFF),
                                      size: 24.0,
                                    ),
                                  ),
                                  const SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      '${(indicatorValue * 100.0).round()}%',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 14.0,
                                        color: Color(0xFFFFFFFF),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16.0),
                                ],
                              ),
                            ),
                          );
                        }))
                      ],
                    ),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
              });
        },
      ),
    );
  }

  var _brightnessValue = 0.0;
  final _brightnessValueProvider = StateProvider.autoDispose((_) => 0.0);
  final _brightnessIndicator = StateProvider.autoDispose((_) => false);
  Timer? _brightnessTimer;

  Future<void> setBrightness(double value) async {
    try {
      await ScreenBrightnessPlatform.instance
          .setApplicationScreenBrightness(value);
    } catch (_) {}
    ref.refresh(_brightnessIndicator.notifier).update((cb) => true);
    _brightnessTimer?.cancel();
    _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
      ref.refresh(_brightnessIndicator.notifier).update((cb) => false);
    });
    // --------------------------------------------------
  }
}
