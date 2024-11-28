import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:path_provider/path_provider.dart';
import '../util/base_export.dart';

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
  late final player = Player(
      configuration: const PlayerConfiguration(
          bufferSize: 100 * 1024 * 1024, logLevel: MPVLogLevel.debug));
  late final controller = VideoController(player);
  late final GlobalKey<VideoState> key = GlobalKey<VideoState>();

  void initPlayer() async {
    player.stream.error.listen((error) => debugPrint(error));
    player.stream.log.listen((log) => debugPrint(log.toString()));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    initPlayer();
    debugPrint("playUrl = ${widget.url}");
    player.open(Media(widget.url));
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {});

    var seekToHistory = false;
    player.stream.buffer.listen((buffer) async {
      var bufferDuration = buffer.inMilliseconds;
      if (bufferDuration > 0 && !seekToHistory) {
        seekToHistory = true;
        var playHistory = findLocalPlayHistory(widget.url);
        if (playHistory != null) {
          var duration = Duration(milliseconds: playHistory.timeInMills);
          await player.seek(duration);
        }
      }
    });

    var lastProgressDuration = 0;
    player.stream.position.listen((event) {
      var time = event.inMilliseconds;
      if (time - lastProgressDuration > 2000) {
        lastProgressDuration = time;
        updatePlayHistory(widget.url, time);
      }
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    player.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top]);
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialVideoControlsTheme(
        normal: MaterialVideoControlsThemeData(
            padding: const EdgeInsets.fromLTRB(15, 0, 15, 45),
            volumeGesture: true,
            brightnessGesture: true,
            seekGesture: true,
            bufferingIndicatorBuilder: (context) {
              return CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              );
            },
            topButtonBarMargin: const EdgeInsets.fromLTRB(15.0, 0, 15, 15),
            topButtonBar: [
              IconButton(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ))
            ],
            bottomButtonBar: [
              const MaterialPositionIndicator(),
            ]),
        fullscreen: const MaterialVideoControlsThemeData(),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.width * 9.0 / 16.0,
            child: Video(key: key, controller: controller),
          ),
        ));
  }
}
