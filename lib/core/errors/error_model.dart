class ErrorModel {
  final int status;
  final String errMessage;

  ErrorModel({required this.status, required this.errMessage});

  factory ErrorModel.fromJson(Map<String, dynamic> jsonData) {
    return ErrorModel(
      status: jsonData[''] ?? 500,
      errMessage: jsonData[''] ?? 'Unknown error occurred',
    );
  }
}
