import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../main.dart';

class TransactionSheet extends StatefulWidget {
  TransactionSheet(
    this.loadPortfolio,
    this.marketListData, {
    Key key,
    this.editMode: false,
    this.snapshot,
    this.symbol,
  }) : super(key: key);

  final Function loadPortfolio;
  final List marketListData;

  final bool editMode;
  final Map snapshot;
  final String symbol;

  @override
  TransactionSheetState createState() => new TransactionSheetState();
}

class TransactionSheetState extends State<TransactionSheet> {
  TextEditingController _symbolController = new TextEditingController();
  TextEditingController _priceController = new TextEditingController();
  TextEditingController _quantityController = new TextEditingController();
  TextEditingController _exchangeController = new TextEditingController();
  TextEditingController _notesController = new TextEditingController();

  FocusNode _priceFocusNode = new FocusNode();
  FocusNode _quantityFocusNode = new FocusNode();
  FocusNode _notesFocusNode = new FocusNode();

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

  Color priceTextColor;
  num price;

  List exchangesList;
  String exchange;

  Map totalQuantities;

  _makeTotalQuantities() {
    totalQuantities = {};
    portfolioMap.forEach((symbol, transactions) {
      num total = 0;
      transactions.forEach((transaction) => total += transaction["quantity"]);
      totalQuantities[symbol] = total;
    });
    if (widget.editMode) {
      totalQuantities[widget.symbol] -= widget.snapshot["quantity"];
    }
  }

  _handleRadioValueChange(int value) {
    radioValue = value;
    _checkValidQuantity(_quantityController.text);
  }

