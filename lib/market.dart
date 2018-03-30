import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import 'main.dart';

numCommaParse(numString) {
  return "\$"+ num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
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

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => new CoinDetails(coinName: snapshot["name"],)
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
              width: MediaQuery.of(context).size.width * 0.2,
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(snapshot["rank"]),
                  new Padding(padding: const EdgeInsets.only(right: 8.0)),
                  new Text(snapshot["symbol"])
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width * 0.35,
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text(numCommaParse(snapshot["market_cap_usd"])),
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
                  )
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
  CoinDetails({this.coinName});
  final String coinName;

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
            title: new Text(widget.coinName),
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
      )
    );
  }
}