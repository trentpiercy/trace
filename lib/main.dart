import 'package:flutter/material.dart';

import 'portfolio.dart';
import 'market.dart';

void main() {
  runApp(new MaterialApp(
    color: Colors.purple[700],
    title: "Trace",
    home: new Tabs(),
    routes: <String, WidgetBuilder> {},
    theme: new ThemeData(
//      primarySwatch: Colors.purple[700],
      primaryColor: primary,
      accentColor: accent,

      textSelectionColor: Colors.grey[700],

      dividerColor: darkEnabled ? Colors.grey[900] : Colors.grey[200],

      brightness: darkEnabled ? Brightness.dark : Brightness.light,
    ),
  ));
}

bool darkEnabled = true;

Color varDarkAccent = darkEnabled ? Colors.purple[300] : primary;

Color primary = Colors.purple[700];
Color accent = Colors.purpleAccent[100];

const double appBarHeight = 50.0;
const double appBarElevation = 1.0;

class Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        bottomNavigationBar: new BottomAppBar(
          elevation: 4.0,
          child: new Container(
//            color: Colors.white,
            height: 34.0,
            child: new TabBar(
              indicatorColor: varDarkAccent,
              indicatorPadding: const EdgeInsets.only(left: 60.0, bottom: 2.0, right: 60.0),
              tabs: <Tab>[
                new Tab(icon: new Icon(Icons.person_outline, color: varDarkAccent)),
                new Tab(icon: new Icon(Icons.menu, color: varDarkAccent))
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