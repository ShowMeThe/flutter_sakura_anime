import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';


class MeijuHomePage extends ConsumerStatefulWidget{
  const MeijuHomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
      return _MeiJuHomePageState();
  }

}

class _MeiJuHomePageState extends ConsumerState<MeijuHomePage> with AutomaticKeepAliveClientMixin{

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MeiJuApi.getHomeData();

  }


  @override
  Widget build(BuildContext context) {
    super.build(context);
      return Container();
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive =>  true;

}