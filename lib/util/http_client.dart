import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:path_provider/path_provider.dart';

import 'base_export.dart';

class HttpClient {
  static const _baseUrl = "";
  static const _timeOut = 15000;
  static Dio? _dio;
  static final Map<String, dynamic> _map = HashMap();
  static final BaseOptions _option = BaseOptions(
      baseUrl: _baseUrl,
      sendTimeout: _timeOut,
      connectTimeout: _timeOut,
      receiveTimeout: _timeOut);

  static Future<String> getAppDir() async{
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
        hitCacheOnErrorExcept:  [401, 403, 404], // for offline behaviour
      )));
    return _dio!;
  }
}
