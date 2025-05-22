
import 'package:muneer/core/api/end_ponits.dart';

class ErrorModel {
  final int status;
  final String errMessage;

  ErrorModel({required this.status, required this.errMessage});
  
  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    return ErrorModel(
      status: jsonData[ApiKeys.status] ?? 500,
      errMessage: jsonData[ApiKeys.errorMessage] ?? 'Unknown error occurred',
    );
  }
}