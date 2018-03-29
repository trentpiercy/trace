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

  void getJSONData() async {
    var response = await http.get(
      Uri.encodeFull(url),
      headers: {"Accept": "application/json"}
    );

    setState(() {
      data = new JsonDecoder().convert(response.body);
    });
  }

  @override
  void initState() {
    super.initState();
    this.getJSONData();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new PreferredSize(
          preferredSize: const Size.fromHeight(appBarHeight),
          child: new AppBar(
            title: new Text("Market Data"),
          ),
        ),
        body: new Column(
          children: <Widget>[
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
      child: new Text(snapshot["name"]),
    );
  }
}