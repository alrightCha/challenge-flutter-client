import '../../../core/network/api_client.dart';
import 'models/bear.dart';
import 'models/color.dart';

class BearApi {
  BearApi(this.client);
  final ApiClient client;

  // GET /bear/size-in-range/:start/:end
  Future<List<Bear>> getBearsBySizeRange(int start, int end) async {
    return client.getJson('/bear/size-in-range/$start/$end', (d) {
      final list = (d as List).cast<Map<String, dynamic>>();
      return list.map(Bear.fromJson).toList();
    });
  }

  // GET /bear/color-size-in-range/:colors/:start/:end
  Future<List<Bear>> getBearsByColorsAndSize(
    List<int> colorIds,
    int start,
    int end,
  ) async {
    final colorsParam = colorIds.join(',');
    return client.getJson(
      '/bear/color-size-in-range/$colorsParam/$start/$end',
      (d) {
        final list = (d as List).cast<Map<String, dynamic>>();
        return list.map(Bear.fromJson).toList();
      },
    );
  }

  // GET /bear/colors/:colors
  Future<List<Bear>> getBearsByColors(List<int> colorIds) async {
    final colorsParam = colorIds.join(',');
    return client.getJson('/bear/colors/$colorsParam', (d) {
      final list = (d as List).cast<Map<String, dynamic>>();
      return list.map(Bear.fromJson).toList();
    });
  }

  // POST /bear with CreateBearDto
  Future<bool> createBear({
    required String name,
    required int size,
    required List<String> colorNames,
  }) async {
    return client.postJson(
      '/bear',
      (d) => d as bool,
      body: {'name': name, 'size': size, 'colors': colorNames},
    );
  }

  // PUT /bear/:id with UpdateBearDto
  Future<Map<String, dynamic>> updateBear({
    required int id,
    String? name,
    int? size,
    List<String>? colorNames,
  }) async {
    final body = <String, dynamic>{};
    if (name != null && name.isNotEmpty) {
      body['name'] = name;
    }
    if (size != null && size > 0) {
      body['size'] = size;
    }
    if (colorNames != null) {
      body['colors'] = colorNames;
    }

    if (body.isEmpty) {
      throw Exception(
        'At least one field (name, size, or colors) must be provided for update',
      );
    }

    return client.putJson(
      '/bear/$id',
      (d) => d as Map<String, dynamic>,
      body: body,
    );
  }

  // DELETE /bear/:id
  Future<bool> deleteBear(int id) async {
    return client.deleteJson('/bear/$id', (d) => d as bool);
  }

  // Colors endpoints
  Future<List<ColorModel>> getAllColors() async {
    return client.getJson('/color/all', (d) {
      final list = (d as List).cast<Map<String, dynamic>>();
      return list.map(ColorModel.fromJson).toList();
    });
  }

  Future<bool> addColor(String color, String hex) async {
    return client.postJson(
      '/color',
      (d) => d as bool,
      body: {'name': color, 'hex': hex},
    );
  }

  Future<bool> deleteColor(String color) async {
    return client.deleteJson('/color/$color', (d) => d as bool);
  }
}
