import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trace/market/coin_details.dart';
import 'package:trace/market/coin_aggregate_stats.dart';
import 'main.dart';


final columnProps = [.3,.3,.25];


numCommaParse(numString) {
  return "\$"+ num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}
numCommaParseNoDollar(numString) {
  return num.parse(numString).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},");
}

class MarketPage extends StatefulWidget {
  @override
  MarketPageState createState() => new MarketPageState();
}

List marketListData;
Map globalData;

class MarketPageState extends State<MarketPage> {
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
          title: new Text("Aggregate Markets"),
          titleSpacing: 0.0,
          leading: new IconButton( // TODO: Searching
            icon: new Icon(Icons.search),
            onPressed: null
          ),
          actions: <Widget>[ // TODO: Number shortening
            new IconButton(
              icon: new Icon(Icons.short_text, color: Theme.of(context).iconTheme.color),
              onPressed: null
            )
          ],
        ),
      ),
      body: new RefreshIndicator(
        color: Theme.of(context).buttonColor,
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
                            new Text("Total Market Cap", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                            new Text(numCommaParse(globalData["total_market_cap_usd"].toString()), style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1, fontWeightDelta: 2)),
                          ],
                        ),
                        new Column(
                          children: <Widget>[
                            new Text("Total 24h Volume", style: Theme.of(context).textTheme.body1.apply(color: Theme.of(context).hintColor)),
                            new Text(numCommaParse(globalData["total_24h_volume_usd"].toString()), style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.1, fontWeightDelta: 2)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ) : new Container(),
              new Container(
                margin: const EdgeInsets.only(left: 6.0, right: 6.0, top: 8.0),
                decoration: new BoxDecoration(
                  border: new Border(bottom: new BorderSide(color: Theme.of(context).dividerColor, width: 1.0))
                ),
                padding: const EdgeInsets.only(bottom: 8.0, left: 2.0, right: 2.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Container(
                      width: MediaQuery.of(context).size.width * columnProps[0],
                      child: new Text("Currency", style: Theme.of(context).textTheme.body2),
                    ),
                    new Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width * columnProps[1],
                      child: new Text("Market Cap/24h", style: Theme.of(context).textTheme.body2),
                    ),
                    new Container(
                      alignment: Alignment.centerRight,
                      width: MediaQuery.of(context).size.width * columnProps[2],
                      child: new Text("Price/24h", style: Theme.of(context).textTheme.body2),
                    ),
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
    if (num.parse(snapshot["rank"]) <= 20) {
      return new Image.network("https://raw.githubusercontent.com/cjdowner/cryptocurrency-icons/master/128/color/"+snapshot["symbol"].toString().toLowerCase()+".png", height: 28.0);
    }
    else {
      return new Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: () {
        resetCoinStats();
        Navigator.of(context).push(
          new MaterialPageRoute(
            builder: (BuildContext context) => new CoinDetails(snapshot: snapshot)
          )
        );
      },
      child: new Container(
        decoration: new BoxDecoration(),
        padding: const EdgeInsets.all(8.0),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Container(
              width: MediaQuery.of(context).size.width * columnProps[0],
              child: new Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  new Text(snapshot["rank"], style: Theme.of(context).textTheme.body2),
                  new Padding(padding: const EdgeInsets.only(right: 7.0)),
                  _getImage(),
                  new Padding(padding: const EdgeInsets.only(right: 7.0)),
                  new Text(snapshot["symbol"], style: Theme.of(context).textTheme.body2),
                ],
              ),
            ),
            new Container(
              width: MediaQuery.of(context).size.width * columnProps[1],
              child: new Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  new Text(numCommaParse(snapshot["market_cap_usd"]), style: Theme.of(context).textTheme.body2),
                  new Padding(padding: const EdgeInsets.only(bottom: 4.0)),
                  new Text(numCommaParse(snapshot["24h_volume_usd"]), style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).hintColor))
                ],
              )
            ),
            new Container(
              width: MediaQuery.of(context).size.width * columnProps[2],
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

