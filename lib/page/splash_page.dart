import 'dart:async';
import 'package:flutter_sakura_anime/util/base_export.dart';
import '../style/router/AppRouter.gr.dart';
import 'home_page.dart';
import 'anime/anime_home_page.dart';


class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<StatefulWidget> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    _animationController = AnimationController(
        duration: const Duration(milliseconds: 1000), vsync: this);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        delayToPage();
      }
    });
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animation.addListener(() {
      setState(() {});
    });
    _animationController.forward();
  }

  Timer delayToPage() {
    return Timer(const Duration(milliseconds: 300), () {
      // var router = FadeRoute(const HomePage());
      // Navigator.of(context).pushAndRemoveUntil(router, (route) => false);

      context.router.push(NewPlayRoute(
          url: "https://yundunm.nowm3.xyz:2083/hls/laosho2.m3u8", title: "", fromLocal: false));
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              A.assets_ic_fanju,
              width: 85.0,
              height: 85.0,
              fit: BoxFit.fitWidth,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: FadeTransition(
                opacity: _animation,
                child: const Text(
                  "番剧",
                  style: TextStyle(color: Colors.orange, fontSize: 23.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
