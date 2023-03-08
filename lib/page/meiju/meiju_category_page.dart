import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/mj_api.dart';

class MjCategoryPage extends ConsumerStatefulWidget {
  final String url;
  final String title;

  const MjCategoryPage(this.url, this.title, {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() {
    return _MjCategoryState();
  }
}

class _MjCategoryState extends ConsumerState<MjCategoryPage> {
  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}
