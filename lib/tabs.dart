import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:flutter/material.dart';

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
    setState(() {
      _filterMarketData();
    });
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
      _filterMarketData();
      _textController.clear();
    });
  }

  _handleTabChange() {
    _tabIndex = _tabController.animation.value.round();
    if (isSearching) {
      _stopSearch();
    } else {
      setState(() {});
    }
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
  }

  @override
  void initState() {
    super.initState();
    print("INIT TABS");
    _tabController = new TabController(length: 3, vsync: this);
    _tabController.animation.addListener(() {
      if (_tabController.animation.value.round() != _tabIndex) {
        _handleTabChange();
      }
    });

    _refreshMarketPage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _tabController.animation.removeListener(_handleTabChange);
    super.dispose();
  }

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
                            top: new BorderSide(color: Theme.of(context).bottomAppBarColor),
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
                          builder: (context) => new PortfolioTabs(0, _makePortfolioDisplay)
                      )),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.pie_chart_outlined),
                      title: new Text("Portfolio Breakdown"),
                      onTap: () => Navigator.push(context, new MaterialPageRoute(
                          builder: (context) => new PortfolioTabs(1, _makePortfolioDisplay)
                      )),
                    )
                  ],
                )
            )
        ),

        floatingActionButton: _tabIndex == 0 ?
        new PortfolioFAB(_scaffoldKey, () {
          setState(() {});
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

//                  new Text("Alerts")
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
                    preferredSize: const Size.fromHeight(38.0),
                    child: new Container(
                      height: 38.0,
                      child: new TabBar(
                        controller: _tabController,
                        indicatorColor: Theme.of(context).accentIconTheme.color,
                        unselectedLabelColor: Theme.of(context).disabledColor,
                        labelColor: Theme.of(context).accentIconTheme.color,
                        tabs: <Tab>[
                          new Tab(icon: new Icon(Icons.person)),
                          new Tab(icon: new Icon(Icons.menu)),
//                          new Tab(icon: new Icon(Icons.notifications))
                        ],
                      ),
                    )
                ),
              )

            ];
          },

          body: new TabBarView(
            controller: _tabController,
            children: [
              portfolioPage(context),
              marketPage(context)
            ],
          ),
        )
    );
  }

  final columnProps = [.2,.3,.3];

  Future<Null> _refreshPortfolioPage() async {
    await getMarketData();
    getGlobalData();
    setState(() {
      _makePortfolioDisplay();
      _filterMarketData();
    });
  }

  final PageStorageKey _marketKey = new PageStorageKey("market");
  final PageStorageKey _portfolioKey = new PageStorageKey("portfolio");

  Widget portfolioPage(BuildContext context) {
    print("[P] built portfolio page");
    _makePortfolioDisplay();
    return new RefreshIndicator(
        key: _portfolioKey,
        onRefresh: _refreshPortfolioPage,
        child: new CustomScrollView(
          slivers: <Widget>[
            new SliverList(
                delegate: new SliverChildListDelegate(<Widget>[
                  new Container(
                    padding: const EdgeInsets.all(10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text("Total Portfolio Value", style: Theme.of(context).textTheme.caption),
                            new Text("\$"+ numCommaParseNoDollar(totalPortfolioStats["value_usd"].toStringAsFixed(2)),
                                style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)
                            ),
                          ],
                        ),
                        new Column(
                          children: <Widget>[
                            new Text("7D Change", style: Theme.of(context).textTheme.caption),
                            new Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
                            new Text(
                                totalPortfolioStats["percent_change_7d"] >= 0 ? "+"+totalPortfolioStats["percent_change_7d"].toStringAsFixed(2)+"%" : totalPortfolioStats["percent_change_7d"].toStringAsFixed(2)+"%",
                                style: Theme.of(context).primaryTextTheme.body2.apply(
                                  color: totalPortfolioStats["percent_change_7d"] >= 0 ? Colors.green : Colors.red,
                                  fontSizeFactor: 1.4,
                                )
                            )
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            new Text("24h Change", style: Theme.of(context).textTheme.caption),
                            new Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
                            new Text(
                                totalPortfolioStats["percent_change_24h"] >= 0 ? "+"+totalPortfolioStats["percent_change_24h"].toStringAsFixed(2)+"%" : totalPortfolioStats["percent_change_24h"].toStringAsFixed(2)+"%",
                                style: Theme.of(context).primaryTextTheme.body2.apply(
                                    color: totalPortfolioStats["percent_change_24h"] >= 0 ? Colors.green : Colors.red,
                                    fontSizeFactor: 1.4
                                )
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                    decoration: new BoxDecoration(
                        border: new Border(bottom: new BorderSide(color: Theme.of(context).dividerColor, width: 1.0))
                    ),
                    padding: const EdgeInsets.only(bottom: 8.0, left: 2.0, right: 2.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * columnProps[0],
                          child: new Text("Currency", style: Theme.of(context).textTheme.body2),
                        ),
                        new Container(
                          alignment: Alignment.centerRight,
                          width: MediaQuery.of(context).size.width * columnProps[1],
                          child: new Text("Holdings", style: Theme.of(context).textTheme.body2),
                        ),
                        new Container(
                          alignment: Alignment.centerRight,
                          width: MediaQuery.of(context).size.width * columnProps[2],
                          child: new Text("Price/24h", style: Theme.of(context).textTheme.body2),
                        ),
                      ],
                    ),
                  ),
                ])
            ),
            portfolioMap.isNotEmpty ? new SliverList(delegate: new SliverChildBuilderDelegate(
                    (context, index) => new PortfolioListItem(portfolioDisplay[index]),
                childCount: portfolioDisplay != null ? portfolioDisplay.length : 0
            )) : new SliverFillRemaining(
              child: new Container(
                alignment: Alignment.topCenter,
                padding: const EdgeInsets.all(32.0),
                child: new Text("Your portfolio is empty. Add a transaction!",
                  style: Theme.of(context).textTheme.caption)
              ),
            )
          ],
        )
    );
  }

  final marketColumnProps = [.3,.3,.25];
  List filteredMarketData;
  Map globalData;

  Future<Null> getGlobalData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/global/"),
        headers: {"Accept": "application/json"}
    );

    globalData = new JsonDecoder().convert(response.body)["data"]["quotes"]["USD"];
  }

  Future<Null> _refreshMarketPage() async {
    await getGlobalData();
    await getMarketData();
    setState(() {
      _filterMarketData();
    });
  }

  _filterMarketData() {
    if (filter == "" || filter == null) {
      filteredMarketData = marketListData;
    } else {
      filteredMarketData = [];
      marketListData.forEach((item) {
        if (item["symbol"].toLowerCase().contains(filter.toLowerCase()) ||
            item["name"].toLowerCase().contains(filter.toLowerCase())) {
          filteredMarketData.add(item);
        }
      });
    }
  }

  Widget marketPage(BuildContext context) {
    print("[M] built market page");
    return filteredMarketData != null ? new RefreshIndicator(
        key: _marketKey,
        onRefresh: () => _refreshMarketPage(),
        child: new CustomScrollView(
          slivers: <Widget>[
            isSearching != true ? new SliverList(
                delegate: new SliverChildListDelegate(<Widget>[
                  globalData != null ? new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Text("Total Market Cap", style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor)),
                              new Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
                              new Text("Total 24h Volume", style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor)),
                            ],
                          ),
                          new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              new Text(numCommaParse(globalData["total_market_cap"].toString()),
                                  style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2, fontWeightDelta: 2)
                              ),
                              new Text(numCommaParse(globalData["total_volume_24h"].toString()),
                                  style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2, fontWeightDelta: 2)
                              ),
                            ],
                          )
                        ],
                      )
                  ) : new Container(),
                  new Container(
                    margin: const EdgeInsets.only(left: 6.0, right: 6.0, top: 8.0),
                    decoration: new BoxDecoration(
                        border: new Border(bottom: new BorderSide(color: Theme.of(context).dividerColor, width: 1.0))
                    ),
                    padding: const EdgeInsets.only(bottom: 8.0, left: 2.0, right: 2.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * marketColumnProps[0],
                          child: new Text("Currency", style: Theme.of(context).textTheme.body2),
                        ),
                        new Container(
                          alignment: Alignment.centerRight,
                          width: MediaQuery.of(context).size.width * marketColumnProps[1],
                          child: new Text("Market Cap/24h", style: Theme.of(context).textTheme.body2),
                        ),
                        new Container(
                          alignment: Alignment.centerRight,
                          width: MediaQuery.of(context).size.width * marketColumnProps[2],
                          child: new Text("Price/24h", style: Theme.of(context).textTheme.body2),
                        ),
                      ],
                    ),
                  ),
                ])
            ) : new SliverPadding(padding: const EdgeInsets.all(0.0)),
            filteredMarketData.isEmpty ? new SliverList(
                delegate: new SliverChildListDelegate(
                    <Widget>[
                      new Container(
                        padding: const EdgeInsets.all(30.0),
                        alignment: Alignment.topCenter,
                        child: new Text("No results found", style: Theme.of(context).textTheme.caption),
                      )
                    ]
                )
            ) :
            new SliverList(delegate: new SliverChildBuilderDelegate(
                    (BuildContext context, int index) =>
                new CoinListItem(filteredMarketData[index], marketColumnProps),
                childCount: filteredMarketData == null ? 0 : filteredMarketData.length
            ))

          ],
        )
    ) : new Container(
      child: new Center(child: new CircularProgressIndicator()),
    );
  }

}