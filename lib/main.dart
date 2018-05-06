import 'package:flutter/material.dart';

import 'portfolio.dart';
import 'market.dart';

void main() {
  runApp(new TraceApp());
}

const double appBarHeight = 48.0;
const double appBarElevation = 1.0;
const double bottomAppBarElevation = 8.0;


class TraceApp extends StatefulWidget {
  @override
  TraceAppState createState() => new TraceAppState();
}

bool darkEnabled = true;
String themeMode = "Automatic";
class TraceAppState extends State<TraceApp> {
  void toggleTheme() {
    switch (themeMode) {
      case "Automatic":
        themeMode = "Dark";
        darkEnabled = true;
        break;
      case "Dark":
        themeMode = "Light";
        darkEnabled = false;
        break;
      case "Light":
        themeMode = "Automatic";
        int nowHour = new DateTime.now().hour;
        if (nowHour > 6 && nowHour < 18) {
          darkEnabled = false;
        } else {
          darkEnabled = true;
        }
        break;
    }
    setState(() {});
  }

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
    dividerColor: Color.fromRGBO(60, 60, 60, 1.0),
  );

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      color: Colors.purple[900],
      title: "Trace",
      home: new Tabs(toggleTheme),
      theme: darkEnabled ? darkTheme : lightTheme,
    );
  }
}

class Tabs extends StatelessWidget {
  Tabs(this.toggleTheme);
  final toggleTheme;

  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
        length: 2,
        child: new Scaffold(
          bottomNavigationBar: new Container(
            decoration: new BoxDecoration(
              color: Theme.of(context).canvasColor,
              boxShadow: <BoxShadow>[
                new BoxShadow(color: Colors.black,
                    blurRadius: 10.0,
                    offset: new Offset(0.0, 10.5))
              ],
            ),
            height: 36.0,
            child: new TabBar(
              indicatorColor: Theme.of(context).accentIconTheme.color,
              indicatorPadding: const EdgeInsets.only(left: 50.0, bottom: 2.0, right: 50.0),
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

          body: new TabBarView(
            children: <Widget>[new PortfolioPage(toggleTheme), new MarketPage()],
          ),
        )
    );
  }
}