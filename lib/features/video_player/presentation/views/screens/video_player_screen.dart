import 'package:flutter/material.dart';
import '../../../../../models/video_model.dart';
import '../../../../../core/utils/styles.dart';
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
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextVideo() {
    if (_currentIndex < widget.videos.length - 1) {
      _currentIndex++;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousVideo() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _pageController.animateToPage(
        _currentIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black87 : Colors.grey.shade200,
        title: Text('Video ${_currentIndex + 1}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Video Information'),
                  content: Text('Video ID: ${widget.videos[_currentIndex].id}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: CustomVideoPlayer(
                    videoUrl: widget.videos[index].url,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Card(
                    margin: const EdgeInsets.symmetric(vertical: 2),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    color: isDarkMode ? null : Colors.white,
                    child: Row(
                      children: [
                        if (_currentIndex > 0)
                          Row(
                            children: [
                              IconButton(
                                onPressed: _previousVideo,
                                icon: const Icon(Icons.arrow_circle_left),
                              ),
                              Text(
                                'Previous',
                                style: AppStyles.styleMedium16(context),
                              ),
                            ],
                          ),
                        const Spacer(),
                        // Indicator showing current page
                        Text(
                          '${_currentIndex + 1}/${widget.videos.length}',
                          style: AppStyles.styleMedium16(context),
                        ),
                        const Spacer(),
                        if (_currentIndex < widget.videos.length - 1)
                          Row(
                            children: [
                              Text(
                                'Next',
                                style: AppStyles.styleMedium16(context),
                              ),
                              IconButton(
                                onPressed: _nextVideo,
                                icon: const Icon(Icons.arrow_circle_right),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Video ${widget.videos[_currentIndex].id}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppStyles.styleMedium24(context),
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.blue, thickness: 3),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Description:',
                        style: AppStyles.styleSemiBold24(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'This is a sample video player application that demonstrates the use of BetterPlayer and Bloc architecture. You can navigate between videos using the previous and next buttons or by swiping left and right.',
                        style: AppStyles.styleMedium20(context),
                      ),
                      const SizedBox(height: 12),
                      Divider(
                        thickness: 3,
                        color: isDarkMode ? null : Colors.white,
                      ),
                      const SizedBox(height: 24),
                      Center(
                        child: Image.network(
                          widget.videos[_currentIndex].thumbnailUrl,
                          height: 150,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.image, size: 150),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}