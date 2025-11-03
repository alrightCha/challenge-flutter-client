class ColorModel {
  final int id;
  final String name;
  final String hex;

  ColorModel({required this.id, required this.name, required this.hex});

  factory ColorModel.fromJson(Map<String, dynamic> j) => ColorModel(
    id: j['id'],
    name: j['name'] as String,
    hex: j['hex'] as String? ?? "#000000",
  );
}
