import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter_sakura_anime/style/import/PageImport.dart';
import 'package:flutter_sakura_anime/widget/hidden_widget.dart';

import '../../util/base_export.dart';

@RoutePage()
class MovieHomePage extends ConsumerStatefulWidget {
  const MovieHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MovieHomePageState();
}

class _MovieHomePageState extends ConsumerState<MovieHomePage> with WidgetsBindingObserver {
  final _pageController = PageController(initialPage: 0, keepPage: true);
  final AutoDisposeStateProvider<int> _pageProvider =
      StateProvider.autoDispose<int>((_) => 0);
  var pageOffset = 0.0;

  final _pages = [const NetflexHomePage(), Container()];

  void onTap(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 550), curve: Curves.ease);
  }

  void onChange(WidgetRef ref, int index) {
    ref.refresh(_pageProvider.notifier).update((state) => index);
  }

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge, overlays: []);
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: setSystemUi(),
      child: const Scaffold(
        body: NetflexHomePage(),
      )
      /*Scaffold(
        body: PageView.builder(
          itemBuilder: (BuildContext context, int index) {
            return _pages[index];
          },
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _pages.length,
          controller: _pageController,
          onPageChanged: (index) {
            onChange(ref, index);
          },
        ),
        bottomNavigationBar: ScrollHidden(
          child: Consumer(builder: (context, ref, _) {
            var currentIndex = ref.watch(_pageProvider.notifier).state;
            return BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: onTap,
                showUnselectedLabels: false,
                showSelectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                      label: "电视剧",
                      icon: ImageIcon(AssetImage(A.assets_ic_meiju))),
                  BottomNavigationBarItem(
                      label: "番剧",
                      icon: ImageIcon(AssetImage(A.assets_ic_fanju)))
                ]);
          }),
        ),
      ),*/
    );
  }
}
