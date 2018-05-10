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

class TraceAppState extends State<TraceApp> {
  bool darkEnabled;
  String themeMode = "Automatic";

  void toggleTheme() {
    switch (themeMode) {
      case "Automatic":
        themeMode = "Dark";
        break;
      case "Dark":
        themeMode = "Light";
        break;
      case "Light":
        themeMode = "Automatic";
        break;
    }
    handleTheme();
  }

  void handleTheme() {
    switch (themeMode) {
      case "Automatic":
        int nowHour = new DateTime.now().hour;
        if (nowHour > 6 && nowHour < 18) {
          darkEnabled = false;
        } else {
          darkEnabled = true;
        }
        break;
      case "Dark":
        darkEnabled = true;
        break;
      case "Light":
        darkEnabled = false;
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
  void initState() {
    super.initState();
    handleTheme();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      color: darkEnabled ? darkTheme.primaryColor : lightTheme.primaryColor,
      title: "Trace",
      home: new Tabs(toggleTheme, darkEnabled, themeMode),
      theme: darkEnabled ? darkTheme : lightTheme,
    );
  }
}



class Tabs extends StatefulWidget {
  Tabs(
      this.toggleTheme,
      this.darkEnabled,
      this.themeMode
      );

  final toggleTheme;
  final darkEnabled;
  final themeMode;

  @override
  TabsState createState() => new TabsState();
}

class TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      bottomNavigationBar: new Container(
        decoration: new BoxDecoration(
          color: Theme.of(context).canvasColor,
          boxShadow: <BoxShadow>[
            new BoxShadow(color: Colors.black,
                blurRadius: 10.0,
                offset: new Offset(0.0, 10.5))
          ],
        ),
        height: 40.0,
        child: new TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).accentIconTheme.color,
          indicatorPadding: const EdgeInsets.only(left: 0.0, bottom: 1.0, right: 0.0),
          indicatorWeight: 2.0,
          tabs: <Tab>[
            new Tab(icon: new Icon(Icons.person, color: _tabController.index == 0 ? Theme.of(context).accentIconTheme.color : Theme.of(context).backgroundColor)),
            new Tab(icon: new Icon(Icons.menu, color: Theme.of(context).accentIconTheme.color)),
//            new Tab(icon: new Icon(Icons.notifications, color: Theme.of(context).accentIconTheme.color))
          ],
        ),
      ),
      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          new PortfolioPage(widget.toggleTheme, widget.darkEnabled, widget.themeMode),
          new MarketPage()
        ],
      ),
    );
  }
}