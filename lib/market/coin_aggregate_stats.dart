import 'package:flutter/material.dart';
import 'package:trace/flutter_candlesticks.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trace/main.dart';
import 'package:trace/market/coin_exchanges_list.dart';


Map OHLCVWidthOptions = {
  "1h":[["1m", 60, 1, "minute"], ["2m", 30, 2, "minute"], ["3m", 20, 3, "minute"]],
  "6h":[["5m", 72, 5, "minute"], ["10m", 36, 10, "minute"], ["15m", 24, 15, "minute"]],
  "12h":[["10m", 72, 10, "minute"], ["15m", 48, 15, "minute"], ["30m", 24, 30, "minute"]],
  "24h":[["15m", 96, 15, "minute"], ["30m", 48, 30, "minute"], ["1h", 24, 1, "hour"]],
  "3D":[["1h", 72, 1, "hour"], ["2h", 36, 2, "hour"], ["4h", 18, 4, "hour"]],
  "7D":[["2h", 86, 2, "hour"], ["4h", 42, 4, "hour"], ["6h", 28, 6, "hour"]],
  "1M":[["12h", 60, 12, "hour"], ["1D", 30, 1, "day"]],
  "3M":[["1D", 90, 1, "day"], ["2D", 45, 2, "day"], ["3D", 30, 3, "day"]],
  "6M":[["2D", 90, 2, "day"], ["3D", 60, 3, "day"], ["7D", 26, 7, "day"]],
  "1Y":[["7D", 52, 7, "day"], ["14D", 26, 14, "day"]],
};


//TODO: have tabs handle data
//TODO: and just clean up all this garbage

Map generalStats;

List historyOHLCV;

String _high = "0";
String _low = "0";
String _change = "0";


int currentOHLCVWidthSetting;

String historyAmt;
String historyType;
String historyTotal;
String historyAgg;


void resetCoinStats() {
  generalStats = null;

  historyOHLCV = null;

  _high = "0";
  _low = "0";
  _change = "0";

  currentOHLCVWidthSetting = 0;
  historyAmt = "720";
  historyAgg = "2";
  historyType = "minute";
  historyTotal = "24h";
}

void resetExchangeData() {
  exchangeData = null;
}

class AggregateStats extends StatefulWidget {
  AggregateStats({
    Key key,
    this.id,
    this.symbol,
    this.toSym = "USD",
  })  : assert(id != null),
        assert(symbol != null),
        super(key: key);

  final String id;
  final String symbol;
  final String toSym;

  @override
  AggregateStatsState createState() => new AggregateStatsState();
}

class AggregateStatsState extends State<AggregateStats> {
  _shortenText(input) {
    return num.parse(input.toStringAsPrecision(9)).toString();
  }

