import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'package:charts_flutter/flutter.dart';

import 'main.dart';


numCommaParse(numString) {
  return "\$"+ num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}
numCommaParseNoDollar(numString) {
  return num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

timeAgo(sSinceEpoch) {
  int nowInSeconds = int.parse(new DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10));
  return (nowInSeconds-sSinceEpoch).toString()+"s ago";
}


class MarketPage extends StatefulWidget {
  @override
  MarketPageState createState() => new MarketPageState();
}

class MarketPageState extends State<MarketPage> {
  List marketListData;
  Map globalData;

  ScrollController _scrollController = new ScrollController();

  Future<Null> refreshData() async {
    getGlobalData();
    getMarketData();
  }

  Future<Null> getMarketData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v1/ticker/?limit=100"),
        headers: {"Accept": "application/json"}
    );
    setState(() {
      marketListData = new JsonDecoder().convert(response.body);
    });
  }

  Future<Null> getGlobalData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v1/global/"),
        headers: {"Accept": "application/json"}
    );
    setState(() {
      globalData = new JsonDecoder().convert(response.body);
    });
  }

  void initState() {
    super.initState();
    if (marketListData == null) {
      getMarketData();
    }
    if (globalData == null) {
      getGlobalData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: new PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: new AppBar(
          elevation: appBarElevation,
          title: new Text("Aggregate Market Caps"),
          actions: <Widget>[
            new IconButton(icon: new Icon(Icons.short_text), onPressed: null)
          ],
        ),
      ),
      body: new RefreshIndicator(
        color: Theme.of(context).buttonColor,
        displacement: 10.0,
        onRefresh: () => refreshData(),
        child: new SingleChildScrollView(
          controller: _scrollController,
          child: new Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              globalData != null ? new Container(
                padding: const EdgeInsets.all(8.0),
                child: new GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      new MaterialPageRoute(
                        builder: (BuildContext context) => new TotalMarketCapDetails()
                      )
                    );
                  },
                  child: new Column(
                    children: <Widget>[
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Column(
                            children: <Widget>[
                              new Text("Total Market Cap", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                              new Text(numCommaParse(globalData["total_market_cap_usd"].toString()), style: Theme.of(context).textTheme.button),
                            ],
                          ),
                          new Column(
                            children: <Widget>[
                              new Text("Total 24h Trade Volume", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                              new Text(numCommaParse(globalData["total_24h_volume_usd"].toString()), style: Theme.of(context).textTheme.button),
                            ],
                          ),
                        ],
                      ),
//                    new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
//                    new Align(
//                      alignment: Alignment.centerRight,
//                      child: new Text("Last Published "+timeAgo(globalData["last_updated"]), style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).disabledColor, fontSizeFactor: 0.8)),
//                    ),
                    ],
                  ),
                )
              ) : new Container(),
              new Container(
                color: Theme.of(context).cardColor,
                padding: const EdgeInsets.all(8.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text("Currency", style: Theme.of(context).textTheme.body2),
                    new Text("Market Cap/24h", style: Theme.of(context).textTheme.body2),
                    new Text("Price/24h", style: Theme.of(context).textTheme.body2)
                  ],
                ),
              ),
              new ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: marketListData == null ? 0 : marketListData.length,
                itemBuilder: (BuildContext context, int index) {
                  return new CoinListItem(snapshot: marketListData[index]);
                }
              )
            ],
          )
        )
      )
    );
  }
}

class CoinListItem extends StatelessWidget {
  CoinListItem({this.snapshot});
  final snapshot;

