import 'package:flutter/material.dart';
import '../repository/user_repository.dart';
import '../repository/device_repository.dart';
import '../models/user.dart';
import '../models/device.dart';
import '../widgets/user_tile.dart';
import '../widgets/device_tile.dart';

class DeviceScreen extends StatefulWidget {
  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen> {
  List<User> _users = <User>[];
  List<Device> _devices = <Device>[];

  @override
  void initState() {
    super.initState();
//    listenForUsers();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      centerTitle: true,
      title: Text('Blockchain Notifications'),
    ),
    body: ListView.builder(
      itemCount: _devices.length,
      itemBuilder: (context, index) => DeviceTile(_devices[index]),
    ),
    floatingActionButton: FloatingActionButton(
      onPressed: listenForDevices,
      tooltip: 'Increment',
      child: Icon(Icons.face),
    ), // This trailing comma makes auto-formatting nicer for build methods.
  );

  void listenForUsers() async {
    final Stream<User> stream = await getUsers();
    stream.listen((User user) =>
        setState(() => _users.add(user))
    );
  }

  void listenForDevices() async {
    final Stream<Device> stream = await getDevices();
    stream.listen((Device device) =>
        setState(() =>  _devices.add(device))
    );
  }
}
