import 'package:flutter/material.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:charts_flutter/flutter.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trace/main.dart';
import 'package:trace/market.dart';


class AggregateStats extends StatefulWidget {
  AggregateStats({this.snapshot});
  final snapshot;

  @override
  AggregateStatsState createState() => new AggregateStatsState();
}

List sparkLineData;

class AggregateStatsState extends State<AggregateStats> {
  List historyOHLCV;
  String historyAmt = "1420";
  String historyType = "minute";
  String historyTotal = "24h";

  Future<Null> getHistoryOHLCV(String type, String amt) async {
    var response = await http.get(
      Uri.encodeFull("https://min-api.cryptocompare.com/data/histo"+type+"?fsym="+widget.snapshot["symbol"]+"&tsym=USD&limit="+amt),
    );
    setState(() {
      historyOHLCV = new JsonDecoder().convert(response.body)["Data"];
    });
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

  void changeHistory(String type, String amt, String total) async {
    setState((){
      historyAmt = amt;
      historyType = type;
      historyTotal = total;
      sparkLineData = null;
    });
    await getHistoryOHLCV(type, amt);
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
        floatingActionButton: new FloatingActionButton(
          elevation: appBarElevation,
          onPressed: null,
          backgroundColor: Theme.of(context).buttonColor,
          child: new PopupMenuButton(
            icon: new Icon(Icons.access_time),
              itemBuilder: (BuildContext context) => [
                new PopupMenuItem(child: new Text("1h"), value: ["minute", "60", "1h"]),
                new PopupMenuItem(child: new Text("6h"), value: ["minute", "360", "6h"]),
                new PopupMenuItem(child: new Text("12h"), value: ["minute", "720", "12h"]),
                new PopupMenuItem(child: new Text("24h"), value: ["minute", "1420", "24h"]),
                new PopupMenuItem(child: new Text("3d"), value: ["hour", "72", "3d"]),
                new PopupMenuItem(child: new Text("7d"), value: ["hour", "168", "7d"]),
                new PopupMenuItem(child: new Text("1m"), value: ["hour", "720", "1m"]),
                new PopupMenuItem(child: new Text("3m"), value: ["day", "90", "3m"]),
                new PopupMenuItem(child: new Text("6m"), value: ["day", "180", "6m"]),
                new PopupMenuItem(child: new Text("1y"), value: ["day", "365", "1y"]),
              ],
            onSelected: (result) {changeHistory(result[0], result[1], result[2]);},
          )
        ),
        body: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                new Container(
                  decoration: new BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: new Border.all(width: 0.0, color: Theme.of(context).cardColor),
                      borderRadius: new BorderRadius.circular(8.0)
                  ),
                  margin: const EdgeInsets.all(6.0),
                  padding: const EdgeInsets.all(6.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text("1h", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Padding(padding: const EdgeInsets.only(right: 3.0)),
                          new Text(
                              num.parse(widget.snapshot["percent_change_1h"]) >= 0 ? "+"+widget.snapshot["percent_change_1h"]+"%" : widget.snapshot["percent_change_1h"]+"%",
                              style: Theme.of(context).primaryTextTheme.body1.apply(fontWeightDelta: 1,
                                  color: num.parse(widget.snapshot["percent_change_1h"]) >= 0 ? Colors.green : Colors.red
                              )
                          ),
                        ],
                      ),
                      new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text("24h", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Padding(padding: const EdgeInsets.only(right: 3.0)),
                          new Text(
                              num.parse(widget.snapshot["percent_change_24h"]) >= 0 ? "+"+widget.snapshot["percent_change_24h"]+"%" : widget.snapshot["percent_change_24h"]+"%",
                              style: Theme.of(context).primaryTextTheme.body1.apply(fontWeightDelta: 1,
                                  color: num.parse(widget.snapshot["percent_change_24h"]) >= 0 ? Colors.green : Colors.red
                              )
                          ),
                        ],
                      ),
                      new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text("7d", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Padding(padding: const EdgeInsets.only(right: 3.0)),
                          new Text(
                              num.parse(widget.snapshot["percent_change_7d"]) >= 0 ? "+"+widget.snapshot["percent_change_7d"]+"%" : widget.snapshot["percent_change_7d"]+"%",
                              style: Theme.of(context).primaryTextTheme.body1.apply(fontWeightDelta: 1,
                                  color: num.parse(widget.snapshot["percent_change_7d"]) >= 0 ? Colors.green : Colors.red
                              )
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                new Container(
//                  decoration: new BoxDecoration(
//                    color: Theme.of(context).cardColor,
//                    border: new Border.all(width: 0.0, color: Theme.of(context).cardColor),
//                    borderRadius: new BorderRadius.circular(8.0)
//                  ),
//                  margin: const EdgeInsets.all(6.0),
                  padding: const EdgeInsets.only(left: 6.0, right: 6.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("Price", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                          new Text("\$"+widget.snapshot["price_usd"].toString(), style: Theme.of(context).textTheme.button.apply(fontSizeFactor: 1.5, color: Theme.of(context).accentColor)),
                          new Text("Circulating Supply", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                          new Text(numCommaParseNoDollar(widget.snapshot["available_supply"].toString()), style: Theme.of(context).textTheme.button),
                        ],
                      ),
                      new Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("Market Cap", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                          new Text(numCommaParse(widget.snapshot["market_cap_usd"].toString()), style: Theme.of(context).textTheme.button),
                          new Text("24h Volume", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                          new Text(numCommaParse(widget.snapshot["24h_volume_usd"].toString()), style: Theme.of(context).textTheme.button),
                        ],
                      ),
                    ],
                  ),
                ),
                new Padding(padding: const EdgeInsets.only(bottom: 2.0)),
                new Container(
                  decoration: new BoxDecoration(
                      color: Theme.of(context).cardColor,
                      border: new Border.all(width: 0.0, color: Theme.of(context).cardColor),
                      borderRadius: new BorderRadius.circular(8.0)
                  ),
                  margin: const EdgeInsets.all(6.0),
                  padding: const EdgeInsets.all(6.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text("Period", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Padding(padding: const EdgeInsets.only(right: 3.0)),
                          new Text(historyTotal)
                        ],
                      ),
                      new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text("Point Distance", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Padding(padding: const EdgeInsets.only(right: 3.0)),
                          new Text("1 $historyType")
                        ],
                      ),
                    ],
                  ),
                ),
                sparkLineData == null ? new Container() : new _SparkLine(data: sparkLineData),
              ],
            )
        )
    );
  }
}

class _SparkLine extends StatelessWidget {
  _SparkLine({this.data});
  final List data;

  @override
  Widget build(BuildContext context) {
    return new Container(
//      color: Theme.of(context).cardColor,
        height: MediaQuery.of(context).size.height * 0.5,
        padding: const EdgeInsets.all(4.0),
//      margin: const EdgeInsets.all(4.0),
        child: new Sparkline(
          data: data,
          lineWidth: 2.0,
          lineGradient: new LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Theme.of(context).buttonColor, Theme.of(context).accentColor]
          ),
        )
    );
  }
}