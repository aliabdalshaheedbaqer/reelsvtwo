import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
import 'package:reelsvtwo/features/video_player/presentation/manger/VideosCacheManager.dart';
import '../../../../../models/video_model.dart';

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

  VideoLoaded(
    this.betterPlayerController,
    this.videoUrl, {
    this.isCached = false,
  });
}

class VideoError extends VideoState {
  final String message;
  VideoError(this.message);
}

class CustomVideoPlayerCubit extends Cubit<VideoState> {
  CustomVideoPlayerCubit(this.cacheManager) : super(VideoInitial());

  final VideosCacheManager cacheManager;
  BetterPlayerController? _controller;
  String? _currentVideoUrl;
  List<VideoModel>? _adjacentVideos;
  int? _currentIndex;

  Future<void> setupVideoPlayer(String videoUrl, String thumbnailUrl) async {
    if (_currentVideoUrl == videoUrl && state is VideoLoaded) {
      return;
    }

    _currentVideoUrl = videoUrl;
    final needsLoading = await cacheManager.needsFullLoading(videoUrl);
    final isCached = await cacheManager.isVideoCached(videoUrl);

    if (needsLoading) {
      emit(VideoLoading(thumbnailUrl, isCached: isCached));
    }

    try {
      _disposeCurrentController();

      _controller = BetterPlayerController(
        BetterPlayerConfiguration(
          aspectRatio: 9 / 16,
          controlsConfiguration: const BetterPlayerControlsConfiguration(
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
          looping: true,
          fullScreenByDefault: false,
          fit: BoxFit.cover,
          startAt: const Duration(milliseconds: 0),
          placeholderOnTop: false,
          handleLifecycle: isCached,
          deviceOrientationsAfterFullScreen: [],
          systemOverlaysAfterFullScreen: [],
          expandToFill: true,
          fullScreenAspectRatio: 9 / 16,
          playerVisibilityChangedBehavior:
              (visibilityFraction) => visibilityFraction > 0,
        ),
        betterPlayerDataSource: BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          videoUrl,
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
        ),
      );

      emit(VideoLoaded(_controller!, videoUrl, isCached: isCached));

      if (!isCached) {
        cacheManager.cacheVideo(videoUrl);
      }

      _cacheAdjacentVideos();
    } catch (e) {
      print('Video load error: $e');
      emit(VideoError("Video load error: $e"));
    }
  }

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
      _controller?.dispose();
      _controller = null;
    } catch (e) {
      print('Controller dispose error: $e');
    }
  }

  @override
  Future<void> close() {
    _disposeCurrentController();
    return super.close();
  }
}
