import 'dart:math';
import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_sakura_anime/style/router/AppRouter.gr.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/fold_text.dart';

import '../../bean/factory_tab.dart';
import '../../bean/hanju_des_data.dart';
import '../../util/factory_api.dart';
import '../../widget/color_container.dart';
import '../../widget/error_view.dart';

class NetflexDetailPageRouter extends PageRouteInfo {
  NetflexDetailPageRouter(super.name);
}

@RoutePage()
class NetflexDetailPage extends ConsumerStatefulWidget {
  final FactoryTabListBean source;
  final String heroTag;

  const NetflexDetailPage({required this.source, required this.heroTag});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MovieDetailState();
}

class _MovieDetailState extends ConsumerState<NetflexDetailPage>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _heroTag = "MovieDetailState";
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

  late final AnimationController _sheetAnimationController =
      AnimationController(
          vsync: this, duration: const Duration(milliseconds: 2000));

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    switch (state) {
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
    _delayToShowAnimation();
    _resetState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _delayToShowAnimation() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sheetAnimationController.forward();
  }

  void _resetState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
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
        iconTheme: const IconThemeData(color: Colors.yellowAccent),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                SlideUpWidget(
                  controller: _sheetAnimationController,
                  direction: SlideDirection.dropDown,
                  child: ClipRect(
                    child: SizedBox(
                      width: double.infinity,
                      height: appBarHeight + statusBarHeight,
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 15,
                          sigmaY: 15,
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 55),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.grey.withValues(alpha: 0.2),
                                Colors.grey.withValues(alpha: 0.4),
                              ],
                              begin: const Alignment(-1, -1),
                              end: const Alignment(0.3, 0.5),
                            ),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: statusBarHeight),
                            child: Align(
                              alignment: Alignment.center,
                              child: FittedBox(
                                  child: Text(
                                widget.source.title,
                                style: const TextStyle(
                                    color: Colors.yellow, fontSize: 22.0),
                              )),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: SlideUpWidget(
                      controller: _sheetAnimationController,
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: min(layoutMaxHeight * 0.3, 110)),
                        child: SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(25),
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
                                      Colors.grey.withValues(alpha: 0.3),
                                      Colors.grey.withValues(alpha: 0.1),
                                    ],
                                    begin: const Alignment(-1, -1),
                                    end: const Alignment(0.3, 0.5),
                                  ),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      Consumer(builder: (context, ref, _) {
                                        var provider =
                                            ref.watch(_desDataProvider);
                                        if (provider.valueOrNull != null) {
                                          var desText =
                                              provider.requireValue.des;
                                          return FoldTextView(
                                              desText,
                                              4,
                                              const TextStyle(
                                                  color: Colors.white),
                                              layoutMaxWidth);
                                        } else {
                                          return Container();
                                        }
                                      }),
                                      _buildDrams(),
                                      _buildPromotion()
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDrams() {
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
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Container(
                    height: 1,
                    color: Colors.amberAccent.withValues(alpha: 0.8),
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
      var minSize = MediaQuery.of(context).size.width / 5.0;
      if (list.isEmpty || parentIndex > list.length - 1) {
        return Container();
      }
      var element = list[parentIndex];
      return Center(
        child: SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: buildChild(minSize, element, element.title),
          ),
        ),
      );
    });
  }

  List<Widget> buildChild(
      double minSize, HjDesPlayData data, String parentTitle) {
    var list = <Widget>[];
    for (int index = 0; index < data.chapterList.length; index++) {
      var element = data.chapterList[index];
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
              if (playUrl.isNotEmpty) {
                context.router.push(NewPlayRoute(
                    url: playUrl, title: element.title, fromLocal: false));
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
                  border: Border.all(
                      color: Colors.amberAccent.withValues(alpha: 0.5)),
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

  Widget _buildPromotion() {
    return Consumer(builder: (context, ref, _) {
      var provider = ref.watch(_desDataProvider);
      var value = provider.valueOrNull;
      var promotionList = value?.promotionList;
      if (value == null || promotionList?.isEmpty == true) return Container();
      var list = promotionList!;
      return _buildPromotionChild(list);
    });
  }

  Widget _buildPromotionChild(List<HjDesPlayPromotion> childList) {
    return Padding(
        padding: const EdgeInsets.only(top: 60.0),
        child: SizedBox(
          height: 250,
          child: CarouselView(
            itemExtent: 150,
            itemSnapping: true,
            shrinkExtent: 75,
            onTap: (index) {
              var item = childList[index];
              var heroTag = "${item.logo}$_heroTag$index";
              context.pushRoute(NetflexDetailRoute(
                  source:
                      FactoryTabListBean(item.url, item.title, "", item.logo),
                  heroTag: heroTag));
            },
            children: _buildCarouselViewChild(childList),
          ),
        ));
  }

  List<Widget> _buildCarouselViewChild(List<HjDesPlayPromotion> childList) {
    var widget = <Widget>[];
    for (var index = 0; index < childList.length; index++) {
      var item = childList[index];
      var heroTag = "${item.logo}$_heroTag$index";
      widget.add(Padding(
        padding: const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
        child: SizedBox(
            width: 90,
            height: double.infinity,
            child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12.0))),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  Hero(
                      tag: heroTag,
                      child:
                          showImage(context, item.logo, double.infinity, 150)),
                  Positioned.fill(
                      top: 130,
                      child: Container(
                        decoration:
                            BoxDecoration(color: Colors.black.withAlpha(45)),
                        child: Text(
                          item.title,
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )),
                  Positioned.fill(
                      left: 0,
                      top: 150,
                      child: ColorContainer(
                        url: item.logo,
                        title: item.title,
                        baseColor: ColorRes.mainColor,
                      )),
                ],
              ),
            )),
      ));
    }
    return widget;
  }
}

