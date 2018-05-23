import 'package:flutter/material.dart';

import 'package:flutter_sparkline/flutter_sparkline.dart';

class PortfolioTimeline extends StatefulWidget {
  @override
  PortfolioTimelineState createState() => new PortfolioTimelineState();
}

class PortfolioTimelineState extends State<PortfolioTimeline> {


  @override
  Widget build(BuildContext context) {
    return new RefreshIndicator(
      onRefresh: () {},
      child: new Column(

      )
    );
  }
}