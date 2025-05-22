import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

import 'package:path_provider/path_provider.dart';

import 'package:reelsvtwo/features/video_player/presentation/manger/VideosCacheManager.dart';
import 'package:reelsvtwo/features/video_player/presentation/views/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إنشاء مدير الكاش
  final cacheManager = VideosCacheManager();

  // إضافة مستمع لدورة حياة التطبيق
  WidgetsBinding.instance.addObserver(AppLifecycleObserver(cacheManager));

  // إنشاء مدير الكاش

  // إضافة مستمع لدورة حياة التطبيق
  WidgetsBinding.instance.addObserver(AppLifecycleObserver(cacheManager));

  runApp(MyApp(cacheManager: cacheManager));
}

// مراقب دورة حياة التطبيق
class AppLifecycleObserver extends WidgetsBindingObserver {
  final VideosCacheManager cacheManager;

  AppLifecycleObserver(this.cacheManager);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // تنظيف الكاش عند إغلاق التطبيق
      cacheManager.clearCache();
      cacheManager.dispose();
    } else if (state == AppLifecycleState.paused) {
      // يمكن تنفيذ بعض عمليات التنظيف للذاكرة عند تصغير التطبيق
      DefaultCacheManager().emptyCache();
    }
  }
}

class MyApp extends StatelessWidget {
  final VideosCacheManager cacheManager;
  const MyApp({required this.cacheManager, super.key});

  @override
  Widget build(BuildContext context) {
    return VideoPlayerCacheProvider(
      cacheManager: cacheManager,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Video Player App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
