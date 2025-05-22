import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;

enum CacheStatus { notCached, caching, cached, error }

class VideosCacheManager {
  static final VideosCacheManager _instance = VideosCacheManager._();
  factory VideosCacheManager() => _instance;
  VideosCacheManager._();

  final Map<String, CacheStatus> _cacheStatus = {};

  Future<bool> isVideoCached(String videoUrl) async {
    try {
      if (_cacheStatus[videoUrl] == CacheStatus.cached) {
        return true;
      }

      final fileInfo = await DefaultCacheManager().getFileFromCache(videoUrl);
      final isCached = fileInfo != null;

      if (isCached) {
        _cacheStatus[videoUrl] = CacheStatus.cached;
      }

      return isCached;
    } catch (e) {
      print('Cache check error: $e');
      return false;
    }
  }

  Future<bool> needsFullLoading(String videoUrl) async {
    return !(await isVideoCached(videoUrl));
  }

  CacheStatus getCacheStatus(String videoUrl) {
    return _cacheStatus[videoUrl] ?? CacheStatus.notCached;
  }

  Future<void> cacheVideo(String videoUrl) async {
    if (_cacheStatus[videoUrl] == CacheStatus.caching ||
        _cacheStatus[videoUrl] == CacheStatus.cached) {
      return;
    }

    _cacheStatus[videoUrl] = CacheStatus.caching;

    try {
      // Pre-cache first 1MB for faster startup
      final response = await http.Client().send(
        http.Request('GET', Uri.parse(videoUrl))
          ..headers['Range'] = 'bytes=0-1048576',
      );

      if (response.statusCode == 200 || response.statusCode == 206) {
        _cacheStatus[videoUrl] = CacheStatus.cached;
        print('Video cached: $videoUrl');
      }
    } catch (e) {
      print('Cache error: $e');
      _cacheStatus[videoUrl] = CacheStatus.error;
    }
  }

  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
    _cacheStatus.clear();
  }
}

class VideoPlayerCacheProvider extends InheritedWidget {
  final VideosCacheManager cacheManager;

  const VideoPlayerCacheProvider({
    super.key,
    required this.cacheManager,
    required super.child,
  });

  static VideosCacheManager of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<VideoPlayerCacheProvider>();
    assert(provider != null, 'VideoPlayerCacheProvider not found in context');
    return provider!.cacheManager;
  }

  @override
  bool updateShouldNotify(VideoPlayerCacheProvider oldWidget) => false;
}
