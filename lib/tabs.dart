import 'dart:async';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'main.dart';
import 'portfolio_item.dart';
import 'confirmerator_item.dart';
import 'models/device.dart';
import 'portfolio/portfolio_tabs.dart';
import 'portfolio/transaction_sheet.dart';
import 'confirmerator/wallet_sheet.dart';
import 'market_coin_item.dart';

class Tabs extends StatefulWidget {
  Tabs(
      {this.toggleTheme,
      this.savePreferences,
      this.handleUpdate,
      this.darkEnabled,
      this.themeMode,
      this.switchOLED,
      this.darkOLED});

  final Function toggleTheme;
  final Function handleUpdate;
  final Function savePreferences;

  final bool darkEnabled;
  final String themeMode;

  final Function switchOLED;
  final bool darkOLED;

  @override
  TabsState createState() => new TabsState();
}

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final String itemId = message['data']['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    ..value = message['data']['value']
    ..symbol = message['data']['symbol'];
  return item;
}

class Item {
  Item({this.itemId});
  final String itemId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;

  String _symbol;
  String get symbol => _symbol;
  set symbol(String value) {
    _symbol = value;
    _controller.add(this);
  }

  String _value;
  String get value => _value;
  set value(String value) {
    _value = value;
    _controller.add(this);
  }

  static final Map<String, Route<void>> routes = <String, Route<void>>{};
  Route<void> get route {
    final String routeName = '/detail/$itemId';
    return routes.putIfAbsent(
      routeName,
          () => MaterialPageRoute<void>(
        settings: RouteSettings(name: routeName),
        builder: (BuildContext context) => DetailPage(itemId),
      ),
    );
  }
}

class DetailPage extends StatefulWidget {
  DetailPage(this.itemId);
  final String itemId;
  @override
  _DetailPageState createState() => _DetailPageState();
}


class _DetailPageState extends State<DetailPage> {
  Item _item;
  StreamSubscription<Item> _subscription;

  @override
  void initState() {
    super.initState();
    _item = _items[widget.itemId];
    _subscription = _item.onChanged.listen((Item item) {
      if (!mounted) {
        _subscription.cancel();
      } else {
        setState(() {
          _item = item;
        });
      }
    });
  }

  // Screen that shows the message
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet ${_item.itemId}"),
      ),
      body: Material(
        child: Center(child: Text("Recieved: ${_item.value}")),
      ),
    );
  }
}

void _saveDevice(String deviceToken) async {
  // Obtain shared preferences
  final prefs = await SharedPreferences.getInstance();
  // Read token from store, return empty string if not found
  final storedToken = prefs.getString(deviceTokenName) ?? "";
  final confirmeratorID = prefs.getString(userID) ?? "";

  if (storedToken.length != 0 && storedToken == deviceToken
      || confirmeratorID.length != 0) {
    print("DeviceID hasn't changed");
    print("Stored userID $storedToken");
    print("CurrentUserID $deviceToken");
    return;
  }
  print("DeviceID changed!!!");
  prefs.setString(deviceTokenName, deviceToken);

  Device newDevice;
  newDevice = Device(42, true, confirmeratorID, deviceToken);
  String json = jsonEncode(newDevice);
  var client = new http.Client();
  try {
    var response = await client.post(testEnv + ApiDevice,
        body: json);
    print('Device update response status: ${response.statusCode}');
    if (response.statusCode == 200) {
      Map<String, dynamic> newDevice = jsonDecode(response.body);
      print("!!!! Hey the ID is:  ${newDevice['id']}");
    }
    prefs.setString(userID, response.headers["id"]);
  } finally {
    client.close();
  }
}

class TabsState extends State<Tabs> with SingleTickerProviderStateMixin {
  TabController _tabController;
  TextEditingController _textController = new TextEditingController();
  int _tabIndex = 0;
  bool _isConfTab = false;

  bool isSearching = false;
  String filter;

  bool sheetOpen = false;

  int radioValue = 0;
  DateTime pickedDate = new DateTime.now();
  TimeOfDay pickedTime = new TimeOfDay.now();
  int epochDate;

