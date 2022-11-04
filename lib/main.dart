import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/page/splash_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';


void main() async {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var style = const SystemUiOverlayStyle(statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(style);
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        platform: TargetPlatform.android,
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        fontFamily: Static.fonts
      ),
      home: const Material(child: SplashPage(),),
    );
  }
}


