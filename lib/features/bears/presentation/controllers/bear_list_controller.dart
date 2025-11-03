import 'package:bear/core/network/api_client.dart';
import 'package:bear/core/services/cache_service.dart';
import 'package:bear/core/utils/app_logger.dart';
import 'package:bear/features/bears/data/bear_api.dart';
import 'package:bear/features/bears/data/bear_repository.dart';
import 'package:bear/features/bears/data/models/bear.dart';
import 'package:bear/features/bears/presentation/controllers/filter_state.dart';
import 'package:riverpod/riverpod.dart';

final apiBaseUrlProvider = Provider<String>((_) => 'http://127.0.0.1:3000');

final apiClientProvider = Provider((ref) {
  final base = ref.watch(apiBaseUrlProvider);
  return ApiClient(baseUrl: base);
});

final bearRepositoryProvider = Provider((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return BearRepository(BearApi(apiClient));
});

class BearListState {
  final List<Bear> items;
  final bool loading;
  final String? error;
  final FilterState filter;

  const BearListState({
    required this.items,
    required this.loading,
    this.error,
    required this.filter,
  });

  BearListState copyWith({
    List<Bear>? items,
    bool? loading,
    String? error,
    FilterState? filter,
  }) => BearListState(
    items: items ?? this.items,
    loading: loading ?? this.loading,
    error: error ?? this.error,
    filter: filter ?? this.filter,
  );

  factory BearListState.initial() => const BearListState(
    items: [],
    loading: false,
    filter: FilterState(),
  );

  /// Create initial state with cached filter
  factory BearListState.fromCachedFilter(FilterState filter) => BearListState(
    items: const [],
    loading: false,
    filter: filter,
  );
}

class BearListController extends StateNotifier<BearListState> {
  BearListController(this._repo) : super(BearListState.initial()) {
    _initialize();
  }
  final BearRepository _repo;

  /// Initialize controller: load cached filter, then load cached bears and fetch fresh data
  Future<void> _initialize() async {
    // First, load cached filter state
    final cachedFilterData = await CacheService.loadFilterState();
    final cachedFilter = FilterState(
      search: cachedFilterData['search'] as String,
      colorIds: cachedFilterData['colorIds'] as List<int>,
      startSize: cachedFilterData['minSize'] as int?,
      endSize: cachedFilterData['maxSize'] as int?,
    );

    // Update state with cached filter
    if (cachedFilter.search.isNotEmpty ||
        cachedFilter.colorIds.isNotEmpty ||
        cachedFilter.startSize != null ||
        cachedFilter.endSize != null) {
      state = state.copyWith(filter: cachedFilter);
      AppLogger.info('Loaded cached filter state');
    }

    // Now load cached bears and fetch fresh data
    await _loadFromCacheAndFetch();
  }

  /// Load cached data immediately, then fetch from backend
  Future<void> _loadFromCacheAndFetch() async {
    // Load from cache first for instant display
    final cached = await CacheService.loadBears();
    if (cached != null && cached.isNotEmpty) {
      try {
        final cachedBears = cached.map((json) => Bear.fromJson(json)).toList();
        final f = state.filter;
        final filtered = _applyClientSideFilter(cachedBears, f);
        state = state.copyWith(items: filtered, loading: true);
        AppLogger.info('Loaded ${cachedBears.length} bears from cache');
      } catch (e, stackTrace) {
        AppLogger.error('Failed to parse cached bears', e, stackTrace);
      }
    }

    // Fetch fresh data from backend
    await load();
  }

  /// Apply client-side name filter
  List<Bear> _applyClientSideFilter(List<Bear> items, FilterState f) {
    return f.search.isEmpty
        ? items
        : items
            .where(
              (b) => b.name.toLowerCase().contains(f.search.toLowerCase()),
            )
            .toList();
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final f = state.filter;
      final items = await _repo.fetch(
        colorIds: f.colorIds.isEmpty ? null : f.colorIds,
        start: f.startSize,
        end: f.endSize,
      );

      // Cache the raw data for next time
      final jsonList = items.map((bear) => {
        'id': bear.id,
        'name': bear.name,
        'size': bear.size,
        'bearColors': bear.colors.map((color) => {
          'color': {
            'id': color.id,
            'name': color.name,
            'hex': color.hex,
          }
        }).toList(),
      }).toList();
      await CacheService.saveBears(jsonList);

      // Client search by name
      final filtered = _applyClientSideFilter(items, f);
      state = state.copyWith(items: filtered, loading: false);
      AppLogger.info('Loaded ${items.length} bears from backend');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load bears from backend', e, stackTrace);
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  void updateFilter(FilterState f) {
    state = state.copyWith(filter: f);

    // Persist filter state to cache
    CacheService.saveFilterState(
      search: f.search,
      minSize: f.startSize,
      maxSize: f.endSize,
      colorIds: f.colorIds,
    );

    load();
  }

  Future<bool> createBear(
    String name,
    int size,
    List<String> colorNames,
  ) async {
    final ok = await _repo.createBear(name, size, colorNames);
    await load();
    return ok;
  }

  Future<bool> updateBear({
    required int id,
    String? name,
    int? size,
    List<String>? colorNames,
  }) async {
    try {
      await _repo.updateBear(id: id, name: name, size: size, colorNames: colorNames);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> deleteBear(int id) async {
    try {
      await _repo.deleteBear(id);
      await load();
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final bearListControllerProvider =
    StateNotifierProvider<BearListController, BearListState>((ref) {
      final repo = ref.watch(bearRepositoryProvider);
      return BearListController(repo);
    });
