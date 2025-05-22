import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reelsvtwo/features/video_player/presentation/manger/VideosCacheManager.dart';
import '../../manger/video_cubit/video_cubit.dart';
import '../../../../../models/video_model.dart';
import '../../../../../core/utils/styles.dart';

class CustomVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final List<VideoModel>? allVideos;
  final int? currentIndex;

  const CustomVideoPlayer({
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    this.allVideos,
    this.currentIndex,
    super.key,
  });

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  CustomVideoPlayerCubit? _cubit;
  bool _showThumbnail = true;
  bool _showLoadingIndicator = false;

  @override
  void initState() {
    super.initState();
    _showThumbnail = true;
    _showLoadingIndicator = false;

    // Show loading indicator after 1 second if still loading
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _cubit != null) {
        final state = _cubit!.state;
        setState(() {
          if (state is VideoLoading) {
            _showLoadingIndicator = true;
          } else if (state is VideoLoaded) {
            _showThumbnail = false;
          }
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cubit ??= CustomVideoPlayerCubit(VideoPlayerCacheProvider.of(context));
    _loadVideo();
  }

  void _loadVideo() {
    setState(() {
      _showThumbnail = true;
      _showLoadingIndicator = false;
    });

    _cubit?.setupVideoPlayer(widget.videoUrl, widget.thumbnailUrl);

    if (widget.allVideos != null && widget.currentIndex != null) {
      _cubit?.setAdjacentVideos(widget.allVideos!, widget.currentIndex!);
    }

    // Hide thumbnail after 1 second if video is loaded
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _cubit != null) {
        final state = _cubit!.state;
        setState(() {
          if (state is VideoLoading) {
            _showLoadingIndicator = true;
          } else if (state is VideoLoaded) {
            _showThumbnail = false;
          }
        });
      }
    });
  }

  @override
  void didUpdateWidget(CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _loadVideo();
    }
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
    if (_cubit == null) return _buildThumbnailOnly();

    return BlocBuilder<CustomVideoPlayerCubit, VideoState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is VideoLoaded && state.videoUrl != widget.videoUrl) {
          Future.microtask(_loadVideo);
          return _buildThumbnailOnly();
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Video Player
            if (state is VideoLoaded && !_showThumbnail)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height,
                    child: BetterPlayer(
                      controller: state.betterPlayerController,
                    ),
                  ),
                ),
              ),

            // Thumbnail
            if (_showThumbnail)
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: Image.network(widget.thumbnailUrl, fit: BoxFit.cover),
                ),
              ),

            // Loading Indicator
            if (_showThumbnail && _showLoadingIndicator)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),

            // Content Overlay
            if (!_showThumbnail || !_showLoadingIndicator)
              Positioned(
                left: 16,
                right: 80,
                bottom: 100,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildInfoContainer(
                      widget.title,
                      AppStyles.styleSemiBold24(context),
                      2,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoContainer(
                      widget.description,
                      AppStyles.styleMedium16(context),
                      3,
                    ),
                  ],
                ),
              ),

            // Error State
            if (state is VideoError) _buildErrorWidget(state.message),

            // State Change Listener
            BlocListener<CustomVideoPlayerCubit, VideoState>(
              bloc: _cubit,
              listener: (context, state) {
                if (state is VideoLoaded) {
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        _showThumbnail = false;
                        _showLoadingIndicator = false;
                      });
                    }
                  });
                }
              },
              child: const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildThumbnailOnly() {
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: Image.network(
          widget.thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(color: Colors.black),
        ),
      ),
    );
  }

  Widget _buildInfoContainer(String text, TextStyle style, int maxLines) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Text(
        text,
        style: style.copyWith(
          color: Colors.white,
          shadows: [
            Shadow(
              offset: const Offset(1, 1),
              blurRadius: 3,
              color: Colors.black.withOpacity(0.8),
            ),
          ],
        ),
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _loadVideo,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
