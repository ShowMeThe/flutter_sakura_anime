import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/page/time_table_page.dart';
import 'package:flutter_sakura_anime/util/api.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/fade_route.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

@override
class _HomePageState extends ConsumerState<HomePage> {
  late ScrollController _controller;
  late AutoDisposeFutureProvider<HomeData> _disposeFutureProvider;
  final AutoDisposeStateProvider<bool> _stateProvider =
      StateProvider.autoDispose((ref) => false);

  @override
  void initState() {
    super.initState();
    _disposeFutureProvider = FutureProvider.autoDispose<HomeData>((_) async {
      var result = await Api.getHomeData();
      ref.read(_stateProvider.state).state = true;
      return result;
    });
    ref.refresh(_disposeFutureProvider);
    _controller = ScrollController();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var top = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Material(
        child: Consumer(builder: (context, ref, _) {
          var loaded = ref.watch(_stateProvider);
          if (loaded) {
            return Column(
              children: [
                Container(
                  height: top,
                  color: Colors.white,
                ),
                Expanded(
                    child: NestedScrollView(
                  controller: _controller,
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      SliverOverlapAbsorber(
                          handle:
                              NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context),
                          sliver: SliverAppBar(
                            backgroundColor: Colors.white,
                            flexibleSpace: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: buildIcon(0),
                                ),
                              ],
                            ),
                          )),
                    ];
                  },
                  body: Text(""),
                ))
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        }),
      ),
    );
  }

  Widget buildIcon(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        MaterialButton(
          elevation: 1.5,
          color: ColorRes.pink400,
          highlightColor: ColorRes.pink50,
          shape: const CircleBorder(),
          height: 50,
          onPressed: () {
            onTap(index);
          },
          child: Center(
            child: Image.asset(
              getImageIndex(index),
              color: Colors.white,
              width: 30,
              height: 30,
              fit: BoxFit.fitWidth,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            getTextIndex(index),
            style: const TextStyle(color: ColorRes.pink50),
          ),
        )
      ],
    );
  }

  void onTap(int index) {
    if (index == 0) {
      /**
       * 更新列表
       */
      Navigator.of(context).push(FadeRoute(const TimeTablePage()));
    } else {}
  }

  String getImageIndex(int index) {
    if (index == 0) {
      return A.assets_ic_time_table;
    } else {
      return "";
    }
  }

  String getTextIndex(int index) {
    if (index == 0) {
      return "时间表";
    } else {
      return "";
    }
  }
}
