import 'dart:async';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:local_auth/local_auth.dart';
import 'home_page.dart';
import 'anime/anime_home_page.dart';
import 'package:local_auth_android/local_auth_android.dart';

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
    _auth();
  }

  void _auth() {
    LocalAuthentication()
        .authenticate(
      localizedReason: "您需要扫描指纹才能进入",
      authMessages: [
       const AndroidAuthMessages(
          biometricHint: "软件登录需要扫描指纹",
          biometricNotRecognized: "指纹无法识别",
          biometricRequiredTitle: "软件登录",
          biometricSuccess: "指纹识别成功",
          cancelButton: "取消",
          goToSettingsButton: "设置",
          goToSettingsDescription: "请先设置指纹才能解锁",
          signInTitle: "您需要扫描指纹才能继续",
        )
      ],
      options: const AuthenticationOptions(
        useErrorDialogs: true,
        stickyAuth: true,
        sensitiveTransaction: true,
        biometricOnly: true,
      ),
    ).then((value) {
      if (value) {
        _animationController.forward();
      }
    }).onError((error, stackTrace) {
      debugPrint("error = $error stackTrace  = $stackTrace");
    });
  }

  Timer delayToPage() {
    return Timer(const Duration(milliseconds: 300), () {
      var router = FadeRoute(const HomePage());
      Navigator.of(context).pushAndRemoveUntil(router, (route) => false);
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
                  "樱花番剧",
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
