import 'package:flutter/material.dart';
import '../main.dart';

class TransactionsPage extends StatefulWidget {
  TransactionsPage({this.symbol});
  final String symbol;

  @override
  TransactionsPageState createState() => new TransactionsPageState();
}

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
      style: Theme.of(context).primaryTextTheme.body1.apply(
        color: num.parse(input) >= 0 ? Colors.green : Colors.red,
        fontSizeFactor: fontSize,
      )
  );
}

class TransactionsPageState extends State<TransactionsPage> {
  num value = 0;
  num cost = 0;
  num holdings = 0;
  num net = 0;
  num netPercent = 0;

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

    if (cost > 0) {
      netPercent = ((value - cost) / cost)*100;
    } else {
      netPercent = 999.99;
    }
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
                    new Text("\$"+ numCommaParseNoRound(value.toStringAsFixed(2)),
                        style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)),
                    new Text(num.parse(holdings.toStringAsPrecision(9)).toString() + " " + widget.symbol,
                        style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2)),
                  ],
                ),
                new Column(
                  children: <Widget>[
                    new Text("Total Net", style: Theme.of(context).textTheme.caption),
                    redGreenParse(context, net.toStringAsFixed(2), 1.5),
                    redGreenParsePercent(context, netPercent.toStringAsFixed(2), 1.2)
                  ],
                ),
                new Column(
//                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text("Total Cost", style: Theme.of(context).textTheme.caption),
                    new Text("\$"+cost.toStringAsFixed(2),
                        style: Theme.of(context).primaryTextTheme.body2.apply(fontSizeFactor: 1.5))
                  ],
                ),
              ],
            ),
          ),
          new Divider(height: 0.0),
        ])),
        new SliverList(delegate: new SliverChildBuilderDelegate(
                (context, index) => new TransactionItem(
                  snapshot: portfolioMap[widget.symbol][portfolioMap[widget.symbol].length-index-1],
                  currentPrice: currentPrice,
                  symbol: widget.symbol,
                ),
            childCount: portfolioMap[widget.symbol].length
        )),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  TransactionItem({this.snapshot, this.symbol, this.currentPrice});
  final Map snapshot;
  final String symbol;
  final num currentPrice;

  @override
  Widget build(BuildContext context) {
    print(snapshot);
    final DateTime time = new DateTime.fromMillisecondsSinceEpoch(snapshot["time_epoch"]);
    return new InkWell(
      onTap: () {},
      child: new Container(
        padding: const EdgeInsets.all(8.0),
        child: new Column(
          children: <Widget>[
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(snapshot["quantity"] >= 0 ? "Bought" : "Sold",
                          style: Theme.of(context).textTheme.body1.apply(
                              color: snapshot["quantity"] >= 0 ? Colors.green : Colors.red
                          )
                      ),
                      new Row(children: <Widget>[
                        new Text(snapshot["quantity"].toString() + " " + symbol,
                            style: Theme.of(context).primaryTextTheme.body2.apply(fontSizeFactor: 1.1)),
                        new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                        new Text("at", style: Theme.of(context).textTheme.caption),
                        new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                        new Text("\$"+snapshot["price_usd"].toStringAsFixed(2),
                            style: Theme.of(context).primaryTextTheme.body2.apply(fontSizeFactor: 1.1)),
                        new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                        redGreenParsePercent(
                            context,
                            ((currentPrice - snapshot["price_usd"]) / snapshot["price_usd"] * 100).toStringAsFixed(2),
                            1.0
                        )
                      ],)
                    ]),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text(snapshot["quantity"] >= 0 ? "Cost" : "Profit", style: Theme.of(context).textTheme.caption),
                    new Text("\$"+(snapshot["quantity"]*snapshot["price_usd"]).abs().toStringAsFixed(2),
                      style: Theme.of(context).primaryTextTheme.body2.apply(fontSizeFactor: 1.2))
                  ]
                ),
              ],
            ),
            new Padding(padding: const EdgeInsets.symmetric(vertical: 1.0)),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Row(children: <Widget>[
                      new Text("Exchange", style: Theme.of(context).textTheme.caption),
                      new Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0)),
                      new Text(snapshot["exchange"],
                          style: Theme.of(context).primaryTextTheme.body1)
                    ]),
                    new Text(time.month.toString()+"/"+time.day.toString()+"/"+time.year.toString().substring(2)
                        +" "+time.hour.toString()+":"+time.minute.toString(),
                        style: Theme.of(context).primaryTextTheme.body1)
                  ],
                ),
                snapshot["notes"] != "" ? new Text(snapshot["notes"]) : new Container()
              ],
            ),
          ],
        )
      )
    );
  }
}