  Future<Null> _selectDate() async {
    DateTime pick = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: new DateTime(1950),
        lastDate: new DateTime.now());
    if (pick != null) {
      setState(() {
        pickedDate = pick;
      });
      _makeEpoch();
    }
  }

  Future<Null> _selectTime() async {
    TimeOfDay pick = await showTimePicker(
        context: context, initialTime: new TimeOfDay.now());
    if (pick != null) {
      setState(() {
        pickedTime = pick;
      });
      _makeEpoch();
    }
  }

  _makeEpoch() {
    epochDate = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
            pickedTime.hour, pickedTime.minute)
        .millisecondsSinceEpoch;
  }

  _checkValidSymbol(String inputSymbol) async {
    if (symbolList == null || symbolList.isEmpty) {
      symbolList = [];
      widget.marketListData.forEach((value) => symbolList.add(value["symbol"]));
    }

    if (symbolList.contains(inputSymbol.toUpperCase())) {
      symbol = inputSymbol.toUpperCase();
      exchangesList = null;
      _getExchangeList();

      for (var value in widget.marketListData) {
        if (value["symbol"] == symbol) {
          price = value["quotes"]["USD"]["price"];
          _priceController.text = price.toString();
          priceTextColor = validColor;
          break;
        }
      }

      exchange = "CCCAGG";
      _exchangeController.text = "Aggregated";
      symbolTextColor = validColor;
      _checkValidQuantity(_quantityController.text);
    } else {
      symbol = null;
      exchangesList = null;
      exchange = null;
      _exchangeController.text = "";
      price = null;
      _priceController.text = "";
      symbolTextColor = errorColor;
      _checkValidQuantity(_quantityController.text);
    }
  }

  _checkValidQuantity(String quantityString) {
    try {
      quantity = num.parse(quantityString);
      if (quantity <= 0 ||
          radioValue == 1 && totalQuantities[symbol] - quantity < 0) {
        quantity = null;
        setState(() {
          quantityTextColor = errorColor;
        });
      } else {
        setState(() {
          quantityTextColor = validColor;
        });
      }
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
      if (price.isNegative) {
        price = null;
        setState(() {
          priceTextColor = errorColor;
        });
      } else {
        setState(() {
          priceTextColor = validColor;
        });
      }
    } catch (e) {
      price = null;
      setState(() {
        priceTextColor = errorColor;
      });
    }
  }

  _handleSave() async {
    if (symbol != null &&
        quantity != null &&
        exchange != null &&
        price != null) {
      print("WRITING TO JSON...");

      await getApplicationDocumentsDirectory().then((Directory directory) {
        File jsonFile = new File(directory.path + "/portfolio.json");
        if (jsonFile.existsSync()) {
          if (radioValue == 1) {
            quantity = -quantity;
          }

          Map newEntry = {
            "quantity": quantity,
            "price_usd": price,
            "exchange": exchange,
            "time_epoch": epochDate,
            "notes": _notesController.text
          };

          Map jsonContent = json.decode(jsonFile.readAsStringSync());
          if (jsonContent == null) {
            jsonContent = {};
          }

          try {
            jsonContent[symbol].add(newEntry);
          } catch (e) {
            jsonContent[symbol] = [];
            jsonContent[symbol].add(newEntry);
          }

          if (widget.editMode) {
            int index = 0;
            for (Map transaction in jsonContent[widget.symbol]) {
              if (transaction.toString() == widget.snapshot.toString()) {
                jsonContent[widget.symbol].removeAt(index);
                break;
              }
              index += 1;
            }
          }

          portfolioMap = jsonContent;
          jsonFile.writeAsStringSync(json.encode(jsonContent));

          print("WRITE SUCCESS");

          Navigator.of(context).pop();
        } else {
          jsonFile.createSync();
          jsonFile.writeAsStringSync("{}");
        }
      });
      widget.loadPortfolio();
    }
  }

  _deleteTransaction() async {
    await getApplicationDocumentsDirectory().then((Directory directory) {
      File jsonFile = new File(directory.path + "/portfolio.json");
      if (jsonFile.existsSync()) {
        Map jsonContent = json.decode(jsonFile.readAsStringSync());

        int index = 0;
        for (Map transaction in jsonContent[widget.symbol]) {
          if (transaction.toString() == widget.snapshot.toString()) {
            jsonContent[widget.symbol].removeAt(index);
            break;
          }
          index += 1;
        }

        if (jsonContent[widget.symbol].isEmpty) {
          jsonContent.remove(widget.symbol);
        }

        portfolioMap = jsonContent;
        Navigator.of(context).pop();
        jsonFile.writeAsStringSync(json.encode(jsonContent));

        Scaffold.of(context).showSnackBar(new SnackBar(
          duration: new Duration(seconds: 5),
          content: new Text("Transaction Deleted."),
          action: new SnackBarAction(
            label: "Undo",
            onPressed: () {
              if (jsonContent[widget.symbol] != null) {
                jsonContent[widget.symbol].add(widget.snapshot);
              } else {
                jsonContent[widget.symbol] = [];
                jsonContent[widget.symbol].add(widget.snapshot);
              }

              jsonFile.writeAsStringSync(json.encode(jsonContent));

              portfolioMap = jsonContent;

              widget.loadPortfolio();
            },
          ),
        ));
      }
    });
    widget.loadPortfolio();
  }

  Future<Null> _getExchangeList() async {
    var response = await http.get(
        Uri.encodeFull(
            "https://min-api.cryptocompare.com/data/top/exchanges?fsym=" +
                symbol +
                "&tsym=USD&limit=100"),
        headers: {"Accept": "application/json"});

    exchangesList = [];

    List exchangeData = new JsonDecoder().convert(response.body)["Data"];
    exchangeData.forEach((value) => exchangesList.add(value["exchange"]));
  }

  _initEditMode() {
    _symbolController.text = widget.symbol;
    _checkValidSymbol(_symbolController.text);

    _priceController.text = widget.snapshot["price_usd"].toString();
    _checkValidPrice(_priceController.text);

    _quantityController.text = widget.snapshot["quantity"].abs().toString();
    _checkValidQuantity(_quantityController.text);

    if (widget.snapshot["quantity"].isNegative) {
      radioValue = 1;
    }

    if (widget.snapshot["exchange"] == "CCCAGG") {
      _exchangeController.text = "Aggregated";
    } else {
      _exchangeController.text = widget.snapshot["exchange"];
    }
    exchange = widget.snapshot["exchange"];

    _notesController.text = widget.snapshot["notes"];

    pickedDate =
        new DateTime.fromMillisecondsSinceEpoch(widget.snapshot["time_epoch"]);
    pickedTime = new TimeOfDay.fromDateTime(pickedDate);
  }

  @override
  void initState() {
    super.initState();
    symbolTextColor = errorColor;
    quantityTextColor = errorColor;
    priceTextColor = errorColor;

    if (widget.editMode) {
      _initEditMode();
    }
    _makeTotalQuantities();
    _makeEpoch();
  }

  @override
  Widget build(BuildContext context) {
    validColor = Theme.of(context).textTheme.body2.color;
    return new Container(
        decoration: new BoxDecoration(
          border: new Border(
              top: new BorderSide(color: Theme.of(context).bottomAppBarColor)),
          color: Theme.of(context).primaryColor,
        ),
        padding: const EdgeInsets.only(
            top: 8.0, bottom: 8.0, right: 16.0, left: 16.0),
        child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
//                    new Container(
//                      padding: const EdgeInsets.symmetric(vertical: 4.0),
//                      child: new Text(widget.editMode ? "Edit Transaction" : "Add Transaction", style: Theme.of(context).textTheme.body2.apply(fontSizeFactor: 1.2, fontWeightDelta: 2))
//                    ),
                    new Row(
                      children: <Widget>[
                        new Text("Buy",
                            style: Theme.of(context).textTheme.caption),
                        new Radio(
                            value: 0,
                            groupValue: radioValue,
                            onChanged: _handleRadioValueChange,
                            activeColor: Theme.of(context).buttonColor),
                        new Text("Sell",
                            style: Theme.of(context).textTheme.caption),
                        new Radio(
                            value: 1,
                            groupValue: radioValue,
                            onChanged: _handleRadioValueChange,
                            activeColor: Theme.of(context).buttonColor),
                        new Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0)),
                        new GestureDetector(
                          onTap: () => _selectDate(),
                          child: new Text(
                              pickedDate.month.toString() +
                                  "/" +
                                  pickedDate.day.toString() +
                                  "/" +
                                  pickedDate.year.toString().substring(2),
                              style: Theme.of(context).textTheme.button),
                        ),
                        new Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 4.0)),
                        new GestureDetector(
                          onTap: () => _selectTime(),
                          child: new Text(
                            (pickedTime.hourOfPeriod == 0
                                    ? "12"
                                    : pickedTime.hourOfPeriod.toString()) +
                                ":" +
                                (pickedTime.minute > 9
                                    ? pickedTime.minute.toString()
                                    : "0" + pickedTime.minute.toString()) +
                                (pickedTime.hour >= 12 ? "PM" : "AM"),
                            style: Theme.of(context).textTheme.button,
                          ),
                        ),
                        new Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 6.0)),
                      ],
                    ),
                    new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          padding: const EdgeInsets.only(right: 4.0),
                          child: new TextField(
                            controller: _symbolController,
                            autofocus: true,
                            autocorrect: false,
                            textCapitalization: TextCapitalization.characters,
                            onChanged: _checkValidSymbol,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_quantityFocusNode),
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .apply(color: symbolTextColor),
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintText: "Symbol",
                            ),
                          ),
                        ),
                        new Container(
                          width: MediaQuery.of(context).size.width * 0.2,
                          padding: const EdgeInsets.only(right: 4.0),
                          child: new TextField(
                            focusNode: _quantityFocusNode,
                            controller: _quantityController,
                            autocorrect: false,
                            onChanged: _checkValidQuantity,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_priceFocusNode),
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .apply(color: quantityTextColor),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: new InputDecoration(
                              border: InputBorder.none,
                              hintText: "Quantity",
                            ),
                          ),
                        ),
                        new Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          padding: const EdgeInsets.only(right: 4.0),
                          child: new TextField(
                            focusNode: _priceFocusNode,
                            controller: _priceController,
                            autocorrect: false,
                            onChanged: _checkValidPrice,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_notesFocusNode),
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .apply(color: priceTextColor),
                            keyboardType: TextInputType.numberWithOptions(decimal: true),
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: "Price",
                                prefixText: "\$",
                                prefixStyle: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: priceTextColor)),
                          ),
                        )
                      ],
                    ),
                    new Row(
                      children: <Widget>[
                        new Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          child: new PopupMenuButton(
                            itemBuilder: (BuildContext context) {
                              List<PopupMenuEntry<dynamic>> options = [
                                new PopupMenuItem(
                                  child: new Text("Aggregated"),
                                  value: "CCCAGG",
                                ),
                              ];
                              if (exchangesList != null &&
                                  exchangesList.isEmpty != true) {
                                options.add(new PopupMenuDivider());
                                exchangesList.forEach(
                                    (exchange) => options.add(new PopupMenuItem(
                                          child: new Text(exchange),
                                          value: exchange,
                                        )));
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
                                FocusScope.of(context)
                                    .requestFocus(_notesFocusNode);
                              });
                            },
                            child: new Text(
                              _exchangeController.text == ""
                                  ? "Exchange"
                                  : _exchangeController.text,
                              style: Theme.of(context).textTheme.body2.apply(
                                  color: _exchangeController.text == ""
                                      ? Theme.of(context).hintColor
                                      : validColor),
                            ),
                          ),
                        ),
                        new Container(
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: new TextField(
                            focusNode: _notesFocusNode,
                            controller: _notesController,
                            autocorrect: true,
                            textCapitalization: TextCapitalization.none,
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .apply(color: validColor),
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                                border: InputBorder.none, hintText: "Notes"),
                          ),
                        ),
                      ],
                    )
                  ]),
              new Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  widget.editMode
                      ? new Container(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: new FloatingActionButton(
                              child: Icon(Icons.delete),
                              backgroundColor: Colors.red,
                              foregroundColor:
                                  Theme.of(context).iconTheme.color,
                              elevation: 2.0,
                              onPressed: _deleteTransaction),
                        )
                      : new Container(),
                  new Container(
                    child: new FloatingActionButton(
                        child: Icon(Icons.check),
                        elevation: symbol != null &&
                                quantity != null &&
                                exchange != null &&
                                price != null
                            ? 4.0
                            : 0.0,
                        backgroundColor: symbol != null &&
                                quantity != null &&
                                exchange != null &&
                                price != null
                            ? Colors.green
                            : Theme.of(context).disabledColor,
                        foregroundColor: Theme.of(context).iconTheme.color,
                        onPressed: _handleSave),
                  )
                ],
              )
            ]));
  }
}
