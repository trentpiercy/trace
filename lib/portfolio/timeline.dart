import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import '../main.dart';

class PortfolioTimeline extends StatefulWidget {
  PortfolioTimeline(this.totalStats);
  final Map totalStats;

  @override
  PortfolioTimelineState createState() => new PortfolioTimelineState();
}

class PortfolioTimelineState extends State<PortfolioTimeline> {
  redGreenParsePercent(context, input, double fontSize) {
    return new Text(
        num.parse(input) >= 0 ? "+"+input+"%" : input+"%",
        style: Theme.of(context).primaryTextTheme.body1.apply(
          color: num.parse(input) >= 0 ? Colors.green : Colors.red,
          fontSizeFactor: fontSize,
        )
    );
  }

  num value = 0;

  List<double> timelineData;
  num high = 0;
  num low = 0;
  num changePercent = 0;
  String periodSetting = "7D";
  bool pullStarted = false;

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

  };

  Map timedData;

  _getTimelineData() async {
    pullStarted = true;
    timedData = {};

    List<Map> needed = [];
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

    for (Map coin in needed) {
      await _pullData(coin);
    }

    print("timedData FINAL: " + timedData.toString());

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

    pullStarted = false;
    setState(() {});
  }

  Future<Null> _pullData(coin) async {
    //TODO: make this pull all data at once
    /// can be done with .forEach(() async {})
    /// but doesn't wait for all data before returning

    int limit = periodOptions[periodSetting]["limit"];
    int msAgo = new DateTime.now().millisecondsSinceEpoch - coin["oldest"];
    int periodInMs =
        limit * periodOptions[periodSetting]["unit_in_ms"];
    if (msAgo < periodInMs) {
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

    print("ran on " + coin["symbol"]);
    print("timedData: " + timedData.toString());

  }


  @override
  void initState() {
    super.initState();
    value = widget.totalStats["value_usd"];
    if (timelineData == null && pullStarted != true) {
      _getTimelineData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new CustomScrollView(
        slivers: <Widget>[
          new SliverList(delegate: new SliverChildListDelegate(<Widget>[
            new Container(
                padding: const EdgeInsets.all(10.0),
                child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("Portfolio Value", style: Theme.of(context).textTheme.caption),
                          new Text("\$"+ numCommaParseNoRound(value.toStringAsFixed(2)),
                            style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)
                          )
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              new Row(
                                children: <Widget>[
                                  new Text(periodSetting, style: Theme.of(context).textTheme.body2),
                                  new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                                  timelineData != null ?
                                    redGreenParsePercent(context, changePercent.toStringAsFixed(2), 1.1)
                                    : new Container(),
                                ],
                              ),
                              new Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
                              timelineData != null ? new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text("High", style: Theme.of(context).textTheme.caption),
                                  new Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0)),
                                  new Text(numCommaParse(high.toString()),
                                      style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)
                                  )
                                ],
                              ) : new Container(),
                              timelineData != null ? new Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  new Text("Low", style: Theme.of(context).textTheme.caption),
                                  new Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0)),
                                  new Text(numCommaParse(low.toString()),
                                      style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1)
                                  )
                                ],
                              ) : new Container(),
                            ],
                          ),
                          new Container(
                            padding: const EdgeInsets.only(left: 10.0),
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
                              }
                            ),
                          )
                        ],
                      )
                    ])
            ),

            new Container(
              padding: const EdgeInsets.only(top: 16.0),
              height: MediaQuery.of(context).size.height*.6,
              child: timelineData != null ? new Sparkline(
                data: timelineData,
                lineGradient: new LinearGradient(colors: [Theme.of(context).buttonColor, Colors.purpleAccent[100]]),
              ) : new Container(
                  alignment: Alignment.center,
                  child: new CircularProgressIndicator()
              ),
            )

          ]))
        ]
    );
  }
}