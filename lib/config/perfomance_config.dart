// lib/config/performance_config.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class PerformanceConfig {
  static Future<void> initialize() async {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      try {
        await FlutterDisplayMode.setHighRefreshRate();
      } catch (e) {
        debugPrint('Failed to set high refresh rate: $e');
      }
    }

    SystemChrome.setSystemUIChangeCallback((systemOverlaysAreVisible) async {
      if (!systemOverlaysAreVisible) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      }
    });

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    PaintingBinding.instance.imageCache.maximumSize = 1000;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20;

    await DefaultCacheManager().emptyCache();
  }

  static void optimizeWidget(BuildContext context) {
    if (!kIsWeb) {
      WidgetsBinding.instance.renderView?.automaticSystemUiAdjustment = false;
    }
  }

  static Widget optimizeListView({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return ListView.builder(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      shrinkWrap: shrinkWrap,
      physics: physics,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      cacheExtent: 100,
    );
  }

  static Widget optimizeGridView({
    required Widget Function(BuildContext, int) itemBuilder,
    required int itemCount,
    required SliverGridDelegate gridDelegate,
    bool shrinkWrap = false,
    ScrollPhysics? physics,
  }) {
    return GridView.builder(
      itemBuilder: itemBuilder,
      itemCount: itemCount,
      gridDelegate: gridDelegate,
      shrinkWrap: shrinkWrap,
      physics: physics,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
      addSemanticIndexes: false,
      cacheExtent: 100,
    );
  }

  static void disposeResources() {
    DefaultCacheManager().emptyCache();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }
}