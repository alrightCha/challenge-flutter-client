import 'package:flutter/material.dart';

/// Utility class for color-related operations
class ColorUtils {
  ColorUtils._();

  static Color hexToColor(String hex) {
    final hexCode = hex.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static String colorToHex(Color color) {
    return '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';
  }
}

extension HexColor on String {
  Color toColor() => ColorUtils.hexToColor(this);
}
