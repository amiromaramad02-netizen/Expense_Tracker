import 'dart:math';
import 'package:flutter/material.dart';

class PieChart extends StatelessWidget {
  final Map<String, double> data;
  final double strokeWidth;
  final bool showLegend;
  final String Function(double)? valueFormatter;
  /// Optional stable ordering of categories used to compute consistent
  /// colors across the app (so the same category always gets the same hue).
  final List<String>? categoryOrder;

  const PieChart({
    super.key,
    required this.data,
    this.strokeWidth = 12,
    this.showLegend = true,
    this.valueFormatter,
    this.categoryOrder,
  });

  @override
  Widget build(BuildContext context) {
    final total = data.values.fold(0.0, (a, b) => a + b);
    final entries = data.entries.toList();

    // Generate a visually distinct palette that scales with number of
    // categories. We use HSL to pick evenly spaced hues for clear
    // differentiation between segments.
    // Use a stable base list for distributing hues so colors remain
    // consistent across different components (pie chart, legend, icons).
    final baseCategories = categoryOrder ?? entries.map((e) => e.key).toList();
    List<Color> palette = [];
    for (var i = 0; i < entries.length; i++) {
      final key = entries[i].key;
      final indexInBase = baseCategories.indexOf(key);
      final indexForHue = indexInBase >= 0 ? indexInBase : i;
      final hue = (indexForHue * 360 / max(1, baseCategories.length));
      final color = HSLColor.fromAHSL(1.0, hue % 360, 0.65, 0.45).toColor();
      palette.add(color);
    }

    return LayoutBuilder(builder: (context, constraints) {
      final size = constraints.biggest;
      final chartSize = Size(size.width, size.height);

      // If legend is disabled, render a compact centered donut that uses the
      // full available square area (so small widgets show a larger, clearer chart).
      if (!showLegend) {
        final d = min(chartSize.width, chartSize.height);
        return SizedBox(
          width: chartSize.width,
          height: chartSize.height,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: d,
              height: d,
              child: CustomPaint(
                painter: _PiePainter(entries, palette, strokeWidth: strokeWidth, valueFormatter: valueFormatter),
              ),
            ),
          ),
        );
      }

      // Default layout: chart on top and legend below as a list (better for
      // narrow/portrait layouts like mobile). Legend items display the color
      // swatch, name, value and percent.
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Chart (keeps square aspect ratio)
          SizedBox(
            width: min(chartSize.width, chartSize.height) * 0.8,
            height: min(chartSize.width, chartSize.height) * 0.8,
            child: CustomPaint(
              painter: _PiePainter(entries, palette, strokeWidth: strokeWidth, valueFormatter: valueFormatter),
            ),
          ),
          const SizedBox(height: 12),
          if (showLegend)
            SizedBox(
              height: chartSize.height * 0.25,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(entries.length, (i) {
                    final e = entries[i];
                    final color = palette[i % palette.length];
                    final percent = total > 0 ? (e.value / total) * 100 : 0.0;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      child: Row(
                        children: [
                          Container(width: 14, height: 14, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
                          const SizedBox(width: 10),
                          Expanded(child: Text(e.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
                          const SizedBox(width: 8),
                          Text(valueFormatter?.call(e.value) ?? e.value.toStringAsFixed(2), style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                          const SizedBox(width: 8),
                          Text('${percent.toStringAsFixed(0)}%', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _PiePainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final List<Color> palette;
  final double strokeWidth;
  final String Function(double)? valueFormatter;

  _PiePainter(this.entries, this.palette, {this.strokeWidth = 12, this.valueFormatter});

  @override
  void paint(Canvas canvas, Size size) {
    final total = entries.fold<double>(0.0, (a, b) => a + b.value);
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide / 2) - strokeWidth;
    final paint = Paint()..style = PaintingStyle.fill;

    double startRads = -pi / 2;
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final sweep = total == 0 ? 0.0 : (entry.value / total) * 2 * pi;
      paint.color = palette[i % palette.length];
      if (sweep > 0) {
        canvas.drawArc(Rect.fromCircle(center: center, radius: radius), startRads, sweep, true, paint);
      }
      // Draw percentage label on the slice if there's enough room.
      final mid = startRads + sweep / 2;
      const minSweepForLabel = 0.12; // ~7 degrees
      if (sweep >= minSweepForLabel) {
        final percent = total > 0 ? (entry.value / total) * 100 : 0.0;
        final label = '${percent.toStringAsFixed(0)}%';
        final labelRadius = radius * 0.6;
        final labelOffset = Offset(center.dx + cos(mid) * labelRadius, center.dy + sin(mid) * labelRadius);
        final textColor = paint.color.computeLuminance() > 0.55 ? Colors.black : Colors.white;
        final tpLabel = TextPainter(
          text: TextSpan(
            text: label,
            style: TextStyle(fontSize: max(8.0, radius * 0.12), fontWeight: FontWeight.w600, color: textColor),
          ),
          textDirection: TextDirection.ltr,
        );
        tpLabel.layout();
        tpLabel.paint(canvas, labelOffset - Offset(tpLabel.width / 2, tpLabel.height / 2));
      }
      startRads += sweep;
    }

    
    // Keep inner circle (donut) but do not draw the total amount in the center
    // — the total is displayed elsewhere in the UI (bottom/legend area).
    final innerPaint = Paint()..color = Colors.white;
    canvas.drawCircle(center, radius - strokeWidth * 0.8, innerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
