import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';

import '../main.dart';
import '../models/account.dart';

const int ChainBitcoin = 1;
const int ChainEthereum = 2;
const int ChainEthereumClassic = 3;
const int ChainBitcoinCash = 4;
const int ChainCallisto = 5;
const int ChainRavenCoin = 6;


class WalletSheet extends StatefulWidget {
  WalletSheet(
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
  WalletSheetState createState() => new WalletSheetState();
}

class WalletSheetState extends State<WalletSheet> {
  TextEditingController _symbolController = new TextEditingController();
  TextEditingController _nickNameController = new TextEditingController();
  TextEditingController _notesController = new TextEditingController();

  FocusNode _quantityFocusNode = new FocusNode();
  FocusNode _nicknameNode = new FocusNode();
  FocusNode _notesFocusNode = new FocusNode();

  Color errorColor = Colors.red;
  Color validColor = Colors.green;

  bool trackInPortfolio = true;
  DateTime pickedDate = new DateTime.now();
  TimeOfDay pickedTime = new TimeOfDay.now();
  int epochDate;

  List symbolList;
  List exchangesList;

  String nickname;
  String symbolDropdownValue = "ETH";
  String walletAddress;
  String symbol = "";

  num quantity;
  num price;

  Color priceTextColor;
  Color symbolTextColor;

  // TODO send to server?
  // Omitted the brackets '{}' and are using fat arrow '=>' instead, this is dart syntax
  _handleRadioValueChange(bool value) => setState(() => trackInPortfolio = value);
  _handleDropdownValueChange(String value) {
    print("Symbol selected: " + value);
    setState(() => symbol = value);
    setState(() => symbolDropdownValue = value);
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
      setState(() {
        symbolTextColor = validColor;
      });

    } else {
      symbol = null;
      exchangesList = null;
      price = null;
      setState(() {
        symbolTextColor = errorColor;
      });

    }
  }

  _handleSave() async {
    if (walletAddress == null) {
      _scanQR();
    }

    if (symbol == null ||
        _nickNameController.text == null) {
      return;
    }

    print("Tracking?: " + trackInPortfolio.toString());
    print("Wallet Address: " + walletAddress);
    print("Symbol: " + symbol);
    final prefs = await SharedPreferences.getInstance();
    // Read token from store, return empty string if not found
    final confirmeratorID = prefs.getString(userID) ?? "";
    if (confirmeratorID.length == 0) {
      print("ERROR: don't have userID :(");
      return;
    }

    // Testing - Don't send to server.
//    trackInPortfolio = false;

    String walletID;
    if (trackInPortfolio) {
      // TODO send to server for notifications
      Account newAccount;
      newAccount = Account(ChainEthereum, 42, symbol, walletAddress, _notesController.text, confirmeratorID);
      String json = jsonEncode(newAccount);
      var client = new http.Client();
      try {
        var response = await client.post(testEnv + ApiAccount,
            body: json);
        print('Device update response status: ${response.statusCode}');
        if (response.statusCode == 200) {
          Map<String, dynamic> newDevice = jsonDecode(response.body);
          print("!!!! Hey the ID is:  ${newDevice['id']}");
          walletID = newDevice['id'];
        }
      } finally {
        client.close();
      }
    }

    print("WRITING TO JSON...");
    await getApplicationDocumentsDirectory().then((Directory directory) {
      File jsonFile = new File(directory.path + "/confirmerator.json");
      if (jsonFile.existsSync()) {

        Map newEntry = {
          "id": walletID,
          "userid": confirmeratorID,
          "walletAddr": walletAddress,
          "blockchain": symbol,
          "nickname": _nickNameController.text,
          "track": trackInPortfolio,
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

  _deleteWallet() async {
    await getApplicationDocumentsDirectory().then((Directory directory) {
      File jsonFile = new File(directory.path + "/confirmerator.json");
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

  Future<String> _scanQR() async {
    String qrcode = await BarcodeScanner.scan();
//      print("!!!!! Whoa Nelly, to many accounts");
//      Navigator.of(context).pop();
//      return null;
    print("\n\n!!!!!  QR Code: " + qrcode + "\n\n");
    setState(() {
      walletAddress = qrcode;
    });

    return qrcode;
  }

  _initEditMode() {
    _symbolController.text = widget.symbol;
    _checkValidSymbol(_symbolController.text);
    symbol = widget.symbol;

    _nickNameController.text = widget.snapshot["nickname"];
    nickname = widget.snapshot["nickname"];

    _notesController.text = widget.snapshot["notes"];
  }

  @override
  void initState() {
    super.initState();
    symbolTextColor = errorColor;

    _scanQR();

    if (widget.editMode) {
      _initEditMode();
    }
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
                    new Row(
                      children: <Widget>[
                        new Text("Track in Portfolio with Confirmerator",
                            style: Theme.of(context).textTheme.caption),
                        new Checkbox(
                            value: trackInPortfolio,
                            onChanged: _handleRadioValueChange,
                            activeColor: Theme.of(context).buttonColor),
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
//                        new Container(
//                          width: MediaQuery.of(context).size.width * 0.25,
//                          padding: const EdgeInsets.only(right: 4.0),
//                          child: new DropdownButton<String>(
//                            items: <String>['BTC', 'BCH', 'ETH', 'ETC'].map((String value) {
//                              return new DropdownMenuItem<String>(
//                                value: value,
//                                child: new Text(value),
//                              );
//                            }).toList(),
//                              onChanged: (newValue) {
//                                _handleDropdownValueChange(newValue);
//                              },
//                          )
//                        ),
                        new Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          padding: const EdgeInsets.only(left: 4.0),
                          child: new TextField(
                            focusNode: _nicknameNode,
                            controller: _nickNameController,
                            autocorrect: false,
//                            onChanged: _checkValidPrice,
                            onSubmitted: (_) => FocusScope.of(context)
                                .requestFocus(_notesFocusNode),
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .apply(color: validColor),
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: "Nickname",
                                ),
                          ),
                        )
                      ],
                    ),
                    new Row(
                      children: <Widget>[
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
                        onPressed: _deleteWallet),
                  )
                      : new Container(),
                  new Container(
                    child: new FloatingActionButton(
                        child: Icon(Icons.check),
                        elevation: 4.0,
                        backgroundColor: Colors.green,
                        foregroundColor: Theme.of(context).iconTheme.color,
                        onPressed: _handleSave),
                  )
                ],
              )
            ]));
  }
}
