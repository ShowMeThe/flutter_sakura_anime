import 'package:flutter_sakura_anime/style/import/PageImport.dart';
import 'package:media_kit/media_kit.dart';
import 'style/router/AppRouter.dart';
import 'util/base_export.dart';

void main() async {
  MediaKit.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MovieApp()));
}

class MovieApp extends StatelessWidget {
  MovieApp({super.key});

  late final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _appRouter.delegate(),
      routeInformationParser: _appRouter.defaultRouteParser(),
      title: "番茄",
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
          useMaterial3: true,
          fontFamily: Static.fonts,
          colorScheme: const ColorScheme.dark(
              primary: Colors.yellow, secondary: Colors.yellowAccent),
          shadowColor: Colors.yellowAccent.withAlpha(80),
          cardTheme: CardTheme(elevation: 8.0,   clipBehavior: Clip.antiAlias, shadowColor: Colors.yellowAccent.withAlpha(80),),
          tabBarTheme: const TabBarThemeData(
              dividerHeight: 0, indicatorColor: Colors.yellow)),
    );
  }
}
