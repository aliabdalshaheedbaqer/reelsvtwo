// lib/features/video_player/presentation/views/widgets/custom_video_player.dart
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
  CustomVideoPlayerCubit? _cubit;
  bool _isInitialized = false;
  String? _lastVideoUrl;
  bool _showThumbnail = true;
  bool _showLoadingIndicator = false;

  @override
  void initState() {
    super.initState();
    _lastVideoUrl = widget.videoUrl;
    
    // Mostrar solo la miniatura al principio, sin indicador
    _showThumbnail = true;
    _showLoadingIndicator = false;
    
    // Esperar 1 segundo exacto antes de mostrar el indicador de carga si es necesario
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          // Después de 1 segundo, mostrar el indicador de carga si el video aún no está listo
          if (_cubit != null) {
            final state = _cubit!.state;
            if (state is VideoLoading) {
              _showLoadingIndicator = true;
            } else if (state is VideoLoaded) {
              // Si el video ya está cargado, ocultar la miniatura
              _showThumbnail = false;
            }
          }
        });
      }
    });
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (_cubit == null) {
      _cubit = CustomVideoPlayerCubit(VideoPlayerCacheProvider.of(context));
      
      if (!_isInitialized) {
        _loadVideo();
      }
    }
  }
  
  void _loadVideo() {
    if (_lastVideoUrl != widget.videoUrl || !_isInitialized) {
      _lastVideoUrl = widget.videoUrl;
      
      // Reiniciar estados de visualización
      setState(() {
        _showThumbnail = true;
        _showLoadingIndicator = false;
      });
      
      // Cargar el video
      _cubit?.setupVideoPlayer(widget.videoUrl, widget.thumbnailUrl);
      
      if (widget.allVideos != null && widget.currentIndex != null) {
        _cubit?.setAdjacentVideos(widget.allVideos!, widget.currentIndex!);
      }
      
      _isInitialized = true;
      
      // Programar verificación después de 1 segundo exacto
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            // Verificar el estado actual después de 1 segundo
            if (_cubit != null) {
              final state = _cubit!.state;
              if (state is VideoLoading) {
                // Si todavía está cargando, mostrar el indicador
                _showLoadingIndicator = true;
              } else if (state is VideoLoaded) {
                // Si ya terminó de cargar, ocultar miniatura
                _showThumbnail = false;
              }
            }
          });
        }
      });
    }
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
    if (_cubit == null) {
      return _buildThumbnailOnly();
    }
    
    return BlocBuilder<CustomVideoPlayerCubit, VideoState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is VideoLoaded && state.videoUrl != widget.videoUrl) {
          Future.microtask(() => _loadVideo());
          return _buildThumbnailOnly();
        }
        
        if (state is VideoLoaded) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Video a pantalla completa (visible o no según _showThumbnail)
              Visibility(
                visible: !_showThumbnail,
                maintainState: true,
                child: Container(
                  color: Colors.black,
                  child: SizedBox.expand(
                    child: Center(
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        margin: const EdgeInsets.symmetric(vertical: 0),
                        child: BetterPlayer(controller: state.betterPlayerController),
                      ),
                    ),
                  ),
                ),
              ),
              
              // Miniatura (se muestra durante 1 segundo o más si es necesario)
              if (_showThumbnail)
                Container(
                  color: Colors.black,
                  child: Image.network(
                    widget.thumbnailUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              
              // Indicador de carga (solo se muestra si el video sigue cargando después de 1 segundo)
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
              
              // Listener para el cambio de estado (para ocultar miniatura cuando el video esté listo)
              BlocListener<CustomVideoPlayerCubit, VideoState>(
                bloc: _cubit,
                listener: (context, state) {
                  if (state is VideoLoaded) {
                    // Esperar al menos 1 segundo antes de ocultar la miniatura
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
                child: const SizedBox.shrink(), // Widget vacío, solo para escuchar cambios
              ),
            ],
          );
        } else if (state is VideoLoading) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // Miniatura a pantalla completa
              Container(
                color: Colors.black,
                child: Image.network(
                  widget.thumbnailUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
              
              // Indicador de carga (solo visible después de 1 segundo)
              if (_showLoadingIndicator)
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
            ],
          );
        } else if (state is VideoError) {
          return _buildErrorWidget(state.message);
        } else {
          return _buildThumbnailOnly();
        }
      },
    );
  }

  // Widget que muestra solo la miniatura sin indicador de carga
  Widget _buildThumbnailOnly() {
    return Container(
      color: Colors.black,
      child: Image.network(
        widget.thumbnailUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => Container(
          color: Colors.black,
        ),
      ),
    );
  }

  // Widget para estado de carga con imagen e indicador opcional
  Widget _buildLoadingPlaceholder() {
    return Container(
      color: Colors.black,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Miniatura a pantalla completa
          Image.network(
            widget.thumbnailUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.black,
            ),
          ),
          
          // Indicador de carga (solo visible si _showLoadingIndicator es true)
          if (_showLoadingIndicator)
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
        ],
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
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}