import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/util/api.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:video_player/video_player.dart';

class AnimePlayPage extends ConsumerStatefulWidget {
  final String url;

  const AnimePlayPage(this.url, {super.key});

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
      var isInit = ref.watch(_initProvider) != null;
      if (watch.isLoading && isInit) {
        return Container(
          color: Colors.black,
          width: double.infinity,
          height: double.infinity,
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      } else {
        debugPrint("controller $_controller");
        return Padding(
          padding: const EdgeInsets.only(left: 65.0, right: 65.0),
          child: AspectRatio(
            aspectRatio: _controller!.value.aspectRatio,
            child: VideoPlayer(_controller!),
          ),
        );
      }
    });
  }
}
