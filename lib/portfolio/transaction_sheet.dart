import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../main.dart';
import '../market_page.dart';

class PortfolioFAB extends StatefulWidget {
  PortfolioFAB(this.scaffoldKey, this.loadPortfolio);
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function loadPortfolio;

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
      return new TransactionSheet(widget.loadPortfolio, key: _sheetKey);
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
  TransactionSheet(this.loadPortfolio, {Key key}) : super(key: key);
  final Function loadPortfolio;

  @override
  TransactionSheetState createState() => new TransactionSheetState();
}

class TransactionSheetState extends State<TransactionSheet> {
  TextEditingController _symbolController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _quantityController = new TextEditingController();
  TextEditingController _exchangeController = new TextEditingController();
  TextEditingController _notesController = new TextEditingController();

  Color errorColor = Colors.red;
  Color validColor;

  int radioValue = 0;
  DateTime pickedDate = new DateTime.now();
  TimeOfDay pickedTime = new TimeOfDay.now();
  int epochDate;

  List symbolList;
  Color symbolTextColor;
  String symbol;

  Color quantityTextColor;
  num quantity;

  Color priceTextColor ;
  num price;

  List exchangesList;
  String exchange;

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
      _makeEpoch();
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
      _makeEpoch();
    }
  }

  _makeEpoch() {
    epochDate = new DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute
    ).millisecondsSinceEpoch;

    print("epoch ms timestamp");
    print(epochDate.toString());

  }

  _checkValidSymbol(String inputSymbol) async {
    if (symbolList == null || symbolList.isEmpty) {
      symbolList = [];
      marketListData.forEach((value) => symbolList.add(value["symbol"]));
    }

    if (symbolList.contains(inputSymbol.toUpperCase())) {
      symbol = inputSymbol.toUpperCase();
      exchangesList = null;
      _getExchangeList();

      for (var value in marketListData) {
        if (value["symbol"] == symbol) {
          price = value["quotes"]["USD"]["price"];
          _priceController.text = price.toString();
          priceTextColor = validColor;
          break;
        }
      }

      exchange = "CCCAGG";
      setState(() {
        _exchangeController.text = "Aggregated";
        symbolTextColor = validColor;
      });

    } else {
      symbol = null;
      exchangesList = null;
      exchange = null;
      _exchangeController.text = "";
      price = null;
      _priceController.text = "";
      setState(() {
        symbolTextColor = errorColor;
      });
    }
  }

  _checkValidQuantity(String quantityString) {
    try {
      quantity = num.parse(quantityString);
      setState(() {
        quantityTextColor = validColor;
      });
    } catch (e) {
      quantity = null;
      setState(() {
        quantityTextColor = errorColor;
      });
    }
  }

  _checkValidPrice(String priceString) {
    try {
      price = num.parse(priceString);
      setState(() {
        priceTextColor = validColor;
      });
    } catch (e) {
      price = null;
      setState(() {
        priceTextColor = errorColor;
      });
    }
  }

  _handleSave() async {
    if (symbol != null && quantity != null && exchange != null && price != null) {
      print("WRITING TO JSON...");

      await getApplicationDocumentsDirectory().then((Directory directory) {
        File jsonFile = new File(directory.path + "/portfolio.json");
        if (jsonFile.existsSync()) {
          if (radioValue == 1) {
            quantity = -quantity;
          }

          Map newEntry = {
            "quantity":quantity,
            "price_usd":price,
            "exchange":exchange,
            "time_epoch":epochDate,
            "notes":_notesController.text //TODO: make sure this works
          };

          Map jsonContent = json.decode(jsonFile.readAsStringSync());

          if (jsonContent[symbol] != null) {
            jsonContent[symbol].add(newEntry);
          } else {
            jsonContent[symbol] = [];
            jsonContent[symbol].add(newEntry);
          }

          portfolioMap = jsonContent;
          jsonFile.writeAsStringSync(json.encode(jsonContent));

          print("WRITE SUCCESS");
          print(jsonContent);

          Navigator.of(context).pop();
          Scaffold.of(context).showSnackBar(
              new SnackBar(
                duration: new Duration(seconds: 5),
                content: new Text("Transaction Saved!"),
                action: new SnackBarAction(
                  label: "Undo",
                  onPressed: () {
                    jsonContent[symbol].removeLast();
                    jsonFile.writeAsStringSync(json.encode(jsonContent));

                    print("UNDID");
                    print(jsonContent);

                    widget.loadPortfolio();
                  },
                ),
              )
          );
        } else {
          print("FAILED - file does not exist");
        }
      });
      widget.loadPortfolio();
    }
  }

  Future<Null> _getExchangeList() async {
    var response = await http.get(
        Uri.encodeFull("https://min-api.cryptocompare.com/data/top/exchanges?fsym="+symbol+"&tsym=USD&limit=100"),
        headers: {"Accept": "application/json"}
    );

    exchangesList = [];

    List exchangeData = new JsonDecoder().convert(response.body)["Data"];
    exchangeData.forEach((value) => exchangesList.add(value["exchange"]));

    print("exchanges:");
    print(exchangesList);
  }

  @override
  void initState() {
    super.initState();
    _checkValidSymbol("");
    _makeEpoch();

    if (marketListData == null) {getMarketData();}

    symbolTextColor = errorColor;
    quantityTextColor = errorColor;
    priceTextColor = errorColor;
  }

  @override
  Widget build(BuildContext context) {
    validColor = Theme.of(context).textTheme.body2.color;
    return new Container(
        decoration: new BoxDecoration(
          border: new Border(top: new BorderSide(color: Theme.of(context).dividerColor)),
          color: Theme.of(context).primaryColor,
        ),
        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Text("Add Transaction", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2)),
            new Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Text("Buy", style: Theme.of(context).textTheme.caption),
                new Radio(value: 0, groupValue: radioValue, onChanged: _handleRadioValueChange,
                    activeColor: Theme.of(context).buttonColor),
                new Text("Sell", style: Theme.of(context).textTheme.caption),
                new Radio(value: 1, groupValue: radioValue, onChanged: _handleRadioValueChange,
                    activeColor: Theme.of(context).buttonColor),

                new Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0)),
                new GestureDetector(
                  onTap: () => _selectDate(),
                  child: new Text(
                      pickedDate.month.toString()
                          + "/" + pickedDate.day.toString()
                          + "/" + pickedDate.year.toString().substring(2),
                      style: Theme.of(context).textTheme.button
                  ),
                ),
                new Padding(padding: const EdgeInsets.symmetric(horizontal: 4.0)),
                new GestureDetector(
                  onTap: () => _selectTime(),
                  child: new Text(
                    (pickedTime.hourOfPeriod == 0 ? "12" : pickedTime.hourOfPeriod.toString()) + ":" +
                        (pickedTime.minute > 9 ? pickedTime.minute.toString() : "0" + pickedTime.minute.toString())
                        + (pickedTime.hour >= 12 ? "PM" : "AM"),
                    style: Theme.of(context).textTheme.button,
                  ),
                ),
                new Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0)),
              ],
            ),
            new Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                new Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width * 0.275,
                            padding: const EdgeInsets.only(right: 4.0, left: 16.0),
                            child: new TextField(
                              controller: _symbolController,
                              autofocus: true,
                              autocorrect: false,
                              onChanged: _checkValidSymbol,
                              style: Theme.of(context).textTheme.body2.apply(color: symbolTextColor),
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: "Symbol",
                              ),
                            ),
                          ),
                          new Container(
                            width: MediaQuery.of(context).size.width * 0.225,
                            padding: const EdgeInsets.only(right: 4.0),
                            child: new TextField(
                              controller: _quantityController,
                              autocorrect: false,
                              onChanged: _checkValidQuantity,
                              style: Theme.of(context).textTheme.body2.apply(color: quantityTextColor),
                              keyboardType: TextInputType.number,
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: "Quantity",
                              ),
                            ),
                          ),
                          new Container(
                            width: MediaQuery.of(context).size.width*0.2,
                            padding: const EdgeInsets.only(right: 4.0),
                            child: new TextField(
                              controller: _priceController,
                              autocorrect: false,
                              onChanged: _checkValidPrice,
                              style: Theme.of(context).textTheme.body2.apply(color: priceTextColor),
                              keyboardType: TextInputType.number,
                              decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Price",
                                  prefixText: "\$",
                                  prefixStyle: Theme.of(context).textTheme.body2.apply(color: priceTextColor)
                              ),
                            ),
                          )
                        ],
                      ),
                      new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Container(
                            width: MediaQuery.of(context).size.width * 0.275,
                            padding: const EdgeInsets.only(left: 16.0),
                            child: new PopupMenuButton(
                              itemBuilder: (BuildContext context) {
                                List<PopupMenuEntry<dynamic>> options = [
                                  new PopupMenuItem(
                                    child: new Text("Aggregated"),
                                    value: "CCCAGG",
                                  ),
                                ];
                                if (exchangesList != null && exchangesList.isEmpty != true) {
                                  options.add(new PopupMenuDivider());
                                  exchangesList.forEach((exchange) => options.add(
                                      new PopupMenuItem(
                                        child: new Text(exchange),
                                        value: exchange,
                                      )
                                  ));
                                }
                                return options;
                              },
                              onSelected: (selected) {
                                setState(() {
                                  exchange = selected;
                                  if (selected == "CCCAGG") {
                                    _exchangeController.text = "Aggregated";
                                  } else {
                                    _exchangeController.text = selected;
                                  }
                                });
                              },
                              child: new Text(
                                _exchangeController.text == "" ? "Exchange" : _exchangeController.text,
                                style: Theme.of(context).textTheme.body2.apply(color:
                                _exchangeController.text == "" ? Theme.of(context).hintColor : validColor
                                ),
                              ),
                            ),
                          ),
                          new Container(
                            width: MediaQuery.of(context).size.width*0.5,
                            child: new TextField(
                              controller: _notesController,
                              autocorrect: false,
                              style: Theme.of(context).textTheme.body2.apply(color: validColor),
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Notes"
                              ),
                            ),
                          )
                        ],
                      ),
                    ]),
                new Container(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: new FloatingActionButton(
                      child: Icon(Icons.check),
                      elevation: symbol != null && quantity != null && exchange != null && price != null ?
                      6.0 : 0.0,
                      backgroundColor:
                      symbol != null && quantity != null && exchange != null && price != null ?
                      Colors.green : Theme.of(context).disabledColor,
                      foregroundColor: Theme.of(context).iconTheme.color,
                      onPressed: _handleSave
                  ),
                )
              ],
            ),
          ],
        )
    );
  }
}