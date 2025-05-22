import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reelsvtwo/features/video_player/presentation/manger/video_cubit/reel_cubit.dart';

import 'video_player_screen.dart';
import '../widgets/video_thumbnail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReelCubit()..getReels(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Reels App'), centerTitle: true),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return BlocBuilder<ReelCubit, ReelState>(
      builder: (context, state) {
        if (state is ReelInitial ||
            state is ReelLoading && state is! ReelLoadingMore) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ReelLoaded || state is ReelLoadingMore) {
          final reels =
              state is ReelLoaded
                  ? state.reels
                  : (state as ReelLoadingMore).reels;

          final videos = reels.map((reel) => reel.toVideoModel()).toList();

          return RefreshIndicator(
            onRefresh: () => context.read<ReelCubit>().getReels(refresh: true),
            child: ListView.builder(
              itemCount: videos.length + (state is ReelLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                // Show loading indicator at the bottom while loading more
                if (index == videos.length && state is ReelLoadingMore) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final video = videos[index];
                return VideoThumbnail(
                  video: video,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => VideoPlayerScreen(
                              videos: videos,
                              initialIndex: index,
                            ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        } else if (state is ReelError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      () => context.read<ReelCubit>().getReels(refresh: true),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
