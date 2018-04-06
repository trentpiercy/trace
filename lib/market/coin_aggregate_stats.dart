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
List historyOHLCVTimeAgg;

String historyOHLCVLimitAmt;
String historyOHLCVAggAmt;

String historyAmt;
String historyType;
String historyTotal;
String historyAgg;

String _high;
String _low;
String _change;

void resetCoinStats() {
  sparkLineData = null;
  historyOHLCV = null;
  historyOHLCVTimeAgg = null;
  historyAmt = "720";
  historyAgg = "2";
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

    Future<Null> getHistorySparkLine() async {
    var response = await http.get(
      Uri.encodeFull("https://min-api.cryptocompare.com/data/histo"+historyType+"?fsym="+widget.snapshot["symbol"]+"&tsym=USD&limit="+(int.parse(historyAmt)-1).toString()+"&aggregate="+historyAgg),
      headers: {"Accept": "application/json"}
    );
    setState(() {
      historyOHLCV = new JsonDecoder().convert(response.body)["Data"];
    });
  }


  Future<Null> getHistoryOHLCV() async {
    var response = await http.get(
        Uri.encodeFull(
            "https://min-api.cryptocompare.com/data/histo"+historyType+
            "?fsym="+widget.snapshot["symbol"]+
            "&tsym=USD&limit="+(int.parse(historyOHLCVLimitAmt)-1).toString()+
            "&aggregate="+historyOHLCVAggAmt
        ),
        headers: {"Accept": "application/json"}
    );
    setState(() {
      historyOHLCVTimeAgg = new JsonDecoder().convert(response.body)["Data"];
    });
  }

  Future<Null> changeOHLCVWidth(String limit, String aggAmt) async {
    historyOHLCVLimitAmt = limit;
    historyOHLCVAggAmt = aggAmt;

    await getHistoryOHLCV();

    //makeOHLCVData();
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

  Future<Null> changeHistory(String type, String amt, String total, String agg) async {
    setState((){
      _high = "0";
      _low = "0";
      _change = "0";

      historyAmt = amt;
      historyType = type;
      historyTotal = total;
      historyAgg = agg;

      sparkLineData = null;
    });
    await getHistorySparkLine();
    _getHL();
    makeSparkLineData();
  }

  void initState() {
    super.initState();
    if (sparkLineData == null) {
      changeHistory(historyType, historyAmt, historyTotal, historyAgg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new RefreshIndicator(
          onRefresh: () => changeHistory(historyType, historyAmt, historyTotal, historyAgg),
          child: new Column(
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(left: 6.0, right: 6.0, top: 5.0, bottom: 1.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text("Price", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                        new Text("\$"+widget.snapshot["price_usd"].toString(), style: Theme.of(context).textTheme.button.apply(fontSizeFactor: 1.4, color: Theme.of(context).accentColor)),
                      ],
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text("Market Cap", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                        new Text(numCommaParse(widget.snapshot["market_cap_usd"].toString()), style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)),
                      ],
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text("24h Volume", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                        new Text(numCommaParse(widget.snapshot["24h_volume_usd"].toString()), style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)),
                      ],
                    ),
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
                          new PopupMenuItem(child: new Text("1h"), value: ["minute", "60", "1h", "1"]),
                          new PopupMenuItem(child: new Text("6h"), value: ["minute", "360", "6h", "1"]),
                          new PopupMenuItem(child: new Text("12h"), value: ["minute", "720", "12h", "1"]),
                          new PopupMenuItem(child: new Text("24h"), value: ["minute", "720", "24h", "2"]),
                          new PopupMenuItem(child: new Text("3D"), value: ["hour", "72", "3d", "1"]),
                          new PopupMenuItem(child: new Text("7D"), value: ["hour", "168", "7d", "1"]),
                          new PopupMenuItem(child: new Text("1M"), value: ["hour", "720", "1m", "1"]),
                          new PopupMenuItem(child: new Text("3M"), value: ["day", "90", "3m", "1"]),
                          new PopupMenuItem(child: new Text("6M"), value: ["day", "180", "6m", "1"]),
                          new PopupMenuItem(child: new Text("1Y"), value: ["day", "365", "1y", "1"]),
                        ],
                        onSelected: (result) {changeHistory(result[0], result[1], result[2], result[3]);},
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
                                      new Text("5m")
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
                                onSelected: (result) {},
                              )
                          ),
                        ],
                      ),
                      new Container(
                        height: 300.0,
                        child: new Center(
                          child: new Text("OHLC GRAPH", style: Theme.of(context).textTheme.title),
                        ),
                      ),
                      new Container(
                        height: 300.0,
                        child: new Center(
                          child: new Text("VOLUME BARS", style: Theme.of(context).textTheme.title),
                        ),
                      ),

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
          lineWidth: 1.8,
          lineGradient: new LinearGradient(
            colors: [Theme.of(context).accentColor, Theme.of(context).buttonColor],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter
          ),
        )
    );
  }
}