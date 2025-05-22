import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

// نوع لتتبع حالة التخزين
enum CacheStatus { notCached, caching, cached, error }

// مدير التخزين المؤقت للفيديو - محسن للتدفق
class VideosCacheManager {
  static final VideosCacheManager _instance = VideosCacheManager._();
  factory VideosCacheManager() => _instance;
  VideosCacheManager._();

  final YoutubeExplode _youtubeExplode = YoutubeExplode();
  final Map<String, String> _resolvedUrls = {}; // تخزين روابط الفيديو المحللة
  final Map<String, CacheStatus> _cacheStatus = {}; // حالة التخزين المؤقت

  // التحقق مما إذا كان الفيديو مخزنًا - بدون استدعاء getProcessedUrl
  Future<bool> isVideoCached(String videoUrl) async {
    try {
      // أولاً نتحقق من حالة الكاش المخزنة لدينا
      if (_cacheStatus[videoUrl] == CacheStatus.cached) {
        return true;
      }
      
      // التحقق مباشرة باستخدام رابط الفيديو كمفتاح (بدون معالجة)
      final fileInfo = await DefaultCacheManager().getFileFromCache(videoUrl);
      
      if (fileInfo != null) {
        _cacheStatus[videoUrl] = CacheStatus.cached;
        return true;
      }
      
      // إذا كان رابط يوتيوب، نتحقق من وجود إصدار محلل مخزن
      if (videoUrl.contains('youtu') && _resolvedUrls.containsKey(videoUrl)) {
        final resolvedUrl = _resolvedUrls[videoUrl]!;
        final resolvedFileInfo = await DefaultCacheManager().getFileFromCache(resolvedUrl);
        
        if (resolvedFileInfo != null) {
          _cacheStatus[videoUrl] = CacheStatus.cached;
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('خطأ في التحقق من حالة التخزين: $e');
      return false;
    }
  }

  // الحصول على URL محلل
  Future<String> getProcessedUrl(String videoUrl) async {
    // التحقق من الكاش للرابط المعالج أولاً
    if (_resolvedUrls.containsKey(videoUrl)) {
      return _resolvedUrls[videoUrl]!;
    }

    try {
      // معالجة روابط يوتيوب
      if (videoUrl.contains('youtu')) {
        print('معالجة رابط يوتيوب: $videoUrl');
        var videoId = VideoId(videoUrl);
        var streamManifest = await _youtubeExplode.videos.streamsClient.getManifest(videoId);
        String resolvedUrl = streamManifest.muxed.withHighestBitrate().url.toString();
        _resolvedUrls[videoUrl] = resolvedUrl;
        return resolvedUrl;
      }
      return videoUrl;
    } catch (e) {
      print('خطأ في معالجة رابط الفيديو: $e');
      return videoUrl;
    }
  }

  // دالة تحقق إذا كان الفيديو يحتاج لتحميل كامل
  Future<bool> needsFullLoading(String videoUrl) async {
    // إذا كان الفيديو مخزن، سيتم تحميله فورًا بدون حالة تحميل
    return !(await isVideoCached(videoUrl));
  }

  // الحصول على حالة التخزين للفيديو
  CacheStatus getCacheStatus(String videoUrl) {
    return _cacheStatus[videoUrl] ?? CacheStatus.notCached;
  }

  // تخزين الفيديو في الخلفية (تخزين ذكي - يحفظ فقط بداية الفيديو للتسريع)
  Future<void> cacheVideo(String videoUrl) async {
    // إذا كان الفيديو قيد التخزين بالفعل أو تم تخزينه، نتخطى
    if (_cacheStatus[videoUrl] == CacheStatus.caching || 
        _cacheStatus[videoUrl] == CacheStatus.cached) {
      return;
    }
    
    _cacheStatus[videoUrl] = CacheStatus.caching;
    
    try {
      // الحصول على الرابط المعالج
      final processedUrl = await getProcessedUrl(videoUrl);
      
      // تحميل فقط الجزء الأول من الفيديو (1 ميجابايت)
      // هذا يساعد في تسريع بدء التشغيل عند إعادة الزيارة
      final response = await http.Client().send(http.Request('GET', Uri.parse(processedUrl))
        ..headers['Range'] = 'bytes=0-1048576'); // تحميل أول 1 ميجابايت فقط
      
      if (response.statusCode == 200 || response.statusCode == 206) {
        _cacheStatus[videoUrl] = CacheStatus.cached;
        print('تم تخزين بداية الفيديو: $videoUrl');
      }
    } catch (e) {
      print('خطأ في تخزين الفيديو: $e');
      _cacheStatus[videoUrl] = CacheStatus.error;
    }
  }

  // تنظيف الكاش
  Future<void> clearCache() async {
    await DefaultCacheManager().emptyCache();
    _resolvedUrls.clear();
    _cacheStatus.clear();
  }

  // إغلاق مدير التخزين المؤقت
  void dispose() {
    _youtubeExplode.close();
  }
}

// مزود مدير التخزين المؤقت
class VideoPlayerCacheProvider extends InheritedWidget {
  final VideosCacheManager cacheManager;

  const VideoPlayerCacheProvider({
    Key? key,
    required this.cacheManager,
    required Widget child,
  }) : super(key: key, child: child);

  static VideosCacheManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<VideoPlayerCacheProvider>();
    assert(provider != null, 'VideoPlayerCacheProvider not found in context');
    return provider!.cacheManager;
  }

  @override
  bool updateShouldNotify(VideoPlayerCacheProvider oldWidget) => false;
}