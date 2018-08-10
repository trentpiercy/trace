import 'dart:math' as math;
import 'dart:ui' as ui show PointMode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Strategy used when filling the area of a sparkline.
enum FillMode {
  /// Do not fill, draw only the sparkline.
  none,

  /// Fill the area above the sparkline: creating a closed path from the line
  /// to the upper edge of the widget.
  above,

  /// Fill the area below the sparkline: creating a closed path from the line
  /// to the lower edge of the widget.
  below,
}

/// Strategy used when drawing individual data points over the sparkline.
enum PointsMode {
  /// Do not draw individual points.
  none,

  /// Draw all the points in the data set.
  all,

  /// Draw only the last point in the data set.
  last,
}

/// A widget that draws a sparkline chart.
///
/// Represents the given [data] in a sparkline chart that spans the available
/// space.
///
/// By default only the sparkline is drawn, with its looks defined by
/// the [lineWidth], [lineColor], and [lineGradient] properties.
///
/// The corners between two segments of the sparkline can be made sharper by
/// setting [sharpCorners] to true.
///
/// The area above or below the sparkline can be filled with the provided
/// [fillColor] or [fillGradient] by setting the desired [fillMode].
///
/// [pointsMode] controls how individual points are drawn over the sparkline
/// at the provided data point. Their appearance is determined by the
/// [pointSize] and [pointColor] properties.
///
/// By default, the sparkline is sized to fit its container. If the
/// sparkline is in an unbounded space, it will size itself according to the
/// given [fallbackWidth] and [fallbackHeight].
class Sparkline extends StatelessWidget {
  /// Creates a widget that represents provided [data] in a Sparkline chart.
  Sparkline({
    Key key,
    @required this.data,
    this.lineWidth = 2.0,
    this.lineColor = Colors.lightBlue,
    this.lineGradient,
    this.pointsMode = PointsMode.none,
    this.pointSize = 4.0,
    this.pointColor = const Color(0xFF0277BD), //Colors.lightBlue[800]
    this.sharpCorners = false,
    this.fillMode = FillMode.none,
    this.fillColor = const Color(0xFF81D4FA), //Colors.lightBlue[200]
    this.fillGradient,
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
    this.enableGridLines = false,
    this.gridLineColor = Colors.grey,
    this.gridLineAmount = 5,
    this.gridLineWidth = 0.5,
    this.gridLineLabelColor = Colors.grey,
    this.labelPrefix = "\$",
  })  : assert(data != null),
        assert(lineWidth != null),
        assert(lineColor != null),
        assert(pointsMode != null),
        assert(pointSize != null),
        assert(pointColor != null),
        assert(sharpCorners != null),
        assert(fillMode != null),
        assert(fillColor != null),
        assert(fallbackHeight != null),
        assert(fallbackWidth != null),
        super(key: key);

  /// List of values to be represented by the sparkline.
  ///
  /// Each data entry represents an individual point on the chart, with a path
  /// drawn connecting the consecutive points to form the sparkline.
  ///
  /// The values are normalized to fit within the bounds of the chart.
  final List<double> data;

  /// The width of the sparkline.
  ///
  /// Defaults to 2.0.
  final double lineWidth;

  /// The color of the sparkline.
  ///
  /// Defaults to Colors.lightBlue.
  ///
  /// This is ignored if [lineGradient] is non-null.
  final Color lineColor;

  /// A gradient to use when coloring the sparkline.
  ///
  /// If this is specified, [lineColor] has no effect.
  final Gradient lineGradient;

  /// Determines how individual data points should be drawn over the sparkline.
  ///
  /// Defaults to [PointsMode.none].
  final PointsMode pointsMode;

  /// The size to use when drawing individual data points over the sparkline.
  ///
  /// Defaults to 4.0.
  final double pointSize;

  /// The color used when drawing individual data points over the sparkline.
  ///
  /// Defaults to Colors.lightBlue[800].
  final Color pointColor;

  /// Determines if the sparkline path should have sharp corners where two
  /// segments intersect.
  ///
  /// Defaults to false.
  final bool sharpCorners;

  /// Determines the area that should be filled with [fillColor].
  ///
  /// Defaults to [FillMode.none].
  final FillMode fillMode;

