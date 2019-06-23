import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

import 'portfolio/portfolio_tabs.dart';
import 'main.dart';
import 'portfolio_item.dart';
import 'portfolio/transaction_sheet.dart';
import 'market_coin_item.dart';

class Tabs extends StatefulWidget {
  Tabs(
      {this.toggleTheme,
      this.savePreferences,
      this.handleUpdate,
      this.darkEnabled,
      this.themeMode,
      this.switchOLED,
      this.darkOLED});

  final Function toggleTheme;
  final Function handleUpdate;
  final Function savePreferences;

  final bool darkEnabled;
  final String themeMode;

  final Function switchOLED;
  final bool darkOLED;

  @override
  TabsState createState() => new TabsState();
}

class TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextEditingController _textController = new TextEditingController();
  int _tabIndex = 0;

  bool isSearching = false;
  String filter;

  bool sheetOpen = false;

  _handleFilter(value) {
    if (value == null) {
      isSearching = false;
      filter = null;
    } else {
      filter = value;
      isSearching = true;
    }
    _filterMarketData();
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
      _filterMarketData();
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

  _openTransaction() {
    setState(() {
      sheetOpen = true;
    });
    _scaffoldKey.currentState
        .showBottomSheet((BuildContext context) {
          return new TransactionSheet(
            () {
              setState(() {
                _makePortfolioDisplay();
              });
            },
            marketListData,
          );
        })
        .closed
        .whenComplete(() {
          setState(() {
            sheetOpen = false;
          });
        });
  }

  _makePortfolioDisplay() {
    print("making portfolio display");
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
      if (neededPriceSymbols.contains(coin["symbol"]) &&
          portfolioTotals[coin["symbol"]] != 0) {
        portfolioDisplay.add({
          "symbol": coin["symbol"],
          "price_usd": coin["quotes"]["USD"]["price"],
          "percent_change_24h": coin["quotes"]["USD"]["percent_change_24h"],
          "percent_change_7d": coin["quotes"]["USD"]["percent_change_7d"],
          "total_quantity": portfolioTotals[coin["symbol"]],
          "id": coin["id"],
          "name": coin["name"],
        });
        totalPortfolioValue +=
            (portfolioTotals[coin["symbol"]] * coin["quotes"]["USD"]["price"]);
      }
    });

    num total24hChange = 0;
    num total7dChange = 0;
    portfolioDisplay.forEach((coin) {
      total24hChange += (coin["percent_change_24h"] *
          ((coin["price_usd"] * coin["total_quantity"]) / totalPortfolioValue));
      total7dChange += (coin["percent_change_7d"] *
          ((coin["price_usd"] * coin["total_quantity"]) / totalPortfolioValue));
    });

    totalPortfolioStats = {
      "value_usd": totalPortfolioValue,
      "percent_change_24h": total24hChange,
      "percent_change_7d": total7dChange
    };

    _sortPortfolioDisplay();
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.animation.addListener(() {
      if (_tabController.animation.value.round() != _tabIndex) {
        _handleTabChange();
      }
    });

    _makePortfolioDisplay();
    _filterMarketData();
    _refreshMarketPage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ScrollController _scrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        drawer: new Drawer(
            child: new Scaffold(
                bottomNavigationBar: new Container(
                    decoration: new BoxDecoration(
                        border: new Border(
                      top: new BorderSide(
                          color: Theme.of(context).bottomAppBarColor),
                    )),
                    child: new ListTile(
                      onTap: widget.toggleTheme,
                      leading: new Icon(
                          widget.darkEnabled
                              ? Icons.brightness_3
                              : Icons.brightness_7,
                          color: Theme.of(context).buttonColor),
                      title: new Text(widget.themeMode,
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .apply(color: Theme.of(context).buttonColor)),
                    )),
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
                      onTap: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  new PortfolioTabs(0, _makePortfolioDisplay))),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.pie_chart_outlined),
                      title: new Text("Portfolio Breakdown"),
                      onTap: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  new PortfolioTabs(1, _makePortfolioDisplay))),
                    ),
                    new Container(
                      decoration: new BoxDecoration(
                          border: new Border(
                              bottom: new BorderSide(
                                  color: Theme.of(context).bottomAppBarColor,
                                  width: 1.0))),
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.short_text),
                      title: new Text("Abbreviate Numbers"),
                      trailing: new Switch(
                          activeColor: Theme.of(context).accentColor,
                          value: shortenOn,
                          onChanged: (onOff) {
                            setState(() {
                              shortenOn = onOff;
                            });
                            widget.savePreferences();
                          }),
                      onTap: () {
                        setState(() {
                          shortenOn = !shortenOn;
                        });
                        widget.savePreferences();
                      },
                    ),
                    new ListTile(
                      leading: new Icon(Icons.opacity),
                      title: new Text("OLED Dark Mode"),
                      trailing: new Switch(
                        activeColor: Theme.of(context).accentColor,
                        value: widget.darkOLED,
                        onChanged: (onOff) {
                          widget.switchOLED(state: onOff);
                        },
                      ),
                      onTap: widget.switchOLED,
                    ),
                  ],
                ))),
        floatingActionButton: _tabIndex == 0 ? _transactionFAB(context) : null,
        body: new NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              new SliverAppBar(
                title: [
                  new Text("Portfolio"),
                  isSearching
                      ? new TextField(
                          controller: _textController,
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          style: Theme.of(context).textTheme.subhead,
                          onChanged: (value) => _handleFilter(value),
                          autofocus: true,
                          textCapitalization: TextCapitalization.none,
                          decoration: new InputDecoration.collapsed(
                              hintText: 'Search names and symbols...'),
                        )
                      : new GestureDetector(
                          onTap: () => _startSearch(),
                          child: new Text("Aggregate Markets"),
                        ),
                ][_tabIndex],
                actions: <Widget>[
                  [
                    new Container(),
                    isSearching
                        ? new IconButton(
                            icon: new Icon(Icons.close),
                            onPressed: () => _stopSearch())
                        : new IconButton(
                            icon: new Icon(Icons.search,
                                color:
                                    Theme.of(context).primaryIconTheme.color),
                            onPressed: () => _startSearch()),
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
                          new Tab(icon: new Icon(Icons.filter_list)),
                        ],
                      ),
                    )),
              )
            ];
          },
          body: new TabBarView(
            controller: _tabController,
            children: [portfolioPage(context), marketPage(context)],
          ),
        ));
  }

  Widget _transactionFAB(BuildContext context) {
    return sheetOpen
        ? new FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(Icons.close),
            foregroundColor: Theme.of(context).iconTheme.color,
            backgroundColor: Theme.of(context).accentIconTheme.color,
            elevation: 4.0,
            tooltip: "Close Transaction",
          )
        : new FloatingActionButton.extended(
              onPressed: _openTransaction,
              icon: Icon(Icons.add),
              label: new Text("Add Transaction"),
              foregroundColor: Theme.of(context).iconTheme.color,
              backgroundColor: Theme.of(context).accentIconTheme.color,
              elevation: 4.0,
              tooltip: "Add Transaction",
        );
  }

  final portfolioColumnProps = [.25, .35, .3];

  Future<Null> _refreshPortfolioPage() async {
    await getMarketData();
    getGlobalData();
    _makePortfolioDisplay();
    _filterMarketData();
    setState(() {});
  }

  List portfolioSortType = ["holdings", true];
  List sortedPortfolioDisplay;
  _sortPortfolioDisplay() {
    sortedPortfolioDisplay = portfolioDisplay;
    if (portfolioSortType[1]) {
      if (portfolioSortType[0] == "holdings") {
        sortedPortfolioDisplay.sort((a, b) =>
            (b["price_usd"] * b["total_quantity"])
                .toDouble()
                .compareTo((a["price_usd"] * a["total_quantity"]).toDouble()));
      } else {
        sortedPortfolioDisplay.sort((a, b) =>
            b[portfolioSortType[0]].compareTo(a[portfolioSortType[0]]));
      }
    } else {
      if (portfolioSortType[0] == "holdings") {
        sortedPortfolioDisplay.sort((a, b) =>
            (a["price_usd"] * a["total_quantity"])
                .toDouble()
                .compareTo((b["price_usd"] * b["total_quantity"]).toDouble()));
      } else {
        sortedPortfolioDisplay.sort((a, b) =>
            a[portfolioSortType[0]].compareTo(b[portfolioSortType[0]]));
      }
    }
  }

  final PageStorageKey _marketKey = new PageStorageKey("market");
  final PageStorageKey _portfolioKey = new PageStorageKey("portfolio");

  Widget portfolioPage(BuildContext context) {
    return new RefreshIndicator(
        key: _portfolioKey,
        onRefresh: _refreshPortfolioPage,
        child: new CustomScrollView(
          slivers: <Widget>[
            new SliverList(
                delegate: new SliverChildListDelegate(<Widget>[
              new Container(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 10.0, bottom: 4.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text("Total Portfolio Value",
                            style: Theme.of(context).textTheme.caption),
                        new Text(
                            "\$" +
                                numCommaParse(totalPortfolioStats["value_usd"]
                                    .toStringAsFixed(2)),
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .apply(fontSizeFactor: 2.2)),
                      ],
                    ),
                    new Column(
                      children: <Widget>[
                        new Text("7D Change",
                            style: Theme.of(context).textTheme.caption),
                        new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0)),
                        new Text(
                            totalPortfolioStats["percent_change_7d"] >= 0
                                ? "+" +
                                    totalPortfolioStats["percent_change_7d"]
                                        .toStringAsFixed(2) +
                                    "%"
                                : totalPortfolioStats["percent_change_7d"]
                                        .toStringAsFixed(2) +
                                    "%",
                            style:
                                Theme.of(context).primaryTextTheme.body2.apply(
                                      color: totalPortfolioStats[
                                                  "percent_change_7d"] >=
                                              0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSizeFactor: 1.4,
                                    ))
                      ],
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        new Text("24h Change",
                            style: Theme.of(context).textTheme.caption),
                        new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0)),
                        new Text(
                            totalPortfolioStats["percent_change_24h"] >= 0
                                ? "+" +
                                    totalPortfolioStats["percent_change_24h"]
                                        .toStringAsFixed(2) +
                                    "%"
                                : totalPortfolioStats["percent_change_24h"]
                                        .toStringAsFixed(2) +
                                    "%",
                            style: Theme.of(context)
                                .primaryTextTheme
                                .body2
                                .apply(
                                    color: totalPortfolioStats[
                                                "percent_change_24h"] >=
                                            0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSizeFactor: 1.4))
                      ],
                    ),
                  ],
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        bottom: new BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.0))),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new InkWell(
                      onTap: () {
                        if (portfolioSortType[0] == "symbol") {
                          portfolioSortType[1] = !portfolioSortType[1];
                        } else {
                          portfolioSortType = ["symbol", false];
                        }
                        setState(() {
                          _sortPortfolioDisplay();
                        });
                      },
                      child: new Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[0],
                        child: portfolioSortType[0] == "symbol"
                            ? new Text(
                                portfolioSortType[1] == true
                                    ? "Currency " + upArrow
                                    : "Currency " + downArrow,
                                style: Theme.of(context).textTheme.body2)
                            : new Text(
                                "Currency",
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: Theme.of(context).hintColor),
                              ),
                      ),
                    ),
                    new InkWell(
                      onTap: () {
                        if (portfolioSortType[0] == "holdings") {
                          portfolioSortType[1] = !portfolioSortType[1];
                        } else {
                          portfolioSortType = ["holdings", true];
                        }
                        setState(() {
                          _sortPortfolioDisplay();
                        });
                      },
                      child: new Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[1],
                        child: portfolioSortType[0] == "holdings"
                            ? new Text(
                                portfolioSortType[1] == true
                                    ? "Holdings " + downArrow
                                    : "Holdings " + upArrow,
                                style: Theme.of(context).textTheme.body2)
                            : new Text("Holdings",
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: Theme.of(context).hintColor)),
                      ),
                    ),
                    new InkWell(
                      onTap: () {
                        if (portfolioSortType[0] == "percent_change_24h") {
                          portfolioSortType[1] = !portfolioSortType[1];
                        } else {
                          portfolioSortType = ["percent_change_24h", true];
                        }
                        setState(() {
                          _sortPortfolioDisplay();
                        });
                      },
                      child: new Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[2],
                        child: portfolioSortType[0] == "percent_change_24h"
                            ? new Text(
                                portfolioSortType[1] == true
                                    ? "Price/24h " + downArrow
                                    : "Price/24h " + upArrow,
                                style: Theme.of(context).textTheme.body2)
                            : new Text("Price/24h",
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: Theme.of(context).hintColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ])),
            portfolioMap.isNotEmpty
                ? new SliverList(
                    delegate: new SliverChildBuilderDelegate(
                        (context, index) => new PortfolioListItem(
                            sortedPortfolioDisplay[index], portfolioColumnProps),
                        childCount: sortedPortfolioDisplay != null
                            ? sortedPortfolioDisplay.length
                            : 0))
                : new SliverFillRemaining(
                    child: new Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                                "Your portfolio is empty. Add a transaction!",
                                style: Theme.of(context).textTheme.caption),
                            new Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0)),
                            new RaisedButton(
                              onPressed: _openTransaction,
                              child: new Text("New Transaction",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body2
                                      .apply(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color)),
                            )
                          ],
                        ))),
          ],
        ));
  }

  final marketColumnProps = [.32, .35, .28];
  List filteredMarketData;
  Map globalData;

  Future<Null> getGlobalData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/global/"),
        headers: {"Accept": "application/json"});

    globalData = new JsonDecoder().convert(response.body)["data"]["quotes"]["USD"];
  }

  Future<Null> _refreshMarketPage() async {
    await getMarketData();
    await getGlobalData();
    _makePortfolioDisplay();
    _filterMarketData();
    setState(() {});
  }

  _filterMarketData() {
    print("filtering market data");
    filteredMarketData = marketListData;
    if (filter != "" && filter != null) {
      List tempFilteredMarketData = [];
      filteredMarketData.forEach((item) {
        if (item["symbol"].toLowerCase().contains(filter.toLowerCase()) ||
            item["name"].toLowerCase().contains(filter.toLowerCase())) {
          tempFilteredMarketData.add(item);
        }
      });
      filteredMarketData = tempFilteredMarketData;
    }
    _sortMarketData();
  }

  List marketSortType = ["market_cap", true];
  _sortMarketData() {
    if (marketSortType[1]) {
      if (marketSortType[0] == "market_cap" ||
          marketSortType[0] == "volume_24h" ||
          marketSortType[0] == "percent_change_24h") {
        filteredMarketData.sort((a, b) => (b["quotes"]["USD"][marketSortType[0]] ?? 0)
            .compareTo(a["quotes"]["USD"][marketSortType[0]] ?? 0));
      } else {
        filteredMarketData.sort(
            (a, b) => (b[marketSortType[0]] ?? 0).compareTo(a[marketSortType[0]] ?? 0));
      }
    } else {
      if (marketSortType[0] == "market_cap" ||
          marketSortType[0] == "volume_24h" ||
          marketSortType[0] == "percent_change_24h") {

        filteredMarketData.sort((a, b) => (a["quotes"]["USD"][marketSortType[0]] ?? 0)
            .compareTo(b["quotes"]["USD"][marketSortType[0]] ?? 0));
      } else {
        filteredMarketData.sort(
            (a, b) => (a[marketSortType[0]] ?? 0).compareTo(b[marketSortType[0]] ?? 0));
      }
    }
  }

  Widget marketPage(BuildContext context) {
    return filteredMarketData != null
        ? new RefreshIndicator(
            key: _marketKey,
            onRefresh: () => _refreshMarketPage(),
            child: new CustomScrollView(
              slivers: <Widget>[
                new SliverList(
                    delegate: new SliverChildListDelegate(<Widget>[
                  globalData != null && isSearching != true
                      ? new Container(
                          padding: const EdgeInsets.all(10.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("Total Market Cap",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .apply(
                                              color:
                                                  Theme.of(context).hintColor)),
                                  new Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 1.0)),
                                  new Text("Total 24h Volume",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .apply(
                                              color:
                                                  Theme.of(context).hintColor)),
                                ],
                              ),
                              new Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1.0)),
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  new Text(
                                      "\$" +
                                          normalizeNum(
                                              globalData["total_market_cap"]),
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .apply(
                                              fontSizeFactor: 1.2,
                                              fontWeightDelta: 2)),
                                  new Text(
                                      "\$" +
                                          normalizeNum(
                                              globalData["total_volume_24h"]),
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .apply(
                                              fontSizeFactor: 1.2,
                                              fontWeightDelta: 2)),
                                ],
                              )
                            ],
                          ))
                      : new Container(),
                  new Container(
                    margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            bottom: new BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1.0))),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new InkWell(
                          onTap: () {
                            if (marketSortType[0] == "symbol") {
                              marketSortType[1] = !marketSortType[1];
                            } else {
                              marketSortType = ["symbol", false];
                            }
                            setState(() {
                              _sortMarketData();
                            });
                          },
                          child: new Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width: MediaQuery.of(context).size.width *
                                marketColumnProps[0],
                            child: marketSortType[0] == "symbol"
                                ? new Text(
                                    marketSortType[1]
                                        ? "Currency " + upArrow
                                        : "Currency " + downArrow,
                                    style: Theme.of(context).textTheme.body2)
                                : new Text("Currency",
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .apply(
                                            color:
                                                Theme.of(context).hintColor)),
                          ),
                        ),
                        new Container(
                          width: MediaQuery.of(context).size.width *
                              marketColumnProps[1],
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new InkWell(
                                  onTap: () {
                                    if (marketSortType[0] == "market_cap") {
                                      marketSortType[1] = !marketSortType[1];
                                    } else {
                                      marketSortType = ["market_cap", true];
                                    }
                                    setState(() {
                                      _sortMarketData();
                                    });
                                  },
                                  child: new Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: marketSortType[0] == "market_cap"
                                        ? new Text(
                                            marketSortType[1]
                                                ? "Market Cap " + downArrow
                                                : "Market Cap " + upArrow,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2)
                                        : new Text("Market Cap",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2
                                                .apply(
                                                    color: Theme.of(context)
                                                        .hintColor)),
                                  )),
                              new Text("/",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body2
                                      .apply(
                                          color: Theme.of(context).hintColor)),
                              new InkWell(
                                onTap: () {
                                  if (marketSortType[0] == "volume_24h") {
                                    marketSortType[1] = !marketSortType[1];
                                  } else {
                                    marketSortType = ["volume_24h", true];
                                  }
                                  setState(() {
                                    _sortMarketData();
                                  });
                                },
                                child: new Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: marketSortType[0] == "volume_24h"
                                      ? new Text(
                                          marketSortType[1] ? "24h " + downArrow : "24h " + upArrow,
                                          style:
                                              Theme.of(context).textTheme.body2)
                                      : new Text("24h",
                                          style: Theme.of(context)
                                              .textTheme
                                              .body2
                                              .apply(
                                                  color: Theme.of(context)
                                                      .hintColor)),
                                ),
                              )
                            ],
                          ),
                        ),
                        new InkWell(
                          onTap: () {
                            if (marketSortType[0] == "percent_change_24h") {
                              marketSortType[1] = !marketSortType[1];
                            } else {
                              marketSortType = ["percent_change_24h", true];
                            }
                            setState(() {
                              _sortMarketData();
                            });
                          },
                          child: new Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width: MediaQuery.of(context).size.width *
                                marketColumnProps[2],
                            child: marketSortType[0] == "percent_change_24h"
                                ? new Text(
                                    marketSortType[1] == true
                                        ? "Price/24h " + downArrow
                                        : "Price/24h " + upArrow,
                                    style: Theme.of(context).textTheme.body2)
                                : new Text("Price/24h",
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .apply(
                                            color:
                                                Theme.of(context).hintColor)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
                filteredMarketData.isEmpty
                    ? new SliverList(
                        delegate: new SliverChildListDelegate(<Widget>[
                        new Container(
                          padding: const EdgeInsets.all(30.0),
                          alignment: Alignment.topCenter,
                          child: new Text("No results found",
                              style: Theme.of(context).textTheme.caption),
                        )
                      ]))
                    : new SliverList(
                        delegate: new SliverChildBuilderDelegate(
                            (BuildContext context, int index) =>
                                new CoinListItem(filteredMarketData[index],
                                    marketColumnProps),
                            childCount: filteredMarketData == null
                                ? 0
                                : filteredMarketData.length))
              ],
            ))
        : new Container(
            child: new Center(child: new CircularProgressIndicator()),
          );
  }
}
