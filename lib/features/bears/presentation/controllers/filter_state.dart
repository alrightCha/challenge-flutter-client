class FilterState {
  final String search;          // by name (client-side filter)
  final List<int> colorIds;     // backend filter
  final int? startSize;         // backend filter
  final int? endSize;           // backend filter

  const FilterState({
    this.search = '',
    this.colorIds = const [],
    this.startSize,
    this.endSize,
  });

  FilterState copyWith({
    String? search,
    List<int>? colorIds,
    int? startSize,
    int? endSize,
  }) =>
      FilterState(
        search: search ?? this.search,
        colorIds: colorIds ?? this.colorIds,
        startSize: startSize ?? this.startSize,
        endSize: endSize ?? this.endSize,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterState &&
          runtimeType == other.runtimeType &&
          search == other.search &&
          _listEquals(colorIds, other.colorIds) &&
          startSize == other.startSize &&
          endSize == other.endSize;

  @override
  int get hashCode =>
      search.hashCode ^
      colorIds.hashCode ^
      startSize.hashCode ^
      endSize.hashCode;

  bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
