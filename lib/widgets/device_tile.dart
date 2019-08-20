import 'package:flutter/material.dart';
import '../models/device.dart';

class DeviceTile extends StatelessWidget {
  final Device _device;
  DeviceTile(this._device);

  @override
  Widget build(BuildContext context) => Column(
    children: <Widget>[
      ListTile(
        title: Text(_device.identifier),
        subtitle: Text(_device.active.toString()),
//        leading: Container(
//            margin: EdgeInsets.only(left: 6.0),
//            child: Image.network(_device.image_url, height: 50.0, fit: BoxFit.fill,)
//        ),
      ),
      Divider()
    ],
  );
}