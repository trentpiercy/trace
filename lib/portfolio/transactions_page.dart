import 'package:flutter/material.dart';
import 'transaction_sheet.dart';
import '../main.dart';
import 'portfolio_tabs.dart';

class TransactionsPage extends StatefulWidget {
  TransactionsPage({this.symbol});
  final String symbol;

  @override
  TransactionsPageState createState() => new TransactionsPageState();
}

class TransactionsPageState extends State<TransactionsPage> {
  num value;
  num cost;
  num holdings;
  num net;
  num netPercent;

  num currentPrice = 0;

  List transactionList;

  _getTotals() {
    for (Map coin in marketListData) {
      if (coin["symbol"] == widget.symbol) {
        currentPrice = coin["quotes"]["USD"]["price"];
        break;
      }
    }
  }

  _updateTotals() {
    value = 0;
    cost = 0;
    holdings = 0;
    net = 0;
    netPercent = 0;

    for (Map transaction in transactionList) {
      cost += transaction["quantity"] * transaction["price_usd"];
      value += transaction["quantity"] * currentPrice;
      holdings += transaction["quantity"];
    }

    net = value - cost;

    if (cost > 0) {
      netPercent = ((value - cost) / cost)*100;
    } else {
      netPercent = 0.0;
    }
  }

  _sortTransactions() {
    transactionList = portfolioMap[widget.symbol];
    transactionList.sort(
        (a, b) => (b["time_epoch"].compareTo(a["time_epoch"]))
    );
  }


  @override
  void initState() {
    print("INIT TRANSACTION PAGE");

    super.initState();
    _getTotals();
  }

  @override
  Widget build(BuildContext context) {

    print("built transactions page");

    _sortTransactions();
    _updateTotals();

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
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        new Text("\$"+ numCommaParseNoDollar(value.toStringAsFixed(2)),
                            style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)
                        ),
                      ],
                    ),
                    new Text(num.parse(holdings.toStringAsPrecision(9)).toString() + " " + widget.symbol,
                        style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2)),
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text("Total Net", style: Theme.of(context).textTheme.caption),
                    new PercentDollarChange(
                      exact: net,
                      percent: netPercent,
                    )
                  ],
                ),
                new Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    new Text("Total Cost", style: Theme.of(context).textTheme.caption),
                    new Text("\$"+numCommaParseNoDollar(cost.toStringAsFixed(2)),
                        style: Theme.of(context).primaryTextTheme.body2.apply(fontSizeFactor: 1.5))
                  ],
                ),
              ],
            ),
          ),
        ])),
        new SliverList(delegate: new SliverChildBuilderDelegate(
            (context, index) => new TransactionItem(
              snapshot: transactionList[index],
              currentPrice: currentPrice,
              symbol: widget.symbol,
              refreshPage: () {},
            ),
            childCount: transactionList.length
        )),
      ],
    );
  }
}

class TransactionItem extends StatelessWidget {
  TransactionItem({this.snapshot, this.symbol, this.currentPrice, this.refreshPage});
  final Map snapshot;
  final String symbol;
  final num currentPrice;

  final Function refreshPage;

  @override
  Widget build(BuildContext context) {
    String date;
    final DateTime time = new DateTime.fromMillisecondsSinceEpoch(snapshot["time_epoch"]);
    final double changePercent = (currentPrice - snapshot["price_usd"]) / snapshot["price_usd"] * 100;

    if (time.minute < 10) {
      date = time.month.toString()+"/"+time.day.toString()+"/"+time.year.toString().substring(2)
          +" "+time.hour.toString()+":0"+time.minute.toString();
    } else {
      date = time.month.toString()+"/"+time.day.toString()+"/"+time.year.toString().substring(2)
          +" "+time.hour.toString()+":"+time.minute.toString();
    }

    String exchange = snapshot["exchange"];
    if (exchange == "CCCAGG") {exchange = "Aggregated";}

    return new Card(
      elevation: 2.0,
      child: new ListTile(
        isThreeLine: false,
        contentPadding: const EdgeInsets.all(8.0),
        onTap: () => showBottomSheet(
            context: context,
            builder: (context) =>
            new TransactionSheet(
              refreshPage,
              marketListData,
              editMode: true,
              snapshot: snapshot,
              symbol: symbol,
            )
        ),
        leading: snapshot["quantity"] >= 0 ?
        new Icon(Icons.add_circle, color: Colors.green, size: 28.0)
            : new Icon(Icons.remove_circle, color: Colors.red, size: 28.0),
        title: new RichText(text: TextSpan(children: <TextSpan>[
          TextSpan(text: "${snapshot["quantity"]} $symbol", style: Theme.of(context).textTheme.body2.apply(fontWeightDelta: 2)),
          TextSpan(text: " at ", style: Theme.of(context).textTheme.body1),
          TextSpan(text: "\$${snapshot["price_usd"]}", style: Theme.of(context).textTheme.body2.apply(fontWeightDelta: 2)),
          TextSpan(text: changePercent > 0 ?
          " +" + changePercent.toStringAsFixed(2) + "%"
              : " " + changePercent.toStringAsFixed(2) + "%",
              style: Theme.of(context).textTheme.body2.apply(color: changePercent > 0 ? Colors.green : Colors.red)
          ),
        ])),
        subtitle: new Text("$exchange (\$${numCommaParseNoDollar((snapshot["quantity"]*snapshot["price_usd"]).toStringAsFixed(2))})\n$date"),
        trailing: snapshot["notes"] != "" ? new Container(
          alignment: Alignment.topRight,
          width: MediaQuery.of(context).size.width * .3,
          child: new Text(snapshot["notes"], overflow: TextOverflow.ellipsis, maxLines: 4,
            style: Theme.of(context).textTheme.caption),
        ) : null,
      ),
    );
  }
}