  num price;
  num quantity;
  String notes;
  String symbol;
  String exchange;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  // The pop-up dialog that shows if the app is in focus when notified
  Widget _buildDialog(BuildContext context, Item item) {
    return AlertDialog(
      content: Text("Account ${item.itemId} recieved a deposit"),
      actions: <Widget>[
        FlatButton(
          child: const Text('CLOSE'),
          onPressed: () {
            Navigator.pop(context, false);
          },
        ),
        FlatButton(
          child: const Text('SHOW'),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
      ],
    );
  }

  void _showItemDialog(Map<String, dynamic> message) {
    showDialog<bool>(
      context: context,
      builder: (_) => _buildDialog(context, _itemForMessage(message)),
    ).then((bool shouldNavigate) {
      if (shouldNavigate == true) {
        _navigateToItemDetail(message);
      }
    });
  }

  // TODO have this navigate to the portfolio symbol
  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  _makeEpoch() {
    epochDate = new DateTime(pickedDate.year, pickedDate.month, pickedDate.day,
        pickedTime.hour, pickedTime.minute)
        .millisecondsSinceEpoch;
  }

  _handleConfirmation(Map<String, dynamic> message) async {
    final Item item = _itemForMessage(message);
    notes = "Walllet: " + item.itemId.toString();
    symbol = item.symbol;
    exchange = "CCCAGG";
    quantity = double.parse(item.value);

    await _refreshMarketPage();
    _makeEpoch();

    for (var value in marketListData) {
      if (value["symbol"] == symbol) {
        price = value["quotes"]["USD"]["price"];
        break;
      }
    }

    if (symbol != null &&
        quantity != null &&
        exchange != null &&
        price != null) {
      print("WRITING TO JSON...\n");
      print("SYMBOL: [ " + symbol + " ] QUANTITIY: [ " + quantity.toString() +
          " ] EXCHANGE: [ " + exchange + " ] PRICE: [ " + price.toString() +
          " ] NOTE: [ " + notes + " ]");

      await getApplicationDocumentsDirectory().then((Directory directory) {
        // Add to both lists
        File jsonPortfolioFile = new File(directory.path + "/portfolio.json");

        Map newEntry = {
          "quantity": quantity,
          "price_usd": price,
          "exchange": exchange,
          "time_epoch": epochDate,
          "notes": notes,
          "confirmerator": true
        };

        if (jsonPortfolioFile.existsSync()) {

          Map jsonContent = json.decode(jsonPortfolioFile.readAsStringSync());
          if (jsonContent == null) {
            jsonContent = {};
          }

          try {
            jsonContent[symbol].add(newEntry);
          } catch (e) {
            jsonContent[symbol] = [];
            jsonContent[symbol].add(newEntry);
          }

          portfolioMap = jsonContent;
          jsonPortfolioFile.writeAsStringSync(json.encode(jsonContent));

          print("WRITE SUCCESS");
        } else {
          jsonPortfolioFile.createSync();
          jsonPortfolioFile.writeAsStringSync("{}");
        }
      });
    }

    _refreshPortfolioPage();
//    _showItemDialog(message);
  }

  _handleFilter(value) {
    if (value == null) {
      isSearching = false;
      filter = null;
    } else {
      filter = value;
      isSearching = true;
    }
    _filterMarketData();
    setState(() {});
  }

  _startSearch() {
    setState(() {
      isSearching = true;
    });
  }

  _stopSearch() {
    setState(() {
      isSearching = false;
      filter = null;
      _textController.clear();
      _filterMarketData();
    });
  }

  _handleTabChange() {
    _tabIndex = _tabController.animation.value.round();
    if (isSearching) {
      _stopSearch();
    } else {
      setState(() {});
    }
    if (_tabIndex == 2) {
      _isConfTab = true;
    } else {
      _isConfTab = false;
    }
  }

  _openTransaction() {
    setState(() {
      sheetOpen = true;
    });
    _scaffoldKey.currentState
        .showBottomSheet((BuildContext context) {
          return new TransactionSheet(
            () {
              setState(() {
                _makePortfolioDisplay();
              });
            },
            marketListData,
          );
        })
        .closed
        .whenComplete(() {
          setState(() {
            sheetOpen = false;
          });
        });
  }

  _addWallet() {
    setState(() {
      sheetOpen = true;
    });
    _scaffoldKey.currentState
        .showBottomSheet((BuildContext context) {
      return new WalletSheet(
            () {
          setState(() {
            _makePortfolioDisplay();
          });
        },
        marketListData,
      );
    })
        .closed
        .whenComplete(() {
      setState(() {
        sheetOpen = false;
      });
    });
  }

  _makePortfolioDisplay() {
    print("making portfolio display");
    Map portfolioTotals = {};
    List neededPriceSymbols = [];

    portfolioMap.forEach((coin, transactions) {
      num quantityTotal = 0;
      transactions.forEach((value) {
        // TODO check to see if quantity is empty
        // This happened when adding new and CMC couldn't be reached.
        quantityTotal += value["quantity"];
      });
      portfolioTotals[coin] = quantityTotal;
      neededPriceSymbols.add(coin);
    });

    portfolioDisplay = [];
    num totalPortfolioValue = 0;
    marketListData.forEach((coin) {
      if (neededPriceSymbols.contains(coin["symbol"]) &&
          portfolioTotals[coin["symbol"]] != 0) {
        portfolioDisplay.add({
          "symbol": coin["symbol"],
          "price_usd": coin["quotes"]["USD"]["price"],
          "percent_change_24h": coin["quotes"]["USD"]["percent_change_24h"],
          "percent_change_7d": coin["quotes"]["USD"]["percent_change_7d"],
          "total_quantity": portfolioTotals[coin["symbol"]],
          "id": coin["id"],
          "name": coin["name"],
        });
        totalPortfolioValue +=
            (portfolioTotals[coin["symbol"]] * coin["quotes"]["USD"]["price"]);
      }
    });

    num total24hChange = 0;
    num total7dChange = 0;
    portfolioDisplay.forEach((coin) {
      total24hChange += (coin["percent_change_24h"] *
          ((coin["price_usd"] * coin["total_quantity"]) / totalPortfolioValue));
      total7dChange += (coin["percent_change_7d"] *
          ((coin["price_usd"] * coin["total_quantity"]) / totalPortfolioValue));
    });

    totalPortfolioStats = {
      "value_usd": totalPortfolioValue,
      "percent_change_24h": total24hChange,
      "percent_change_7d": total7dChange
    };

    _sortPortfolioDisplay();
  }

  _makeConfirmeratorDisplay() {
    print("making confirmerator display");
    List neededPriceSymbols = [];
    num trackedWallets = 0;
    num availableWallets = 5;
    num totalWalletDeposits = 0;

    confirmeratorDisplay = [];
    confirmeratorMap.forEach((coin, wallets) {
      wallets.forEach((value) {
        print("Wallet loop: " + value.toString());

        if (value["track"] == true) {
          ++trackedWallets;
        }

        confirmeratorDisplay.add({
          "id": value["id"],
          "symbol": coin.toString(),
          "walletAddr": value["walletAddr"],
          "nickname": value["nickname"],
          "track": value["track"],
          "id": value["id"],
          "name": value["name"],
        });
      });

      neededPriceSymbols.add(coin);
    });

    portfolioMap.forEach((coin, transactions) {
      transactions.forEach((value) {
        print("Transaction loop: " + value.toString());
        if (value["confirmerator"] == true) {
          ++totalWalletDeposits;
        }
      });
    });

    totalConfirmationStats = {
      "total_deposits": totalWalletDeposits,
      "numWalletsTracking": trackedWallets,
      "numWalletsAvailable": availableWallets - trackedWallets,
    };

    _sortConfirmeratorDisplay();
  }

  _initFirebase() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _handleConfirmation(message);
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _handleConfirmation(message);
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _handleConfirmation(message);
        _navigateToItemDetail(message);
      },
    );

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _saveDevice(token);
      print(token);
    });
  }

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(length: 3, vsync: this);
    _tabController.animation.addListener(() {
      if (_tabController.animation.value.round() != _tabIndex) {
        _handleTabChange();
      }
    });

    _initFirebase();
    _makePortfolioDisplay();
    _makeConfirmeratorDisplay();
    _filterMarketData();
    _refreshMarketPage();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  ScrollController _scrollController = new ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        drawer: new Drawer(
            child: new Scaffold(
                bottomNavigationBar: new Container(
                    decoration: new BoxDecoration(
                        border: new Border(
                      top: new BorderSide(
                          color: Theme.of(context).bottomAppBarColor),
                    )),
                    child: new ListTile(
                      onTap: widget.toggleTheme,
                      leading: new Icon(
                          widget.darkEnabled
                              ? Icons.brightness_3
                              : Icons.brightness_7,
                          color: Theme.of(context).buttonColor),
                      title: new Text(widget.themeMode,
                          style: Theme.of(context)
                              .textTheme
                              .body2
                              .apply(color: Theme.of(context).buttonColor)),
                    )),
                body: new ListView(
                  children: <Widget>[
                    new ListTile(
                      leading: new Icon(Icons.settings),
                      title: new Text("Settings"),
                      onTap: () => Navigator.pushNamed(context, "/settings"),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.timeline),
                      title: new Text("Portfolio Timeline"),
                      onTap: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  new PortfolioTabs(0, _makePortfolioDisplay))),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.pie_chart_outlined),
                      title: new Text("Portfolio Breakdown"),
                      onTap: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  new PortfolioTabs(1, _makePortfolioDisplay))),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.pie_chart_outlined),
                      title: new Text("Confirmerator Breakdown"),
                      onTap: () => Navigator.push(
                          context,
                          new MaterialPageRoute(
                              builder: (context) =>
                                  new PortfolioTabs(2, _makeConfirmeratorDisplay()))),
                    ),
                    new Container(
                      decoration: new BoxDecoration(
                          border: new Border(
                              bottom: new BorderSide(
                                  color: Theme.of(context).bottomAppBarColor,
                                  width: 1.0))),
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                    ),
                    new ListTile(
                      leading: new Icon(Icons.short_text),
                      title: new Text("Abbreviate Numbers"),
                      trailing: new Switch(
                          activeColor: Theme.of(context).accentColor,
                          value: shortenOn,
                          onChanged: (onOff) {
                            setState(() {
                              shortenOn = onOff;
                            });
                            widget.savePreferences();
                          }),
                      onTap: () {
                        setState(() {
                          shortenOn = !shortenOn;
                        });
                        widget.savePreferences();
                      },
                    ),
                    new ListTile(
                      leading: new Icon(Icons.opacity),
                      title: new Text("OLED Dark Mode"),
                      trailing: new Switch(
                        activeColor: Theme.of(context).accentColor,
                        value: widget.darkOLED,
                        onChanged: (onOff) {
                          widget.switchOLED(state: onOff);
                        },
                      ),
                      onTap: widget.switchOLED,
                    ),
                  ],
                ))),
        floatingActionButton: _addNewFAB(context),
        body: new NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              new SliverAppBar(
                title: [
                  new Text("Portfolio"),
                  isSearching
                      ? new TextField(
                          controller: _textController,
                          autocorrect: false,
                          keyboardType: TextInputType.text,
                          style: Theme.of(context).textTheme.subhead,
                          onChanged: (value) => _handleFilter(value),
                          autofocus: true,
                          textCapitalization: TextCapitalization.none,
                          decoration: new InputDecoration.collapsed(
                              hintText: 'Search names and symbols...'),
                        )
                      : new GestureDetector(
                          onTap: () => _startSearch(),
                          child: _tabText()
                        ),
                ][1], // TODO - why are we going out of bounds @ index 3
                actions: <Widget>[
                  [
                    new Container(),
                    isSearching
                        ? new IconButton(
                            icon: new Icon(Icons.close),
                            onPressed: () => _stopSearch())
                        : new IconButton(
                            icon: new Icon(Icons.search,
                                color:
                                    Theme.of(context).primaryIconTheme.color),
                            onPressed: () => _startSearch()),
                    new Container()
                  ][1],
                ],
                pinned: true,
                floating: true,
                titleSpacing: 3.0,
                elevation: appBarElevation,
                forceElevated: innerBoxIsScrolled,
                bottom: new PreferredSize(
                    preferredSize: const Size.fromHeight(38.0),
                    child: new Container(
                      height: 38.0,
                      child: new TabBar(
                        controller: _tabController,
                        indicatorColor: Theme.of(context).accentIconTheme.color,
                        unselectedLabelColor: Theme.of(context).disabledColor,
                        labelColor: Theme.of(context).accentIconTheme.color,
                        tabs: <Tab>[
                          new Tab(icon: new Icon(Icons.person)),
                          new Tab(icon: new Icon(Icons.filter_list)),
                          new Tab(icon: new Icon(Icons.alarm)),
                        ],
                      ),
                    )),
              )
            ];
          },
          body: new TabBarView(
            controller: _tabController,
            // TODO Add tab here!
            children: [portfolioPage(context), marketPage(context), confirmeratorPage(context)],
          ),
        ));
  }

  Text _tabText() {
    Text tabLabel;
    switch (_tabIndex) {
      case 0:
        tabLabel = Text("Portfolio");
        break;
      case 1:
        tabLabel = Text("Aggregate Market");
        break;
      case 2:
        tabLabel = Text("Confirmerator");
        break;
    }

    return tabLabel;
  }

  Widget _addNewFAB(BuildContext context) {
    String _label;
    String _toolTipClose;
    String _toolTipOpen;
    if (_tabIndex == 0) {
      _label        = "Add Transaction";
      _toolTipClose = "Close Transaction";
      _toolTipOpen  = "Add Transaction";
    } else if (_tabIndex == 1) {
      return null;
    } else if (_tabIndex == 2) {
      _label        = "Add Wallet";
      _toolTipClose = "Close Wallet";
      _toolTipOpen  = "Add Wallet";
    }
    return sheetOpen
        ? new FloatingActionButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Icon(Icons.close),
            foregroundColor: Theme.of(context).iconTheme.color,
            backgroundColor: Theme.of(context).accentIconTheme.color,
            elevation: 4.0,
            tooltip: _toolTipClose,
          )
        : new FloatingActionButton.extended(
              onPressed: _tabIndex == 0 ? _openTransaction : _addWallet,
              icon: Icon(Icons.add),
              label: new Text(_label),
              foregroundColor: Theme.of(context).iconTheme.color,
              backgroundColor: Theme.of(context).accentIconTheme.color,
              elevation: 4.0,
              tooltip: _toolTipOpen,
        );
  }

  final portfolioColumnProps = [.25, .35, .3];

  Future<Null> _refreshPortfolioPage() async {
    await getMarketData();
    getGlobalData();
    _makePortfolioDisplay();
    _filterMarketData();
    setState(() {});
  }

  List portfolioSortType = ["holdings", true];
  List sortedPortfolioDisplay;
  _sortPortfolioDisplay() {
    sortedPortfolioDisplay = portfolioDisplay;
    if (portfolioSortType[1]) {
      if (portfolioSortType[0] == "holdings") {
        sortedPortfolioDisplay.sort((a, b) =>
            (b["price_usd"] * b["total_quantity"])
                .toDouble()
                .compareTo((a["price_usd"] * a["total_quantity"]).toDouble()));
      } else {
        sortedPortfolioDisplay.sort((a, b) =>
            b[portfolioSortType[0]].compareTo(a[portfolioSortType[0]]));
      }
    } else {
      if (portfolioSortType[0] == "holdings") {
        sortedPortfolioDisplay.sort((a, b) =>
            (a["price_usd"] * a["total_quantity"])
                .toDouble()
                .compareTo((b["price_usd"] * b["total_quantity"]).toDouble()));
      } else {
        sortedPortfolioDisplay.sort((a, b) =>
            a[portfolioSortType[0]].compareTo(b[portfolioSortType[0]]));
      }
    }
  }

  List confirmeratorSortType = ["holdings", true];
  List sortedConfirmeratorDisplay;
  _sortConfirmeratorDisplay() {
    sortedConfirmeratorDisplay = confirmeratorDisplay;
    if (confirmeratorSortType[1]) {
      if (confirmeratorSortType[0] == "holdings") {
        sortedConfirmeratorDisplay.sort((a, b) =>
            b["nickname"].compareTo(a["nickname"]));
      } else {
        sortedConfirmeratorDisplay.sort((a, b) =>
            b[confirmeratorSortType[0]].compareTo(a[confirmeratorSortType[0]]));
      }
    } else {
      if (confirmeratorSortType[0] == "holdings") {
        sortedConfirmeratorDisplay.sort((a, b) =>
            a["nickname"].compareTo(b["nickname"]));
      } else {
        sortedConfirmeratorDisplay.sort((a, b) =>
            a[confirmeratorSortType[0]].compareTo(b[confirmeratorSortType[0]]));
      }
    }
  }

  final PageStorageKey _marketKey = new PageStorageKey("market");
  final PageStorageKey _portfolioKey = new PageStorageKey("portfolio");
  final PageStorageKey _confirmeratorKey = new PageStorageKey("confirmerator");

  Widget portfolioPage(BuildContext context) {
    return new RefreshIndicator(
        key: _portfolioKey,
        onRefresh: _refreshPortfolioPage,
        child: new CustomScrollView(
          slivers: <Widget>[
            new SliverList(
                delegate: new SliverChildListDelegate(<Widget>[
              new Container(
                padding: const EdgeInsets.only(
                    left: 10.0, right: 10.0, top: 10.0, bottom: 4.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text("Total Portfolio Value",
                            style: Theme.of(context).textTheme.caption),
                        new Text(
                            "\$" +
                                numCommaParse(totalPortfolioStats["value_usd"]
                                    .toStringAsFixed(2)),
                            style: Theme.of(context)
                                .textTheme
                                .body2
                                .apply(fontSizeFactor: 2.2)),
                      ],
                    ),
                    new Column(
                      children: <Widget>[
                        new Text("7D Change",
                            style: Theme.of(context).textTheme.caption),
                        new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0)),
                        new Text(
                            totalPortfolioStats["percent_change_7d"] >= 0
                                ? "+" +
                                    totalPortfolioStats["percent_change_7d"]
                                        .toStringAsFixed(2) +
                                    "%"
                                : totalPortfolioStats["percent_change_7d"]
                                        .toStringAsFixed(2) +
                                    "%",
                            style:
                                Theme.of(context).primaryTextTheme.body2.apply(
                                      color: totalPortfolioStats[
                                                  "percent_change_7d"] >=
                                              0
                                          ? Colors.green
                                          : Colors.red,
                                      fontSizeFactor: 1.4,
                                    ))
                      ],
                    ),
                    new Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        new Text("24h Change",
                            style: Theme.of(context).textTheme.caption),
                        new Padding(
                            padding: const EdgeInsets.symmetric(vertical: 1.0)),
                        new Text(
                            totalPortfolioStats["percent_change_24h"] >= 0
                                ? "+" +
                                    totalPortfolioStats["percent_change_24h"]
                                        .toStringAsFixed(2) +
                                    "%"
                                : totalPortfolioStats["percent_change_24h"]
                                        .toStringAsFixed(2) +
                                    "%",
                            style: Theme.of(context)
                                .primaryTextTheme
                                .body2
                                .apply(
                                    color: totalPortfolioStats[
                                                "percent_change_24h"] >=
                                            0
                                        ? Colors.green
                                        : Colors.red,
                                    fontSizeFactor: 1.4))
                      ],
                    ),
                  ],
                ),
              ),
              new Container(
                margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                decoration: new BoxDecoration(
                    border: new Border(
                        bottom: new BorderSide(
                            color: Theme.of(context).dividerColor,
                            width: 1.0))),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new InkWell(
                      onTap: () {
                        if (portfolioSortType[0] == "symbol") {
                          portfolioSortType[1] = !portfolioSortType[1];
                        } else {
                          portfolioSortType = ["symbol", false];
                        }
                        setState(() {
                          _sortPortfolioDisplay();
                        });
                      },
                      child: new Container(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[0],
                        child: portfolioSortType[0] == "symbol"
                            ? new Text(
                                portfolioSortType[1] == true
                                    ? "Currency " + upArrow
                                    : "Currency " + downArrow,
                                style: Theme.of(context).textTheme.body2)
                            : new Text(
                                "Currency",
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: Theme.of(context).hintColor),
                              ),
                      ),
                    ),
                    new InkWell(
                      onTap: () {
                        if (portfolioSortType[0] == "holdings") {
                          portfolioSortType[1] = !portfolioSortType[1];
                        } else {
                          portfolioSortType = ["holdings", true];
                        }
                        setState(() {
                          _sortPortfolioDisplay();
                        });
                      },
                      child: new Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[1],
                        child: portfolioSortType[0] == "holdings"
                            ? new Text(
                                portfolioSortType[1] == true
                                    ? "Holdings " + downArrow
                                    : "Holdings " + upArrow,
                                style: Theme.of(context).textTheme.body2)
                            : new Text("Holdings",
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: Theme.of(context).hintColor)),
                      ),
                    ),
                    new InkWell(
                      onTap: () {
                        if (portfolioSortType[0] == "percent_change_24h") {
                          portfolioSortType[1] = !portfolioSortType[1];
                        } else {
                          portfolioSortType = ["percent_change_24h", true];
                        }
                        setState(() {
                          _sortPortfolioDisplay();
                        });
                      },
                      child: new Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[2],
                        child: portfolioSortType[0] == "percent_change_24h"
                            ? new Text(
                                portfolioSortType[1] == true
                                    ? "Price/24h " + downArrow
                                    : "Price/24h " + upArrow,
                                style: Theme.of(context).textTheme.body2)
                            : new Text("Price/24h",
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: Theme.of(context).hintColor)),
                      ),
                    ),
                  ],
                ),
              ),
            ])),
            portfolioMap.isNotEmpty
                ? new SliverList(
                    delegate: new SliverChildBuilderDelegate(
                        (context, index) => new PortfolioListItem(
                            sortedPortfolioDisplay[index], portfolioColumnProps),
                        childCount: sortedPortfolioDisplay != null
                            ? sortedPortfolioDisplay.length
                            : 0))
                : new SliverFillRemaining(
                    child: new Container(
                        alignment: Alignment.topCenter,
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                                "Your portfolio is empty. Add a transaction!",
                                style: Theme.of(context).textTheme.caption),
                            new Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0)),
                            new RaisedButton(
                              onPressed: _openTransaction,
                              child: new Text("New Transaction",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body2
                                      .apply(
                                          color: Theme.of(context)
                                              .iconTheme
                                              .color)),
                            )
                          ],
                        ))),
          ],
        ));
  }

  Widget confirmeratorPage(BuildContext context) {
    return new RefreshIndicator(
        key: _confirmeratorKey,
        onRefresh: _refreshPortfolioPage,
        child: new CustomScrollView(
          slivers: <Widget>[
            new SliverList(
                delegate: new SliverChildListDelegate(<Widget>[
                  new Container(
                    padding: const EdgeInsets.only(
                        left: 10.0, right: 10.0, top: 10.0, bottom: 4.0),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Text("Total Deposits ",
                                style: Theme.of(context).textTheme.caption),
                            new Text(
                                    numCommaParse(totalConfirmationStats["total_deposits"]
                                        .toStringAsFixed(2)),
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(fontSizeFactor: 2.2)),
                          ],
                        ),
                        new Column(
                          children: <Widget>[
                            new Text("Wallets Being Tracked",
                                style: Theme.of(context).textTheme.caption),
                            new Padding(
                                padding: const EdgeInsets.symmetric(vertical: 1.0)),
                            new Text(
                                totalConfirmationStats["numWalletsTracking"] >= 0
                                    ?
                                    totalConfirmationStats["numWalletsTracking"]
                                        .toStringAsFixed(2)
                                    : totalConfirmationStats["numWalletsTracking"]
                                    .toStringAsFixed(2),
                                style:
                                Theme.of(context).primaryTextTheme.body2.apply(
                                  color: totalConfirmationStats[
                                  "numWalletsTracking"] >=
                                      5
                                      ? Colors.green
                                      : Colors.red,
                                  fontSizeFactor: 1.4,
                                ))
                          ],
                        ),
                        new Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            new Text("Available To Track",
                                style: Theme.of(context).textTheme.caption),
                            new Padding(
                                padding: const EdgeInsets.symmetric(vertical: 1.0)),
                            new Text(
                                totalConfirmationStats["numWalletsAvailable"] >= 0
                                    ? "+"
                                    : totalConfirmationStats["numWalletsAvailable"]
                                    .toStringAsFixed(2),
                                style: Theme.of(context)
                                    .primaryTextTheme
                                    .body2
                                    .apply(
                                    color: totalConfirmationStats[
                                    "numWalletsAvailable"] >=
                                        0
                                        ? Colors.red
                                        : Colors.green,
                                    fontSizeFactor: 1.4))
                          ],
                        ),
                      ],
                    ),
                  ),
                  new Container(
                    margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            bottom: new BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1.0))),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new InkWell(
                          onTap: () {
                            if (portfolioSortType[0] == "symbol") {
                              portfolioSortType[1] = !portfolioSortType[1];
                            } else {
                              portfolioSortType = ["symbol", false];
                            }
//                            setState(() {
//                              _sortPortfolioDisplay();
//                            });
                          },
                          child: new Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[0],
                            child: portfolioSortType[0] == "symbol"
                                ? new Text(
                                portfolioSortType[1] == true
                                    ? "Currency " + upArrow
                                    : "Currency " + downArrow,
                                style: Theme.of(context).textTheme.body2)
                                : new Text(
                              "Currency",
                              style: Theme.of(context)
                                  .textTheme
                                  .body2
                                  .apply(color: Theme.of(context).hintColor),
                            ),
                          ),
                        ),
                        new InkWell(
                          onTap: () {
                            if (portfolioSortType[0] == "holdings") {
                              portfolioSortType[1] = !portfolioSortType[1];
                            } else {
                              portfolioSortType = ["holdings", true];
                            }
//                            setState(() {
//                              _sortPortfolioDisplay();
//                            });
                          },
                          child: new Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[1],
                            child: new Text(
                                "Name",
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: Theme.of(context).hintColor)
                            ),
                          ),
                        ),
                        new InkWell(
                          onTap: () {
                            if (portfolioSortType[0] == "total_deposit_30d") {
                              portfolioSortType[1] = !portfolioSortType[1];
                            } else {
                              portfolioSortType = ["total_deposit_30d", true];
                            }
//                            setState(() {
//                              _sortPortfolioDisplay();
//                            });
                          },
                          child: new Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width:
                            MediaQuery.of(context).size.width * portfolioColumnProps[2],
                            child: Text(
                                "Name",
                                style: Theme.of(context)
                                    .textTheme
                                    .body2
                                    .apply(color: Theme.of(context).hintColor)
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
            confirmeratorMap.isNotEmpty
                ? new SliverList(
                delegate: new SliverChildBuilderDelegate(
                        (context, index) => new ConfirmeratorListItem(
                            sortedConfirmeratorDisplay[index], portfolioColumnProps),
                    childCount: sortedConfirmeratorDisplay != null
                        ? sortedConfirmeratorDisplay.length
                        : 0))
                : new SliverFillRemaining(
                child: new Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: new Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        new Text(
                            "No wallets found. Add a wallet!",
                            style: Theme.of(context).textTheme.caption),
                        new Padding(
                            padding:
                            const EdgeInsets.symmetric(vertical: 8.0)),
                        new RaisedButton(
                          onPressed: _addWallet,
                          child: new Text("New Wallet",
                              style: Theme.of(context)
                                  .textTheme
                                  .body2
                                  .apply(
                                  color: Theme.of(context)
                                      .iconTheme
                                      .color)),
                        )
                      ],
                    ))),
          ],
        ));
  }

  final marketColumnProps = [.32, .35, .28];
  List filteredMarketData;
  Map globalData;

  Future<Null> getGlobalData() async {
    var response = await http.get(
        Uri.encodeFull("https://api.coinmarketcap.com/v2/global/"),
        headers: {"Accept": "application/json"});

//    print("\n\nCMC Global response: \n" + response.body + "\n\n");
    globalData = new JsonDecoder().convert(response.body)["data"]["quotes"]["USD"];
  }

  Future<Null> _refreshMarketPage() async {
    await getMarketData();
    await getGlobalData();
    _makePortfolioDisplay();
    _filterMarketData();
    setState(() {});
  }

  _filterMarketData() {
    print("filtering market data");
    filteredMarketData = marketListData;
    if (filter != "" && filter != null) {
      List tempFilteredMarketData = [];
      filteredMarketData.forEach((item) {
        if (item["symbol"].toLowerCase().contains(filter.toLowerCase()) ||
            item["name"].toLowerCase().contains(filter.toLowerCase())) {
          tempFilteredMarketData.add(item);
        }
      });
      filteredMarketData = tempFilteredMarketData;
    }
    _sortMarketData();
  }

  List marketSortType = ["market_cap", true];
  _sortMarketData() {
    if (marketSortType[1]) {
      if (marketSortType[0] == "market_cap" ||
          marketSortType[0] == "volume_24h" ||
          marketSortType[0] == "percent_change_24h") {
        filteredMarketData.sort((a, b) => (b["quotes"]["USD"][marketSortType[0]] ?? 0)
            .compareTo(a["quotes"]["USD"][marketSortType[0]] ?? 0));
      } else {
        filteredMarketData.sort(
            (a, b) => (b[marketSortType[0]] ?? 0).compareTo(a[marketSortType[0]] ?? 0));
      }
    } else {
      if (marketSortType[0] == "market_cap" ||
          marketSortType[0] == "volume_24h" ||
          marketSortType[0] == "percent_change_24h") {

        filteredMarketData.sort((a, b) => (a["quotes"]["USD"][marketSortType[0]] ?? 0)
            .compareTo(b["quotes"]["USD"][marketSortType[0]] ?? 0));
      } else {
        filteredMarketData.sort(
            (a, b) => (a[marketSortType[0]] ?? 0).compareTo(b[marketSortType[0]] ?? 0));
      }
    }
  }

  Widget marketPage(BuildContext context) {
    return filteredMarketData != null
        ? new RefreshIndicator(
            key: _marketKey,
            onRefresh: () => _refreshMarketPage(),
            child: new CustomScrollView(
              slivers: <Widget>[
                new SliverList(
                    delegate: new SliverChildListDelegate(<Widget>[
                  globalData != null && isSearching != true
                      ? new Container(
                          padding: const EdgeInsets.all(10.0),
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  new Text("Total Market Cap",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .apply(
                                              color:
                                                  Theme.of(context).hintColor)),
                                  new Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 1.0)),
                                  new Text("Total 24h Volume",
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .apply(
                                              color:
                                                  Theme.of(context).hintColor)),
                                ],
                              ),
                              new Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 1.0)),
                              new Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  new Text(
                                      "\$" +
                                          normalizeNum(
                                              globalData["total_market_cap"]),
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .apply(
                                              fontSizeFactor: 1.2,
                                              fontWeightDelta: 2)),
                                  new Text(
                                      "\$" +
                                          normalizeNum(
                                              globalData["total_volume_24h"]),
                                      style: Theme.of(context)
                                          .textTheme
                                          .body2
                                          .apply(
                                              fontSizeFactor: 1.2,
                                              fontWeightDelta: 2)),
                                ],
                              )
                            ],
                          ))
                      : new Container(),
                  new Container(
                    margin: const EdgeInsets.only(left: 6.0, right: 6.0),
                    decoration: new BoxDecoration(
                        border: new Border(
                            bottom: new BorderSide(
                                color: Theme.of(context).dividerColor,
                                width: 1.0))),
                    child: new Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new InkWell(
                          onTap: () {
                            if (marketSortType[0] == "symbol") {
                              marketSortType[1] = !marketSortType[1];
                            } else {
                              marketSortType = ["symbol", false];
                            }
                            setState(() {
                              _sortMarketData();
                            });
                          },
                          child: new Container(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width: MediaQuery.of(context).size.width *
                                marketColumnProps[0],
                            child: marketSortType[0] == "symbol"
                                ? new Text(
                                    marketSortType[1]
                                        ? "Currency " + upArrow
                                        : "Currency " + downArrow,
                                    style: Theme.of(context).textTheme.body2)
                                : new Text("Currency",
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .apply(
                                            color:
                                                Theme.of(context).hintColor)),
                          ),
                        ),
                        new Container(
                          width: MediaQuery.of(context).size.width *
                              marketColumnProps[1],
                          child: new Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              new InkWell(
                                  onTap: () {
                                    if (marketSortType[0] == "market_cap") {
                                      marketSortType[1] = !marketSortType[1];
                                    } else {
                                      marketSortType = ["market_cap", true];
                                    }
                                    setState(() {
                                      _sortMarketData();
                                    });
                                  },
                                  child: new Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
                                    child: marketSortType[0] == "market_cap"
                                        ? new Text(
                                            marketSortType[1]
                                                ? "Market Cap " + downArrow
                                                : "Market Cap " + upArrow,
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2)
                                        : new Text("Market Cap",
                                            style: Theme.of(context)
                                                .textTheme
                                                .body2
                                                .apply(
                                                    color: Theme.of(context)
                                                        .hintColor)),
                                  )),
                              new Text("/",
                                  style: Theme.of(context)
                                      .textTheme
                                      .body2
                                      .apply(
                                          color: Theme.of(context).hintColor)),
                              new InkWell(
                                onTap: () {
                                  if (marketSortType[0] == "volume_24h") {
                                    marketSortType[1] = !marketSortType[1];
                                  } else {
                                    marketSortType = ["volume_24h", true];
                                  }
                                  setState(() {
                                    _sortMarketData();
                                  });
                                },
                                child: new Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: marketSortType[0] == "volume_24h"
                                      ? new Text(
                                          marketSortType[1] ? "24h " + downArrow : "24h " + upArrow,
                                          style:
                                              Theme.of(context).textTheme.body2)
                                      : new Text("24h",
                                          style: Theme.of(context)
                                              .textTheme
                                              .body2
                                              .apply(
                                                  color: Theme.of(context)
                                                      .hintColor)),
                                ),
                              )
                            ],
                          ),
                        ),
                        new InkWell(
                          onTap: () {
                            if (marketSortType[0] == "percent_change_24h") {
                              marketSortType[1] = !marketSortType[1];
                            } else {
                              marketSortType = ["percent_change_24h", true];
                            }
                            setState(() {
                              _sortMarketData();
                            });
                          },
                          child: new Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            width: MediaQuery.of(context).size.width *
                                marketColumnProps[2],
                            child: marketSortType[0] == "percent_change_24h"
                                ? new Text(
                                    marketSortType[1] == true
                                        ? "Price/24h " + downArrow
                                        : "Price/24h " + upArrow,
                                    style: Theme.of(context).textTheme.body2)
                                : new Text("Price/24h",
                                    style: Theme.of(context)
                                        .textTheme
                                        .body2
                                        .apply(
                                            color:
                                                Theme.of(context).hintColor)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ])),
                filteredMarketData.isEmpty
                    ? new SliverList(
                        delegate: new SliverChildListDelegate(<Widget>[
                        new Container(
                          padding: const EdgeInsets.all(30.0),
                          alignment: Alignment.topCenter,
                          child: new Text("No results found",
                              style: Theme.of(context).textTheme.caption),
                        )
                      ]))
                    : new SliverList(
                        delegate: new SliverChildBuilderDelegate(
                            (BuildContext context, int index) =>
                                new CoinListItem(filteredMarketData[index],
                                    marketColumnProps),
                            childCount: filteredMarketData == null
                                ? 0
                                : filteredMarketData.length))
              ],
            ))
        : new Container(
            child: new Center(child: new CircularProgressIndicator()),
          );
  }
}
