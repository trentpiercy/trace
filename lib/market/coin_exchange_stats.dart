import 'package:flutter/material.dart';

import 'package:trace/flutter_candlesticks.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

//import 'package:trace/market/coin_exchanges_list.dart';
import 'package:trace/main.dart';
import 'coin_aggregate_stats.dart';
import 'package:trace/market.dart';


class CoinMarketStats extends StatefulWidget {
  CoinMarketStats({
    Key key,
    this.exchangeData,
    this.e = "CCCAGG",
    this.currentOHLCVWidthSetting = 0,
    this.historyAmt = "720",
    this.historyAgg = "2",
    this.historyType = "minute",
    this.historyTotal = "24h",
    this.toSym = "USD",
  })  :
        super(key: key);

  final exchangeData;
  final e;

  final currentOHLCVWidthSetting;

  final historyAmt;
  final historyType;
  final historyTotal;
  final historyAgg;

  final toSym;

  @override
  CoinMarketStatsState createState() => new CoinMarketStatsState(
    exchangeData: exchangeData,
    e: e,
    currentOHLCVWidthSetting: currentOHLCVWidthSetting,
    historyAmt: historyAmt,
    historyAgg: historyAgg,
    historyType: historyType,
    historyTotal: historyTotal,
    toSym: toSym,
  );
}

class CoinMarketStatsState extends State<CoinMarketStats> {
  CoinMarketStatsState({
    this.exchangeData,
    this.e,
    this.currentOHLCVWidthSetting,
    this.historyAmt ,
    this.historyAgg,
    this.historyType,
    this.historyTotal,
    this.toSym,
  });

  Map exchangeData;
  String price;

  String e;
  List historyOHLCV;

  int currentOHLCVWidthSetting;

  String historyAmt;
  String historyType;
  String historyTotal;
  String historyAgg;

  String _high = "0";
  String _low = "0";
  String _change = "0";

  String toSym;

  final ScrollController _scrollController = new ScrollController();

  Future<Null> getPrice() async {
    var response = await http.get(
        Uri.encodeFull("https://min-api.cryptocompare.com/data/price?fsym="+exchangeData["FROMSYMBOL"]
            +"&tsyms="+toSym
            +"&e="+e),
        headers: {"Accept": "application/json"}
    );
    setState(() {
      price = new JsonDecoder().convert(response.body)[toSym].toString();
    });
  }

  Future<Null> getHistoryOHLCV() async {
    var response = await http.get(
        Uri.encodeFull(
            "https://min-api.cryptocompare.com/data/histo"+OHLCVWidthOptions[historyTotal][currentOHLCVWidthSetting][3]+
                "?fsym="+exchangeData["FROMSYMBOL"]+
                "&tsym=USD&limit="+(OHLCVWidthOptions[historyTotal][currentOHLCVWidthSetting][1] - 1).toString()+
                "&aggregate="+OHLCVWidthOptions[historyTotal][currentOHLCVWidthSetting][2].toString()+
                "&e=" + e
        ),
        headers: {"Accept": "application/json"}
    );
    setState(() {
      historyOHLCV = new JsonDecoder().convert(response.body)["Data"];
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

    _high = highReturn.toString();
    _low = lowReturn.toString();

    var start = historyOHLCV[0]["close"] == 0 ? 1 : historyOHLCV[0]["close"];
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
    getPrice();
    await getHistoryOHLCV();
    _getHL();
  }

  void initState() {
    super.initState();
    if (historyOHLCV == null) {
      changeHistory(historyType, historyAmt, historyTotal, historyAgg);
      price = exchangeData["PRICE"].toString();
      getPrice();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: new AppBar(
          titleSpacing: 0.0,
          elevation: appBarElevation,
          title: new Text(exchangeData["FROMSYMBOL"] + " on " + exchangeData["MARKET"]),
        ),
      ),
      resizeToAvoidBottomPadding: false,
      body: new RefreshIndicator(
        color: Theme.of(context).buttonColor,
        onRefresh: () => changeHistory(historyType, historyAmt, historyTotal, historyAgg),
        child: new ListView(
          children: <Widget>[
            new Container(
              height: MediaQuery.of(context).size.height - (appBarHeight+25.0),
              child: new Column(
                children: <Widget>[
                  new Container(
                    margin: const EdgeInsets.only(left: 12.0, right: 12.0, top: 10.0, bottom: 10.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        new Text("\$"+ price.toString(), style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            new Text("24h Volume", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                            new Text(numCommaParse((exchangeData["VOLUME24HOURTO"]).toString()), style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  new Card(
                    child: new Row(
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
                                              new Text(num.parse(_change) > 0 ? "+" + _change+"%" : _change+"%",
                                                  style: Theme.of(context).primaryTextTheme.body1.apply(
                                                      fontWeightDelta: 1,
                                                      color: num.parse(_change) >= 0 ? Colors.green : Colors.red
                                                  )
                                              )
                                            ],
                                          ),
                                          new Padding(padding: const EdgeInsets.only(bottom: 1.5)),
                                          new Row(
                                            children: <Widget>[
                                              new Text("Candle Width", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                              new Padding(padding: const EdgeInsets.only(right: 3.0)),
                                              new Text(OHLCVWidthOptions[historyTotal][currentOHLCVWidthSetting][0], style: Theme.of(context).primaryTextTheme.body1)
                                            ],
                                          ),
                                        ],
                                      ),
                                      new Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: <Widget>[
                                          new Row(
                                            children: <Widget>[
                                              new Text("High", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                              new Padding(padding: const EdgeInsets.only(right: 3.0)),
                                              new Text("\$"+_high)
                                            ],
                                          ),
                                          new Row(
                                            children: <Widget>[
                                              new Text("Low", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                                              new Padding(padding: const EdgeInsets.only(right: 3.0)),
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

                  new Padding(padding: const EdgeInsets.only(top: 10.0)),

                  new Flexible(
                    child: historyOHLCV != null ? new Container(
                      padding: const EdgeInsets.only(left: 2.0, right: 0.0),
                      child: new OHLCVGraph(
                        data: historyOHLCV,
                        enableGridLines: true,
                        gridLineColor: Theme.of(context).dividerColor,
                        gridLineLabelColor: Theme.of(context).hintColor,
                        gridLineAmount: 5,
                        volumeProp: 0.2,
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
    );
  }
}