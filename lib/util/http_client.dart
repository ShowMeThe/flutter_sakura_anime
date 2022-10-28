import 'dart:collection';

import 'package:dio/dio.dart';


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

  static Dio get({bool needCookie = false}){
    _dio ??= Dio(_option);
    return _dio!;
  }

}