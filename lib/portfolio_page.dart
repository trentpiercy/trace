import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

class PortfolioFAB extends StatefulWidget {
  PortfolioFAB(this.scaffoldKey);
  final GlobalKey<ScaffoldState> scaffoldKey;

  PortfolioFABState createState() => new PortfolioFABState();
}

class PortfolioFABState extends State<PortfolioFAB> {
  bool sheetOpen = false;

  final _sheetKey = new Key("transactionSheet");

  openTransaction() {
    setState(() {
      sheetOpen = true;
    });
    widget.scaffoldKey.currentState.showBottomSheet((BuildContext context) {
      return new TransactionSheet(key: _sheetKey);
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

class TransactionSheet extends StatefulWidget {
  TransactionSheet({Key key}) : super(key: key);

  @override
  TransactionSheetState createState() => new TransactionSheetState();
}

class TransactionSheetState extends State<TransactionSheet> {
  int radioValue = 0;
  DateTime pickedDate = new DateTime.now();
  TimeOfDay pickedTime = new TimeOfDay.now();

  _handleRadioValueChange(int value) {
    setState(() {
      radioValue = value;
    });
  }

  Future<Null> _selectDate() async {
    DateTime pick = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(1950),
        lastDate: new DateTime.now()
    );
    if (pick != null) {
      setState(() {
        pickedDate = pick;
      });
    }
  }

  Future<Null> _selectTime() async {
    TimeOfDay pick = await showTimePicker(
      context: context,
      initialTime: new TimeOfDay.now()
    );
    if (pick != null) {
      setState(() {
        pickedTime = pick;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    ThemeData overrideTheme = new ThemeData(
      primaryColor: Theme.of(context).buttonColor,
      accentColor: Theme.of(context).accentColor,
      hintColor: Theme.of(context).hintColor,
      unselectedWidgetColor: Theme.of(context).unselectedWidgetColor
    );

    return new Container(
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 20.0, left: 20.0),
        color: Theme.of(context).primaryColor,
        child: new Theme(
            data: overrideTheme,
            child: new Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                new Text("Add Transaction", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2)),
                new Row(
                  children: <Widget>[
                    new Row(
                      children: <Widget>[
                        new Text("Buy", style: Theme.of(context).textTheme.caption),
                        new Radio(value: 0, groupValue: radioValue, onChanged: _handleRadioValueChange),
                        new Text("Sell", style: Theme.of(context).textTheme.caption),
                        new Radio(value: 1, groupValue: radioValue, onChanged: _handleRadioValueChange),
                      ],
                    ),

                    new Row(
                      children: <Widget>[
                        new FlatButton(
                          onPressed: () => _selectDate(),
                          child: new Text(pickedDate.month.toString()
                              + "/" + pickedDate.day.toString()
                              + "/" + pickedDate.year.toString()
                          ),
                          textColor: Theme.of(context).accentColor,
                        ),

                        new FlatButton(
                          onPressed: () => _selectTime(),
                          child: new Text(
                              (pickedTime.hourOfPeriod == 0 ? "12" : pickedTime.hourOfPeriod.toString()) + ":" +
                                  (pickedTime.minute > 9 ? pickedTime.minute.toString() : "0" + pickedTime.minute.toString())
                                  + (pickedTime.hour >= 12 ? "PM" : "AM")
                          ),
                          textColor: Theme.of(context).accentColor,
                        )
                      ],
                    )

                  ],
                ),
                new Row(
                  children: <Widget>[
                    new Flexible(
                      child: new TextField(
                        style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).accentColor),
                        decoration: new InputDecoration(
                          labelText: "Symbol",
                          border: InputBorder.none,
                          hintText: "BTC",
                        ),
                      ),
                    ),
                    new Flexible(
                        child: new TextField(
                          style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).accentColor),
                          keyboardType: TextInputType.number,
                          decoration: new InputDecoration(
                            border: InputBorder.none,
                            labelText: "Quantity",
                            hintText: "Enter Quantity",
                          ),
                        )
                    ),
                  ],
                ),
//            new Padding(padding: const EdgeInsets.symmetric(vertical: 2.0)),
                new Row(
                  children: <Widget>[
                    new Flexible(
                      child: new TextField(
                        style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).accentColor),
                        decoration: new InputDecoration(
                          labelText: "Exchange",
                          border: InputBorder.none,
                          hintText: "Coinbase",
                        ),
                      ),
                    ),
                    new Flexible(
                      child: new TextField(
                        style: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).accentColor),
                        keyboardType: TextInputType.number,
                        decoration: new InputDecoration(
                            labelText: "Price",
                            border: InputBorder.none,
                            hintText: "Enter Price in USD",
                            prefixText: "\$",
                            prefixStyle: Theme.of(context).textTheme.body2.apply(color: Theme.of(context).accentColor)
                        ),
                      ),
                    ),
                  ],
                )
              ],
            )
        )
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
                        child: new Text("Holdings/24h", style: Theme.of(context).textTheme.body2),
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