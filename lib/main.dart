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
    brightness: Brightness.light,
    accentColor: Colors.purpleAccent[100],
    primaryColor: Colors.purple[700],
    textSelectionColor: Colors.grey[200],
    dividerColor: Colors.grey[200],
    buttonColor: Colors.purple[700],
    iconTheme: new IconThemeData(color: Colors.white),
    primaryIconTheme: new IconThemeData(color: Colors.black),
    accentIconTheme: new IconThemeData(color: Colors.purple[700]),
    backgroundColor: Colors.grey[500],
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
    handleUpdate();
  }

  @override
  Widget build(BuildContext context) {
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

  PageController _pageController = new PageController();

  _testPage(BuildContext context) {
    return new SliverList(
        delegate: new SliverChildBuilderDelegate((context, index) => new ListTile(title: new Text("item $index")))
    );
  }

  bottomAppBar(BuildContext context) {
    return new PreferredSize(
        preferredSize: const Size.fromHeight(20.0),
        child: new Container(
          height: 36.0,
          child: new TabBar(
            controller: _tabController,
            indicatorColor: Theme.of(context).buttonColor,
            tabs: <Tab>[
              new Tab(icon: new Icon(Icons.person, color: _tabIndex == 0 ? Theme.of(context).accentIconTheme.color : Theme.of(context).backgroundColor)),
              new Tab(icon: new Icon(Icons.menu, color: _tabIndex == 1 ? Theme.of(context).accentIconTheme.color : Theme.of(context).backgroundColor)),
              new Tab(icon: new Icon(Icons.notifications, color: _tabIndex == 2 ? Theme.of(context).accentIconTheme.color : Theme.of(context).backgroundColor))
            ],
          ),
        )
    );
  }

  portfolioAppBar(BuildContext context) {
    return new PreferredSize(
      preferredSize: const Size.fromHeight(85.0),
      child: new AppBar(
          backgroundColor: Theme.of(context).cardColor,
          titleSpacing: 0.0,
          elevation: appBarElevation,
          title: new Text("Portfolio", style: Theme.of(context).textTheme.title),
          bottom: bottomAppBar(context)
      ),
    );
  }

  marketsAppBar(BuildContext context) {
    return new PreferredSize(
      preferredSize: const Size.fromHeight(85.0),
      child: new AppBar(
          backgroundColor: Theme.of(context).cardColor,
          elevation: appBarElevation,
          title: new Text("Aggregate Markets", style: Theme.of(context).textTheme.title),
          titleSpacing: 0.0,
          leading: new IconButton( // TODO: Searching
              icon: new Icon(Icons.search, color: Theme.of(context).primaryIconTheme.color),
              onPressed: null
          ),
          bottom: bottomAppBar(context)
      ),
    );
  }


  int _tabIndex = 0;
  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _tabIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: _tabIndex == 0 ? portfolioAppBar(context) : marketsAppBar(context),

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

//      body: new CustomScrollView(
//        slivers: <Widget>[
//          new SliverAppBar(
//            pinned: false,
//            floating: true,
//
//            title: new Text("meme"),
//          ),
//
////          new PageView.custom(
////              childrenDelegate: new SliverChildBuilderDelegate(
////                (context, index) => [_testPage(context), _testPage(context)][index],
////                childCount: 2
////              )
////          )
//
//        new PageView(
//          controller: _pageController,
//          children: <Widget>[
//            _testPage(context),
//            _testPage(context)
//          ],
//        )
//
//        ],
//      ),

      body: new TabBarView(
        controller: _tabController,
        children: <Widget>[
          new PortfolioPage(),
          new MarketPage()
        ],
      ),
    );
  }
}