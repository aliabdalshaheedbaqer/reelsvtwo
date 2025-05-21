import 'package:flutter/material.dart';
import 'package:reelsvtwo/features/video_player/presentation/manger/VideosCacheManager.dart';
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
    
    // استخدام viewportFraction للمساعدة في تحميل الصفحات بشكل صحيح
    _pageController = PageController(
      initialPage: _currentIndex,
      keepPage: true,
      viewportFraction: 1.0,
    );
    
    // بدء تخزين الفيديو التالي في الخلفية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cacheNextVideo();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // تخزين الفيديو التالي
  void _cacheNextVideo() {
    final cacheManager = VideoPlayerCacheProvider.of(context);
    
    // تخزين الفيديو التالي فقط
    if (_currentIndex < widget.videos.length - 1) {
      cacheManager.cacheVideo(widget.videos[_currentIndex + 1].url);
    }
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
    
    // الحصول على مدير الكاش
    final cacheManager = VideoPlayerCacheProvider.of(context);
    
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black87 : Colors.grey.shade200,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black87 : Colors.grey.shade200,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('فيديو ${_currentIndex + 1}'),
            const SizedBox(width: 8),
            // إظهار علامة الكاش للفيديو الحالي إذا كان مخزنًا
            if (cacheManager.getCacheStatus(widget.videos[_currentIndex].url) == CacheStatus.cached)
              const Icon(Icons.check_circle, color: Colors.green, size: 14),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // Show info dialog
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('معلومات الفيديو'),
                  content: Text('معرف الفيديو: ${widget.videos[_currentIndex].id}\nالرابط: ${widget.videos[_currentIndex].url}'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إغلاق'),
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
        // تقليل التحميل المسبق لصفحة واحدة فقط
        allowImplicitScrolling: false,
        onPageChanged: (index) {
          print('تغيير الصفحة إلى $index - URL: ${widget.videos[index].url}');
          setState(() {
            _currentIndex = index;
          });
          
          // تخزين الفيديو التالي عند تغيير الصفحة
          _cacheNextVideo();
        },
        itemCount: widget.videos.length,
        itemBuilder: (context, index) {
          // التحقق مما إذا كانت الصفحة الحالية أو مجاورة للصفحة الحالية (صفحة واحدة فقط)
          final isCurrentOrAdjacent = (index == _currentIndex);
          
          if (!isCurrentOrAdjacent) {
            // عرض صورة مصغرة فقط للصفحات البعيدة
            return _buildPlaceholderPage(widget.videos[index]);
          }
          
          // إضافة مفتاح فريد للمساعدة في إعادة البناء
          return SingleChildScrollView(
            key: ValueKey('video_page_${widget.videos[index].id}'),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.3,
                  width: double.infinity,
                  child: CustomVideoPlayer(
                    videoUrl: widget.videos[index].url,
                    thumbnailUrl: widget.videos[index].thumbnailUrl,
                    allVideos: widget.videos,
                    currentIndex: index,
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
                                'السابق',
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
                                'التالي',
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
                    'فيديو ${widget.videos[_currentIndex].id}',
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
                        'الوصف:',
                        style: AppStyles.styleSemiBold24(context),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'هذا تطبيق مشغل فيديو نموذجي يوضح استخدام BetterPlayer وهيكلية Bloc. يمكنك التنقل بين مقاطع الفيديو باستخدام أزرار السابق والتالي أو عن طريق التمرير لليسار واليمين.',
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
  
  // بناء صفحة مؤقتة للصفحات البعيدة
  Widget _buildPlaceholderPage(VideoModel video) {
    // الحصول على حالة الكاش
    final cacheStatus = VideoPlayerCacheProvider.of(context).getCacheStatus(video.url);
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة مصغرة بدلاً من مشغل الفيديو
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            width: double.infinity,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  video.thumbnailUrl,
                  height: double.infinity,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: Colors.black12,
                  ),
                ),
                
                // أيقونة التشغيل مع مؤشر الحالة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // أيقونة التشغيل
                      const Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                      
                      // مؤشر التحميل - للحالة caching
                      if (cacheStatus == CacheStatus.caching)
                        const CircularProgressIndicator(
                          color: Colors.blue,
                          strokeWidth: 2,
                        ),
                        
                      // علامة اكتمال التحميل المسبق  
                      if (cacheStatus == CacheStatus.cached)
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                        ),
                    ],
                  ),
                ),
                
                // إضافة نص لحالة التخزين المؤقت
                if (cacheStatus == CacheStatus.caching)
                  Positioned(
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'جاري تخزين الفيديو...',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                
                if (cacheStatus == CacheStatus.cached)
                  Positioned(
                    bottom: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'جاهز للتشغيل السريع',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // تضمين نفس العناصر الأخرى من الواجهة كما في العرض الرئيسي
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 2),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              color: Theme.of(context).brightness == Brightness.dark ? null : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'فيديو ${video.id}',
                  style: AppStyles.styleMedium20(context),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'انقر للمشاهدة',
              style: AppStyles.styleMedium16(context),
            ),
          ),
        ],
      ),
    );
  }
}