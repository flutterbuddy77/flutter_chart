import 'dart:math';
import 'dart:ui';

import 'package:flutter/animation.dart';
import 'package:flutter/rendering.dart' as rendering;
import 'package:flutter_chart/chart/chart.dart';
import 'package:flutter_chart/data/chartdata.dart';
import 'package:flutter_chart/data/dataset.dart';
import 'package:flutter_chart/data/entry.dart';
import 'package:meta/meta.dart';

class DonutChartData extends ChartData {
  DonutChartData({
    @required List<DataSet> dataSets,
    this.colors,
    this.arcWidth: 50.0,
    this.arcWidthStep: 5.0,
  }):
    assert(dataSets != null && dataSets.length == 1),
    assert(colors == null || (colors.length == dataSets[0].data.length)),
    super(dataSets: dataSets);

  final List<Color> colors;
  final double arcWidth;
  final double arcWidthStep;
}

class DonutChart extends Chart<DonutChartData> {
  DonutChart({ @required DonutChartData data }): super(data: data);

  @override
  ChartPainter<DonutChartData> createChartPainter(
      DonutChartData data, Animation<double> animation) {
    return new DonutChartPainter(data: data, animation: animation);
  }
}

class DonutChartPainter extends ChartPainter<DonutChartData> {
  static const START = -0.5 * PI;

  Color _darkerColor(Color color, int amt) {
    int col = color.value;
    return new Color(
        ((col & 0x0000FF) + amt) |
        ((((col >> 8) & 0x00FF) + amt) << 8) |
        (((col >> 16) + amt) << 16)
    );
  }

  DonutChartPainter(
      {@required DonutChartData data, @required Animation<double> animation})
      : super(data: data, animation: animation);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.butt
      ..style = PaintingStyle.fill;

    var startAngle = START;
    List<Entry> entries = this.data.dataSets[0].data;
    double sum = entries.reduce((e1, e2) => new Entry(e1.value + e2.value)).value;
    List<double> values = entries.map((entry) => entry.value / sum).toList();
    var index = 0;

    double radius = min(size.width, size.height) - this.data.arcWidth;

    values.forEach((value) {
      Path path = new Path();
      double sweepAngle = value * 2 * PI;
      paint.color = this.data.colors[index];

      Rect rect = new Rect.fromLTWH(
          (size.width - radius) / 2,
          (size.height - radius) / 2,
          radius,
          radius);

      paint.shader = new Gradient.linear(new Offset(0.0, 0.0), new Offset(size.width, size.height),
          <Color>[
          _darkerColor(this.data.colors[index], -50),
          this.data.colors[index],
        ]
      );
      double start = START + animation.value * (startAngle - START);
      double sweep = animation.value * sweepAngle;

      path.arcTo(rect, start, sweep, true);

      double outerRadius = radius + (this.data.arcWidth - index * this.data.arcWidthStep);
      rect = new Rect.fromLTWH(
          (size.width - outerRadius) / 2,
          (size.height - outerRadius) / 2,
          outerRadius,
          outerRadius);
      path.arcTo(rect, start + sweep, - sweep, false);
      path.close();

      rect = new Rect.fromLTWH(
          (size.width - radius) / 2,
          (size.height - radius) / 2,
          radius,
          radius);

      canvas.drawPath(path, paint);
      startAngle += sweepAngle;
      index += 1;
    });
  }

  @override
  bool shouldRepaint(rendering.CustomPainter oldDelegate) {
    return true;
  }
}