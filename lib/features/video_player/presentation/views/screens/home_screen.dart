import 'package:flutter/material.dart';
import '../../../../../models/video_model.dart';
import 'video_player_screen.dart';
import '../widgets/video_thumbnail.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final videos = VideoModel.getSampleVideos();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video Player App'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: videos.length,
        itemBuilder: (context, index) {
          final video = videos[index];
          return VideoThumbnail(
            video: video,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
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
  }
}