import 'package:dio/dio.dart';

import 'package:muneer/core/errors/error_model.dart';

class ServerException implements Exception {
  final ErrorModel errModel;

  ServerException({required this.errModel});
}

ServerException handleDioException(DioException e) {
  if (e.type == DioExceptionType.badResponse) {
    final response = e.response;
    if (response != null && response.data is Map<String, dynamic>) {
      return ServerException(
        errModel: ErrorModel.fromJson(response.data),
      );
    }
  }
  
 
  String errorMessage;
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
      errorMessage = 'Connection timeout with API server';
      break;
    case DioExceptionType.sendTimeout:
      errorMessage = 'Send timeout with API server';
      break;
    case DioExceptionType.receiveTimeout:
      errorMessage = 'Receive timeout with API server';
      break;
    case DioExceptionType.badCertificate:
      errorMessage = 'Invalid certificate with API server';
      break;
    case DioExceptionType.connectionError:
      errorMessage = 'Connection error, please check your internet connection';
      break;
    case DioExceptionType.cancel:
      errorMessage = 'Request to API server was cancelled';
      break;
    case DioExceptionType.unknown:
      errorMessage = e.message?.contains('SocketException') ?? false
          ? 'No internet connection'
          : 'Unexpected error, please try again';
      break;
    default:
      errorMessage = 'Something went wrong, please try again';
  }
  
  return ServerException(
    errModel: ErrorModel(
      status: e.response?.statusCode ?? 500,
      errMessage: errorMessage,
    ),
  );
}