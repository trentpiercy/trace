import 'package:flutter/material.dart';

import 'main.dart';
import 'portfolio_page.dart';
import 'market_page.dart';

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
  TextEditingController _textController = new TextEditingController();
  int _tabIndex = 0;

  bool isSearching = false;
  String filter;

  _handleFilter(value) {
    if (value == null) {
      isSearching = false;
      filter = null;
    } else {
      filter = value;
      isSearching = true;
    }
    setState(() {});
  }

  _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  _stopSearch() {
    setState(() {
      isSearching = false;
      filter = null;
      _textController.clear();
    });
  }

  _handleTabChange() {
    _tabIndex = _tabController.animation.value.round();
    _stopSearch();
  }

  @override
  void initState() {
    print("INIT TABS");

    super.initState();
    _tabController = new TabController(length: 3, vsync: this);

    _tabController.animation.addListener(() {
      if (_tabController.animation.value.round() != _tabIndex) {
        _handleTabChange();
      }
    });

  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    super.dispose();
  }

  PageStorageKey _marketKey = new PageStorageKey("market");
  PageStorageKey _portfolioKey = new PageStorageKey("portfolio");
  PageStorageKey _portfolioKey2 = new PageStorageKey("portfolio2");

  ScrollController _scrollController = new ScrollController();

  @override
  Widget build(BuildContext context) {

    print("built tabs");

    return new Scaffold(
        drawer: new Drawer(
            child: new Scaffold(
                bottomNavigationBar: new Container(
                    decoration: new BoxDecoration(
                        border: new Border(
                            top: new BorderSide(color: Theme.of(context).dividerColor),
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
//                    new ListTile(
//                      leading: new Icon(Icons.settings),
//                      title: new Text("Settings"),
//                    ),
                    new ListTile(
                      leading: new Icon(Icons.timeline),
                      title: new Text("Portfolio Timeline"),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.pie_chart_outlined),
                      title: new Text("Portfolio Breakdown"),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.short_text),
                      title: new Text(shortenOn ? "Full Numbers" : "Abbreviate Numbers"),
                      onTap: () {
                        setState(() {
                          shortenOn = !shortenOn;
                        });
                      },
                    )
                  ],
                )
            )
        ),

        floatingActionButton: [
          new FloatingActionButton(
            onPressed: null,
            child: Icon(Icons.add),
            foregroundColor: Theme.of(context).iconTheme.color,
            backgroundColor: Theme.of(context).accentIconTheme.color,
            elevation: 4.0,
            tooltip: "Add transaction",
          ),
          null,
          null
        ][_tabIndex],

        body: new NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              new SliverAppBar(
                title: [
                  new Text("Portfolio"),

                  isSearching ? new TextField(
                    controller: _textController,
                    autocorrect: false,
                    keyboardType: TextInputType.text,
                    style: Theme.of(context).textTheme.subhead,
                    onChanged: (value) => _handleFilter(value),
                    autofocus: true,
                    decoration: new InputDecoration.collapsed(
                        hintText: 'Search names and symbols...'
                    ),
                  ) :
                  new GestureDetector(
                    onTap: () => _startSearch(),
                    child: new Text("Aggregate Markets"),
                  ),

                  new Text("Alerts")
                ][_tabIndex],

                actions: <Widget>[
                  [
                    new Container(),

                    isSearching ? new IconButton(
                        icon: new Icon(Icons.close),
                        onPressed: () => _stopSearch()
                    ) :
                    new IconButton(
                        icon: new Icon(Icons.search, color: Theme.of(context).primaryIconTheme.color),
                        onPressed: () => _startSearch()
                    ),

                    new Container()
                  ][_tabIndex],
                ],

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
              new MarketPage(filter, isSearching, key: _marketKey),
              new PortfolioPage(key: _portfolioKey2,)
            ],
          ),
        )

    );
  }
}