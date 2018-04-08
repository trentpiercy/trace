import 'dart:math' as math;
import 'dart:ui' as ui show PointMode;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class OHLCVGraph extends StatelessWidget {
  OHLCVGraph({
    Key key,
    @required this.data,
    this.lineWidth = 1.0,
  })  : assert(data != null),
        assert(lineWidth != null),
        super(key: key);

  final List data;
  final double lineWidth;

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new CustomPaint(
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

      double rectLeft = i * rectWidth;
      double rectRight = (i+1) * rectWidth;

      double rectTop;
      double rectBottom;

      Paint rectPaint;

      if (data[i]["open"] > data[i]["close"]) {
        rectTop = (data[i]["open"] - _min) * heightNormalizer;
        rectBottom = (data[i]["close"] - _min) * heightNormalizer;
        rectPaint = new Paint() ..color=Colors.red;
      } else {
        rectTop = (data[i]["close"] - _min) * heightNormalizer;
        rectBottom = (data[i]["open"] - _min) * heightNormalizer;
        rectPaint = new Paint() ..color=Colors.green;
      }

      print(data.length);
      print("L: " + rectLeft.toString());
      print("T: " + rectTop.toString());
      print("R: " + rectRight.toString());
      print("B: " + rectBottom.toString());
      print("");

      Rect ocRect = new Rect.fromLTRB(rectLeft, rectTop, rectRight, rectBottom);

      canvas.drawRect(ocRect, rectPaint);

    }



  }

  @override
  bool shouldRepaint(_OHLCVPainter old) {
    return data != old.data ||
        lineWidth != old.lineWidth;
  }
}
