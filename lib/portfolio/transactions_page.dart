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
  num netPercent = 0;

  num currentPrice;

  redGreenParse(context, input, double fontSize) {
    return new Text(
        num.parse(input) >= 0 ? "+\$"+input : "\$"+input,
        style: Theme.of(context).primaryTextTheme.body2.apply(
          color: num.parse(input) >= 0 ? Colors.green : Colors.red,
          fontSizeFactor: fontSize,
        )
    );
  }
  redGreenParsePercent(context, input, double fontSize) {
    return new Text(
        num.parse(input) >= 0 ? "+"+input+"%" : input+"%",
        style: Theme.of(context).primaryTextTheme.body2.apply(
          color: num.parse(input) >= 0 ? Colors.green : Colors.red,
          fontSizeFactor: fontSize,
        )
    );
  }

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
    netPercent = ((value - cost) / cost)*100;
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
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text("Total Value", style: Theme.of(context).textTheme.caption),
                    new Row(
                      children: <Widget>[
                        new Text("\$"+ numCommaParseNoRound(value.toStringAsFixed(2)),
                            style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)
                        ),
                        new Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0)),
                        new Column(
                          children: <Widget>[
                            redGreenParse(context, net.toStringAsFixed(2), 1.1),
                            redGreenParsePercent(context, netPercent.toStringAsFixed(2), 1.1)
                          ],
                        )
                      ],
                    ),
                    new Text(num.parse(holdings.toStringAsPrecision(9)).toString() + " " + widget.symbol,
                        style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2)),
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text("Net Cost", style: Theme.of(context).textTheme.caption),
                    new Text("\$"+cost.toStringAsFixed(2),
                        style: Theme.of(context).primaryTextTheme.body2.apply(fontSizeFactor: 1.8))
                  ],
                ),
              ],
            ),
          ),

          new Divider(height: 0.0)

        ]))
      ],
    );
  }
}