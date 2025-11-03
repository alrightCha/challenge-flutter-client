import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_logger.dart';

/// Handles bears, colors, and filter state caching
class CacheService {
  CacheService._();

  // Cache keys
  static const String _bearsKey = 'cached_bears';
  static const String _colorsKey = 'cached_colors';
  static const String _filterSearchKey = 'filter_search';
  static const String _filterMinSizeKey = 'filter_min_size';
  static const String _filterMaxSizeKey = 'filter_max_size';
  static const String _filterColorIdsKey = 'filter_color_ids';

  /// Save bears data to cache
  static Future<void> saveBears(List<Map<String, dynamic>> bears) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(bears);
      await prefs.setString(_bearsKey, encoded);
      AppLogger.debug('CacheService: Saved ${bears.length} bears to cache');
    } catch (e, stackTrace) {
      AppLogger.error('CacheService: Failed to save bears', e, stackTrace);
    }
  }

  /// Load bears data from cache
  static Future<List<Map<String, dynamic>>?> loadBears() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_bearsKey);
      if (cached == null) {
        AppLogger.debug('CacheService: No cached bears found');
        return null;
      }
      final List<dynamic> decoded = json.decode(cached);
      final bears = decoded.cast<Map<String, dynamic>>();
      AppLogger.debug('CacheService: Loaded ${bears.length} bears from cache');
      return bears;
    } catch (e, stackTrace) {
      AppLogger.error('CacheService: Failed to load bears', e, stackTrace);
      return null;
    }
  }

  /// Save colors data to cache
  static Future<void> saveColors(List<Map<String, dynamic>> colors) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = json.encode(colors);
      await prefs.setString(_colorsKey, encoded);
      AppLogger.debug('CacheService: Saved ${colors.length} colors to cache');
    } catch (e, stackTrace) {
      AppLogger.error('CacheService: Failed to save colors', e, stackTrace);
    }
  }

  /// Load colors data from cache
  static Future<List<Map<String, dynamic>>?> loadColors() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString(_colorsKey);
      if (cached == null) {
        AppLogger.debug('CacheService: No cached colors found');
        return null;
      }
      final List<dynamic> decoded = json.decode(cached);
      final colors = decoded.cast<Map<String, dynamic>>();
      AppLogger.debug('CacheService: Loaded ${colors.length} colors from cache');
      return colors;
    } catch (e, stackTrace) {
      AppLogger.error('CacheService: Failed to load colors', e, stackTrace);
      return null;
    }
  }

  /// Save filter state to cache
  static Future<void> saveFilterState({
    String? search,
    int? minSize,
    int? maxSize,
    List<int>? colorIds,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (search != null) {
        await prefs.setString(_filterSearchKey, search);
      }
      if (minSize != null) {
        await prefs.setInt(_filterMinSizeKey, minSize);
      }
      if (maxSize != null) {
        await prefs.setInt(_filterMaxSizeKey, maxSize);
      }
      if (colorIds != null) {
        await prefs.setString(_filterColorIdsKey, json.encode(colorIds));
      }

      AppLogger.debug('CacheService: Saved filter state to cache');
    } catch (e, stackTrace) {
      AppLogger.error('CacheService: Failed to save filter state', e, stackTrace);
    }
  }

  /// Load filter state from cache
  static Future<Map<String, dynamic>> loadFilterState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final search = prefs.getString(_filterSearchKey) ?? '';
      final minSize = prefs.getInt(_filterMinSizeKey);
      final maxSize = prefs.getInt(_filterMaxSizeKey);

      List<int> colorIds = [];
      final colorIdsStr = prefs.getString(_filterColorIdsKey);
      if (colorIdsStr != null) {
        final List<dynamic> decoded = json.decode(colorIdsStr);
        colorIds = decoded.cast<int>();
      }

      AppLogger.debug('CacheService: Loaded filter state from cache');

      return {
        'search': search,
        'minSize': minSize,
        'maxSize': maxSize,
        'colorIds': colorIds,
      };
    } catch (e, stackTrace) {
      AppLogger.error('CacheService: Failed to load filter state', e, stackTrace);
      return {
        'search': '',
        'minSize': null,
        'maxSize': null,
        'colorIds': <int>[],
      };
    }
  }

  /// Clear all cached data
  static Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_bearsKey);
      await prefs.remove(_colorsKey);
      await prefs.remove(_filterSearchKey);
      await prefs.remove(_filterMinSizeKey);
      await prefs.remove(_filterMaxSizeKey);
      await prefs.remove(_filterColorIdsKey);
      AppLogger.info('CacheService: Cleared all cached data');
    } catch (e, stackTrace) {
      AppLogger.error('CacheService: Failed to clear cache', e, stackTrace);
    }
  }
}
