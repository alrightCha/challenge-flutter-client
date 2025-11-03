import 'package:bear/features/bears/data/bear_repository.dart';
import 'package:bear/features/bears/data/models/color.dart';
import 'package:bear/features/bears/presentation/controllers/bear_list_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/cache_service.dart';
import '../../../../core/utils/app_logger.dart';

class ColorListState {
  final List<ColorModel> items;
  final bool loading;
  final String? error;

  const ColorListState({
    required this.items,
    required this.loading,
    this.error,
  });

  ColorListState copyWith({
    List<ColorModel>? items,
    bool? loading,
    String? error,
  }) =>
      ColorListState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );

  factory ColorListState.initial() => const ColorListState(
        items: [],
        loading: false,
      );
}

class ColorListController extends StateNotifier<ColorListState> {
  ColorListController(this._repo) : super(ColorListState.initial()) {
    _loadFromCacheAndFetch();
  }
  final BearRepository _repo;

  /// Load cached colors immediately, then fetch from backend
  Future<void> _loadFromCacheAndFetch() async {
    // Load from cache first for instant display
    final cached = await CacheService.loadColors();
    if (cached != null && cached.isNotEmpty) {
      try {
        final cachedColors = cached.map((json) => ColorModel.fromJson(json)).toList();
        state = state.copyWith(items: cachedColors, loading: true);
        AppLogger.info('ColorListController: Loaded ${cachedColors.length} colors from cache');
      } catch (e, stackTrace) {
        AppLogger.error('ColorListController: Failed to parse cached colors', e, stackTrace);
      }
    }

    // Fetch fresh data from backend
    await load();
  }

  Future<void> load() async {
    AppLogger.info('ColorListController: Loading colors from backend...');
    state = state.copyWith(loading: true, error: null);
    try {
      final items = await _repo.colors();

      // Cache the raw data for next time
      final jsonList = items.map((color) => {
        'id': color.id,
        'name': color.name,
        'hex': color.hex,
      }).toList();
      await CacheService.saveColors(jsonList);

      AppLogger.info('ColorListController: Loaded ${items.length} colors from backend');
      state = state.copyWith(items: items, loading: false);
    } catch (e, stackTrace) {
      AppLogger.error('ColorListController: Error loading colors', e, stackTrace);
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<bool> addColor(String colorName, String hex) async {
    try {
      await _repo.addColor(colorName, hex);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteColor(String colorName) async {
    try {
      final success = await _repo.deleteColor(colorName);
      if (success) {
        await load();
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final colorListControllerProvider =
    StateNotifierProvider<ColorListController, ColorListState>((ref) {
  final repo = ref.watch(bearRepositoryProvider);
  return ColorListController(repo);
});
