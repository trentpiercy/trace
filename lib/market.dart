import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_sparkline/flutter_sparkline.dart';

import 'main.dart';

class MarketPage extends StatefulWidget {
  @override
  MarketPageState createState() => new MarketPageState();
}

class MarketPageState extends State<MarketPage> {
  final String url = "https://api.coinmarketcap.com/v1/ticker/?limit=100";
  List data;

  Future<Null> getJSONData() async {
    var response = await http.get(
        Uri.encodeFull(url),
        headers: {"Accept": "application/json"}
    );
    setState(() {
      data = new JsonDecoder().convert(response.body);
    });
  }

  void initState() {
    super.initState();
    if (data == null) {
      getJSONData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new PreferredSize(
        preferredSize: const Size.fromHeight(appBarHeight),
        child: new AppBar(
          elevation: appBarElevation,
          title: new Text("Market Stats"),
        ),
      ),
      body: new RefreshIndicator(
        color: varDarkAccent,
        displacement: 10.0,
        onRefresh: () => getJSONData(),
        child: new Column(
          children: <Widget>[
            new Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(8.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Text("Currency", style: Theme.of(context).textTheme.body2),
                  new Text("Market Cap", style: Theme.of(context).textTheme.body2),
                  new Text("Price/24h", style: Theme.of(context).textTheme.body2)
                ],
              ),
            ),
            new Divider(height: 0.0),
            new Flexible(
              child: new ListView.builder(
                itemCount: data == null ? 0 : data.length,
                itemBuilder: (BuildContext context, int index) {
                  return new CoinListItem(snapshot: data[index]);
                }
              )
            )
          ],
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
    return new Container(
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
            alignment: Alignment.centerRight,
            child: new Text("\$"+ num.parse(snapshot["market_cap_usd"]).round().toString().replaceAllMapped(new RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => "${m[1]},"))
          ),
          new Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                new Text("\$"+snapshot["price_usd"]),
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
    );
  }
}

//"id": "bitcoin",
//"name": "Bitcoin",
//"symbol": "BTC",
//"rank": "1",
//"price_usd": "7232.11",
//"price_btc": "1.0",
//"24h_volume_usd": "5533450000.0",
//"market_cap_usd": "122559762111",
//"available_supply": "16946612.0",
//"total_supply": "16946612.0",
//"max_supply": "21000000.0",
//"percent_change_1h": "-2.46",
//"percent_change_24h": "-9.02",
//"percent_change_7d": "-16.46",
//"last_updated": "1522357168"