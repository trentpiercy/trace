import 'package:flutter/material.dart';

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:trace/market_page.dart';
import 'coin_exchange_stats.dart';
import 'coin_aggregate_stats.dart';
import 'package:trace/main.dart';

priceTrim(number) {
  if (number.toString().length < 7) {
    return "\$" + number.toString();
  }
  return "\$" + number.toString().substring(0, 7);
}

percentTrim(percent) {
  if (percent >= 0) {
    return "+" + percent.toStringAsFixed(2) + "%";
  } else {
    return percent.toStringAsFixed(2) + "%";
  }
}

class MarketList extends StatefulWidget {
  MarketList({
    Key key,
    this.symbol,
    this.toSym = "USD",
  })  : assert(symbol != null),
        super(key: key);

  final String symbol;
  final String toSym;

  @override
  MarketListState createState() => new MarketListState();
}

List exchangeData;

class MarketListState extends State<MarketList> {
  Future<Null> getExchangeData(String toSym) async {
    var response = await http.get(
        Uri.encodeFull(
            "https://min-api.cryptocompare.com/data/top/exchanges/full?fsym=" +
                widget.symbol +
                "&tsym=" + toSym +
                "&limit=1000"),
        headers: {"Accept": "application/json"});

    if (new JsonDecoder().convert(response.body)["Response"] != "Success") {
      setState(() {
        exchangeData = [];
      });
    } else {
      exchangeData = new JsonDecoder().convert(response.body)["Data"]["Exchanges"];
      makeExchangeData();
    }
  }

  void makeExchangeData() {
    List sortedExchangeData = [];
    for (var i in exchangeData) {
      if (i["VOLUME24HOURTO"] > 1000) {
        sortedExchangeData.add(i);
      }
    }
    setState(() {
      exchangeData = sortedExchangeData;
    });
  }

  void initState() {
    super.initState();
    if (exchangeData == null) {
      getExchangeData(widget.toSym);
    }
  }

  @override
  Widget build(BuildContext context) {
    return exchangeData != null ? new RefreshIndicator(
        onRefresh: () => getExchangeData(widget.toSym),
        child: exchangeData.isEmpty != true ? new CustomScrollView(
            slivers: <Widget>[
            new SliverList(delegate: new SliverChildListDelegate(<Widget>[
                    new Container(
                      margin: const EdgeInsets.only(left: 6.0, right: 6.0, top: 8.0),
                      decoration: new BoxDecoration(
                          border: new Border(
                              bottom: new BorderSide(
                                  color: Theme.of(context).dividerColor,
                                  width: 1.0))),
                      padding: const EdgeInsets.only(bottom: 8.0, left: 2.0, right: 2.0),
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width * columnProps[0],
                            child: new Text("Exchange",
                                style: Theme.of(context).textTheme.body2),
                          ),
                          new Container(
                            alignment: Alignment.centerRight,
                            width: MediaQuery.of(context).size.width * columnProps[1],
                            child: new Text("24h Volume",
                                style: Theme.of(context).textTheme.body2),
                          ),
                          new Container(
                            alignment: Alignment.centerRight,
                            width: MediaQuery.of(context).size.width * columnProps[2],
                            child: new Text("Price/24h",
                                style: Theme.of(context).textTheme.body2),
                          ),
                        ],
                      ),
                    ),
                  ]
                )
            ),
            new SliverList(
                delegate: new SliverChildBuilderDelegate(
                  (BuildContext context, int index) {
                      return new ExchangeListItem(
                        exchangeDataSnapshot: exchangeData[index]
                      );
                  },
                  childCount: exchangeData == null ? 0 : exchangeData.length,
                )
            )
          ],
        ) : new CustomScrollView(
          slivers: <Widget>[
            new SliverList(delegate: new SliverChildListDelegate(
                <Widget>[
                  new Container(
                    padding: const EdgeInsets.all(30.0),
                    alignment: Alignment.topCenter,
                    child: new Text("No exchanges found :(", style: Theme.of(context).textTheme.caption),
                  )
                ]
            ))
          ],
        )
    ) : new Container(
      child: new Center(child: new CircularProgressIndicator()),
    );
  }
}

class ExchangeListItem extends StatelessWidget {
  ExchangeListItem({this.exchangeDataSnapshot});
  final exchangeDataSnapshot;

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        onTap: () {
          resetCoinStats();
          Navigator.of(context).push(
              new MaterialPageRoute(
                  builder: (BuildContext context) => new CoinMarketStats(
                    exchangeData: exchangeDataSnapshot,
                    e: exchangeDataSnapshot["MARKET"],
                  )
              )
          );
        },
        child: new Container(
          padding: const EdgeInsets.all(6.0),
          decoration: new BoxDecoration(),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Container(
                width: MediaQuery.of(context).size.width * columnProps[0],
                child: new Text(exchangeDataSnapshot["MARKET"],
                    style: Theme.of(context).textTheme.body2),
              ),
              new Container(
                alignment: Alignment.centerRight,
                width: MediaQuery.of(context).size.width * columnProps[1],
                child: new Text(
                    numCommaParse(
                        exchangeDataSnapshot["VOLUME24HOURTO"].toString()),
                    style: Theme.of(context).textTheme.body1),
              ),
              new Container(
                width: MediaQuery.of(context).size.width * columnProps[2],
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(priceTrim(exchangeDataSnapshot["PRICE"])),
                    new Text(
                        percentTrim(exchangeDataSnapshot["CHANGEPCT24HOUR"]),
                        style: Theme.of(context).primaryTextTheme.body1.apply(
                            color: exchangeDataSnapshot["CHANGEPCT24HOUR"] >= 0
                                ? Colors.green
                                : Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}
