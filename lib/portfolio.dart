import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import 'main.dart';

class PortfolioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: new AppBar(
          title: new Text("Portfolio"),
        ),
      ),
      body: new Container(
        padding: const EdgeInsets.all(16.0),
        height: 200.0,
        child: new _SparkLine1(),
      ),
    );
  }
}

class _SparkLine1 extends StatelessWidget {

  final List<double> _data = [3.0,7.0,20.0,3.0,5.0,1.0,10.0];

  @override
  Widget build(BuildContext context) {
    return new Sparkline(
      data: _data,
      lineWidth: 5.0,
      lineGradient: new LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor]
      ),
    );
  }
}