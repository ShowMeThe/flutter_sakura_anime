import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_sakura_anime/style/router/AppRouter.gr.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/fold_text.dart';

import '../../bean/factory_tab.dart';
import '../../bean/hanju_des_data.dart';
import '../../util/factory_api.dart';
import '../../widget/error_view.dart';

@RoutePage()
class NetflexDetailPage extends ConsumerStatefulWidget  {
  final FactoryTabListBean source;
  final String heroTag;

  const NetflexDetailPage(this.source, this.heroTag);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MovieDetailState();
}

class _MovieDetailState extends ConsumerState<NetflexDetailPage> with WidgetsBindingObserver{
  final ScrollController _tabScroller = ScrollController();
  final AutoDisposeStateProvider<int> tabSelect =
      StateProvider.autoDispose((ref) => 0);
  late final AutoDisposeFutureProvider<HjDesData> _desDataProvider =
      FutureProvider.autoDispose((ref) async {
    debugPrint("_desDataProvider getData");
    var result = await FactoryApi.getDes(widget.source.url);
    await Future.delayed(const Duration(milliseconds: 400));
    return result;
  });
  late AutoDisposeFutureProvider<LocalHistory?> _localHisFuture;


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.resumed:
        _resetState();
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _resetState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _resetState(){
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var appBarHeight = theme.appBarTheme.toolbarHeight ?? kToolbarHeight;
    var statusBarHeight = MediaQuery.of(context).padding.top;
    var layoutMaxWidth = MediaQuery.of(context).size.width;
    var layoutMaxHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FittedBox(
            child: Text(
          widget.source.title,
          style: const TextStyle(color: Colors.white),
        )),
      ),
      body: Material(
        child: Stack(
          children: [
            Hero(
              tag: widget.heroTag,
              child: Image(
                image: ExtendedNetworkImageProvider(widget.source.img,
                    cache: true),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                    Colors.grey.withAlpha(50),
                    Colors.black.withAlpha(100),
                    Colors.black.withAlpha(200),
                    Colors.black
                  ])),
            ),
            Column(
              children: [
                ClipRect(
                  child: SizedBox(
                    height: appBarHeight + statusBarHeight,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 15,
                        sigmaY: 15,
                      ),
                      child: Container(
                          decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.4),
                          ],
                          begin: const Alignment(-1, -1),
                          end: const Alignment(0.3, 0.5),
                        ),
                      )),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding:
                        EdgeInsets.only(top: min(layoutMaxHeight * 0.3, 110)),
                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(
                            sigmaX: 15,
                            sigmaY: 15,
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15,
                              vertical: 15,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.4),
                                  Colors.white.withValues(alpha: 0.2),
                                ],
                                begin: const Alignment(-1, -1),
                                end: const Alignment(0.3, 0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0x00000000)
                                        .withValues(alpha: 0.1),
                                    offset: const Offset(0, 1),
                                    blurRadius: 24,
                                    spreadRadius: -1)
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Consumer(builder: (context, ref, _) {
                                    var provider = ref.watch(_desDataProvider);
                                    if (provider.valueOrNull != null) {
                                      var desText = provider.requireValue.des;
                                      return FoldTextView(
                                          desText,
                                          4,
                                          const TextStyle(color: Colors.white),
                                          layoutMaxWidth);
                                    } else {
                                      return Container();
                                    }
                                  }),
                                  buildDrams()
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildDrams() {
    return Consumer(
      builder: (context, ref, _) {
        var provider = ref.watch(_desDataProvider);
        if (provider.isLoading) {
          return const SizedBox(
            width: double.infinity,
            height: 350,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else if (provider.hasError || provider.valueOrNull == null) {
          return SizedBox(
              width: double.infinity,
              height: 350,
              child: ErrorView(
                () {
                  ref.invalidate(_desDataProvider);
                },
                textColor: Colors.white,
              ));
        } else {
          var data = provider.value!;
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                      top: 8.0, bottom: 8.0),
                  child: Container(
                    height: 1,
                    color: Colors.amberAccent
                        .withValues(alpha: 0.8),
                  ),
                ),
                buildTabs(data.playList),
                buildPlayList(data.playList)
              ]);
        }
      },
    );
  }

  Widget buildTabs(List<HjDesPlayData> list) {
    return SizedBox(
      height: 45,
      child: ListView.builder(
          controller: _tabScroller,
          itemCount: list.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            var item = list[index];
            return SizedBox(
              width: 75.0,
              child: Consumer(
                builder: (context, ref, _) {
                  return TextButton(
                      child: Text(
                        item.title,
                        style: TextStyle(
                            fontSize: 18,
                            color: ref.watch(tabSelect) == index
                                ? Colors.amberAccent
                                : Colors.amberAccent.withValues(alpha: 0.5)),
                      ),
                      onPressed: () {
                        ref.watch(tabSelect.notifier).update((state) => index);
                      });
                },
              ),
            );
          }),
    );
  }

  Widget buildPlayList(List<HjDesPlayData> list) {
    return Consumer(builder: (context, ref, _) {
      var parentIndex = ref.watch(tabSelect);
      var minSize = MediaQuery.of(context).size.width / 4.0;
      if (list.isEmpty || parentIndex > list.length - 1) {
        return Container();
      }
      var element = list[parentIndex];
      return Wrap(
        alignment: WrapAlignment.center,
        children: buildChild(minSize, element, element.title),
      );
    });
  }

  List<Widget> buildChild(
      double minSize, HjDesPlayData data, String parentTitle) {
    var list = <Widget>[];
    for (int index = 0; index < data.chapterList.length; index++) {
      var element = data.chapterList[index];
      debugPrint("minSize = $minSize");
      list.add(
        Padding(
          padding: const EdgeInsets.only(left: 8.0, top: 6.0, bottom: 6.0),
          child: GestureDetector(
            onTap: () async {
              var item = widget.source;
              String? playUrl;
              if (playUrl == null || playUrl.isEmpty) {
                LoadingDialogHelper.showLoading(context);
                playUrl = await FactoryApi.getPlayUrl(element.url);
                debugPrint("playUrl = $playUrl");
                // updateChapterPlayUrls(item.url, element.url, playUrl);
                if (!mounted) return;
                LoadingDialogHelper.dismissLoading(context);
              }
              if (!mounted) return;
              if(playUrl.isNotEmpty){
                context.router.push(NewPlayRoute(url: playUrl,title: element.title,fromLocal: false));
              }
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 5,
                  vertical: 5,
                ),
                width: minSize,
                height: 55.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amberAccent.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.amberAccent.withValues(alpha: 0.1),
                        offset: const Offset(0, 1),
                        blurRadius: 24,
                        spreadRadius: -1)
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: 0.2),
                      Colors.white.withValues(alpha: 0.4),
                    ],
                    begin: const Alignment(-1, -1),
                    end: const Alignment(0.3, 0.5),
                  ),
                ),
                child: Center(
                  child: AutoSizeText(
                    maxLines: 2,
                    minFontSize: 5,
                    textAlign: TextAlign.center,
                    element.title,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }
    return list;
  }
}
