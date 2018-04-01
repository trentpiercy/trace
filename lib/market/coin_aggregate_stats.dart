import 'package:flutter/material.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:charts_flutter/flutter.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trace/market.dart';


class AggregateStats extends StatefulWidget {
  AggregateStats({this.snapshot});
  final snapshot;

  @override
  AggregateStatsState createState() => new AggregateStatsState();
}

class AggregateStatsState extends State<AggregateStats> {
  String historyLength = "24h";
  String historyOHLCVType = "minute";
  String historyOHLCVAmt = "1420";

  void _setHistoryStrings(length) {
    historyLength = length;

    switch (historyLength) {
      case "1h":
        historyOHLCVType = "minute";
        historyOHLCVAmt = "60";
        break;
      case "6h":
        historyOHLCVType = "minute";
        historyOHLCVAmt = "360";
        break;
      case "12h":
        historyOHLCVType = "minute";
        historyOHLCVAmt = "720";
        break;
      case "24h":
        historyOHLCVType = "minute";
        historyOHLCVAmt = "1420";
        break;
      case "3d":
        historyOHLCVType = "hour";
        historyOHLCVAmt = "168";
        break;
      case "7d":
        historyOHLCVType = "hour";
        historyOHLCVAmt = "168";
        break;
      case "1m":
        historyOHLCVType = "hour";
        historyOHLCVAmt = "720";
        break;
      case "3m":
        historyOHLCVType = "day";
        historyOHLCVAmt = "90";
        break;
      case "6m":
        historyOHLCVType = "day";
        historyOHLCVAmt = "180";
        break;
      case "1y":
        historyOHLCVType = "day";
        historyOHLCVAmt = "365";
        break;
    }
  }

  List historyOHLCV;
  Future<Null> getHistoryOHLCV(String type, String amt) async {
    var response = await http.get(
      Uri.encodeFull("https://min-api.cryptocompare.com/data/histo"+type+"?fsym="+widget.snapshot["symbol"]+"&tsym=USD&limit="+amt),
    );
    setState(() {
      historyOHLCV = new JsonDecoder().convert(response.body)["Data"];
    });
  }

  List sparkLineData;
  Future<Null> getSparkLineData() async {
    if (historyOHLCV == null) {
      await getHistoryOHLCV(historyOHLCVType, historyOHLCVAmt);
    }
    List returnData = [];
    for (var i in historyOHLCV) {
      if (i["close"] != 0) {
        returnData.add(i["close"]);
      }
    }
    setState(() {
      sparkLineData = returnData;
    });
  }

  void initState() {
    super.initState();
    if (sparkLineData == null) {
      getSparkLineData();
    }
  }

  bool showFAB = true;
  void _showFAB() {
    setState(() {showFAB = true;});
  }
  void _hideFAB() {
    setState(() {showFAB = false;});
  }

  void _openHistorySettings() {
    _hideFAB();
    showBottomSheet(context: context, builder: (BuildContext context) {
      TextStyle _style = Theme.of(context).textTheme.button.apply(fontSizeFactor: 1.25);

      return new Container(
        padding: const EdgeInsets.all(8.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
//                new OutlineButton(
//                    onPressed: _showFAB,
//                    shape: new StadiumBorder(),
//                    child: new Text("1h", style: _style),
//                ),
//                new OutlineButton(
//                    onPressed: _showFAB,
//                    shape: new StadiumBorder(),
//                    child: new Text("6h", style: _style)
//                ),
//                new OutlineButton(
//                    onPressed: _showFAB,
//                    shape: new StadiumBorder(),
//                    child: new Text("12h", style: _style)
//                ),
//                new OutlineButton(
//                    onPressed: _showFAB,
//                    shape: new StadiumBorder(),
//                    child: new Text("24h", style: _style)
//                ),
              ],
            ),
            new Slider(
                value: 1.0,
                max: 10.0,
                divisions: 10,
                onChanged: null
            )
          ],
        ),
      );
    }).closed.whenComplete((){_showFAB();});
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        floatingActionButton: showFAB ? new OutlineButton(
          borderSide: new BorderSide(color: Theme.of(context).accentColor, width: 3.0),
          onPressed: _openHistorySettings,
//        elevation: appBarElevation,
//        backgroundColor: Theme.of(context).buttonColor,
          child: new Text(historyLength, style: DefaultTextStyle.of(context).style.apply(color: Theme.of(context).accentColor, fontSizeFactor: 1.25)),
        ) : new Container(),
        body: new SingleChildScrollView(
            child: new Column(
              children: <Widget>[
                new Container(
                  color: Theme.of(context).cardColor,
                  padding: const EdgeInsets.all(4.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("Price", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Text("\$"+widget.snapshot["price_usd"].toString(), style: Theme.of(context).textTheme.button),
                          new Text("Circulating Supply", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Text(numCommaParseNoDollar(widget.snapshot["available_supply"].toString()), style: Theme.of(context).textTheme.button),
                        ],
                      ),
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
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
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          new Text("Market Cap", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Text(numCommaParse(widget.snapshot["market_cap_usd"].toString()), style: Theme.of(context).textTheme.button),
                          new Text("24h Volume", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                          new Text(numCommaParse(widget.snapshot["24h_volume_usd"].toString()), style: Theme.of(context).textTheme.button),
                        ],
                      ),
                    ],
                  ),
                ),
                new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
//            new Container(
//              color: Theme.of(context).cardColor,
//              padding: const EdgeInsets.all(4.0),
//              alignment: Alignment.center,
//              child: new GestureDetector(
//                child: new Text("30d", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).buttonColor, fontSizeFactor: 1.5)),
//              )
//            ),
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
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Theme.of(context).primaryColor, Theme.of(context).accentColor]
          ),
        )
    );
  }
}