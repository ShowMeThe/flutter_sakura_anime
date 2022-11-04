import 'dart:ui';

import 'package:flutter_sakura_anime/util/api.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';

class AnimeDesPage extends ConsumerStatefulWidget {
  final String animeShowUrl;

  const AnimeDesPage(this.animeShowUrl, {super.key});

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
          height: 350,
          fit: BoxFit.cover,
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: const SizedBox(
            width: double.infinity,
            height: 350,
          ),
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
                  Colors.black.withAlpha(85),
                  Colors.black
                ]))),
        SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            children: [
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
              SizedBox(
                width: size.width / 2,
                height: 255,
                child: Image.network(
                  data.logo!,
                  width: double.infinity,
                  height: 255,
                  fit: BoxFit.cover,
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}
