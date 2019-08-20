import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:barcode_scan/barcode_scan.dart';
import '../repository/user_repository.dart';
import '../repository/device_repository.dart';
import '../models/user.dart';
import '../models/device.dart';
import '../widgets/user_tile.dart';
import '../widgets/device_tile.dart';

GoogleSignIn _googleSignIn = GoogleSignIn(
  scopes: [
    'email',
    'profile',
  ],
);
List<String> walletAccounts;
const String deviceTokenName = "deviceToken";
const String walletAccountName = "walletAccounts";

final Map<String, Item> _items = <String, Item>{};
Item _itemForMessage(Map<String, dynamic> message) {
  final String itemId = message['data']['id'];
  final Item item = _items.putIfAbsent(itemId, () => Item(itemId: itemId))
    ..status = message['data']['status'];
  return item;
}

class Item {
  Item({this.itemId});
  final String itemId;

  StreamController<Item> _controller = StreamController<Item>.broadcast();
  Stream<Item> get onChanged => _controller.stream;

  String _status;
  String get status => _status;
  set status(String value) {
    _status = value;
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
        title: Text("Item ${_item.itemId}"),
      ),
      body: Material(
        child: Center(child: Text("Recieved: ${_item.status}")),
      ),
    );
  }
}

class GoogleSignInAuthentication {
  GoogleSignInAuthentication._(this._data);

  final Map<String, dynamic> _data;

  /// An OpenID Connect ID token that identifies the user.
  String get idToken => _data['idToken'];

  /// The OAuth2 access token to access Google services.
  String get accessToken => _data['accessToken'];

  @override
  String toString() => 'GoogleSignInAuthentication:$_data';
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String _homeScreenText = "Waiting for token...";
  bool _topicButtonsDisabled = false;
  GoogleSignInAccount _currentUser;
  String _idToken;
  String displayName;
  String email;
  String id;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TextEditingController _topicController =
  TextEditingController(text: 'topic');

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

  void _navigateToItemDetail(Map<String, dynamic> message) {
    final Item item = _itemForMessage(message);
    // Clear away dialogs
    Navigator.popUntil(context, (Route<dynamic> route) => route is PageRoute);
    if (!item.route.isCurrent) {
      Navigator.push(context, item.route);
    }
  }

  @override
  void initState() {
    super.initState();
    _handleSignIn();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _navigateToItemDetail(message);
      },
    );

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        print("~~~~~~~~~ Logged in!!!!!!!");
        print("User: " + _currentUser.email);
        print("Name: " + _currentUser.displayName);
        print("id: " + _currentUser.id);
      }
    });
    _googleSignIn.signInSilently();

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _startUpStuff(token);
      setState(() {
        _homeScreenText = "TODO - List currently saved addresses?";
      });
      print(_homeScreenText);
      print(token);
    });
  }

  void _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  void _addWallet() async {
    // Scan QR
    String qrcode = await BarcodeScanner.scan();
    print("!!!!!  QR Code: " + qrcode);

    if (walletAccounts.length >= 5) {
      print("!!!!! Whoa Nelly, to many accounts");
    } else {
      setState(() {
        walletAccounts.add(qrcode);
      });
    }

    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(walletAccountName, walletAccounts);


  }

  FloatingActionButton getActionButton() {
    if (_currentUser != null) {
      return FloatingActionButton(
        onPressed: _addWallet,
        child: const Icon(Icons.account_balance),
      );
    } else {
      return FloatingActionButton(
        onPressed: _handleSignIn,
        child: const Icon(Icons.account_circle),
      );
    }
  }

  ListView walletView() {
    return ListView(
      children: <Widget>[
        ListTile(
          leading: Icon(Icons.map),
          title: Text('Map'),
        ),
        ListTile(
          leading: Icon(Icons.photo_album),
          title: Text('Album'),
        ),
        ListTile(
          leading: Icon(Icons.phone),
          title: Text('Phone'),
        ),
      ],
    );
  }

  Material noWalletView() {
    return Material(
      child: Column(
        children: <Widget>[
          Center(
            child: Text(_homeScreenText),
          ),
          Row(children: <Widget>[
            Expanded(
              child: TextField(
                  controller: _topicController,
                  onChanged: (String v) {
                    setState(() {
                      _topicButtonsDisabled = v.isEmpty;
                    });
                  }),
            ),
            FlatButton(
              child: const Text("subscribe"),
              onPressed: _topicButtonsDisabled
                  ? null
                  : () {
                _firebaseMessaging
                    .subscribeToTopic(_topicController.text);
                _clearTopicText();
              },
            ),
            FlatButton(
              child: const Text("unsubscribe"),
              onPressed: _topicButtonsDisabled
                  ? null
                  : () {
                _firebaseMessaging
                    .unsubscribeFromTopic(_topicController.text);
                _clearTopicText();
              },
            ),
          ])
        ],
      ),
    );
}

  Widget hasWallet() {
    var hasWallet = false;

    if (hasWallet) {
      return walletView();
    } else {
      return noWalletView();
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Blockchain Notifications'),
        ),
        floatingActionButton: getActionButton(),
        body: hasWallet(),
    );
  }
}

void _startUpStuff(String deviceToken) async {
  // Obtain shared preferences
  final prefs = await SharedPreferences.getInstance();
  // Read token from store, return empty string if not found
  final storedToken = prefs.getString(deviceTokenName) ?? "";

  if (storedToken != deviceToken) {
    _notifyServer(deviceToken);
    print("DeviceID changed");
    prefs.setString(deviceTokenName, deviceToken);
  }
  
  // Get the walletAccounts
  walletAccounts = prefs.getStringList(walletAccountName);
}

void _notifyServer(String deviceToken) async {

}

void _clearTopicText() {
//  setState(() {
//    _topicController.text = "";
//    _topicButtonsDisabled = true;
//  });
}

void main() {
  runApp(
    MaterialApp(
      home: Home(),
    ),
  );
}

