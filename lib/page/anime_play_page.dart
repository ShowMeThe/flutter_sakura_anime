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
  final AutoDisposeStateProvider<ChewieController?> _initProvider =
      StateProvider.autoDispose<ChewieController?>((ref) => null);
  VideoPlayerController? _controller;
  ChewieController? _chewieController;

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
    _controller?.dispose();
    _chewieController?.dispose();
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
    var chewieController = ChewieController(
      aspectRatio: controller.value.aspectRatio,
      videoPlayerController: controller,
      autoPlay: true,
      looping: true,
    );
    _chewieController = chewieController;
    ref.read(_initProvider.state).state = chewieController;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      var watch = ref.watch(_playNowUrlProvider);
      var controller = ref.watch(_initProvider);
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
          child: Chewie(
            controller: controller,
          ),
        );
      }
    });
  }
}
