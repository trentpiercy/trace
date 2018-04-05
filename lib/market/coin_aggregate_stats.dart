import 'package:flutter/material.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:charts_flutter/flutter.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trace/main.dart';
import 'package:trace/market.dart';
import 'package:trace/market/coin_markets_list.dart';


class AggregateStats extends StatefulWidget {
  AggregateStats({this.snapshot});
  final snapshot;

  @override
  AggregateStatsState createState() => new AggregateStatsState();
}

List sparkLineData;
List historyOHLCV;
String historyAmt = "1420";
String historyType = "minute";
String historyTotal = "24h";

String _high;
String _low;
String _change = "0";

void resetCoinStats() {
  sparkLineData = null;
  historyOHLCV = null;
  historyAmt = "1420";
  historyType = "minute";
  historyTotal = "24h";

  _high = null;
  _low = null;
  _change = "0";

  exchangeData = null;
  toSym = "USD";
}

class AggregateStatsState extends State<AggregateStats> {
  final ScrollController _scrollController = new ScrollController();

  Future<Null> getHistoryOHLCV(String type, String amt) async {
    var response = await http.get(
      Uri.encodeFull("https://min-api.cryptocompare.com/data/histo"+type+"?fsym="+widget.snapshot["symbol"]+"&tsym=USD&limit="+(int.parse(amt)-1).toString()),
      headers: {"Accept": "application/json"}
    );
    setState(() {
      historyOHLCV = new JsonDecoder().convert(response.body)["Data"];
    });
  }

  void _getHL() {
    var highReturn = 0;
    for (var i in historyOHLCV) {
      if (i["high"] > highReturn) {
        highReturn = i["high"];
      }
    }
    _high = highReturn.toString();

    var lowReturn = double.infinity;
    for (var i in historyOHLCV) {
      if (i["low"] < lowReturn) {
        lowReturn = i["low"];
      }
    }
    _low = lowReturn.toString();

    var start = historyOHLCV[0]["open"];
    var end = historyOHLCV[int.parse(historyAmt)-1]["close"];

    var changePercent = (end-start)/start*100;

    _change = changePercent.toString().substring(0, changePercent > 0 ? 5 : 6);
  }

  Future<Null> makeSparkLineData() async {
    List returnData = [];

    for (var i in historyOHLCV) {
      returnData.add(double.parse(i["close"].toString()));
    }

    setState(() {
      sparkLineData = returnData;
    });
  }

  Future<Null> changeHistory(String type, String amt, String total) async {
    setState((){
      _high = "0";
      _low = "0";
      _change = "0";

      historyAmt = amt;
      historyType = type;
      historyTotal = total;

      sparkLineData = null;
    });
    await getHistoryOHLCV(type, amt);
    _getHL();
    makeSparkLineData();
  }

