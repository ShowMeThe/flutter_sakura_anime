import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:flutter_sakura_anime/page/splash_page.dart';
import 'package:flutter_sakura_anime/util/base_export.dart';
import 'package:flutter_sakura_anime/util/collect.dart';
import 'dart:ui';

import 'package:media_kit/media_kit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
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
          colorScheme: const ColorScheme(
              brightness: Brightness.light,
              onSurface: Colors.black,
              surfaceContainerHighest: ColorRes.mainColor,
              primary: Colors.white,
              onPrimary: Colors.blue,
              secondary: Colors.white,
              onSecondary: Colors.blue,
              surface:  Colors.black,
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
              bodyMedium: TextStyle(color: Colors.white, fontSize: 12),
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
          colorScheme: const ColorScheme(
              brightness: Brightness.light,
              onSurface: Colors.white,
              surfaceContainerHighest: ColorRes.mainColor,
              primary: ColorRes.pink400,
              onPrimary: Colors.white,
              secondary: ColorRes.pink400,
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
              surface: Colors.white),
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
              bodyMedium: TextStyle(color: Colors.white, fontSize: 12),
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
