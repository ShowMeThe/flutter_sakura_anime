import 'package:fade_shimmer/fade_shimmer.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';

import '../util/collect.dart';
import 'anime_desc_page.dart';

class AnimeCollectPage extends ConsumerStatefulWidget {
  const AnimeCollectPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AnimeCollectPage();
}

class _AnimeCollectPage extends ConsumerState<AnimeCollectPage> {
  late AutoDisposeFutureProvider<List<LocalCollect>> _futureProvider;
  final _movies = <LocalCollect>[];
  static const _HeroTag = "des";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _futureProvider =
        FutureProvider.autoDispose((ref) async => findAllCollect());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("追番"),
      ),
      body: Consumer(
        builder: (context, ref, _) {
          var provider = ref.watch(_futureProvider);
          if (provider.value == null) {
            return buildLoadingBody();
          } else {
            _movies.clear();
            _movies.addAll(provider.value!);
            return GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5,
                    mainAxisSpacing: 5,
                    childAspectRatio: 0.55),
                itemCount: _movies.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
                    child: GestureDetector(
                      onTap: () {
                        var url = _movies[index].showUrl;
                        Navigator.of(context).push(FadeRoute(AnimeDesPage(
                          url,
                          _movies[index].logo,
                          heroTag: _HeroTag,
                        )));
                      },
                      child: SizedBox(
                          width: 90,
                          height: double.infinity,
                          child: Card(
                            shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12.0))),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                Hero(
                                    tag: _movies[index].logo + _HeroTag,
                                    child: Image(
                                      image: ExtendedNetworkImageProvider(
                                        _movies[index].logo,
                                        cache: true,
                                      ),
                                      width: double.infinity,
                                      height: 150,
                                      fit: BoxFit.fitWidth,
                                    )),
                                Expanded(
                                    child: Container(
                                  color: ColorRes.mainColor,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        _movies[index].title,
                                        style: const TextStyle(
                                          fontSize: 10.0,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                  ),
                                ))
                              ],
                            ),
                          )),
                    ),
                  );
                });
          }
        },
      ),
    );
  }

  Widget buildLoadingBody() {
    return GridView.builder(
        padding: const EdgeInsets.only(top: 0),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            childAspectRatio: 0.55),
        itemCount: 40,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(left: 2.0, top: 2.0, bottom: 2.0),
            child: SizedBox(
                width: 90,
                height: double.infinity,
                child: Card(
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0))),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      const FadeShimmer(
                          height: 150,
                          width: double.infinity,
                          radius: 0,
                          millisecondsDelay: 50,
                          fadeTheme: FadeTheme.light),
                      Expanded(
                          child: Container(
                        color: ColorRes.mainColor,
                        child: const FadeShimmer(
                            height: double.infinity,
                            width: double.infinity,
                            radius: 0,
                            millisecondsDelay: 50,
                            fadeTheme: FadeTheme.light),
                      ))
                    ],
                  ),
                )),
          );
        });
  }
}
