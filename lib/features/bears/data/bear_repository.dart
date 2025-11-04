import 'bear_api.dart';
import 'models/bear.dart';
import 'models/color.dart';

class BearRepository {
  BearRepository(this.api);
  final BearApi api;

  Future<List<Bear>> fetch({
    List<int>? colorIds,
    int? start,
    int? end,
  }) async {
    if (colorIds != null && colorIds.isNotEmpty && start != null && end != null) {
      return api.getBearsByColorsAndSize(colorIds, start, end);
    }
    if (colorIds != null && colorIds.isNotEmpty) {
      return api.getBearsByColors(colorIds);
    }
    if (start != null && end != null) {
      return api.getBearsBySizeRange(start, end);
    }
    // fallback: fetch all bears with maximum size range
    return api.getBearsBySizeRange(
      0,
      9999,
    );
  }

  Future<bool> createBear(String name, int size, List<String> colorNames) =>
      api.createBear(name: name, size: size, colorNames: colorNames);

  Future<Map<String, dynamic>> updateBear({
    required int id,
    String? name,
    int? size,
    List<String>? colorNames,
  }) =>
      api.updateBear(id: id, name: name, size: size, colorNames: colorNames);

  Future<bool> deleteBear(int id) => api.deleteBear(id);

  Future<List<ColorModel>> colors() => api.getAllColors();

  Future<bool> addColor(String colorName, String hex) => api.addColor(colorName, hex);

  Future<bool> deleteColor(String color) => api.deleteColor(color); 
}
