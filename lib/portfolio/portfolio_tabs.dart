import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../sparkline.dart';
import 'dart:math';

import '../main.dart';
import 'breakdown.dart';
import 'transactions_page.dart';

normalizeNum(num input) {
  if (input < 1) {
    return input.toStringAsFixed(4);
  } else {
    return numCommaParseNoDollar(input.toStringAsFixed(2));
  }
}

class PortfolioTabs extends StatefulWidget {
  PortfolioTabs(this.tab, this.makePortfolioDisplay);
  final int tab;
  final Function makePortfolioDisplay;

  @override
  PortfolioTabsState createState() => new PortfolioTabsState();
}

class PortfolioTabsState extends State<PortfolioTabs> with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 2, vsync: this);
    _tabController.animateTo(widget.tab);
    if (timelineData == null) {
      _getTimelineData();
    }
    _getBreakdownTotals();
    _makeBreakdownPortions();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new PreferredSize(
          preferredSize: const Size.fromHeight(75.0),
          child: new AppBar(
            backgroundColor: Theme.of(context).primaryColor,
            titleSpacing: 0.0,
            elevation: appBarElevation,
            title: new Text("Portfolio", style: Theme.of(context).textTheme.title),
            bottom: new PreferredSize(
                preferredSize: const Size.fromHeight(25.0),
                child: new Container(
                    height: 30.0,
                    child: new TabBar(
                      controller: _tabController,
                      indicatorColor: Theme.of(context).accentIconTheme.color,
                      indicatorWeight: 2.0,
                      unselectedLabelColor: Theme.of(context).disabledColor,
                      labelColor: Theme.of(context).primaryIconTheme.color,
                      tabs: <Widget>[
                        new Tab(text: "Timeline"),
                        new Tab(text: "Breakdown"),
                      ],
                    ))),
          ),
        ),
        body: new TabBarView(
          controller: _tabController,
          children: <Widget>[
            _timeline(context),
            new PortfolioBreakdown(
              refresh: _refresh,
              value: value,
              net: net,
              netPercent: netPercent,
              cost: cost,
              segments: segments,
              colors: colors,
            )
          ],
        )
    );
  }

  num value = 0;

  List<double> timelineData;
  num high = 0;
  num low = 0;
  num changePercent = 0;
  num changeAmt = 0;
  String periodSetting = "24h";

  final Map periodOptions = {
    "24h":{
      "limit": 96,
      "aggregate_by": 15,
      "hist_type": "minute",
      "unit_in_ms": 900000
    },
    "3D":{
      "limit": 72,
      "aggregate_by": 1,
      "hist_type": "hour",
      "unit_in_ms": 3600000
    },
    "7D":{
      "limit": 86,
      "aggregate_by": 2,
      "hist_type": "hour",
      "unit_in_ms": 3600000*2
    },
    "1M":{
      "limit": 90,
      "aggregate_by": 8,
      "hist_type": "hour",
      "unit_in_ms": 3600000*8
    },
    "3M":{
      "limit": 90,
      "aggregate_by": 1,
      "hist_type": "day",
      "unit_in_ms": 3600000*24
    },
    "6M":{
      "limit": 90,
      "aggregate_by": 2,
      "hist_type": "day",
      "unit_in_ms": 3600000*24*2
    },
    "1Y":{
      "limit": 73,
      "aggregate_by": 5,
      "hist_type": "day",
      "unit_in_ms": 3600000*24*5
    },
    "All":{
      "limit": 0,
      "aggregate_by": 1,
      "hist_type": "day",
      "unit_in_ms": 3600000*24
    }

  };

  List<Map> transactionList;

  List<CircularSegmentEntry> segments;
  num cost;
  num net;
  num netPercent;

  final List colors = [
    Colors.red[400],
    Colors.purple[400],
    Colors.indigo[400],
    Colors.blue[400],
    Colors.teal[400],
    Colors.green[400],
    Colors.lime[400],
    Colors.orange[400],
  ];

  Future<Null>_refresh() async {
    await _getTimelineData();
    widget.makePortfolioDisplay();
    _getBreakdownTotals();
    _makeBreakdownPortions();
    setState(() {});
  }

  _getBreakdownTotals() {
    cost = 0;
    net = 0;
    netPercent = 0;
    value = totalPortfolioStats["value_usd"];

    portfolioMap.forEach((symbol, transactions){
      transactions.forEach((transaction) {
        cost += transaction["quantity"] * transaction["price_usd"];
      });
    });

    net = value - cost;

    if (cost > 0) {
      netPercent = ((value - cost) / cost)*100;
    } else {
      netPercent = 0.0;
    }
  }

  _makeBreakdownPortions() {
    int colorInt = 0;
    segments = [];

    portfolioDisplay.forEach((coin) {
      if (colorInt > (colors.length-1)) {
        colorInt = 1;
      }

      segments.add(new CircularSegmentEntry(
          coin["total_quantity"] * coin["price_usd"],
          colors[colorInt]
      ));
      colorInt += 1;
    });
  }

  List<Map> needed;
  List retrieved;
  Map timedData;
  DateTime oldestPoint = new DateTime.now();
  _getTimelineData() async {
    timedData = {};
    needed = [];
    retrieved = [];

    portfolioMap.forEach((symbol, transactions) {
      num oldest = double.infinity;

      transactions.forEach((transaction) {
        if (transaction["time_epoch"] < oldest) {
          oldest = transaction["time_epoch"];
        }
      });

      needed.add({
        "symbol":symbol,
        "oldest":oldest
      });
    });

    needed.forEach((Map coin) async {
      await _pullData(coin);
      _finalizeTimelineData();
    });
  }

  Future<Null> _pullData(coin) async {
    int msAgo = new DateTime.now().millisecondsSinceEpoch - coin["oldest"];
    int limit = periodOptions[periodSetting]["limit"];
    int periodInMs = limit * periodOptions[periodSetting]["unit_in_ms"];

    if (periodSetting == "All") {
      limit = msAgo ~/ periodOptions[periodSetting]["unit_in_ms"];
    }
    else if (msAgo < periodInMs) {
      limit = limit - ((periodInMs - msAgo) ~/ periodOptions[periodSetting]["unit_in_ms"]);
    }

    var response = await http.get(
        Uri.encodeFull(
            "https://min-api.cryptocompare.com/data/histo"+
                periodOptions[periodSetting]["hist_type"].toString() +
                "?fsym=" + coin["symbol"] +
                "&tsym=USD&limit="+ limit.toString() +
                "&aggregate=" + periodOptions[periodSetting]["aggregate_by"].toString()
        ),
        headers: {"Accept": "application/json"}
    );

    List responseData = json.decode(response.body)["Data"];

    responseData.forEach((point) {
      num averagePrice = (point["open"] + point["close"]) / 2;
      portfolioMap[coin["symbol"]].forEach((transaction) {
        if (transaction["time_epoch"] < point["time"]*1000) {
          if (timedData[point["time"]*1000] == null) {
            timedData[point["time"]*1000] = 0;
          }
          timedData[point["time"]*1000] += transaction["quantity"] * averagePrice;
        }
      });
    });

    retrieved.add(coin["symbol"]);
  }

  _finalizeTimelineData() {
    if (retrieved.length == needed.length) {
      List<int> times = [];
      needed.forEach((e) => times.add(e["oldest"]));

      int oldestInData = times.reduce(min);
      int oldestInRange = new DateTime.now().millisecondsSinceEpoch - periodOptions[periodSetting]["unit_in_ms"] * periodOptions[periodSetting]["limit"];

      if (oldestInData > oldestInRange || periodSetting == "All") {
        oldestPoint = new DateTime.fromMillisecondsSinceEpoch(oldestInData);
      } else {
        oldestPoint = new DateTime.fromMillisecondsSinceEpoch(oldestInRange);
      }

      timelineData = [];
      high = -double.infinity;
      low = double.infinity;
      timedData.forEach((time, amt) {
        timelineData.add(amt.toDouble());
        if (amt > high) {
          high = amt;
        }
        if (amt < low) {
          low = amt;
        }
      });

      num start = timelineData[0] != 0 ? timelineData[0] : 1;
      num end = timelineData.last;
      changePercent = (end-start)/start*100;
      changeAmt = end - start;

      setState(() {});
    }
  }

  _makeTransactionList() {
    transactionList = [];
    portfolioMap.forEach((symbol, transactions) {
      num currentPrice;
      for (Map coin in marketListData) {
        if (coin["symbol"] == symbol) {
          currentPrice = coin["quotes"]["USD"]["price"];
          break;
        }
      }

      transactions.forEach((transaction) => transactionList.add({
        "snapshot": transaction,
        "current_price": currentPrice,
        "symbol": symbol
      }));

      transactionList.sort((a, b) => b["snapshot"]["time_epoch"].compareTo(a["snapshot"]["time_epoch"]));
    });
  }

  Widget _timeline(BuildContext context) {
    print("built timeline");
    _makeTransactionList();
    return RefreshIndicator(
      onRefresh: _refresh,
      child: new CustomScrollView(
          slivers: <Widget>[
            new SliverList(delegate: new SliverChildListDelegate(<Widget>[
              new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text("Portfolio Value", style: Theme.of(context).textTheme.caption),
                            new Row(
                              mainAxisSize: MainAxisSize.max,
                              children: <Widget>[
                                new Text("\$"+ numCommaParseNoDollar(value.toStringAsFixed(2)),
                                    style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)
                                ),
                                new Padding(padding: const EdgeInsets.symmetric(horizontal: 3.0)),
                                timelineData != null ?
                                    new PercentDollarChange(
                                      percent: changePercent,
                                      exact: changeAmt,
                                    )
                                    : new Container(),
                              ],
                            ),
//                          new Padding(padding: const EdgeInsets.symmetric(vertical: 2.5)),
                            timelineData != null ? new Row(
                              children: <Widget>[
                                new Text("High", style: Theme.of(context).textTheme.caption),
                                new Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0)),
                                new Text("\$"+normalizeNum(high),
                                    style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)
                                )
                              ],
                            ) : new Container(),
                            timelineData != null ? new Row(
                              children: <Widget>[
                                new Text("Low", style: Theme.of(context).textTheme.caption),
                                new Padding(padding: const EdgeInsets.symmetric(horizontal: 3.0)),
                                new Text("\$"+normalizeNum(low),
                                    style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)
                                )
                              ],
                            ) : new Container(),
                          ],
                        ),
                        new Card(
                          elevation: 2.0,
                          child: new Container(
                            margin: const EdgeInsets.only(left: 14.0, bottom: 12.0),
                            child: new Column(
//                            crossAxisAlignment: CrossAxisAlignment.end,
                              children: <Widget>[
                                new Row(
                                  children: <Widget>[
                                    new Text(periodSetting, style: Theme.of(context).textTheme.body2.apply(fontWeightDelta: 2, fontSizeFactor: 1.2)),
                                    new Container(
                                      child: new PopupMenuButton(
                                          icon: new Icon(Icons.access_time, color: Theme.of(context).buttonColor),
                                          tooltip: "Select Period",
                                          itemBuilder: (context) {
                                            List<PopupMenuEntry<dynamic>> options = [];
                                            periodOptions.forEach((K, V) => options.add(
                                                new PopupMenuItem(child: new Text(K), value: K)
                                            ));
                                            return options;
                                          },
                                          onSelected: (chosen) {
                                            setState(() {
                                              periodSetting = chosen;
                                              timelineData = null;
                                            });
                                            _getTimelineData();
                                          },
                                      ),
                                    ),
                                  ],
                                ),
                                new Container(
                                  padding: const EdgeInsets.only(right: 14.0),
                                  child: new Text("${oldestPoint.month.toString()}/${oldestPoint.day.toString()}"
                                      "/${oldestPoint.year.toString().substring(2)} ➞ Now",
                                      style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: .9)),
                                ),
                              ],
                            ),
                          ),
                        )
                      ])
              ),

              new Container(
                padding: const EdgeInsets.only(top: 16.0, left: 4.0, right: 2.0),
                height: MediaQuery.of(context).size.height*.6,
                child: timelineData != null ? new Sparkline(
                  data: timelineData,
                  lineGradient: new LinearGradient(colors: [Theme.of(context).buttonColor, Colors.purpleAccent[100]]),
                  enableGridLines: true,
                  gridLineColor: Theme.of(context).dividerColor,
                  gridLineLabelColor: Theme.of(context).hintColor,
                  gridLineAmount: 4,
                ) : new Container(
                    alignment: Alignment.center,
                    child: new CircularProgressIndicator()
                ),
              ),
              new Container(
                padding: const EdgeInsets.only(top: 16.0, left: 8.0, bottom: 4.0),
                child: new Text("All Transactions", style: Theme.of(context).textTheme.caption),
              )
            ])),
            new SliverList(delegate: new SliverChildBuilderDelegate(
              (context, index) => new TransactionItem(
                symbol: transactionList[index]["symbol"],
                currentPrice: transactionList[index]["current_price"],
                snapshot: transactionList[index]["snapshot"],
                refreshPage: () => _refresh(),
              ),
              childCount: transactionList.length
            ))
          ]
      ),
    );
  }
}

class PercentDollarChange extends StatelessWidget {
  PercentDollarChange({this.percent, this.exact});
  final num percent;
  final num exact;

  @override
  Widget build(BuildContext context) {
    return new Text.rich(new TextSpan(children: [
      percent > 0 ?
      new TextSpan(text: "+${percent.toStringAsFixed(2)}%\n",
          style: Theme.of(context).textTheme.body2.apply(
              color: Colors.green, fontSizeFactor: 1.1))
          : new TextSpan(text: "${percent.toStringAsFixed(2)}%\n",
          style: Theme.of(context).textTheme.body2.apply(
              color: Colors.red, fontSizeFactor: 1.1)),
      exact > 0 ?
      new TextSpan(text: "(\$${normalizeNum(exact)})",
          style: Theme.of(context).textTheme.body1.apply(
              color: Colors.green, fontSizeFactor: 1.0))
          : new TextSpan(text: "(\$${normalizeNum(exact)})",
          style: Theme.of(context).textTheme.body1.apply(
              color: Colors.red, fontSizeFactor: 1.0)),
    ]));
  }
}