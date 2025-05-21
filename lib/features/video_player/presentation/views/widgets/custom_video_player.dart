import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reelsvtwo/features/video_player/presentation/manger/VideosCacheManager.dart';
import '../../manger/video_cubit/video_cubit.dart';
import '../../../../../models/video_model.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final List<VideoModel>? allVideos;
  final int? currentIndex;

  const CustomVideoPlayer({
    required this.videoUrl,
    required this.thumbnailUrl,
    this.allVideos,
    this.currentIndex,
    super.key
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  CustomVideoPlayerCubit? _cubit;  // Cambiado a nullable
  bool _isInitialized = false;
  String? _lastVideoUrl;

  @override
  void initState() {
    super.initState();
    _lastVideoUrl = widget.videoUrl;
    // NO inicializar _cubit aquí - lo inicializamos en didChangeDependencies
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Inicializar el cubit si aún no está inicializado
    if (_cubit == null) {
      _cubit = CustomVideoPlayerCubit(VideoPlayerCacheProvider.of(context));
      
      // تحميل الفيديو الأولي
      if (!_isInitialized) {
        _loadVideo();
      }
    }
  }
  
  void _loadVideo() {
    // تحميل الفيديو فقط إذا تغير URL أو لم يتم التحميل بعد
    if (_lastVideoUrl != widget.videoUrl || !_isInitialized) {
      _lastVideoUrl = widget.videoUrl;
      _cubit?.setupVideoPlayer(widget.videoUrl, widget.thumbnailUrl);
      
      // تعيين معلومات الفيديوهات المجاورة
      if (widget.allVideos != null && widget.currentIndex != null) {
        _cubit?.setAdjacentVideos(widget.allVideos!, widget.currentIndex!);
      }
      
      _isInitialized = true;
    }
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // تحقق من تغير الفيديو
    if (oldWidget.videoUrl != widget.videoUrl) {
      print('تغير عنوان الفيديو من ${oldWidget.videoUrl} إلى ${widget.videoUrl}');
      _loadVideo();
    }
    
    // تحديث معلومات الفيديوهات المجاورة إذا تغير المؤشر
    if (widget.allVideos != null && 
        widget.currentIndex != null && 
        oldWidget.currentIndex != widget.currentIndex) {
      _cubit?.setAdjacentVideos(widget.allVideos!, widget.currentIndex!);
    }
  }

  @override
  void dispose() {
    _cubit?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cubit == null) {
      return _buildLoadingPlaceholder();
    }
    
    // الحصول على حالة الكاش مباشرة
    final cacheManager = VideoPlayerCacheProvider.of(context);
    final isCached = cacheManager.getCacheStatus(widget.videoUrl) == CacheStatus.cached;
    
    return BlocBuilder<CustomVideoPlayerCubit, VideoState>(
      bloc: _cubit,
      builder: (context, state) {
        // التحقق من أن حالة الفيديو المحمل تتطابق مع URL الحالي
        if (state is VideoLoaded && state.videoUrl != widget.videoUrl) {
          // إذا كان الفيديو المحمل مختلفًا عن الفيديو المطلوب، نعيد التحميل
          Future.microtask(() => _loadVideo());
          
          // استخدام مؤشر مختلف للفيديوهات المخزنة
          if (isCached) {
            return _buildInstantPlayPlaceholder();
          }
          return _buildLoadingPlaceholder();
        }
        
        // عرض الحالة المناسبة
        if (state is VideoLoaded) {
          // عرض الفيديو مع مؤشر الكاش
          return Stack(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: BetterPlayer(controller: state.betterPlayerController),
              ),
              // مؤشر الكاش
              if (state.isCached)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'من الكاش',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        } else if (state is VideoLoading) {
          // عرض حالة التحميل
          return _buildLoadingPlaceholder();
        } else if (state is VideoError) {
          // عرض حالة الخطأ
          return _buildErrorWidget(state.message);
        } else {
          // حالة البدء - عرض مؤشر مختلف للفيديوهات المخزنة
          if (isCached) {
            return _buildInstantPlayPlaceholder();
          }
          return _buildLoadingPlaceholder();
        }
      },
    );
  }

  // بناء مؤشر التحميل الأولي
  Widget _buildLoadingPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // صورة مصغرة كخلفية
        Image.network(
          widget.thumbnailUrl,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black12,
          ),
        ),
        // مؤشر التحميل
        const CircularProgressIndicator(
          color: Colors.white,
        ),
      ],
    );
  }

  // مؤشر التشغيل الفوري للفيديوهات المخزنة
  Widget _buildInstantPlayPlaceholder() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // الصورة المصغرة
        Image.network(
          widget.thumbnailUrl,
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: Colors.black12,
          ),
        ),
        // أيقونة التشغيل الفوري
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(50),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 36,
              ),
              SizedBox(width: 4),
              Icon(
                Icons.flash_on,
                color: Colors.green,
                size: 16,
              ),
            ],
          ),
        ),
        // مؤشر التشغيل الفوري
        Positioned(
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cached,
                  color: Colors.green,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  'جاهز للتشغيل الفوري',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // مؤشر الخطأ
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _loadVideo,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}