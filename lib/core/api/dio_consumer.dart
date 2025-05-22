import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:reelsvtwo/core/api/api_consumer.dart';
import 'package:reelsvtwo/core/api/api_interceptors.dart';
import 'package:reelsvtwo/core/api/end_ponits.dart';
import 'package:reelsvtwo/core/errors/error_model.dart';
import 'package:reelsvtwo/core/errors/exceptions.dart';

class DioConsumer implements ApiConsumer {
  final Dio _dio;
  final Dio _authDio;

  static final DioConsumer _instance = DioConsumer._internal();

  factory DioConsumer() {
    // Check and update base URL if needed
    _instance._updateBaseUrls();
    return _instance;
  }

  // Method to update the base URLs when endpoints change
  void _updateBaseUrls() {
    if (_dio.options.baseUrl != EndPoints.baseUrl) {
      _dio.options.baseUrl = EndPoints.baseUrl;
      debugPrint('DioConsumer: Updated _dio baseUrl to ${EndPoints.baseUrl}');
    }
  }

  DioConsumer._internal() : _dio = Dio(), _authDio = Dio() {
    _dio.options
      ..baseUrl = EndPoints.baseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 10)
      ..followRedirects = true
      ..validateStatus = (status) => status != null && status < 500;

    // Auth Dio (sharedBaseUrl)
    _authDio.options
      ..baseUrl = EndPoints.sharedBaseUrl
      ..connectTimeout = const Duration(seconds: 10)
      ..receiveTimeout = const Duration(seconds: 15)
      ..sendTimeout = const Duration(seconds: 10)
      ..followRedirects = true
      ..validateStatus = (status) => status != null && status < 500;

    _dio.interceptors.add(ApiInterceptor());
    _authDio.interceptors.add(ApiInterceptor());

    if (kDebugMode) {
      final logInterceptor = LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: true,
        error: true,
      );
      _dio.interceptors.add(logInterceptor);
      _authDio.interceptors.add(logInterceptor);
    }
  }

  bool _isAuthEndpoint(String path) {
    return path == EndPoints.loginAuth ||
        path == EndPoints.verifyAuth ||
        path == EndPoints.profileCheck ||
        path == EndPoints.uploadFile ||
        path == EndPoints.setFcmToken ||
        path == EndPoints.userProfile;
  }

  Future<dynamic> _request({
    required String path,
    required String method,
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    try {
      // Ensure base URL is up to date before each request
      _updateBaseUrls();

      final dioInstance = _isAuthEndpoint(path) ? _authDio : _dio;

      final formattedData =
          isFormData && data != null && data is! FormData
              ? FormData.fromMap(data as Map<String, dynamic>)
              : data;

      final response = await dioInstance.request(
        path,
        data: formattedData,
        queryParameters: queryParameters,
        options: Options(method: method, headers: headers),
        cancelToken: cancelToken,
      );

      return response.data;
    } on DioException catch (e) {
      throw handleDioException(e);
    } catch (e) {
      throw ServerException(
        errModel: ErrorModel(status: 500, errMessage: e.toString()),
      );
    }
  }

  @override
  Future<dynamic> get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    CancelToken? cancelToken,
  }) async {
    return _request(
      path: path,
      method: 'GET',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    return _request(
      path: path,
      method: 'POST',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      isFormData: isFormData,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<dynamic> put(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    return _request(
      path: path,
      method: 'PUT',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      isFormData: isFormData,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<dynamic> patch(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    return _request(
      path: path,
      method: 'PATCH',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      isFormData: isFormData,
      cancelToken: cancelToken,
    );
  }

  @override
  Future<dynamic> delete(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
    bool isFormData = false,
    CancelToken? cancelToken,
  }) async {
    return _request(
      path: path,
      method: 'DELETE',
      data: data,
      queryParameters: queryParameters,
      headers: headers,
      isFormData: isFormData,
      cancelToken: cancelToken,
    );
  }
}
