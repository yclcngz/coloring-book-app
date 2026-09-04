import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';
import 'package:xml/xml.dart';
import 'package:flutter/services.dart' show rootBundle;

class ColorablePath {
  final Path path;
  Color color;

  ColorablePath({required this.path, this.color = Colors.white});
}

class SvgParser {
  static Future<List<ColorablePath>> parseSvg(String assetPath) async {
    try {
      final String svgString = await rootBundle.loadString(assetPath);
      final document = XmlDocument.parse(svgString);
      final paths = document.findAllElements('path');
      
      List<ColorablePath> colorablePaths = [];
      
      for (var element in paths) {
        final pathData = element.getAttribute('d');
        if (pathData != null) {
          final path = parseSvgPathData(pathData);
          colorablePaths.add(ColorablePath(path: path));
        }
      }
      return colorablePaths;
    } catch (e) {
      debugPrint("Error parsing SVG: $e");
      return []; // Return empty if file not found or invalid
    }
  }
}

class ColoringPainter extends CustomPainter {
  final List<ColorablePath> paths;
  final Size originalSize;

  ColoringPainter({required this.paths, this.originalSize = const Size(500, 500)});

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate scale to fit the canvas
    final scaleX = size.width / originalSize.width;
    final scaleY = size.height / originalSize.height;
    final scale = scaleX < scaleY ? scaleX : scaleY;

    // Center the drawing
    final dx = (size.width - originalSize.width * scale) / 2;
    final dy = (size.height - originalSize.height * scale) / 2;

    canvas.translate(dx, dy);
    canvas.scale(scale, scale);

    final paint = Paint()..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black
      ..strokeWidth = 2.0;

    for (var colorablePath in paths) {
      paint.color = colorablePath.color;
      canvas.drawPath(colorablePath.path, paint);
      canvas.drawPath(colorablePath.path, borderPaint);
    }
  }

  @override
  bool hitTest(Offset position) {
    return true; // We handle hit testing in the gesture detector
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for simplicity when color changes
  }
}
