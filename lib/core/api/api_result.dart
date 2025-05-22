class ApiResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;
  
  const ApiResult._({
    this.data,
    this.error,
    required this.isSuccess,
  });
  
  factory ApiResult.success(T data) => ApiResult._(
    data: data,
    isSuccess: true,
  );
  
  factory ApiResult.failure(String error) => ApiResult._(
    error: error,
    isSuccess: false,
  );
}

