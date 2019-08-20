import 'package:flutter/material.dart';
import '../models/user.dart';

class UserTile extends StatelessWidget {
  final User _user;
  UserTile(this._user);

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      ListTile(
        title: Text(_user.nickname),
        subtitle: Text(_user.uid),
//        leading: Container(
//            margin: EdgeInsets.only(left: 6.0),
//            child: Image.network(_user.image_url, height: 50.0, fit: BoxFit.fill,)
//        ),
      ),
      Divider()
    ],
  );
}