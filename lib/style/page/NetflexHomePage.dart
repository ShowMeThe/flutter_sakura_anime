import 'package:flutter_sakura_anime/style/page/NetflexListPage.dart';

import '../../bean/factory_tab.dart';
import '../../page/factory/factory_page.dart';
import '../../util/base_export.dart';
import '../../util/factory_api.dart';

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
  @override
  void initState() {
    super.initState();
    _homeTabFutureProvider =
        FutureProvider.autoDispose<List<FactoryTab>>((_) async {
          var result = await FactoryApi.getHomeTab();
          if (result.isNotEmpty) {
            ref.watch(_tabControllerProvider.notifier)
                .update((cb) =>
                TabController(length: result.length, vsync: this)..addListener((){
                   setState(() {
                     _pageOffset = _pageController.page!;
                   });
                }));
          }
          return result;
        });
    _pageController
        .addListener(
          () => setState(() {
        _pageOffset = _pageController.page!;
      }),
    );

  }

  @override
  void dispose() {
    super.dispose();
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
      debugPrint("do after hasError = ${homeTabProvider.hasError}");
      if(homeTabProvider.isLoading || homeTabProvider.hasError){
        return const Center(
            child: CircularProgressIndicator(),
        );
      }else{
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
              double angleY = (_pageOffset - index).abs();
              var matrix4 = Matrix4.identity();
              matrix4..setEntry(3, 2, 0.001)
                ..rotateY(angleY);
              if (index == _pageOffset.floor()) {
                //当前的item
              } else if (index == _pageOffset.floor() + 1) {
                //右边的item
              } else if (index == _pageOffset.floor() - 1) {
              } else {
              }
              return Transform(transform: matrix4,child: NetflexListPage(tabs[index].url));
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
        .map((element) => Tab(text: element.title,))
        .toList();
  }
}
