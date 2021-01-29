import 'package:flutter/material.dart';
import 'package:bottle_crm/ui/widgets/side_menu.dart';
import 'package:bottle_crm/utils/utils.dart';

class EventsList extends StatefulWidget {
  EventsList();
  @override
  State createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: Scaffold(
          appBar: AppBar(
            title: Text("Events"),
          ),
          drawer: SideMenuDrawer(),
          body: Center(
            child: Text("This page under Development..."),
          )),
    );
  }
}
