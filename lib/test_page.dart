import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/base_widget_function.dart';
import 'package:flutter_sakura_anime/widget/ball_cliprotate_pulse.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<StatefulWidget> createState() => _TestPage();
}

class _TestPage extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(width: 150, height: 150, child: RepaintBoundary(child: BallClipRotatePulse(),)),
    );
  }
}
