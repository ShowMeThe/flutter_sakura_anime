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
    "电视剧",
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
    // TODO: implement initState
    super.initState();
    _pageController.addListener(
            () => setState(() {
              pageOffset = _pageController.page!;
            }),
      );
  }

  @override
  Widget build(BuildContext context) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
          value: setSystemUi(),
          child: Scaffold(
            body: PageView.builder(
              itemBuilder: (BuildContext context, int index) {
                double angleY = (pageOffset - index).abs();
                var matrix4 = Matrix4.identity();
                matrix4..setEntry(3, 2, 0.001)
                        ..rotateY(angleY);

                if (index == pageOffset.floor()) {
                  //当前的item
                } else if (index == pageOffset.floor() + 1) {
                  //右边的item
                } else if (index == pageOffset.floor() - 1) {
                } else {
                }
                return Transform(transform: matrix4,child: _pages[index],);
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