import 'dart:async';
import 'package:flutter_sakura_anime/page/home_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import '../util/fade_route.dart';

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
    return Timer.periodic(const Duration(milliseconds: 300), (timer) {
      var router = FadeRoute(const HomePage());
      Navigator.of(context).pushAndRemoveUntil(router, (route) => false);
      timer.cancel();
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
      color: ColorRes.pink600,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              A.assets_ic_sakura_flower,
              width: 85.0,
              height: 85.0,
              fit: BoxFit.fitWidth,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: FadeTransition(
                opacity: _animation,
                child: const Text(
                  "樱花动漫",
                  style: TextStyle(color: Colors.white, fontSize: 23.0),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
