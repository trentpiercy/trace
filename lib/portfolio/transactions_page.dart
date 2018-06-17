import 'package:flutter/material.dart';

import '../main.dart';

class TransactionsPage extends StatefulWidget {
  TransactionsPage({this.symbol});
  final String symbol;

  @override
  TransactionsPageState createState() => new TransactionsPageState();
}

class TransactionsPageState extends State<TransactionsPage> {
  num value = 0;
  num cost = 0;
  num holdings = 0;
  num net = 0;

  num currentPrice;

  _getTotals() {
    for (Map coin in marketListData) {
      if (coin["symbol"] == widget.symbol) {
        currentPrice = coin["quotes"]["USD"]["price"];
        break;
      }
    }
    for (Map transaction in portfolioMap[widget.symbol]) {
      cost += transaction["quantity"] * transaction["price_usd"];
      value += transaction["quantity"] * currentPrice;
      holdings += transaction["quantity"];
    }

    net = value - cost;
  }

  @override
  void initState() {
    super.initState();
    _getTotals();
  }

  @override
  Widget build(BuildContext context) {
    return new CustomScrollView(
      slivers: <Widget>[
        new SliverList(delegate: new SliverChildListDelegate(<Widget>[
          new Container(
            padding: const EdgeInsets.all(10.0),
            child: new Column(
              children: <Widget>[
                new Text(value.toString()),
                new Text(holdings.toString()),
                new Text(cost.toString()),
                new Text(net.toString())
              ],
            ),
          )
        ]))
      ],
    );
  }
}