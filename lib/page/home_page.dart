import 'package:flutter/material.dart';
import 'package:flutter_sakura_anime/util/static.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late ScrollController _controller;

  @override
  void initState() {
    super.initState();
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
      backgroundColor: ColorRes.mainColor,
      body: Material(
        child: Column(
          children: [
            Container(
              height: top,
              color: ColorRes.mainColor,
            ),
            Expanded(
                child: NestedScrollView(
              controller: _controller,
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverOverlapAbsorber(
                      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                          context),
                      sliver: SliverAppBar(
                        backgroundColor: ColorRes.mainColor,
                        flexibleSpace: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Icon(Icons.ice_skating),
                            ),
                          ],
                        ),
                      )),
                ];
              },
              body: const Expanded(
                flex: 1,
                child: Text(""),
              ),
            ))
          ],
        ),
      ),
    );
  }


  Widget buildIcon(){
    return Column(
        children: [
          
        ],
    );
  }

}
