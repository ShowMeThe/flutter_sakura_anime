import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

import 'base_export.dart';

class HttpClient {
  static const _baseUrl = "";
  static const _timeOut = Duration(milliseconds: 15000);
  static Dio? _dio;
  static Dio? _dio2;
  static Dio? _dio3;
  static final Map<String, dynamic> _map = HashMap();
  static final BaseOptions _option = BaseOptions(
      baseUrl: _baseUrl,
      sendTimeout: _timeOut,
      connectTimeout: _timeOut,
      receiveTimeout: _timeOut)
    ..headers.clear();

  static Future<String> getAppDir() async {
    var future = await getApplicationDocumentsDirectory();
    return future.path;
  }

  static Future<Dio> get() async {
    _dio ??= Dio(_option)
      ..interceptors.add(DioCacheInterceptor(
          options: CacheOptions(
        maxStale: const Duration(days: 1),
        store: HiveCacheStore(await getAppDir()),
        policy: CachePolicy.refreshForceCache,
        hitCacheOnErrorExcept: [401, 403, 404], // for offline behaviour
      )));
    return _dio!;
  }

  static Future<Dio> get2() async {
    _dio2 ??= Dio(_option)
      ..options = BaseOptions(responseType: ResponseType.bytes)
      ..interceptors.add(DioCacheInterceptor(
          options: CacheOptions(
        maxStale: const Duration(days: 1),
        store: HiveCacheStore(await getAppDir()),
        policy: CachePolicy.refreshForceCache,
        hitCacheOnErrorExcept: [401, 403, 404], // for offline behaviour
      )));
    return _dio2!;
  }

  static Dio get3() {
    _dio3 ??= Dio(_option);
    return _dio3!;
  }
}
