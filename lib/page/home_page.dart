

import 'package:flutter_sakura_anime/page/anime/anime_home_page.dart';
import 'package:flutter_sakura_anime/page/factory/factory_page.dart';
import 'package:flutter_sakura_anime/page/hanju/hanju_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/hidden_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'download/down_load_page.dart';
import 'meiju/meiju_home_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final tabIndex = "TabIndex";
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _pageController = PageController(initialPage: 0, keepPage: true);
  final AutoDisposeStateProvider<int> _pageProvider =
      StateProvider.autoDispose<int>((_) => 0);
  final _pages = [
    const AnimeHomePage(),
    const HanjuPage(),
    const MeijuHomePage(),
    const FactoryPage(),
    const DownLoadPage()
  ];

  final _titles = [
    "动漫",
    "日/韩剧",
    "美剧",
    "厂长",
    "下载"
  ];

  void onTap(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
    _saveTabIndex(index);
  }

  void onChange(WidgetRef ref, int index) {
    ref.refresh(_pageProvider.notifier).update((state) => index);
  }

  void _settingTab() async {
    var lastIndex = (await _prefs).getInt(tabIndex) ?? 0;
    if (lastIndex != 0) {
      ref.refresh(_pageProvider.notifier).update((state) => lastIndex);
      _pageController.animateToPage(lastIndex,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void _saveTabIndex(int index) async {
    (await _prefs).setInt(tabIndex, index);
  }

  @override
  void initState() {
    super.initState();
    _settingTab();
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
                showSelectedLabels: true,
                showUnselectedLabels: false,
                selectedFontSize: 12,
                onTap: onTap,
                currentIndex: currentIndex,
                items: [
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(A.assets_ic_sakura_flower)),
                      label: _titles[0]),
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(A.assets_ic_hanju)),
                      label: _titles[1]),
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(A.assets_ic_meiju)),
                      label: _titles[2]),
                  BottomNavigationBarItem(
                      icon: ImageIcon(AssetImage(A.assets_ic_more_movie)),
                      label: _titles[3]),
                  BottomNavigationBarItem(
                      icon: const Icon(Icons.download),
                      label: _titles[4]),
                ]);
          }),
        ),
      ),
    );
  }
}
