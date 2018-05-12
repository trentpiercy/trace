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
    handleUpdate();
  }

  void handleUpdate() {
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
    primarySwatch: Colors.purple,

    brightness: Brightness.light,
    accentColor: Colors.purpleAccent[100],
    primaryColor: Colors.white,
    primaryColorLight: Colors.purple[700],

    textSelectionColor: Colors.grey[200],
    dividerColor: Colors.grey[200],
    buttonColor: Colors.purple[700],
    iconTheme: new IconThemeData(color: Colors.white),
    primaryIconTheme: new IconThemeData(color: Colors.black),
    accentIconTheme: new IconThemeData(color: Colors.purple[700]),
    disabledColor: Colors.grey[500],
  );

  final ThemeData darkTheme = new ThemeData(
    primarySwatch: Colors.purple,

    brightness: Brightness.dark,
    accentColor: Colors.deepPurpleAccent[100],
    primaryColor: Color.fromRGBO(50, 50, 60, 1.0),
    primaryColorLight: Colors.deepPurpleAccent[100],

    textSelectionColor: Colors.blueGrey[800],
    buttonColor: Colors.deepPurpleAccent[200],
    iconTheme: new IconThemeData(color: Colors.white),
    accentIconTheme: new IconThemeData(color: Colors.deepPurpleAccent[100]),
    cardColor: Color.fromRGBO(55, 55, 55, 1.0),
    dividerColor: Color.fromRGBO(60, 60, 60, 1.0),
  );

  @override
  void initState() {
    super.initState();
    handleUpdate();
  }

  @override
  Widget build(BuildContext context) {
    print("BUILT MAIN APP ==========");

    return new MaterialApp(
      color: darkEnabled ? darkTheme.primaryColor : lightTheme.primaryColor,
      title: "Trace",
      home: new Tabs(toggleTheme, handleUpdate, darkEnabled, themeMode),
      theme: darkEnabled ? darkTheme : lightTheme,
    );
  }
}



class Tabs extends StatefulWidget {
  Tabs(
    this.toggleTheme,
    this.handleUpdate,
    this.darkEnabled,
    this.themeMode,
  );

  final toggleTheme;
  final handleUpdate;

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
    _tabController.addListener(() { //TODO: laggy - try different approach - possibly change top appBar on let go of swipe
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  PageStorageKey _marketKey = new PageStorageKey("market");
  PageStorageKey _portfolioKey = new PageStorageKey("portfolio");
  PageStorageKey _portfolioKey2 = new PageStorageKey("portfolio2");

  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {

    print("built tabs @@@@@@@");

    return new Scaffold(
      drawer: new Drawer(
          child: new Scaffold(
              bottomNavigationBar: new Container(
                  decoration: new BoxDecoration(
                      border: new Border(
                          top: new BorderSide(color: Theme.of(context).dividerColor),
                          bottom: new BorderSide(color: Theme.of(context).dividerColor)
                      )
                  ),
                  child: new ListTile(
                    onTap: widget.toggleTheme,
                    leading: new Icon(widget.darkEnabled ? Icons.brightness_3 : Icons.brightness_7, color: Theme.of(context).buttonColor),
                    title: new Text(widget.themeMode, style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).buttonColor)),
                  )
              ),
              body: new ListView(
                children: <Widget>[
                  new ListTile(
                    leading: new Icon(Icons.settings),
                    title: new Text("Settings"),
                  ),
                  new ListTile(
                    leading: new Icon(Icons.timeline),
                    title: new Text("Portfolio Timeline"),
                  ),
                  new ListTile(
                    leading: new Icon(Icons.short_text),
                    title: new Text("Shorten Numbers"),
                  )
                ],
              )
          )
      ),
    
    body: new NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            new SliverAppBar(
              title: [
                new Text("Portfolio"),
                new Text("Aggregate Markets"),
                new Text("Alerts")
              ][_tabController.index],

              leading: [
                null,
                new IconButton( // TODO: Searching
                    icon: new Icon(Icons.search, color: Theme.of(context).primaryIconTheme.color),
                    onPressed: null
                ),
                null
              ][_tabController.index],

              pinned: true,
              floating: true,
              titleSpacing: 3.0,
              elevation: appBarElevation,
              forceElevated: innerBoxIsScrolled,

              bottom: new PreferredSize(
                preferredSize: const Size.fromHeight(45.0),
                child: new Container(
                  height: 45.0,
                  child: new TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).accentIconTheme.color,
                    unselectedLabelColor: Theme.of(context).disabledColor,
                    labelColor: Theme.of(context).accentIconTheme.color,
                    tabs: <Tab>[
                      new Tab(icon: new Icon(Icons.person)),
                      new Tab(icon: new Icon(Icons.menu)),
                      new Tab(icon: new Icon(Icons.notifications))
                    ],
                  ),
                )
              ),
            )

          ];
        },

      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          new PortfolioPage(key: _portfolioKey),
          new MarketPage(key: _marketKey),
          new PortfolioPage(key: _portfolioKey2,)
        ],
      ),
    )
    
    );
  }
}