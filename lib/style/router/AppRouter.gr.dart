// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i9;
import 'package:flutter_sakura_anime/bean/factory_tab.dart' as _i11;
import 'package:flutter_sakura_anime/style/page/AnimeSplashPage.dart' as _i1;
import 'package:flutter_sakura_anime/style/page/MovieHomePage.dart' as _i2;
import 'package:flutter_sakura_anime/style/page/NetflexDetailPage.dart' as _i5;
import 'package:flutter_sakura_anime/style/page/NetflexHomePage.dart' as _i6;
import 'package:flutter_sakura_anime/style/page/NetFlexSearchPage.dart' as _i3;
import 'package:flutter_sakura_anime/style/page/NetFlexSearchResultPage.dart'
    as _i4;
import 'package:flutter_sakura_anime/style/page/NewPlayPage.dart' as _i7;
import 'package:flutter_sakura_anime/style/page/ViewTestPage.dart' as _i8;
import 'package:flutter_sakura_anime/util/base_export.dart' as _i10;

/// generated route for
/// [_i1.AnimeSplashPage]
class AnimeSplashRoute extends _i9.PageRouteInfo<void> {
  const AnimeSplashRoute({List<_i9.PageRouteInfo>? children})
      : super(
          AnimeSplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'AnimeSplashRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i1.AnimeSplashPage();
    },
  );
}

/// generated route for
/// [_i2.MovieHomePage]
class MovieHomeRoute extends _i9.PageRouteInfo<void> {
  const MovieHomeRoute({List<_i9.PageRouteInfo>? children})
      : super(
          MovieHomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'MovieHomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i2.MovieHomePage();
    },
  );
}

/// generated route for
/// [_i3.NetFlexSearchPage]
class NetFlexSearchRoute extends _i9.PageRouteInfo<void> {
  const NetFlexSearchRoute({List<_i9.PageRouteInfo>? children})
      : super(
          NetFlexSearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'NetFlexSearchRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i3.NetFlexSearchPage();
    },
  );
}

/// generated route for
/// [_i4.NetFlexSearchResultPage]
class NetFlexSearchResultRoute
    extends _i9.PageRouteInfo<NetFlexSearchResultRouteArgs> {
  NetFlexSearchResultRoute({
    required String keyWord,
    _i10.Key? key,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          NetFlexSearchResultRoute.name,
          args: NetFlexSearchResultRouteArgs(
            keyWord: keyWord,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'NetFlexSearchResultRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NetFlexSearchResultRouteArgs>();
      return _i4.NetFlexSearchResultPage(
        keyWord: args.keyWord,
        key: args.key,
      );
    },
  );
}

class NetFlexSearchResultRouteArgs {
  const NetFlexSearchResultRouteArgs({
    required this.keyWord,
    this.key,
  });

  final String keyWord;

  final _i10.Key? key;

  @override
  String toString() {
    return 'NetFlexSearchResultRouteArgs{keyWord: $keyWord, key: $key}';
  }
}

/// generated route for
/// [_i5.NetflexDetailPage]
class NetflexDetailRoute extends _i9.PageRouteInfo<NetflexDetailRouteArgs> {
  NetflexDetailRoute({
    required _i11.FactoryTabListBean source,
    required String heroTag,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          NetflexDetailRoute.name,
          args: NetflexDetailRouteArgs(
            source: source,
            heroTag: heroTag,
          ),
          initialChildren: children,
        );

  static const String name = 'NetflexDetailRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NetflexDetailRouteArgs>();
      return _i5.NetflexDetailPage(
        source: args.source,
        heroTag: args.heroTag,
      );
    },
  );
}

class NetflexDetailRouteArgs {
  const NetflexDetailRouteArgs({
    required this.source,
    required this.heroTag,
  });

  final _i11.FactoryTabListBean source;

  final String heroTag;

  @override
  String toString() {
    return 'NetflexDetailRouteArgs{source: $source, heroTag: $heroTag}';
  }
}

/// generated route for
/// [_i6.NetflexHomePage]
class NetflexHomeRoute extends _i9.PageRouteInfo<void> {
  const NetflexHomeRoute({List<_i9.PageRouteInfo>? children})
      : super(
          NetflexHomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'NetflexHomeRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return const _i6.NetflexHomePage();
    },
  );
}

/// generated route for
/// [_i7.NewPlayPage]
class NewPlayRoute extends _i9.PageRouteInfo<NewPlayRouteArgs> {
  NewPlayRoute({
    required String url,
    required String title,
    required bool fromLocal,
    _i10.Key? key,
    List<_i9.PageRouteInfo>? children,
  }) : super(
          NewPlayRoute.name,
          args: NewPlayRouteArgs(
            url: url,
            title: title,
            fromLocal: fromLocal,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'NewPlayRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NewPlayRouteArgs>();
      return _i7.NewPlayPage(
        args.url,
        args.title,
        args.fromLocal,
        key: args.key,
      );
    },
  );
}

class NewPlayRouteArgs {
  const NewPlayRouteArgs({
    required this.url,
    required this.title,
    required this.fromLocal,
    this.key,
  });

  final String url;

  final String title;

  final bool fromLocal;

  final _i10.Key? key;

  @override
  String toString() {
    return 'NewPlayRouteArgs{url: $url, title: $title, fromLocal: $fromLocal, key: $key}';
  }
}

/// generated route for
/// [_i8.ViewTestPage]
class ViewTestRoute extends _i9.PageRouteInfo<void> {
  const ViewTestRoute({List<_i9.PageRouteInfo>? children})
      : super(
          ViewTestRoute.name,
          initialChildren: children,
        );

  static const String name = 'ViewTestRoute';

  static _i9.PageInfo page = _i9.PageInfo(
    name,
    builder: (data) {
      return _i8.ViewTestPage();
    },
  );
}
