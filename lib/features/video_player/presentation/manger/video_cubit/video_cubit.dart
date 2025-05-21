import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:reelsvtwo/features/video_player/presentation/manger/VideosCacheManager.dart';
import '../../../../../models/video_model.dart';

// Cubit State
@immutable
abstract class VideoState {}

class VideoInitial extends VideoState {}

class VideoLoading extends VideoState {
  final String thumbnailUrl;
  final bool isCached;
  
  VideoLoading(this.thumbnailUrl, {this.isCached = false});
}

class VideoLoaded extends VideoState {
  final BetterPlayerController betterPlayerController;
  final bool isCached;
  final String videoUrl; // إضافة رابط الفيديو للتحقق

  VideoLoaded(this.betterPlayerController, this.videoUrl, {this.isCached = false});
}

class VideoError extends VideoState {
  final String message;

  VideoError(this.message);
}

// Video Cubit
class CustomVideoPlayerCubit extends Cubit<VideoState> {
  CustomVideoPlayerCubit(this.cacheManager) : super(VideoInitial());

  final VideosCacheManager cacheManager;
  BetterPlayerController? _controller;
  String? _currentVideoUrl; // تتبع الفيديو الحالي

  Future<void> setupVideoPlayer(String videoUrl, String thumbnailUrl) async {
    // التحقق من أن الفيديو ليس نفس الفيديو الحالي
    if (_currentVideoUrl == videoUrl && state is VideoLoaded) {
      print('الفيديو قيد التشغيل بالفعل: $videoUrl');
      return;
    }
    
    // تعيين الفيديو الحالي
    _currentVideoUrl = videoUrl;
    
    // التحقق مما إذا كان الفيديو يحتاج لحالة تحميل كاملة
    bool needsLoading = await cacheManager.needsFullLoading(videoUrl);
    bool isCached = await cacheManager.isVideoCached(videoUrl);
    
    // إظهار حالة التحميل فقط للفيديوهات غير المخزنة
    if (needsLoading) {
      emit(VideoLoading(thumbnailUrl, isCached: isCached));
    }

    try {
      // الحصول على الرابط المعالج
      String processedUrl = await cacheManager.getProcessedUrl(videoUrl);
      
      // التخلص من المتحكم السابق
      _disposeCurrentController();
      
      // إنشاء مصدر البيانات مع إعدادات تدفق محسنة
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        processedUrl,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 3 * 1024 * 1024,     // 3 ميجابايت فقط للتحميل المسبق
          maxCacheSize: 100 * 1024 * 1024,   // 100 ميجابايت للكاش الكلي
          maxCacheFileSize: 30 * 1024 * 1024, // 30 ميجابايت لملف الكاش
          key: videoUrl, // استخدام رابط الفيديو الأصلي كمفتاح للكاش
        ),
        // إعدادات تدفق محسنة للتشغيل السريع
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 2000,                 // 2 ثانية فقط للتخزين المؤقت الأدنى
          maxBufferMs: 10000,                // 10 ثواني للتخزين المؤقت الأقصى
          bufferForPlaybackMs: 200,          // بدء التشغيل بعد 200 مللي ثانية فقط
          bufferForPlaybackAfterRebufferMs: 500, // 500 مللي ثانية بعد إعادة التخزين المؤقت
        ),
      );

      // إنشاء متحكم بإعدادات محسنة للتشغيل السريع
      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: 16 / 9,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            enableSkips: true,
            skipBackIcon: Icons.replay_10,
            skipForwardIcon: Icons.forward_10,
            enableMute: true,
            enableFullscreen: true,
            enablePlaybackSpeed: true,
            showControlsOnInitialize: false, // تغيير: عدم إظهار عناصر التحكم مباشرة للفيديوهات المخزنة
            enableProgressBar: true,
            enableProgressText: true,
          ),
          autoPlay: true,
          looping: false,
          fullScreenByDefault: false,
          fit: BoxFit.contain,
          startAt: const Duration(milliseconds: 0),
          placeholderOnTop: true,
          // للفيديوهات المخزنة، إعدادات خاصة لتسريع التحميل
          handleLifecycle: isCached, // استخدام في الفيديوهات المخزنة فقط
          playerVisibilityChangedBehavior: (visibilityFraction) {
            return visibilityFraction > 0;
          },
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );

      // إصدار حالة التحميل الناجح
      emit(VideoLoaded(_controller!, videoUrl, isCached: isCached));
        
      // تخزين الفيديو في الخلفية للاستخدام اللاحق
      if (!isCached) {
        cacheManager.cacheVideo(videoUrl);
      }
        
      // تحميل الفيديوهات المجاورة
      if (_adjacentVideos != null && _currentIndex != null) {
        _cacheAdjacentVideos();
      }
    } catch (e) {
      print('خطأ في تحميل الفيديو: $e');
      emit(VideoError("خطأ في تحميل الفيديو: $e"));
    }
  }

  // المتغيرات المستخدمة للتخزين
  List<VideoModel>? _adjacentVideos;
  int? _currentIndex;

  // تعيين الفيديوهات المجاورة للتخزين المسبق
  void setAdjacentVideos(List<VideoModel> videos, int currentIndex) {
    _adjacentVideos = videos;
    _currentIndex = currentIndex;
    
    // بدء تخزين الفيديوهات
    _cacheAdjacentVideos();
  }

  // تخزين الفيديوهات المجاورة
  Future<void> _cacheAdjacentVideos() async {
    if (_adjacentVideos == null || _currentIndex == null) return;
    
    // تخزين الفيديو التالي فقط (الأكثر احتمالاً للمشاهدة)
    if (_currentIndex! < _adjacentVideos!.length - 1) {
      cacheManager.cacheVideo(_adjacentVideos![_currentIndex! + 1].url);
    }
  }

  // التخلص من المتحكم الحالي
  void _disposeCurrentController() {
    try {
      if (_controller != null) {
        _controller!.dispose();
        _controller = null;
      }
    } catch (e) {
      print('خطأ في التخلص من المتحكم: $e');
    }
  }

  @override
  Future<void> close() {
    _disposeCurrentController();
    return super.close();
  }
}