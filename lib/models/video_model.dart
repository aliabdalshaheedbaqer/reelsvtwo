class VideoModel {
  final String id;
  final String url;
  final String thumbnailUrl;
  final String title;
  final String description;

  VideoModel({
    required this.id,
    required this.url,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
  });

  static List<VideoModel> getSampleVideos() {
    return [
      VideoModel(
        id: 'video_1',
        url:
            'https://fsn1.your-objectstorage.com/777/895fdf06-e455-42b7-9449-bc396ea42d8b.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/BigBuckBunny.jpg',
        title: 'Big Buck Bunny',
        description:
            'A beautifully animated short film about a big buck bunny and his adventures in the forest.',
      ),
      VideoModel(
        id: 'video_2',
        url:
            'https://fsn1.your-objectstorage.com/777/d8c1ed81-fd6c-4c46-9d9c-4fabdb233a8b.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ElephantsDream.jpg',
        title: 'Elephants Dream',
        description:
            'An artistic journey through a surreal world of dreams and imagination.',
      ),
      VideoModel(
        id: 'video_3',
        url:
            'https://fsn1.your-objectstorage.com/777/fd1e000c-1fc6-4d1c-b3e7-72b03581dc00.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerBlazes.jpg',
        title: 'For Bigger Blazes',
        description:
            'Experience the thrill of adventure and excitement in this action-packed video.',
      ),
      VideoModel(
        id: 'video_4',
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerEscapes.jpg',
        title: 'For Bigger Escapes',
        description:
            'Journey to breathtaking destinations and discover amazing landscapes.',
      ),
      VideoModel(
        id: 'video_5',
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerFun.jpg',
        title: 'For Bigger Fun',
        description:
            'Get ready for endless entertainment and joy with this fun-filled video.',
      ),
      VideoModel(
        id: 'video_6',
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerJoyrides.jpg',
        title: 'For Bigger Joyrides',
        description:
            'Take an exciting ride through amazing adventures and thrilling moments.',
      ),
      VideoModel(
        id: 'video_7',
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/ForBiggerMeltdowns.jpg',
        title: 'For Bigger Meltdowns',
        description:
            'Experience intense moments and dramatic scenes in this captivating video.',
      ),
      VideoModel(
        id: 'video_8',
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/Sintel.jpg',
        title: 'Sintel',
        description:
            'A touching story of friendship and adventure in a fantasy world.',
      ),
      VideoModel(
        id: 'video_9',
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/SubaruOutbackOnStreetAndDirt.jpg',
        title: 'Subaru Outback Adventure',
        description:
            'Explore both urban streets and rugged terrain with the versatile Subaru Outback.',
      ),
      VideoModel(
        id: 'video_10',
        url:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
        thumbnailUrl:
            'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/images/TearsOfSteel.jpg',
        title: 'Tears of Steel',
        description:
            'A sci-fi action short film featuring robots, warriors, and epic battles.',
      ),
    ];
  }
}
