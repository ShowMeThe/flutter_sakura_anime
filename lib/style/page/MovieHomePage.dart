import 'package:flutter_sakura_anime/style/import/PageImport.dart';
import 'package:flutter_sakura_anime/widget/hidden_widget.dart';

import '../../util/base_export.dart';

@RoutePage()
class MovieHomePage extends ConsumerStatefulWidget{
  const MovieHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MovieHomePageState();

}

class _MovieHomePageState extends ConsumerState<MovieHomePage>{


  final _pageController = PageController(initialPage: 0, keepPage: true);
  final AutoDisposeStateProvider<int> _pageProvider =
  StateProvider.autoDispose<int>((_) => 0);
  var pageOffset = 0.0;

  final _pages = [
    NetflexHomePage(),
    NetflexHomePage()
  ];

  final _titles = [
    "厂长资源",
    "电视剧",
  ];

  void onTap(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 550), curve: Curves.ease);
  }

  void onChange(WidgetRef ref, int index) {
    ref.refresh(_pageProvider.notifier).update((state) => index);
  }

  @override
  void initState() {
    super.initState();
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
          child: Scaffold(
            body: PageView.builder(
              itemBuilder: (BuildContext context, int index) {
                return  _pages[index];
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
                    showSelectedLabels: true,
                    showUnselectedLabels: false,
                    selectedFontSize: 12,
                    onTap: onTap,
                    currentIndex: currentIndex,
                    items: [
                      BottomNavigationBarItem(
                          icon: ImageIcon(AssetImage(A.assets_ic_meiju)),
                          label: _titles[0]),
                      BottomNavigationBarItem(
                          icon: ImageIcon(AssetImage(A.assets_ic_more_movie)),
                          label: _titles[1]),
                    ]);
              }),
            ),
          ),
      );
  }

}