  /// The fill color used in the chart, as determined by [fillMode].
  ///
  /// Defaults to Colors.lightBlue[200].
  ///
  /// This is ignored if [fillGradient] is non-null.
  final Color fillColor;

  /// A gradient to use when filling the chart, as determined by [fillMode].
  ///
  /// If this is specified, [fillColor] has no effect.
  final Gradient fillGradient;

  /// The width to use when the sparkline is in a situation with an unbounded
  /// width.
  ///
  /// See also:
  ///
  ///  * [fallbackHeight], the same but vertically.
  final double fallbackWidth;

  /// The height to use when the sparkline is in a situation with an unbounded
  /// height.
  ///
  /// See also:
  ///
  ///  * [fallbackWidth], the same but horizontally.
  final double fallbackHeight;

  /// Enable or disable grid lines
  final bool enableGridLines;

  /// Color of grid lines and label text
  final Color gridLineColor;
  final Color gridLineLabelColor;

  /// Number of grid lines
  final int gridLineAmount;

  /// Width of grid lines
  final double gridLineWidth;

  /// Symbol prefix for grid line labels
  final String labelPrefix;

  @override
  Widget build(BuildContext context) {
    return new LimitedBox(
      maxWidth: fallbackWidth,
      maxHeight: fallbackHeight,
      child: new CustomPaint(
        size: Size.infinite,
        painter: new _SparklinePainter(data,
            lineWidth: lineWidth,
            lineColor: lineColor,
            lineGradient: lineGradient,
            sharpCorners: sharpCorners,
            fillMode: fillMode,
            fillColor: fillColor,
            fillGradient: fillGradient,
            pointsMode: pointsMode,
            pointSize: pointSize,
            pointColor: pointColor,
            enableGridLines: enableGridLines,
            gridLineColor: gridLineColor,
            gridLineAmount: gridLineAmount,
            gridLineLabelColor: gridLineLabelColor,
            gridLineWidth: gridLineWidth,
            labelPrefix: labelPrefix),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.dataPoints,
      {@required this.lineWidth,
      @required this.lineColor,
      this.lineGradient,
      @required this.sharpCorners,
      @required this.fillMode,
      @required this.fillColor,
      this.fillGradient,
      @required this.pointsMode,
      @required this.pointSize,
      @required this.pointColor,
      @required this.enableGridLines,
      this.gridLineColor,
      this.gridLineAmount,
      this.gridLineWidth,
      this.gridLineLabelColor,
      this.labelPrefix});

  final List<double> dataPoints;

  final double lineWidth;
  final Color lineColor;
  final Gradient lineGradient;

  final bool sharpCorners;

  final FillMode fillMode;
  final Color fillColor;
  final Gradient fillGradient;

  final PointsMode pointsMode;
  final double pointSize;
  final Color pointColor;

  double _max;
  double _min;

  final bool enableGridLines;
  final Color gridLineColor;
  final int gridLineAmount;
  final double gridLineWidth;
  final Color gridLineLabelColor;
  final String labelPrefix;

  List<TextPainter> gridLineTextPainters = [];

  update() {
    _max = dataPoints.reduce(math.max);
    _min = dataPoints.reduce(math.min);

    if (enableGridLines) {
      double gridLineValue;
      for (int i = 0; i < gridLineAmount; i++) {
        // Label grid lines
        gridLineValue = _max - (((_max - _min) / (gridLineAmount - 1)) * i);

        String gridLineText;
        if (gridLineValue < 1) {
          gridLineText = gridLineValue.toStringAsPrecision(4);
        } else if (gridLineValue < 1000) {
          gridLineText = gridLineValue.toStringAsFixed(2);
        } else {
          gridLineText = gridLineValue.round().toString().replaceAllMapped(
              new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
              (Match m) => "${m[1]},");
        }

        gridLineTextPainters.add(new TextPainter(
            text: new TextSpan(
                text: labelPrefix + gridLineText,
                style: new TextStyle(
                    color: gridLineLabelColor,
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold)),
            textDirection: TextDirection.ltr));
        gridLineTextPainters[i].layout();
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (gridLineTextPainters.isEmpty) {
      update();
    }

    double width = size.width - lineWidth;
    final double height = size.height - lineWidth;
    final double heightNormalizer = height / (_max - _min);

    final Path path = new Path();
    final List<Offset> points = <Offset>[];

    Offset startPoint;

    if (enableGridLines) {
      width = size.width - gridLineTextPainters[0].text.text.length * 6;
      Paint gridPaint = new Paint()
        ..color = gridLineColor
        ..strokeWidth = gridLineWidth;

      double gridLineDist = height / (gridLineAmount - 1);
      double gridLineY;

      // Draw grid lines
      for (int i = 0; i < gridLineAmount; i++) {
        gridLineY = (gridLineDist * i).round().toDouble();
        canvas.drawLine(new Offset(0.0, gridLineY),
            new Offset(width, gridLineY), gridPaint);

        // Label grid lines
        gridLineTextPainters[i]
            .paint(canvas, new Offset(width + 2.0, gridLineY - 6.0));
      }
    }

    final double widthNormalizer = width / dataPoints.length;

    for (int i = 0; i < dataPoints.length; i++) {
      double x = i * widthNormalizer + lineWidth / 2;
      double y =
          height - (dataPoints[i] - _min) * heightNormalizer + lineWidth / 2;

      if (pointsMode == PointsMode.all) {
        points.add(new Offset(x, y));
      }

      if (pointsMode == PointsMode.last && i == dataPoints.length - 1) {
        points.add(new Offset(x, y));
      }

      if (i == 0) {
        startPoint = new Offset(x, y);
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    Paint paint = new Paint()
      ..strokeWidth = lineWidth
      ..color = lineColor
      ..strokeCap = StrokeCap.round
      ..strokeJoin = sharpCorners ? StrokeJoin.miter : StrokeJoin.round
      ..style = PaintingStyle.stroke;

    if (lineGradient != null) {
      final Rect lineRect = new Rect.fromLTWH(0.0, 0.0, width, height);
      paint.shader = lineGradient.createShader(lineRect);
    }

    if (fillMode != FillMode.none) {
      Path fillPath = new Path()..addPath(path, Offset.zero);
      if (fillMode == FillMode.below) {
        fillPath.relativeLineTo(lineWidth / 2, 0.0);
        fillPath.lineTo(size.width, size.height);
        fillPath.lineTo(0.0, size.height);
        fillPath.lineTo(startPoint.dx - lineWidth / 2, startPoint.dy);
      } else if (fillMode == FillMode.above) {
        fillPath.relativeLineTo(lineWidth / 2, 0.0);
        fillPath.lineTo(size.width, 0.0);
        fillPath.lineTo(0.0, 0.0);
        fillPath.lineTo(startPoint.dx - lineWidth / 2, startPoint.dy);
      }
      fillPath.close();

      Paint fillPaint = new Paint()
        ..strokeWidth = 0.0
        ..color = fillColor
        ..style = PaintingStyle.fill;

      if (fillGradient != null) {
        final Rect fillRect = new Rect.fromLTWH(0.0, 0.0, width, height);
        fillPaint.shader = fillGradient.createShader(fillRect);
      }
      canvas.drawPath(fillPath, fillPaint);
    }

    canvas.drawPath(path, paint);

    if (points.isNotEmpty) {
      Paint pointsPaint = new Paint()
        ..strokeCap = StrokeCap.round
        ..strokeWidth = pointSize
        ..color = pointColor;
      canvas.drawPoints(ui.PointMode.points, points, pointsPaint);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) {
    return dataPoints != old.dataPoints ||
        lineWidth != old.lineWidth ||
        lineColor != old.lineColor ||
        lineGradient != old.lineGradient ||
        sharpCorners != old.sharpCorners ||
        fillMode != old.fillMode ||
        fillColor != old.fillColor ||
        fillGradient != old.fillGradient ||
        pointsMode != old.pointsMode ||
        pointSize != old.pointSize ||
        pointColor != old.pointColor ||
        enableGridLines != old.enableGridLines ||
        gridLineColor != old.gridLineColor ||
        gridLineAmount != old.gridLineAmount ||
        gridLineWidth != old.gridLineWidth ||
        gridLineLabelColor != old.gridLineLabelColor;
  }
}
