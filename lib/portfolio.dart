import 'package:flutter/material.dart';

class PortfolioPage extends StatefulWidget {
  PortfolioPage({Key key}) : super(key: key);

  @override
  PortfolioPageState createState() => new PortfolioPageState();
}

class PortfolioPageState extends State<PortfolioPage> {
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new CustomScrollView(
        slivers: <Widget>[
          new SliverList(
              delegate: new SliverChildListDelegate(<Widget>[

              ])
          ),

          new SliverList(delegate: new SliverChildBuilderDelegate(
            (context, index) => new ListTile(
              title: new Text("item $index"),
            ))
          )

        ],
    );
  }
}