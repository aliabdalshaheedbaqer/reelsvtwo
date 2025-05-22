import 'package:reelsvtwo/core/api/end_ponits.dart';

class ReelResponse {
  final int total;
  final List<ReelModel> data;

  ReelResponse({required this.total, required this.data});

  factory ReelResponse.fromJson(Map<String, dynamic> json) {
    return ReelResponse(
      total: json['total'] ?? 0,
      data:
          (json['data'] as List?)
              ?.map((item) => ReelModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ReelModel {
  final String id;
  final String title;
  final String description;
  final String videoId;
  final String adminId;
  final String businessType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final VideoData video;

  ReelModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoId,
    required this.adminId,
    required this.businessType,
    required this.createdAt,
    required this.updatedAt,
    required this.video,
  });

  factory ReelModel.fromJson(Map<String, dynamic> json) {
    return ReelModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      videoId: json['videoId'] ?? '',
      adminId: json['adminId'] ?? '',
      businessType: json['businessType'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      video: VideoData.fromJson(json['video'] ?? {}),
    );
  }

  String get fullVideoUrl => '${EndPoints.storageBaseUrl}${video.key}';

  String get thumbnailUrl =>
      'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg'; // Default thumbnail

  // Convert ReelModel to VideoModel for compatibility with existing player
  VideoModel toVideoModel() {
    return VideoModel(
      id: id,
      url: fullVideoUrl,
      thumbnailUrl: thumbnailUrl,
      title: title,
      description: description,
    );
  }
}

class VideoData {
  final String key;

  VideoData({required this.key});

  factory VideoData.fromJson(Map<String, dynamic> json) {
    return VideoData(key: json['key'] ?? '');
  }
}

// Import VideoModel class for conversion
class VideoModel {
  final String id;
  final String url;
  final String thumbnailUrl;
  final String title;
  final String description;

  VideoModel({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
  });

  static List<VideoModel> getSampleVideos() {
    return [
      // Sample videos implementation remains the same
    ];
  }
}
