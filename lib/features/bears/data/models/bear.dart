import 'color.dart';

class Bear {
  final int id;
  final String name;
  final int size;
  final List<ColorModel> colors;

  Bear({
    required this.id,
    required this.name,
    required this.size,
    required this.colors,
  });

  factory Bear.fromJson(Map<String, dynamic> j) {
    final bearColors = (j['bearColors'] as List?) ?? [];
    final colors = bearColors.map((bc) {
      final colorData = bc['color'] as Map<String, dynamic>;
      // Ensure we have all required fields for ColorModel
      return ColorModel(
        id: colorData['id'] as int,
        name: colorData['name'] as String,
        hex: colorData['hex'] as String? ?? "#000000",
      );
    }).toList();

    return Bear(
      id: j['id'] as int,
      name: j['name'] as String,
      size: j['size'] as int,
      colors: colors,
    );
  }
}
