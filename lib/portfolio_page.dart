import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class PortfolioFAB extends StatefulWidget {
//  PortfolioFAB(this.updateParent);
//  final Function updateParent;

  PortfolioFABState createState() => new PortfolioFABState();
}

class PortfolioFABState extends State<PortfolioFAB> {
  bool sheetOpen = false;
  int radioValue = 0;

  _handleRadioValueChange(int value) {
    print("called");
    setState(() {
      radioValue = value;
    });
  }

  openTransaction() {
    setState(() {
      sheetOpen = true;
    });
    showBottomSheet(context: context, builder: (BuildContext context) {
      return new Container(
        padding: const EdgeInsets.all(8.0),
        color: Theme.of(context).primaryColor,
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text("Add Transaction", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2)),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text("Buy", style: Theme.of(context).textTheme.caption),
                new Radio(value: 0, groupValue: radioValue, onChanged: _handleRadioValueChange),
                new Text("Sell", style: Theme.of(context).textTheme.caption),
                new Radio(value: 1, groupValue: radioValue, onChanged: _handleRadioValueChange),
              ],
            ),
            new Row(
              children: <Widget>[
                new Flexible(
                  child: new TextField(
                    decoration: new InputDecoration(
                      hintText: "Symbol... (BTC)"
                    ),
                  ),
                ),
                new Flexible(
                  child: new TextField(
                    decoration: new InputDecoration(
                      hintText: "Quantity"
                    ),
                  ),
                ),
              ],
            ),
            new Row(
              children: <Widget>[
                new Flexible(
                  child: new TextField(
                    decoration: new InputDecoration(
                        hintText: "Exchange"
                    ),
                  ),
                ),
                new Flexible(
                  child: new TextField(
                    decoration: new InputDecoration(
                      prefixText: "\$",
                      prefixStyle: Theme.of(context).textTheme.body1,
                      hintText: "Price"
                    ),
                  ),
                ),
              ],
            )
          ],
        )
      );

    }).closed.whenComplete(() {
      setState(() {
        sheetOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return sheetOpen ? new FloatingActionButton(
      onPressed: () => Navigator.of(context).pop(),
      child: Icon(Icons.close),
      foregroundColor: Theme.of(context).iconTheme.color,
      backgroundColor: Theme.of(context).accentIconTheme.color,
      elevation: 4.0,
      tooltip: "Close Transaction",
    ) :
    new FloatingActionButton(
      onPressed: openTransaction,
      child: Icon(Icons.add),
      foregroundColor: Theme.of(context).iconTheme.color,
      backgroundColor: Theme.of(context).accentIconTheme.color,
      elevation: 4.0,
      tooltip: "Add Transaction",
    );
  }
}


class PortfolioPage extends StatefulWidget {
  PortfolioPage({Key key}) : super(key: key);

  @override
  PortfolioPageState createState() => new PortfolioPageState();
}

class PortfolioPageState extends State<PortfolioPage> {
  final columnProps = [.2,.3,.3];

  List<Map> portfolioList;

  void writeToLocal() {

  }

  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then((Directory directory) {
      File jsonFile = new File(directory.path + "/portfolio.json");
//      jsonFile.delete();
      if (jsonFile.existsSync()) {
        print("file exists");
        portfolioList = new JsonDecoder().convert(jsonFile.readAsStringSync());
      } else {
        print("creating file");
        jsonFile.createSync();
      }
      print("contents: " + portfolioList.toString());
    });

  }


  @override
  Widget build(BuildContext context) {
    return new CustomScrollView(
        slivers: <Widget>[
          new SliverList(
              delegate: new SliverChildListDelegate(<Widget>[
                new Container(
                  padding: const EdgeInsets.all(10.0),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("Total Portfolio Value", style: Theme.of(context).textTheme.caption),
                          new Text("\$"+"VALUE", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 2.2)),
                        ],
                      ),
                      new Row(
                        children: <Widget>[
                          new Text("24h", style: Theme.of(context).textTheme.caption),
                          new Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0)),
                          new Text("+99%", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2)),
                        ],
                      )
                    ],
                  ),
                ),

                new Container(
                  margin: const EdgeInsets.only(left: 6.0, right: 6.0),
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
                        child: new Text("Holdings", style: Theme.of(context).textTheme.body2),
                      ),
                      new Container(
                        alignment: Alignment.centerRight,
                        width: MediaQuery.of(context).size.width * columnProps[2],
                        child: new Text("Price/24h", style: Theme.of(context).textTheme.body2),
                      ),
                    ],
                  ),
                ),

              ])
          ),

          new SliverList(delegate: new SliverChildBuilderDelegate(
            (context, index) => new ListTile(
              title: new Text("placeholder $index"),
            ))
          )

        ],
    );
  }
}