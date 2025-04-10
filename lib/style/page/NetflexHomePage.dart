import 'dart:async';

import 'package:video_sniffing/video_sniffing_platform_interface.dart';

import '../../util/base_export.dart';
import '../import/PageImport.dart';

@RoutePage()
class NetflexHomePage extends ConsumerStatefulWidget {
  const NetflexHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetflexHomePageState();
}

class _NetflexHomePageState extends ConsumerState<NetflexHomePage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  late AutoDisposeFutureProvider<List<FactoryTab>> _homeTabFutureProvider;
  late final _tabControllerProvider =
      StateProvider.autoDispose((_) => TabController(length: 0, vsync: this));
  late final _pageController = PageController(initialPage: 0);
  var _pageOffset = 0.0;
  late StreamSubscription _streamSubscription;

  @override
  void initState() {
    super.initState();
    _homeTabFutureProvider =
        FutureProvider.autoDispose<List<FactoryTab>>((_) async {
      var result = await FactoryApi.getHomeTab();
      if (result.isNotEmpty) {
        ref
            .watch(_tabControllerProvider.notifier)
            .update((cb) => TabController(length: result.length, vsync: this)
              ..addListener(() {
                setState(() {
                  _pageOffset = _pageController.page!;
                });
              }));
      }
      return result;
    });
    _pageController.addListener(
      () => setState(() {
        _pageOffset = _pageController.page!;
      }),
    );

    _streamSubscription =
        VideoSniffingPlatform.instance.watchCloudflareResult().listen((data) {
      if (data is bool) {
        if (data) {
          debugPrint("watchCloudflareResult refresh");
          ref.invalidate(_homeTabFutureProvider);
        }
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _streamSubscription.cancel();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(child: Consumer(builder: (context, ref, _) {
      var homeTabProvider = ref.watch(_homeTabFutureProvider);
      var tabController = ref.watch(_tabControllerProvider);
      var tabs = <FactoryTab>[];
      if (homeTabProvider.valueOrNull != null) {
        tabs.addAll(homeTabProvider.requireValue);
      }
      if (homeTabProvider.isLoading || homeTabProvider.hasError) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return Scaffold(
          appBar: TabBar(
              isScrollable: true,
              indicatorSize: TabBarIndicatorSize.label,
              indicatorAnimation: TabIndicatorAnimation.elastic,
              controller: tabController,
              onTap: (index) {
                _pageController.animateToPage(index,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.ease);
              },
              tabs: buildTab(tabs)),
          body: PageView.builder(
            onPageChanged: (page) {
              tabController.animateTo(page,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.ease);
            },
            controller: _pageController,
            itemBuilder: (context, index) {
              // var matrix4 = Matrix4.identity();
              // if(index == _pageOffset.floor()){
              //   var currentScale = 1
              //   matrix4 = Matrix4.diagonal3Values(1.0, y, z)
              // }

              return NetflexListPage(tabs[index].url);
            },
            itemCount: tabs.length,
          ),
        );
      }
    }));
  }

  @override
  bool get wantKeepAlive => true;

  List<Tab> buildTab(List<FactoryTab> tabs) {
    return tabs
        .map((element) => Tab(
              text: element.title,
            ))
        .toList();
  }
}
