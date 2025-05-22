import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class ApiInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final locale =
        WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final lang = locale;

    options.headers['lang'] = lang;

    super.onRequest(options, handler);
  }
}
