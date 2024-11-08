// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i4;
import 'package:flutter_sakura_anime/style/page/AnimeSplashPage.dart' as _i1;
import 'package:flutter_sakura_anime/style/page/MovieHomePage.dart' as _i2;
import 'package:flutter_sakura_anime/style/page/NeflexHomePage.dart' as _i3;

/// generated route for
/// [_i1.AnimeSplashPage]
class AnimeSplashRoute extends _i4.PageRouteInfo<void> {
  const AnimeSplashRoute({List<_i4.PageRouteInfo>? children})
      : super(
          AnimeSplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'AnimeSplashRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i1.AnimeSplashPage();
    },
  );
}

/// generated route for
/// [_i2.MovieHomePage]
class MovieHomeRoute extends _i4.PageRouteInfo<void> {
  const MovieHomeRoute({List<_i4.PageRouteInfo>? children})
      : super(
          MovieHomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'MovieHomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i2.MovieHomePage();
    },
  );
}

/// generated route for
/// [_i3.NetflexHomePage]
class NetflexHomeRoute extends _i4.PageRouteInfo<void> {
  const NetflexHomeRoute({List<_i4.PageRouteInfo>? children})
      : super(
          NetflexHomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'NetflexHomeRoute';

  static _i4.PageInfo page = _i4.PageInfo(
    name,
    builder: (data) {
      return const _i3.NetflexHomePage();
    },
  );
}
