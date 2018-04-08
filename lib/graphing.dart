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

  final Map data;
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
      })  : _max = data["high"].reduce(math.max),
        _min = data["low"].reduce(math.min);

  final Map data;
  final double lineWidth;

  final double _max;
  final double _min;


  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width - lineWidth;
    final double height = size.height - lineWidth;
    final double widthNormalizer = width / (data.length - 1);
    final double heightNormalizer = height / (_max - _min);



  }

  @override
  bool shouldRepaint(_OHLCVPainter old) {
    return data != old.data ||
        lineWidth != old.lineWidth;
  }
}
