

import 'package:auto_route/auto_route.dart';
import 'package:flutter_sakura_anime/page/home_page.dart';
import 'package:flutter_sakura_anime/style/router/AppRouter.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {

  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: MovieHomeRoute.page),
    AutoRoute(page: AnimeSplashRoute.page,initial: true),
    AutoRoute(page: NetflexDetailRoute.page,fullMatch: true),
    AutoRoute(page: NewPlayRoute.page)
  ];

  @override
  List<AutoRouteGuard> get guards => [

  ];
}