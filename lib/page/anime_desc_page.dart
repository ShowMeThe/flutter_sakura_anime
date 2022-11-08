import 'dart:ui';

import 'package:flutter_sakura_anime/util/api.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/widget/fold_text.dart';

import '../widget/score_shape_border.dart';

class AnimeDesPage extends ConsumerStatefulWidget {
  final String animeShowUrl;
  final String episode;

  const AnimeDesPage(this.animeShowUrl, this.episode, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimeDesPageState();
}

class _AnimeDesPageState extends ConsumerState<AnimeDesPage> {
  final AutoDisposeStateProvider<bool> _stateProvider =
      StateProvider.autoDispose((ref) => false);
  late AutoDisposeFutureProvider<AnimeDesData> _desDataProvider;

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _scrollController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _desDataProvider = FutureProvider.autoDispose<AnimeDesData>((_) async {
      var result = await Api.getAnimeDes(widget.animeShowUrl);
      ref.read(_stateProvider.state).state = true;
      return result;
    });
    ref.refresh(_desDataProvider);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorRes.mainColor,
      body: Material(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Consumer(
            builder: (context, ref, _) {
              var loaded = ref.watch(_stateProvider);
              if (!loaded) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              } else {
                return buildChild(ref.watch(_desDataProvider).value);
              }
            },
          ),
        ),
      ),
    );
  }

  Widget buildChild(AnimeDesData? data) {
    if (data == null) return Container();
    var size = MediaQuery.of(context).size;
    return Stack(
      children: [
        Image.network(
          data.logo!,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(),
        ),
        Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                  Colors.black.withAlpha(15),
                  Colors.black.withAlpha(125),
                  Colors.black
                ]))),
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SafeArea(
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    )),
              ),
              Center(
                child: SizedBox(
                  width: size.width / 3,
                  child: Stack(
                    children: [
                      Image.network(
                        data.logo!,
                        width: double.infinity,
                        fit: BoxFit.fitWidth,
                      ),
                      Positioned(
                          child: SizedBox(
                        width: 45.0,
                        height: 35.0,
                        child: CustomPaint(
                          painter:
                              ScoreShapeBorder(ColorRes.pink400.withAlpha(200)),
                        ),
                      )),
                      Positioned(
                          left: 10,
                          child: Text(
                            data.score!,
                            style: const TextStyle(color: Colors.white),
                          )),
                      Positioned(
                          left: 0,
                          bottom: 0,
                          right: 0,
                          child: Container(
                            alignment: Alignment.centerRight,
                            width: double.infinity,
                            height: 20,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                  Colors.black12.withAlpha(30),
                                  Colors.black12.withAlpha(125)
                                ])),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4.0),
                              child: Text(
                                widget.episode,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 12.0),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
                child: Center(
                  child: Text(
                    data.title == null ? "" : data.title!,
                    style: const TextStyle(color: Colors.white, fontSize: 15.0),
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 5.0,
                    runSpacing: 5.0,
                    alignment: WrapAlignment.start,
                    children: buildTag(data),
                  ),
                ),
              ),
              Center(
                  child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 0.0),
                child: FoldTextView(data.des == null ? "" : data.des!, 4,
                    const TextStyle(color: Colors.white, fontSize: 12.0), 320),
              )),
            ],
          ),
        )
      ],
    );
  }

  List<Widget> buildTag(AnimeDesData? data) {
    var list = <Widget>[];
    if (data != null) {
      for (var element in data.tags) {
        list.add(Material(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
          color: ColorRes.pink50,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(element.title,
                style: const TextStyle(color: Colors.white, fontSize: 12.0)),
          ),
        ));
      }
    }
    return list;
  }
}
