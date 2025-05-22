import 'package:reelsvtwo/core/api/api_consumer.dart';
import 'package:reelsvtwo/core/api/api_result.dart';
import 'package:reelsvtwo/core/api/dio_consumer.dart';
import 'package:reelsvtwo/core/api/end_ponits.dart';
import 'package:reelsvtwo/core/errors/exceptions.dart';
import 'package:reelsvtwo/models/video_model.dart';

class ReelRepository {
  final ApiConsumer _apiConsumer;

  ReelRepository({ApiConsumer? apiConsumer})
    : _apiConsumer = apiConsumer ?? DioConsumer();

  Future<ApiResult<ReelResponse>> getReels({
    int page = 1,
    int pageSize = 10,
  }) async {
    try {
      final response = await _apiConsumer.get(
        EndPoints.getReels,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );

      final reelResponse = ReelResponse.fromJson(response);
      return ApiResult.success(reelResponse);
    } on ServerException catch (e) {
      return ApiResult.failure(e.errModel.errMessage);
    } catch (e) {
      return ApiResult.failure(e.toString());
    }
  }
}
