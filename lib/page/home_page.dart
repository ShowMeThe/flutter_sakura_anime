
import 'package:flutter_sakura_anime/page/anime/anime_home_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';

import 'meiju/meiju_home_page.dart';

class HomePage extends ConsumerStatefulWidget{
  const HomePage({super.key});


  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();

}

class _HomePageState extends ConsumerState<HomePage>{

  final _pageController = PageController(initialPage: 0, keepPage: true);
  final AutoDisposeStateProvider<int> _pageProvider =
  StateProvider.autoDispose<int>((_) => 0);
  final _pages = [
    const AnimeHomePage(),
    const MeijuHomePage(),
  ];

  final _titles = ["动漫","美剧"];


  void onTap(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  void onChange(WidgetRef ref, int index) {
    ref.read(_pageProvider.state).state = index;
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

     return Scaffold(
       backgroundColor: Colors.white,
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
       bottomNavigationBar: Consumer(builder: (context, ref, _) {
         return BottomNavigationBar(
             showSelectedLabels: true,
             showUnselectedLabels: false,
             selectedFontSize: 12,
             onTap: onTap,
             currentIndex: ref.watch(_pageProvider.state).state,
             items: [
               BottomNavigationBarItem(
                   icon: ImageIcon(AssetImage(A.assets_ic_sakura_flower)),
                   label: _titles[0]),
               BottomNavigationBarItem(
                   icon: ImageIcon(AssetImage(A.assets_ic_meiju)),
                   label: _titles[1]),
             ]);
       }),
     );
  }

}