  Future<Null> getGeneralStats() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/ticker/"+ widget.id),
        headers: {"Accept": "application/json"}
    );
    setState(() {
      generalStats = new JsonDecoder().convert(response.body)["data"]["quotes"]["USD"];
    });
  }


  Future<Null> getHistoryOHLCV() async {
    var response = await http.get(
        Uri.encodeFull(
            "https://min-api.cryptocompare.com/data/histo"+OHLCVWidthOptions[historyTotal][currentOHLCVWidthSetting][3]+
            "?fsym="+widget.symbol+
            "&tsym=USD&limit="+(OHLCVWidthOptions[historyTotal][currentOHLCVWidthSetting][1] - 1).toString()+
            "&aggregate="+OHLCVWidthOptions[historyTotal][currentOHLCVWidthSetting][2].toString()
        ),
        headers: {"Accept": "application/json"}
    );
    setState(() {
      historyOHLCV = new JsonDecoder().convert(response.body)["Data"];

      if (historyOHLCV == null) {
        historyOHLCV = [];
      }

    });
  }

  Future<Null> changeOHLCVWidth(int currentSetting) async {
    currentOHLCVWidthSetting = currentSetting;
    historyOHLCV = null;
    getHistoryOHLCV();
  }

  void _getHL() {
    num highReturn = -double.infinity;
    num lowReturn = double.infinity;

    for (var i in historyOHLCV) {
      if (i["high"] > highReturn) {
        highReturn = i["high"].toDouble();
      }
      if (i["low"] < lowReturn) {
        lowReturn = i["low"].toDouble();
      }
    }

    _high = _shortenText(highReturn);
    _low = _shortenText(lowReturn);

    var start = historyOHLCV[0]["open"] == 0 ? 1 : historyOHLCV[0]["open"];
    var end = historyOHLCV.last["close"];
    var changePercent = (end-start)/start*100;
    _change = changePercent.toString().substring(0, changePercent > 0 ? 5 : 6);
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

      historyOHLCV = null;

    });
    getGeneralStats();
    await getHistoryOHLCV();
    _getHL();
  }

  void initState() {
    super.initState();
    if (historyOHLCV == null || generalStats == null) {
      changeHistory(historyType, historyAmt, historyTotal, historyAgg);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        resizeToAvoidBottomPadding: false,
        body: new RefreshIndicator(
          onRefresh: () => changeHistory(historyType, historyAmt, historyTotal, historyAgg),
          child: new ListView(
            children: <Widget>[
              new Container(
                height: MediaQuery.of(context).size.height - (appBarHeight+75.0),
                child: new Column(
                  children: <Widget>[
                    new Container(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0, bottom: 4.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Text("\$"+ (generalStats != null ? generalStats["price"].toString() : "0"), style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)),
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("Market Cap", style: Theme.of(context).textTheme.caption),
                                  new Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
                                  new Text("24h Volume", style: Theme.of(context).textTheme.caption),
                                ],
                              ),
                              new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  new Text(generalStats != null ? numCommaParse(generalStats["market_cap"].toString()) : "0", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)),
                                  new Text(generalStats != null ? numCommaParse(generalStats["volume_24h"].toString()) : "0", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)),
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    new Card(
                      elevation: 2.0,
                      child: new Row(
                        children: <Widget>[
                          new Flexible(
                            child: new Container(
//                                color: Theme.of(context).canvasColor,
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
                                                new Text(historyTotal, style: Theme.of(context).textTheme.body2.apply(fontWeightDelta: 2)),
                                                new Padding(padding: const EdgeInsets.only(right: 4.0)),
                                                new Text(num.parse(_change) > 0 ? "+" + _change+"%" : _change+"%",
                                                    style: Theme.of(context).primaryTextTheme.body2.apply(
                                                        color: num.parse(_change) >= 0 ? Colors.green : Colors.red
                                                    )
                                                )
                                              ],
                                            ),
                                            new Row(
                                              children: <Widget>[
                                                new Text("Candle Width", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                                new Padding(padding: const EdgeInsets.only(right: 2.0)),
                                                new Text(OHLCVWidthOptions[historyTotal][currentOHLCVWidthSetting][0], style: Theme.of(context).textTheme.body2.apply(fontWeightDelta: 2))
                                              ],
                                            ),
                                          ],
                                        ),
                                        new Row(
//                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            new Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: <Widget>[
                                                new Text("High", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                                new Text("Low", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                              ],
                                            ),
                                            new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                                            new Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: <Widget>[
                                                new Text("\$"+_high),
                                                new Text("\$"+_low)
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
                                tooltip: "Select Width",
                                icon: new Icon(Icons.swap_horiz, color: Theme.of(context).buttonColor),
                                itemBuilder: (BuildContext context) {
                                  List<PopupMenuEntry<dynamic>> options = [];
                                  for (int i = 0; i < OHLCVWidthOptions[historyTotal].length; i++) {
                                    options.add(new PopupMenuItem(child: new Text(OHLCVWidthOptions[historyTotal][i][0]), value: i));
                                  }
                                  return options;
                                },
                                onSelected: (result) {
                                  changeOHLCVWidth(result);
                                },
                              )
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
                                  new PopupMenuItem(child: new Text("3D"), value: ["hour", "72", "3D", "1"]),
                                  new PopupMenuItem(child: new Text("7D"), value: ["hour", "168", "7D", "1"]),
                                  new PopupMenuItem(child: new Text("1M"), value: ["hour", "720", "1M", "1"]),
                                  new PopupMenuItem(child: new Text("3M"), value: ["day", "90", "3M", "1"]),
                                  new PopupMenuItem(child: new Text("6M"), value: ["day", "180", "6M", "1"]),
                                  new PopupMenuItem(child: new Text("1Y"), value: ["day", "365", "1Y", "1"]),
                                ],
                                onSelected: (result) {changeHistory(result[0], result[1], result[2], result[3]);},
                              )
                          ),
                        ],
                      ),
                    ),
                    new Flexible(
                      child: historyOHLCV != null ? new Container(
                        padding: const EdgeInsets.only(left: 2.0, right: 1.0, top: 10.0),
                        child: historyOHLCV.isEmpty != true ? new OHLCVGraph(
                          data: historyOHLCV,
                          enableGridLines: true,
                          gridLineColor: Theme.of(context).dividerColor,
                          gridLineLabelColor: Theme.of(context).hintColor,
                          gridLineAmount: 5,
                          volumeProp: 0.2,
                        ) : new Container(
                          padding: const EdgeInsets.all(30.0),
                          alignment: Alignment.topCenter,
                          child: new Text("No OHLCV data found :(", style: Theme.of(context).textTheme.caption),
                        ),
                      ) : new Container(
                        child: new Center(
                          child: new CircularProgressIndicator(),
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          )
        ),
        bottomNavigationBar: new BottomAppBar(
          elevation: appBarElevation,
          child: generalStats != null
            ? new QuickPercentChangeBar(snapshot: generalStats)
            : new Container(
              height: 0.0,
            ),
        ),
    );
  }
}


class QuickPercentChangeBar extends StatelessWidget {
  QuickPercentChangeBar({this.snapshot});
  final snapshot;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.only(left: 6.0, right: 6.0, bottom: 3.0, top: 3.0),
      color: Theme.of(context).primaryColor,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("1h", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
              new Padding(padding: const EdgeInsets.only(right: 3.0)),
              new Text(
                  snapshot["percent_change_1h"] >= 0 ? "+"+snapshot["percent_change_1h"].toString()+"%" : snapshot["percent_change_1h"].toString()+"%",
                  style: Theme.of(context).primaryTextTheme.body2.apply(
                      color: snapshot["percent_change_1h"] >= 0 ? Colors.green : Colors.red
                  )
              )
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("24h", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
              new Padding(padding: const EdgeInsets.only(right: 3.0)),
              new Text(
                  snapshot["percent_change_24h"] >= 0 ? "+"+snapshot["percent_change_24h"].toString()+"%" : snapshot["percent_change_24h"].toString()+"%",
                  style: Theme.of(context).primaryTextTheme.body2.apply(
                      color: snapshot["percent_change_24h"] >= 0 ? Colors.green : Colors.red
                  )
              )
            ],
          ),
          new Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Text("7D", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
              new Padding(padding: const EdgeInsets.only(right: 3.0)),
              new Text(
                  snapshot["percent_change_7d"] >= 0 ? "+"+snapshot["percent_change_7d"].toString()+"%" : snapshot["percent_change_7d"].toString()+"%",
                  style: Theme.of(context).primaryTextTheme.body2.apply(
                      color: snapshot["percent_change_7d"] >= 0 ? Colors.green : Colors.red
                  )
              ),
            ],
          )
        ],
      ),
    );
  }
}