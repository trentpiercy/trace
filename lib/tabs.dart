import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'portfolio/portfolio_tabs.dart';
import 'main.dart';
import 'portfolio_page.dart';
import 'portfolio/transaction_sheet.dart';
import 'market_page.dart';

class Tabs extends StatefulWidget {
  Tabs(
      this.toggleTheme,
      this.savePreferences,
      this.handleUpdate,
      this.darkEnabled,
      this.themeMode,
      );

  final Function toggleTheme;
  final Function handleUpdate;
  final Function savePreferences;

  final bool darkEnabled;
  final String themeMode;

  @override
  TabsState createState() => new TabsState();
}

class TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextEditingController _textController = new TextEditingController();
  int _tabIndex = 0;
  List<Widget> _tabChildren;

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
    _makeTabChildren();
  }

  _startSearch() {
    isSearching = true;
    _makeTabChildren();
  }

  _stopSearch() {
    isSearching = false;
    filter = null;
    _textController.clear();
    _makeTabChildren();
  }

  _handleTabChange() {
    _tabIndex = _tabController.animation.value.round();
    if (isSearching) {
      _stopSearch();
    } else {
      setState(() {});
    }
  }

  _loadPortfolioJson({firstRun = false}) async {
    print("started JSON load...");

    await getApplicationDocumentsDirectory().then((Directory directory) async {
      File jsonFile = new File(directory.path + "/portfolio.json");
      if (jsonFile.existsSync()) {
        portfolioMap = json.decode(jsonFile.readAsStringSync());
      } else {
        print("creating file");
        jsonFile.createSync();
        jsonFile.writeAsStringSync("{}");
        portfolioMap = json.decode(jsonFile.readAsStringSync());
      }

      print("finished JSON load");

      if (firstRun) {
        print("loading cached market data...");
        File jsonFile = new File(directory.path + "/marketData.json");
        if (jsonFile.existsSync()) {
          marketListData = json.decode(jsonFile.readAsStringSync());
        }
        print("finished loading cached market data");
      }
    });

    _makePortfolioDisplay();
    _makeTabChildren();

    if (firstRun || marketListData == null) {
      await getMarketData();
      _makePortfolioDisplay();
      _makeTabChildren();
    }

    print("FINISHED loadPortfolioJson function");
  }

  _makePortfolioDisplay() {
    Map portfolioTotals = {};
    List neededPriceSymbols = [];

    portfolioMap.forEach((coin, transactions) {
      num quantityTotal = 0;
      transactions.forEach((value) {
        quantityTotal += value["quantity"];
      });
      portfolioTotals[coin] = quantityTotal;
      neededPriceSymbols.add(coin);
    });

    portfolioDisplay = [];
    num totalPortfolioValue = 0;
    marketListData.forEach((coin) {
      if (neededPriceSymbols.contains(coin["symbol"]) && portfolioTotals[coin["symbol"]] != 0) {
        portfolioDisplay.add({
          "symbol": coin["symbol"],
          "price_usd": coin["quotes"]["USD"]["price"],
          "percent_change_24h": coin["quotes"]["USD"]["percent_change_24h"],
          "percent_change_7d": coin["quotes"]["USD"]["percent_change_7d"],
          "total_quantity": portfolioTotals[coin["symbol"]],
          "id": coin["id"],
          "name": coin["name"],
        });
        totalPortfolioValue += (portfolioTotals[coin["symbol"]]*coin["quotes"]["USD"]["price"]);
      }
    });

    portfolioDisplay.sort(
        (a, b) => (b["total_quantity"]*b["price_usd"]).compareTo(a["total_quantity"]*a["price_usd"])
    );


    num total24hChange = 0;
    num total7dChange = 0;
    portfolioDisplay.forEach((coin) {
      total24hChange += (
          coin["percent_change_24h"]*((coin["price_usd"]*coin["total_quantity"])/totalPortfolioValue)
      );
      total7dChange += (
          coin["percent_change_7d"]*((coin["price_usd"]*coin["total_quantity"])/totalPortfolioValue)
      );

    });

    totalPortfolioStats = {
      "value_usd": totalPortfolioValue,
      "percent_change_24h": total24hChange,
      "percent_change_7d": total7dChange
    };

    print("display list: " + portfolioDisplay.toString());
  }

  _makeTabChildren() {
    print("MADE TAB CHILDREN");
    setState(() {
      _tabChildren = [
        new PortfolioPage(_makePortfolioDisplay, key: _portfolioKey),
        new MarketPage(filter, isSearching, key: _marketKey),
        new Container(),
      ];
    });
  }

  @override
  void initState() {
    super.initState();
    print("INIT TABS");

    _tabChildren = [
      new PortfolioPage(_makePortfolioDisplay, key: _portfolioKey),
      new MarketPage(filter, isSearching, key: _marketKey),
      new Container(),
    ];

    _loadPortfolioJson(firstRun: true);
    if (globalData == null) {getGlobalData();}

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
    _tabController.animation.removeListener(_handleTabChange);
    super.dispose();
  }

  final PageStorageKey _marketKey = new PageStorageKey("market");
  final PageStorageKey _portfolioKey = new PageStorageKey("portfolio");

  ScrollController _scrollController = new ScrollController();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print("[T] built tabs");

    return new Scaffold(
      key: _scaffoldKey,
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
                    new ListTile(
                      leading: new Icon(Icons.settings),
                      title: new Text("Settings"),
                      onTap: () => Navigator.pushNamed(context, "/settings"),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.timeline),
                      title: new Text("Portfolio Timeline"),
                      onTap: () => Navigator.push(context, new MaterialPageRoute(
                          builder: (context) => new PortfolioTabs(0, totalPortfolioStats, portfolioDisplay)
                      )),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.pie_chart_outlined),
                      title: new Text("Portfolio Breakdown"),
                      onTap: () => Navigator.push(context, new MaterialPageRoute(
                          builder: (context) => new PortfolioTabs(1, totalPortfolioStats, portfolioDisplay)
                      )),
                    )
                  ],
                )
            )
        ),

        floatingActionButton: _tabIndex == 0 ?
        new PortfolioFAB(_scaffoldKey, () {
          setState(() {_makePortfolioDisplay();});
        }, marketListData) : null,

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
            children: _tabChildren,
          ),
        )

    );
  }
}