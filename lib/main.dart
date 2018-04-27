import 'package:flutter/material.dart';

import 'portfolio.dart';
import 'market.dart';

void main() {
  runApp(new MaterialApp(
    color: Colors.purple[900],
    title: "Trace",
    home: new Tabs(),
    routes: <String, WidgetBuilder>{},
    theme: darkEnabled ? darkTheme : lightTheme,
  ));
}

bool darkEnabled = true; //TODO: in app switch

final ThemeData lightTheme = new ThemeData(
    brightness: Brightness.light,
    accentColor: Colors.purpleAccent[100],
    primaryColor: Colors.purple[700],
    textSelectionColor: Colors.grey[200],
    dividerColor: Colors.grey[200],
    buttonColor: Colors.purple[700],
    iconTheme: new IconThemeData(color: Colors.white),
    accentIconTheme: new IconThemeData(color: Colors.purple[700]),
);

final ThemeData darkTheme = new ThemeData(
    brightness: Brightness.dark,
    accentColor: Colors.deepPurpleAccent[200],
    primaryColor: Colors.purple[900],
    textSelectionColor: Colors.blueGrey[800],
    buttonColor: Colors.deepPurpleAccent,
    iconTheme: new IconThemeData(color: Colors.white),
    accentIconTheme: new IconThemeData(color: Colors.deepPurpleAccent[200]),
    cardColor: Color.fromRGBO(55, 55, 55, 1.0),
);

const double appBarHeight = 48.0;
const double appBarElevation = 1.0;
const double bottomAppBarElevation = 8.0;

class Tabs extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          bottomNavigationBar: new Card(
            elevation: 2.0,
            child: new Container(
//              color: Theme.of(context).canvasColor,
              height: 36.0,
              child: new TabBar(
                indicatorColor: Theme.of(context).accentIconTheme.color,
                indicatorPadding:
                const EdgeInsets.only(left: 50.0, bottom: 2.0, right: 50.0),
                tabs: <Tab>[
                  new Tab(
                      icon: new Icon(Icons.person_outline,
                          color: Theme.of(context).accentIconTheme.color)),
                  new Tab(
                      icon: new Icon(Icons.menu,
                          color: Theme.of(context).accentIconTheme.color))
                ],
              ),
            ),
          ),
          body: new TabBarView(
            children: <Widget>[new PortfolioPage(), new MarketPage()],
          ),
        ));
  }
}