  _getImage() {
    if (num.parse(snapshot["rank"]) <= 50) {
      return new Image.network("https://raw.githubusercontent.com/cjdowner/cryptocurrency-icons/master/128/color/"+snapshot["symbol"].toString().toLowerCase()+".png", height: 22.0);
    }
    else {
      return new Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => new CoinDetails(snapshot: snapshot)
          )
        );
      },
      child: new Container(
        padding: const EdgeInsets.all(8.0),
        decoration: new BoxDecoration(border: new Border(bottom: new BorderSide(color: Theme.of(context).dividerColor, width: 0.5))),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Container(
              width: MediaQuery.of(context).size.width * 0.25,
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(snapshot["rank"]),
                  new Padding(padding: const EdgeInsets.only(right: 6.0)),
//                  new Image.asset("assets/icons/"+snapshot["symbol"].toString().toLowerCase()+".png", height: 22.0,),
//                  new Image.network("https://raw.githubusercontent.com/cjdowner/cryptocurrency-icons/master/128/color/"+snapshot["symbol"].toString().toLowerCase()+".png", height: 22.0),
                  _getImage(),
                  new Padding(padding: const EdgeInsets.only(right: 6.0)),
                  new Text(snapshot["symbol"]),
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width * 0.35,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text(numCommaParse(snapshot["market_cap_usd"]), style: Theme.of(context).textTheme.button),
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text(numCommaParse(snapshot["24h_volume_usd"]))
                ],
              )
            ),
            new Container(
              width: MediaQuery.of(context).size.width * 0.3,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text("\$"+snapshot["price_usd"]),
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text(
                    num.parse(snapshot["percent_change_24h"]) >= 0 ? "+"+snapshot["percent_change_24h"]+"%" : snapshot["percent_change_24h"]+"%",
                    style: Theme.of(context).primaryTextTheme.body1.apply(
                      color: num.parse(snapshot["percent_change_24h"]) >= 0 ? Colors.green : Colors.red
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}

class CoinDetails extends StatefulWidget {
  CoinDetails({this.snapshot});
  final snapshot;

  @override
  CoinDetailsState createState() => new CoinDetailsState();
}

class CoinDetailsState extends State<CoinDetails> {
  @override
  Widget build(BuildContext context) {
    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new PreferredSize(
          preferredSize: const Size.fromHeight(75.0),
          child: new AppBar(
            titleSpacing: 0.0,
            elevation: appBarElevation,
            title: new Text(widget.snapshot["name"]),
            bottom: new PreferredSize(
              preferredSize: const Size.fromHeight(25.0),
              child: new Container(
                height: 30.0,
                child: new TabBar(
//                  indicatorPadding: const EdgeInsets.only(left: 2.0, bottom: 0.0, right: 2.0),
                  indicatorColor: Theme.of(context).iconTheme.color,
                  tabs: <Widget>[
                    new Tab(text: "Aggregate Stats"),
                    new Tab(text: "Markets"),
                  ],
                )
              )
            ),
          ),
        ),
        body: new TabBarView(
          children: <Widget>[
            new AggregateStats(snapshot: widget.snapshot),
            new Text("xd")
          ],
        )
      )
    );
  }
}

class AggregateStats extends StatefulWidget {
  AggregateStats({this.snapshot});
  final snapshot;

  @override
  AggregateStatsState createState() => new AggregateStatsState();
}

class AggregateStatsState extends State<AggregateStats> {
  String historyOHLCVType = "minute";
  String historyOHLCVAmt = "1420";

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

  @override
  Widget build(BuildContext context) {
    return new SingleChildScrollView(
      padding: const EdgeInsets.all(4.0),
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
                  children: <Widget>[
                    new Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text("1h", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                        new Padding(padding: const EdgeInsets.only(right: 3.0)),
                        new Text(
                          num.parse(widget.snapshot["percent_change_1h"]) >= 0 ? "+"+widget.snapshot["percent_change_1h"]+"%" : widget.snapshot["percent_change_1h"]+"%",
                          style: Theme.of(context).primaryTextTheme.body1.apply(
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
                          style: Theme.of(context).primaryTextTheme.body1.apply(
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
                          style: Theme.of(context).primaryTextTheme.body1.apply(
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
          new Container(
//            color: Theme.of(context).cardColor,
            padding: const EdgeInsets.all(4.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Text("Price History", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
                new Text("30d", style: Theme.of(context).textTheme.button.apply(color: Theme.of(context).hintColor)),
              ],
            )
          ),
          sparkLineData == null ? new Container() : new _SparkLine(data: sparkLineData),
        ],
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
        padding: const EdgeInsets.all(4.0),
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




// TODO: make this exist
class TotalMarketCapDetails extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Container();
  }
}