  void initState() {
    super.initState();
    if (sparkLineData == null) {
      changeHistory(historyType, historyAmt, historyTotal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new RefreshIndicator(
          onRefresh: () => changeHistory(historyType, historyAmt, historyTotal),
          child: new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 5.0, bottom: 1.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text("Price", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                        new Text("\$"+widget.snapshot["price_usd"].toString(), style: Theme.of(context).textTheme.button.apply(fontSizeFactor: 1.3, color: Theme.of(context).accentColor)),
                      ],
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text("24h Volume", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                        new Text(numCommaParse(widget.snapshot["24h_volume_usd"].toString()), style: Theme.of(context).textTheme.button),
                      ],
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text("Market Cap", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                        new Text(numCommaParse(widget.snapshot["market_cap_usd"].toString()), style: Theme.of(context).textTheme.button),
                      ],
                    )
                  ],
                ),
              ),
              new Row(
                children: <Widget>[
                  new Flexible(
                    child: new Container(
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.all(6.0),
                        child: new Column(
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Row(
                                      children: <Widget>[
                                        new Text("Period", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                        new Padding(padding: const EdgeInsets.only(right: 3.0)),
                                        new Text(historyTotal, style: Theme.of(context).textTheme.button),
                                        new Padding(padding: const EdgeInsets.only(right: 4.0)),
                                        new Text(num.parse(_change) > 0 ? "+$_change%" : "$_change%",
                                            style: Theme.of(context).primaryTextTheme.body1.apply(
                                                fontWeightDelta: 1,
                                                color: num.parse(_change) >= 0 ? Colors.green : Colors.red
                                            )
                                        )
                                      ],
                                    ),
                                    new Padding(padding: const EdgeInsets.only(bottom: 1.5)),
                                    new Text("CCCAGG Data Set", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor, fontSizeFactor: 0.7)),
                                  ],
                                ),
                                new Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    new Row(
                                      children: <Widget>[
                                        new Text("High", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                        new Padding(padding: const EdgeInsets.only(right: 3.0)),
                                        new Text("\$$_high")
                                      ],
                                    ),
                                    new Row(
                                      children: <Widget>[
                                        new Text("Low", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                        new Padding(padding: const EdgeInsets.only(right: 3.0)),
                                        new Text("\$$_low")
                                      ],
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        )
                    ),
                  ),
                  new Container(
                      child: new PopupMenuButton(
                        tooltip: "Select Period",
                        icon: new Icon(Icons.access_time, color: Theme.of(context).buttonColor),
                        itemBuilder: (BuildContext context) => [
                          new PopupMenuItem(child: new Text("1h"), value: ["minute", "60", "1h"]),
                          new PopupMenuItem(child: new Text("6h"), value: ["minute", "360", "6h"]),
                          new PopupMenuItem(child: new Text("12h"), value: ["minute", "720", "12h"]),
                          new PopupMenuItem(child: new Text("24h"), value: ["minute", "1420", "24h"]),
                          new PopupMenuItem(child: new Text("3d"), value: ["hour", "72", "3d"]),
                          new PopupMenuItem(child: new Text("7d"), value: ["hour", "168", "7d"]),
                          new PopupMenuItem(child: new Text("1m"), value: ["hour", "720", "1m"]),
                          new PopupMenuItem(child: new Text("3m"), value: ["hour", "1420", "3m"]),
                          new PopupMenuItem(child: new Text("6m"), value: ["day", "180", "6m"]),
                          new PopupMenuItem(child: new Text("1y"), value: ["day", "365", "1y"]),
                        ],
                        onSelected: (result) {changeHistory(result[0], result[1], result[2]);},
                      )
                  ),
                ],
              ),
              new Flexible(
                child: new SingleChildScrollView(
                  controller: _scrollController,
                  child: new Column(
                    children: <Widget>[
                      sparkLineData == null ? new Container(height: MediaQuery.of(context).size.height * 0.4) : new _SparkLine(data: sparkLineData), // TODO: loading symbol instead of empty container
                      new Row(
                        children: <Widget>[
                          new Flexible(
                            child: new Container(
                              color: Theme.of(context).cardColor,
                              padding: const EdgeInsets.all(6.0),
                              child: new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Row(
                                    children: <Widget>[
                                      new Text("Candlestick Width", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                      new Padding(padding: const EdgeInsets.only(right: 3.0)),
                                      new Text("30 Minutes")
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          new Container(
                              child: new PopupMenuButton( // TODO: make exist
                                tooltip: "Select Width",
                                icon: new Icon(Icons.swap_horiz, color: Theme.of(context).buttonColor),
                                itemBuilder: (BuildContext context) => [

                                ],
                                onSelected: (result) {changeHistory(result[0], result[1], result[2]);},
                              )
                          ),
                        ],
                      ),
                      new Container(
                        height: 500.0,
                      ),
                      new Text("OHLC GRAPH", style: Theme.of(context).textTheme.title),
                      new Text("VOLUME BARS", style: Theme.of(context).textTheme.title),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      bottomNavigationBar: new BottomAppBar(
        elevation: bottomAppBarElevation,
        child: new QuickPercentChangeBar(snapshot: widget.snapshot, bgColor: Theme.of(context).canvasColor),
      ),
    );
  }
}

class QuickPercentChangeBar extends StatelessWidget {
  QuickPercentChangeBar({this.snapshot, this.bgColor});
  final snapshot;
  final bgColor;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 3.0, top: 3.0),
      color: bgColor != null ? bgColor : Theme.of(context).canvasColor,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("1H", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
              new Padding(padding: const EdgeInsets.only(right: 3.0)),
              new Text(
                  num.parse(snapshot["percent_change_1h"]) >= 0 ? "+"+snapshot["percent_change_1h"]+"%" : snapshot["percent_change_1h"]+"%",
                  style: Theme.of(context).primaryTextTheme.body1.apply(fontWeightDelta: 1,
                      color: num.parse(snapshot["percent_change_1h"]) >= 0 ? Colors.green : Colors.red
                  )
              ),
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("24H", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
              new Padding(padding: const EdgeInsets.only(right: 3.0)),
              new Text(
                  num.parse(snapshot["percent_change_24h"]) >= 0 ? "+"+snapshot["percent_change_24h"]+"%" : snapshot["percent_change_24h"]+"%",
                  style: Theme.of(context).primaryTextTheme.body1.apply(fontWeightDelta: 1,
                      color: num.parse(snapshot["percent_change_24h"]) >= 0 ? Colors.green : Colors.red
                  )
              ),
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("7D", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
              new Padding(padding: const EdgeInsets.only(right: 3.0)),
              new Text(
                  num.parse(snapshot["percent_change_7d"]) >= 0 ? "+"+snapshot["percent_change_7d"]+"%" : snapshot["percent_change_7d"]+"%",
                  style: Theme.of(context).primaryTextTheme.body1.apply(fontWeightDelta: 1,
                      color: num.parse(snapshot["percent_change_7d"]) >= 0 ? Colors.green : Colors.red
                  )
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _SparkLine extends StatelessWidget {
  _SparkLine({this.data});
  final List data;

  @override
  Widget build(BuildContext context) {
    return new Container(
        height: MediaQuery.of(context).size.height * 0.4,
        padding: const EdgeInsets.all(8.0),
        child: new Sparkline(
          data: data,
          lineWidth: 1.5,
          lineGradient: new LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Theme.of(context).accentColor, Theme.of(context).buttonColor]
          ),
        )
    );
  }
}