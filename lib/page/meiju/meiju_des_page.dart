import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';

class MjDesPage extends ConsumerStatefulWidget {
  final String logo;
  final String url;
  final String title;

  MjDesPage(this.logo, this.url, this.title);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MjDesPageState();
  }
}

class _MjDesPageState extends ConsumerState<MjDesPage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    MeiJuApi.getDesPage(widget.url);

  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
