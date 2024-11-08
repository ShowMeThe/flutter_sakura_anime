import 'package:flutter_sakura_anime/style/import/PageImport.dart';
import 'style/router/AppRouter.dart';
import 'util/base_export.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MovieApp()));
}


class MovieApp extends StatelessWidget{
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
          colorScheme: const ColorScheme.dark()
        ),
     );
  }
}