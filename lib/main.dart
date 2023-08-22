import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/page/splash_page.dart';
import 'package:flutter_sakura_anime/test_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/collect.dart';
import 'dart:ui';

void main() async {
  runApp(const ProviderScope(child: MyApp()));
  initDb();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '番茄',
      darkTheme: ThemeData(
          useMaterial3: true,
          platform: TargetPlatform.android,
          brightness: Brightness.light,
          colorScheme: ColorScheme(
              brightness: Brightness.light,
              background: Colors.black,
              onBackground: ColorRes.mainColor,
              primary: Colors.white,
              onPrimary: Colors.blue,
              secondary: Colors.white,
              onSecondary: Colors.blue,
              onSurface: Colors.white.withAlpha(125),
              surface: Colors.white.withAlpha(225),
              error: Colors.red,
              onError: Colors.white),
          primarySwatch: Colors.blue,
          primaryColor: Colors.black,
          cardColor: Colors.blue,
          dividerColor: Colors.white,
          chipTheme: const ChipThemeData(
            secondaryLabelStyle:
                TextStyle(color: Colors.black, fontFamily: Static.fonts),
            labelStyle:
                TextStyle(color: Colors.white, fontFamily: Static.fonts),
          ),
          tabBarTheme: TabBarTheme(
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.blue.withAlpha(155),
          ),
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white38,
              iconTheme: IconThemeData(color: Colors.blue)),
          textTheme: const TextTheme(
              titleSmall: TextStyle(color: Colors.white, fontSize: 15),
              bodySmall: TextStyle(color: Colors.blue, fontSize: 12),
              displaySmall: TextStyle(color: Colors.white, fontSize: 12),
              displayMedium: TextStyle(color: Colors.white, fontSize: 20)),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
              backgroundColor: Colors.black,
              unselectedItemColor: Colors.white.withAlpha(125),
              selectedItemColor: Colors.white),
          fontFamily: Static.fonts),
      theme: ThemeData(
          useMaterial3: true,
          platform: TargetPlatform.android,
          brightness: Brightness.light,
          primarySwatch: Colors.pink,
          primaryColor: Colors.pink,
          cardColor: Colors.pink,
          dividerColor: Colors.transparent,
          chipTheme: const ChipThemeData(
            secondaryLabelStyle:
                TextStyle(color: Colors.white, fontFamily: Static.fonts),
            labelStyle:
                TextStyle(color: Colors.black, fontFamily: Static.fonts),
          ),
          colorScheme: ColorScheme(
              brightness: Brightness.light,
              background: Colors.white,
              onBackground: ColorRes.mainColor,
              primary: ColorRes.pink400,
              onPrimary: Colors.white,
              secondary: ColorRes.pink400,
              onSecondary: Colors.white,
              onSurface: Colors.white.withAlpha(125),
              surface: Colors.white.withAlpha(225),
              error: Colors.red,
              onError: Colors.white),
          tabBarTheme: const TabBarTheme(
            indicatorColor: ColorRes.pink400,
            labelColor: ColorRes.pink400,
            unselectedLabelColor: ColorRes.pink200,
          ),
          appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: Colors.pink,
              iconTheme: IconThemeData(color: Colors.pink)),
          textTheme: const TextTheme(
              titleSmall: TextStyle(color: Colors.black, fontSize: 15),
              bodySmall: TextStyle(color: Colors.pink, fontSize: 12),
              displaySmall: TextStyle(color: Colors.pink, fontSize: 12),
              displayMedium: TextStyle(color: Colors.pink, fontSize: 20)),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: Colors.pink,
            unselectedItemColor: Colors.pink.withAlpha(125),
          ),
          fontFamily: Static.fonts),
      home: AnnotatedRegion<SystemUiOverlayStyle>(
        value: setSystemUi(),
        child: const Material(
          child: SplashPage(),
        ),
      ),
    );
  }
}
