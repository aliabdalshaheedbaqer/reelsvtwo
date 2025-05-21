// lib/features/video_player/presentation/views/screens/video_player_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reelsvtwo/features/video_player/presentation/manger/VideosCacheManager.dart';
import '../../../../../models/video_model.dart';
import '../widgets/custom_video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final List<VideoModel> videos;
  final int initialIndex;

  const VideoPlayerScreen({
    super.key,
    required this.videos,
    required this.initialIndex,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    
    // Cambiar a pantalla completa para experiencia tipo TikTok
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    _pageController = PageController(
      initialPage: _currentIndex,
      keepPage: true,
      viewportFraction: 1.0,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cacheNextVideo();
    });
  }

  @override
  void dispose() {
    // Restaurar UI del sistema al salir
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    
    _pageController.dispose();
    super.dispose();
  }

  void _cacheNextVideo() {
    final cacheManager = VideoPlayerCacheProvider.of(context);
    
    if (_currentIndex < widget.videos.length - 1) {
      cacheManager.cacheVideo(widget.videos[_currentIndex + 1].url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      // Agregar botón de retroceso muy sutil
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white54, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Eliminar todo padding o margin
      body: SizedBox.expand(
        child: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: false,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
            _cacheNextVideo();
          },
          itemCount: widget.videos.length,
          itemBuilder: (context, index) {
            return SizedBox.expand(
              child: CustomVideoPlayer(
                videoUrl: widget.videos[index].url,
                thumbnailUrl: widget.videos[index].thumbnailUrl,
                allVideos: widget.videos,
                currentIndex: index,
              ),
            );
          },
        ),
      ),
    );
  }
}