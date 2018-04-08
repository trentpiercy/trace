import 'dart:math' as math;
import 'dart:ui' as ui show PointMode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OHLCVGraph extends StatelessWidget {
  OHLCVGraph({
    Key key,
    @required this.data,
    this.lineWidth = 1.0,
    this.fallbackHeight = 100.0,
    this.fallbackWidth = 300.0,
  })  : assert(data != null),
        assert(lineWidth != null),
        super(key: key);

  final List data;
  final double lineWidth;

  final double fallbackHeight;
  final double fallbackWidth;

  @override
  Widget build(BuildContext context) {
    return new LimitedBox(
      maxHeight: fallbackHeight,
      maxWidth: fallbackWidth,
      child: new CustomPaint(
        size: Size.infinite,
        painter: new _OHLCVPainter(data, lineWidth: lineWidth),
      ),
    );
  }
}



class _OHLCVPainter extends CustomPainter {

  _OHLCVPainter(
      this.data, {
        @required this.lineWidth
      });

  final List data;
  final double lineWidth;


  @override
  void paint(Canvas canvas, Size size) {

    double _min = double.infinity;
    double _max = 0.0;

    for (var i in data) {
      if (i["high"] > _max) {
        _max = i["high"];
      }
      if (i["low"] < _min) {
        _min = i["low"];
      }
    }

    final double width = size.width;
    final double height = size.height;

    final double heightNormalizer = height / (_max - _min);

    final double rectWidth = width / data.length;

    for (int i = 0; i < data.length; i++) {

      if (data[i]["open"] > data[i]["close"]) {
        double rectLeft = i * rectWidth;
        double rectRight = (i+1) * rectWidth;
        double rectTop = height - (data[i]["open"] - _min) * heightNormalizer;
        double rectBottom = height - (data[i]["close"] - _min) * heightNormalizer;
        Paint rectPaint = new Paint() ..color=Colors.red ..strokeWidth=lineWidth;
        Rect ocRect = new Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);
        canvas.drawRect(ocRect, rectPaint);

        double low = height - (data[i]["low"] - _min) * heightNormalizer;
        double high = height - (data[i]["high"] - _min) * heightNormalizer;
        canvas.drawLine(new Offset(rectLeft+rectWidth/2-lineWidth/2, rectBottom), new Offset(rectLeft+rectWidth/2-lineWidth/2, low), rectPaint);
        canvas.drawLine(new Offset(rectLeft+rectWidth/2-lineWidth/2, rectTop), new Offset(rectLeft+rectWidth/2-lineWidth/2, high), rectPaint);

      } else {
        double rectLeft = (i * rectWidth) + lineWidth/2;
        double rectRight = ((i+1) * rectWidth) - lineWidth/2;
        double rectTop = (height - (data[i]["close"] - _min) * heightNormalizer) + lineWidth/2;
        double rectBottom = (height - (data[i]["open"] - _min) * heightNormalizer) - lineWidth/2;
        Paint rectPaint = new Paint() ..color=Colors.green ..strokeWidth=lineWidth;
        canvas.drawLine(new Offset(rectLeft-lineWidth/2, rectBottom), new Offset(rectRight+lineWidth/2, rectBottom), rectPaint);
        canvas.drawLine(new Offset(rectLeft-lineWidth/2, rectTop), new Offset(rectRight+lineWidth/2, rectTop), rectPaint);
        canvas.drawLine(new Offset(rectLeft, rectBottom), new Offset(rectLeft, rectTop), rectPaint);
        canvas.drawLine(new Offset(rectRight, rectBottom), new Offset(rectRight, rectTop), rectPaint);

        double low = height - (data[i]["low"] - _min) * heightNormalizer;
        double high = height - (data[i]["high"] - _min) * heightNormalizer;
        canvas.drawLine(new Offset(rectLeft+rectWidth/2-lineWidth/2, rectBottom), new Offset(rectLeft+rectWidth/2-lineWidth/2, low), rectPaint);
        canvas.drawLine(new Offset(rectLeft+rectWidth/2-lineWidth/2, rectTop), new Offset(rectLeft+rectWidth/2-lineWidth/2, high), rectPaint);
      }

    }



  }

  @override
  bool shouldRepaint(_OHLCVPainter old) {
    return data != old.data ||
        lineWidth != old.lineWidth;
  }
}
