import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import 'portfolio.dart';
import 'market.dart';

void main() {
  runApp(new MaterialApp(
    color: Colors.orange,
    title: "Trace",
    home: new Tabs(),
    routes: <String, WidgetBuilder> {},
    theme: new ThemeData(
//      primarySwatch: Colors.purple[700],
      primaryColor: Colors.purple[700],
      accentColor: Colors.purpleAccent[100],

      textSelectionColor: Colors.grey[700],

      brightness: darkEnabled ? Brightness.dark : Brightness.light,
    ),
  ));
}

bool darkEnabled = true;

const double appBarHeight = 50.0;
final double appBarElevation = 0.5;

class Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        bottomNavigationBar: new BottomAppBar(
            elevation: 4.0,
            child: new Container(
//                color: Colors.white,
                height: 34.0,
                child: new TabBar(
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorPadding: const EdgeInsets.only(left: 60.0, bottom: 2.0, right: 60.0),
                  tabs: <Tab>[
                    new Tab(icon: new Icon(Icons.person_outline, color: Theme.of(context).primaryColor)),
                    new Tab(icon: new Icon(Icons.trending_up, color: Theme.of(context).primaryColor))
                  ],
                )
            )
        ),
        body: new TabBarView(
          children: <Widget>[
            new PortfolioPage(),
            new MarketPage()
          ],
        ),
      )
    );
  }
}