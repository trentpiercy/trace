import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OHLCGraph extends StatelessWidget {
  OHLCGraph({
    Key key,
    @required this.data,
    this.lineWidth = 1.0,
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
    this.gridLineColor = Colors.grey,
    this.gridLineAmount = 5,
    this.gridLineWidth = 0.5,
  })  : assert(data != null),
        assert(lineWidth != null),
        super(key: key);

  /// OHLCV data to graph
  /// List of Maps containing open, high, low, close and volumeto
  /// Example: [["open" : 40.0, "high" : 75.0, "low" : 25.0, "close" : 50.0, "volumeto" : 5000.0}, {...}]
  final List data;

  /// All lines in chart are drawn with this width
  final double lineWidth;

  /// Color of grid lines and value indicating text
  final Color gridLineColor;

  /// Number of grid lines
  final int gridLineAmount;

  /// Width of grid lines
  final double gridLineWidth;

  /// If graph is given unbounded space,
  /// it will default to given fallback height and width
  final double fallbackHeight;
  final double fallbackWidth;

  @override
  Widget build(BuildContext context) {
    return new LimitedBox(
      maxHeight: fallbackHeight,
      maxWidth: fallbackWidth,
      child: new CustomPaint(
        size: Size.infinite,
        painter: new _OHLCVPainter(
            data,
            lineWidth: lineWidth,
            gridLineColor: gridLineColor,
            gridLineAmount: gridLineAmount,
            gridLineWidth: gridLineWidth,
        ),
      ),
    );
  }
}

class _OHLCVPainter extends CustomPainter {

  _OHLCVPainter(this.data,
    {
      @required this.lineWidth,
      @required this.gridLineColor,
      @required this.gridLineAmount,
      @required this.gridLineWidth,
    }
  );

  final List data;
  final double lineWidth;
  final Color gridLineColor;
  final int gridLineAmount;
  final double gridLineWidth;
  final double volumeProp = 0.2; //TODO

  @override
  void paint(Canvas canvas, Size size) {

    double _min = double.infinity;
    double _max = -double.infinity;
    for (var i in data) {
      if (i["high"] > _max) {
        _max = i["high"];
      }
      if (i["low"] < _min) {
        _min = i["low"];
      }
    }

    double _maxVolume = -double.infinity;
    for (var i in data) {
      if (i["volumeto"] > _maxVolume) {
        _maxVolume = i["volumeto"];
      }
    }

    final double volumeHeight = size.height*volumeProp;
    final double volumeNormalizer = volumeHeight / _maxVolume;

    final double width = size.width;
    final double height = size.height*(1-volumeProp);


    Paint gridPaint = new Paint()
      ..color=gridLineColor
      ..strokeWidth=0.5; //TODO: var for this

    double gridLineDist = height/(gridLineAmount-1);

    for (int i = 0; i < gridLineAmount; i++) {
      double gridLineY = (gridLineDist*i).round().toDouble();
      canvas.drawLine(new Offset(0.0, gridLineY), new Offset(width, gridLineY), gridPaint);
    }


    final double heightNormalizer = height / (_max - _min);
    final double rectWidth = width / data.length;

    double rectLeft;
    double rectTop;
    double rectRight;
    double rectBottom;

    Paint rectPaint;

    // Loop through all data
    for (int i = 0; i < data.length; i++) {
      rectLeft = (i * rectWidth) + lineWidth/2;
      rectRight = ((i+1) * rectWidth) - lineWidth/2;

      double volumeBarTop = (height+volumeHeight) - (data[i]["volumeto"]*volumeNormalizer - lineWidth);
      double volumeBarBottom = height+volumeHeight;

      if (data[i]["open"] > data[i]["close"]) {
        // Draw candlestick if decrease
        rectTop = height - (data[i]["open"] - _min) * heightNormalizer;
        rectBottom = height - (data[i]["close"] - _min) * heightNormalizer;
        rectPaint = new Paint()
          ..color=Colors.red
          ..strokeWidth=lineWidth;

        Rect ocRect = new Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);
        canvas.drawRect(ocRect, rectPaint);

        // Draw volume bars
        Rect volumeRect = new Rect.fromLTRB(rectLeft, volumeBarTop, rectRight, volumeBarBottom);
        canvas.drawRect(volumeRect, rectPaint);

      } else {
        // Draw candlestick if increase
        rectTop = (height - (data[i]["close"] - _min) * heightNormalizer) + lineWidth/2;
        rectBottom = (height - (data[i]["open"] - _min) * heightNormalizer) - lineWidth/2;
        rectPaint = new Paint()
          ..color=Colors.green
          ..strokeWidth=lineWidth;

        canvas.drawLine(new Offset(rectLeft, rectBottom-lineWidth/2), new Offset(rectRight, rectBottom-lineWidth/2), rectPaint);
        canvas.drawLine(new Offset(rectLeft, rectTop+lineWidth/2), new Offset(rectRight, rectTop+lineWidth/2), rectPaint);
        canvas.drawLine(new Offset(rectLeft+lineWidth/2, rectBottom), new Offset(rectLeft+lineWidth/2, rectTop), rectPaint);
        canvas.drawLine(new Offset(rectRight-lineWidth/2, rectBottom), new Offset(rectRight-lineWidth/2, rectTop), rectPaint);

        // Draw volume bars
        canvas.drawLine(new Offset(rectLeft, volumeBarBottom-lineWidth/2), new Offset(rectRight, volumeBarBottom-lineWidth/2), rectPaint);
        canvas.drawLine(new Offset(rectLeft, volumeBarTop+lineWidth/2), new Offset(rectRight, volumeBarTop+lineWidth/2), rectPaint);
        canvas.drawLine(new Offset(rectLeft+lineWidth/2, volumeBarBottom), new Offset(rectLeft+lineWidth/2, volumeBarTop), rectPaint);
        canvas.drawLine(new Offset(rectRight-lineWidth/2, volumeBarBottom), new Offset(rectRight-lineWidth/2, volumeBarTop), rectPaint);
      }


      // Draw low/high candlestick wicks
      double low = height - (data[i]["low"] - _min) * heightNormalizer;
      double high = height - (data[i]["high"] - _min) * heightNormalizer;
      canvas.drawLine(new Offset(rectLeft+rectWidth/2-lineWidth/2, rectBottom), new Offset(rectLeft+rectWidth/2-lineWidth/2, low), rectPaint);
      canvas.drawLine(new Offset(rectLeft+rectWidth/2-lineWidth/2, rectTop), new Offset(rectLeft+rectWidth/2-lineWidth/2, high), rectPaint);
    }
  }

  @override
  bool shouldRepaint(_OHLCVPainter old) {
    return data != old.data ||
        lineWidth != old.lineWidth;
  }
}



