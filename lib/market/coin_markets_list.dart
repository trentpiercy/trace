import 'package:flutter/material.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trace/market.dart';
//import 'coin_aggregate_stats.dart';


class MarketList extends StatefulWidget {
  MarketList({this.snapshot});
  final snapshot;

  @override
  MarketListState createState() => new MarketListState();
}

List exchangeData;
String toSym = "USD";

class MarketListState extends State<MarketList> {
  ScrollController _scrollController = new ScrollController();

  Future<Null> getExchangeData(String toSym) async {
    var response = await http.get(
      Uri.encodeFull("https://min-api.cryptocompare.com/data/top/exchanges/full?fsym="+widget.snapshot["symbol"]+"&tsym="+toSym+"&limit=50"),
    );
    exchangeData = new JsonDecoder().convert(response.body)["Data"]["Exchanges"];
    makeExchangeData();
  }

  void makeExchangeData() {
    List sortedExchangeData = [];
    for (var i in exchangeData) {
      if (i["VOLUME24HOURTO"] > 1000) {
        sortedExchangeData.add(i);
      }
    }
    setState((){
      exchangeData = sortedExchangeData;
    });
  }

  void initState() {
    super.initState();
    if (exchangeData == null) {
      getExchangeData(toSym);
    }
  }

  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: () => getExchangeData(toSym),
      child: new SingleChildScrollView(
        controller: _scrollController,
        child: new Column(
          children: <Widget>[
            new Container(
              color: Theme.of(context).cardColor,
              padding: const EdgeInsets.all(6.0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  new Container(
                    width: MediaQuery.of(context).size.width * columnProps[0],
                    child: new Text("Exchange", style: Theme.of(context).textTheme.body2),
                  ),
                  new Container(
                    alignment: Alignment.centerRight,
                    width: MediaQuery.of(context).size.width * columnProps[1],
                    child: new Text("24h Volume", style: Theme.of(context).textTheme.body2),
                  ),
                  new Container(
                    alignment: Alignment.centerRight,
                    width: MediaQuery.of(context).size.width * columnProps[2],
                    child: new Text("Price", style: Theme.of(context).textTheme.body2),
                  ),
                ],
              ),
            ),
            new ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: exchangeData == null ? 0 : exchangeData.length,
              itemBuilder: (BuildContext context, int index) {
                return new ExchangeListItem(exchangeDataSnapshot: exchangeData[index]);
              }
            ),
          ],
        ),
      )
    );
  }
}

class ExchangeListItem extends StatelessWidget {
  ExchangeListItem({this.exchangeDataSnapshot});
  final exchangeDataSnapshot;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
      onTap: null,
      child: new Container(
        padding: const EdgeInsets.all(10.0),
        decoration: new BoxDecoration(border: new Border(bottom: new BorderSide(color: Theme.of(context).dividerColor, width: 0.5))),
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            new Container(
              width: MediaQuery.of(context).size.width * columnProps[0],
              child: new Text(exchangeDataSnapshot["MARKET"].toString()),
            ),
            new Container(
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * columnProps[1],
              child: new Text(numCommaParse(exchangeDataSnapshot["VOLUME24HOURTO"].toString())),
            ),
            new Container(
              alignment: Alignment.centerRight,
              width: MediaQuery.of(context).size.width * columnProps[2],
              child: new Text(priceTrim(exchangeDataSnapshot["PRICE"])),
            ),
          ],
        ),
      )
    );
  }
}

priceTrim(number) {
  if (number.toString().length < 7) {
    return "\$" + number.toString();
  }
  return "\$" + number.toString().substring(0,7);
}









