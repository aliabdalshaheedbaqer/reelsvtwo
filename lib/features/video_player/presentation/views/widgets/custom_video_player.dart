import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../manger/video_cubit/video_cubit.dart';

class CustomVideoPlayer extends StatelessWidget {
  final String videoUrl;

  const CustomVideoPlayer({required this.videoUrl, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CustomVideoPlayerCubit()..setupVideoPlayer(videoUrl),
      child: BlocBuilder<CustomVideoPlayerCubit, VideoState>(
        buildWhen: (previous, current) =>
            previous != current, // Improve performance by preventing unnecessary rebuilds
        builder: (context, state) {
          print(videoUrl);
          if (state is VideoLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            );
          } else if (state is VideoLoaded) {
            return AspectRatio(
              aspectRatio: 16 / 9,
              child: BetterPlayer(controller: state.betterPlayerController),
            );
          } else if (state is VideoError) {
            return Center(child: Text(state.message));
          } else {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            );
          }
        },
      ),
    );
  }
}