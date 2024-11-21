import 'package:flutter_sakura_anime/style/router/AppRouter.gr.dart';

import '../../util/base_export.dart';

@RoutePage()
class AnimeSplashPage extends StatefulWidget {
  const AnimeSplashPage({super.key});

  @override
  State<StatefulWidget> createState() =>
      _AnimeSplashPageState();
}

class _AnimeSplashPageState extends State<AnimeSplashPage>
    with SingleTickerProviderStateMixin,WidgetsBindingObserver {
  late final double _kBounce = 0.8;
  late final int _kDuration = 1;
  late final AnimationController _animationController = AnimationController(
      vsync: this, duration: Duration(seconds: _kDuration));
  late final CurvedAnimation _animation = CurvedAnimation(
      parent: _animationController,
      curve: _elegantCurve,
      reverseCurve: _elegantCurve.flipped);
  late final ElegantSpring _elegantCurve = ElegantSpring(bounce: _kBounce);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.replaceRoute(const MovieHomeRoute());
      }
    });
    _animation.addListener(() {
      setState(() {});
    });
    var isStart = _animationController.isAnimating;
    if(!isStart){
      _animationController.forward();
    }

  }


  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   // TODO: implement didChangeAppLifecycleState
  //   super.didChangeAppLifecycleState(state);
  //   debugPrint("go to run $state");
  //   switch(state){
  //     case AppLifecycleState.resumed:
  //       break;
  //     case AppLifecycleState.detached:
  //     case AppLifecycleState.inactive:
  //     case AppLifecycleState.hidden:
  //     case AppLifecycleState.paused:
  //       break;
  //   }
  // }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: setSystemUi(),
        child: Material(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _animation.drive(Tween<double>(begin: 0.2, end: 1.0)),
                  child: Image.asset(
                    A.assets_ic_fanju,
                    width: 85.0,
                    height: 85.0,
                    fit: BoxFit.fitWidth,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: ScaleTransition(
                    scale: _animation.drive(Tween<double>(begin: 0.2, end: 1.0)),
                    child: FadeTransition(
                      opacity: _animation.drive(Tween<double>(begin: 0.5, end: 1.0)),
                      child: const Text(
                        "番剧",
                        style: TextStyle(color: Colors.orange, fontSize: 23.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
