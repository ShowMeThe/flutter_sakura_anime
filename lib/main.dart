import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/page/splash_page.dart';
import 'package:flutter_sakura_anime/test_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/collect.dart';


void main() async {
  runApp(const ProviderScope(child: MyApp()));
  var style = const SystemUiOverlayStyle(statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent);
  SystemChrome.setSystemUIOverlayStyle(style);
  initDb();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: '番茄',
      theme: ThemeData(
        useMaterial3: true,
        platform: TargetPlatform.android,
        brightness: Brightness.light,
        primarySwatch: Colors.pink,
        fontFamily: Static.fonts
      ),
      home: const Material(child: SplashPage(),),
    );
  }
}


