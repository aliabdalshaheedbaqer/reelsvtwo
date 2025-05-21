// lib/features/video_player/presentation/manger/video_cubit/video_cubit.dart
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
  final String videoUrl;

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
  String? _currentVideoUrl;

  Future<void> setupVideoPlayer(String videoUrl, String thumbnailUrl) async {
    if (_currentVideoUrl == videoUrl && state is VideoLoaded) {
      print('الفيديو قيد التشغيل بالفعل: $videoUrl');
      return;
    }
    
    _currentVideoUrl = videoUrl;
    
    bool needsLoading = await cacheManager.needsFullLoading(videoUrl);
    bool isCached = await cacheManager.isVideoCached(videoUrl);
    
    if (needsLoading) {
      emit(VideoLoading(thumbnailUrl, isCached: isCached));
    }

    try {
      String processedUrl = await cacheManager.getProcessedUrl(videoUrl);
      
      _disposeCurrentController();
      
      BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        processedUrl,
        cacheConfiguration: BetterPlayerCacheConfiguration(
          useCache: true,
          preCacheSize: 3 * 1024 * 1024,
          maxCacheSize: 100 * 1024 * 1024,
          maxCacheFileSize: 30 * 1024 * 1024,
          key: videoUrl,
        ),
        bufferingConfiguration: const BetterPlayerBufferingConfiguration(
          minBufferMs: 2000,
          maxBufferMs: 10000,
          bufferForPlaybackMs: 200,
          bufferForPlaybackAfterRebufferMs: 500,
        ),
      );

      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          // Eliminamos aspectRatio para que se adapte automáticamente
          // aspectRatio: 16 / 9,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
            // Ocultar completamente todos los controles para experiencia tipo TikTok
            showControls: false,
            enableMute: false,
            enableFullscreen: false,
            enablePlaybackSpeed: false,
            showControlsOnInitialize: false,
            enableProgressBar: false,
            enableProgressText: false,
            enableSkips: false,
          ),
          autoPlay: true,
          looping: true, // Habilitar loop para experiencia tipo TikTok
          fullScreenByDefault: false,
          // Usar BoxFit.cover para que el video llene toda la pantalla
          fit: BoxFit.cover,
          startAt: const Duration(milliseconds: 0),
          // Eliminar marcador de posición
          placeholderOnTop: false,
          handleLifecycle: isCached,
          playerVisibilityChangedBehavior: (visibilityFraction) {
            return visibilityFraction > 0;
          },
        ),
        betterPlayerDataSource: betterPlayerDataSource,
      );

      emit(VideoLoaded(_controller!, videoUrl, isCached: isCached));
        
      if (!isCached) {
        cacheManager.cacheVideo(videoUrl);
      }
        
      if (_adjacentVideos != null && _currentIndex != null) {
        _cacheAdjacentVideos();
      }
    } catch (e) {
      print('خطأ في تحميل الفيديو: $e');
      emit(VideoError("خطأ في تحميل الفيديو: $e"));
    }
  }

  List<VideoModel>? _adjacentVideos;
  int? _currentIndex;

  void setAdjacentVideos(List<VideoModel> videos, int currentIndex) {
    _adjacentVideos = videos;
    _currentIndex = currentIndex;
    
    _cacheAdjacentVideos();
  }

  Future<void> _cacheAdjacentVideos() async {
    if (_adjacentVideos == null || _currentIndex == null) return;
    
    if (_currentIndex! < _adjacentVideos!.length - 1) {
      cacheManager.cacheVideo(_adjacentVideos![_currentIndex! + 1].url);
    }
  }

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