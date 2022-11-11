import 'package:chewie/chewie.dart';
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
  final AutoDisposeStateProvider<VideoPlayerController?> _initProvider =
      StateProvider.autoDispose<VideoPlayerController?>((ref) => null);
  VideoPlayerController? _controller;

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
    if (_controller != null) {
      _controller?.dispose();
    }
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  void refreshController(String playerUrl) {
    if (_controller != null) {
      _controller?.dispose();
    }
    _controller = VideoPlayerController.network(playerUrl)
      ..initialize().then((_) {
        _controller?.play();
      });
    ref.read(_initProvider.state).state = _controller;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      var watch = ref.watch(_playNowUrlProvider);
      var provider = ref.watch(_initProvider);
      if (watch.isRefreshing || provider == null) {
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
        return Stack(
          children: [
            Positioned(
                left: 65.0,
                top: 0,
                right: 65.0,
                bottom: 0,
                child: AspectRatio(
                  aspectRatio: provider.value.aspectRatio,
                  child: VideoPlayer(provider),
                )),
            Positioned(
                left: 0.0,
                top: 0,
                right: 0.0,
                bottom: 0,
                child: PlayUiStateWidget(provider, widget.title))
          ],
        );
      }
    });
  }
}

class PlayUiStateWidget extends ConsumerStatefulWidget {
  final VideoPlayerController _controller;
  final String title;

  const PlayUiStateWidget(this._controller, this.title, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PlayUiState();
}

class _PlayUiState extends ConsumerState<PlayUiStateWidget> {
  String get title => widget.title;

  VideoPlayerController get controller => widget._controller;


  late ChewieController chewieController = ChewieController(
    videoPlayerController: controller,
    autoPlay: true,
    looping: true,
  );

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Chewie(
        controller: chewieController,
      ),
    );
  }
}
