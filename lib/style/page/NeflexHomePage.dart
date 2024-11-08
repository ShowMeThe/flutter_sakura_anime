import '../../util/base_export.dart';

@RoutePage()
class NetflexHomePage extends ConsumerStatefulWidget {
  const NetflexHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NetflexHomePageState();
}

class _NetflexHomePageState extends ConsumerState<NetflexHomePage>
    with AutomaticKeepAliveClientMixin {

  late final _controller =
      HiddenController.instant.newController(this);


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    HiddenController.instant.removeController(this);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: ListView.builder(
          controller: _controller,
          itemCount: 50,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Image.network(
                  "http://resource.unbing.cn/business/movie_cache/4506d5eb-78fd-4239-81bd-e655ad9e2c79.webp",
                  width: 450,
                  height: 450,
                ),
              ),
            );
          }),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