enum SlideDirection {
  slideUp,
  dropDown,
}

class SlideUpWidget extends StatefulWidget {
  final Widget child;
  final SlideDirection direction;
  final Duration duration;
  final AnimationController? controller;

  const SlideUpWidget(
      {required this.child,
      this.duration = const Duration(milliseconds: 1000),
      this.direction = SlideDirection.slideUp,
      this.controller,
      super.key});

  @override
  State<StatefulWidget> createState() => _SlideUpWidgetState();
}

class _SlideUpWidgetState extends State<SlideUpWidget>
    with SingleTickerProviderStateMixin {
  late final double _kBounce = 0.4;
  late final Duration _kDuration = widget.duration;
  late final AnimationController _animationController = widget.controller ??
      AnimationController(vsync: this, duration: _kDuration);
  late final ElegantSpring _elegantCurve = ElegantSpring(bounce: _kBounce);
  late final CurvedAnimation _curvedAnimation = CurvedAnimation(
      parent: _animationController,
      curve: _elegantCurve,
      reverseCurve: _elegantCurve.flipped);

  Tween<Offset> _getOffset() {
    if (widget.direction == SlideDirection.slideUp) {
      return Tween(begin: const Offset(0, 1), end: Offset.zero);
    } else {
      return Tween(begin: const Offset(0.0, -1), end: Offset.zero);
    }
  }

  late final Animation<Offset> _offsetAnimation =
      _curvedAnimation.drive(_getOffset());

  void animationListener() {
    if (mounted && _animationController.isAnimating) {
      setState(() {});
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.controller == null) {
      _animationController.forward();
    }
    _animationController.addListener(animationListener);
  }

  @override
  void dispose() {
    super.dispose();
    try {
      _curvedAnimation.dispose();
      _animationController.dispose();
    } catch (e) {
      debugPrint("e : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    var opacity = 0.0;
    if (widget.direction == SlideDirection.dropDown) {
      opacity = _offsetAnimation.value.dy.abs();
    } else {
      opacity = _offsetAnimation.value.dy;
    }
    return Opacity(
      opacity: (1 - opacity).clamp(0.0, 1.0),
      child: SlideTransition(
        position: _offsetAnimation,
        child: widget.child,
      ),
    );
  }
}
