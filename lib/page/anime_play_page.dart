import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/util/api.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:video_player/video_player.dart';

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
  var _slideValue = 0.0;
  var _downPosition = 0;
  var _downVolume = 0.0;
  var _volumeValue = 0.0;
  VideoPlayerValue? _videoPlayerValue;

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
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
    _controller = controller;
    await controller.initialize();

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
                  left: 55.0,
                  top: 0,
                  bottom: 0,
                  right: 55,
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
                  top: 125,
                  bottom: 125,
                  child: GestureDetector(
                    onPanDown: (detail){
                      _downVolume = controller.flickVideoManager?.videoPlayerValue?.volume?? 0.5;
                    },
                    onPanUpdate: (details){
                      // _volumeValue +=
                      // controller.flickControlManager.setVolume(volume)
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(color:Colors.white,),
                  )),
              Positioned(
                left: sizeHeight + 55,
                right: 55,
                top: 125,
                bottom: 125,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanDown: (details) {
                    _slideValue = 0;
                    _downPosition = controller.flickVideoManager
                            ?.videoPlayerValue?.position.inMilliseconds ??
                        0;
                    ref.read(_slideX.state).update(
                        (state) => Duration(milliseconds: _downPosition));
                  },
                  onPanUpdate: (details) {
                    // debugPrint("onPanUpdate ${details.delta.dx}");
                    _slideValue += details.delta.dx;
                    if (_slideValue.abs() > 12.0) {
                      ref
                          .read(_isShowSlideDialog.state)
                          .update((state) => true);
                    }
                    var offset = 60 * 1000 * _slideValue ~/ sizeHeight;
                    var nextValue = (_downPosition + offset);
                    if (nextValue >= _totalDuration) {
                      nextValue = _totalDuration;
                    } else if (nextValue <= 0) {
                      nextValue = 0;
                    }
                    ref
                        .read(_slideX.state)
                        .update((state) => Duration(milliseconds: nextValue));
                  },
                  onPanEnd: (details) {
                    ref.read(_isShowSlideDialog.state).update((state) => false);
                    controller.flickControlManager?.seekTo(ref.watch(_slideX));
                  },
                  child: Container(),
                ),
              ),
              IgnorePointer(
                ignoring: true,
                child: Align(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: ref.watch(_isShowSlideDialog) ? 1.0 : 0.0,
                    child: Text(
                      "${getTimeInDuration(ref.watch(_slideX))}/${getTimeInDuration(Duration(milliseconds: _totalDuration))}",
                      style: const TextStyle(fontSize: 25.0, color: Colors.white),
                    ),
                  ),
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
