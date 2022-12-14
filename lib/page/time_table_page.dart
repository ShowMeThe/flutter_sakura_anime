import 'package:flutter_sakura_anime/util/api.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/fade_route.dart';

import 'anime_desc_page.dart';

class TimeTablePage extends ConsumerStatefulWidget {
  const TimeTablePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimeTableState();
}

class _TimeTableState extends ConsumerState<TimeTablePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    var data = DateTime.now();
    _tabController.animateTo(data.weekday - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.mainColor,
      appBar: AppBar(
        title: const Text("时间表"),
        bottom: TabBar(
          isScrollable: true,
          controller: _tabController,
          tabs: tabs(),
        ),
      ),
      body: TabBarView(controller: _tabController, children: tabViews()),
    );
  }

  List<Widget> tabs() {
    var tabs = <Widget>[];
    if (Api.homeData?.homeTimeTable != null) {
      for (var element in Api.homeData?.homeTimeTable ?? []) {
        tabs.add(Tab(
          text: element.week,
        ));
      }
    }
    return tabs;
  }

  List<Widget> tabViews() {
    var tabView = <Widget>[];
    if (Api.homeData?.homeTimeTable != null) {
      for (int index = 0, size = Api.homeData?.homeTimeTable.length ?? 0;
      index < size;
      index++) {
        tabView.add(_WeekTabPage(index));
      }
    }
    return tabView;
  }
}

class _WeekTabPage extends ConsumerStatefulWidget {
  final int page;

  const _WeekTabPage(this.page);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => __WeekTabPageState();
}

class __WeekTabPageState extends ConsumerState<_WeekTabPage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  var list = <TimeTableData>[];

  @override
  void initState() {
    super.initState();
    if (Api.homeData != null) {
      list = Api.homeData!.homeTimeTable[widget.page].timeData;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListView.builder(
        itemCount: list.length,
        controller: _scrollController,
        itemBuilder: (context, index) {
          return buildChild(index);
        });
  }

  Widget buildChild(int index) {
    var item = list[index];
    return GestureDetector(
      onTap: () {
        if (item.url != null) {
          Navigator.of(context).push(FadeRoute(AnimeDesPage(item.url!, "")));
        }
      },
      child: Card(
        color: Colors.white,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(12.0))),
        child: SizedBox(
          width: double.infinity,
          height: 45.0,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(width: 150, child: Text(item.title)),
                Text(
                  item.episode,
                  style: const TextStyle(color: ColorRes.pink50),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
