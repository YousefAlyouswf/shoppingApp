import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/models/tabModels.dart';
import 'package:shop_app/screens/employeeScreen/orders_screen/my_order.dart';
import 'package:shop_app/screens/employeeScreen/orders_screen/All_order.dart';

class EmployeeScreen extends StatefulWidget {
  final String name;
  final String city;
  final LatLng latLng;
  final String phone;
  final String accept;
  final String id;

  const EmployeeScreen(
      {Key key,
      this.name,
      this.city,
      this.latLng,
      this.phone,
      this.accept,
      this.id})
      : super(key: key);
  @override
  _EmployeeScreenState createState() => _EmployeeScreenState();
}

class _EmployeeScreenState extends State<EmployeeScreen>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<TabModels> pages = [
    TabModels(
      "طلبات توصيل",
      Icon(Icons.people),
    ),
    TabModels(
      "طلباتي",
      Icon(Icons.person),
    ),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              icon: FaIcon(FontAwesomeIcons.signOutAlt),
              onPressed: () {
                HelperFunction.emplyeeLogin("");
                Navigator.pop(context);
              })
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: pages[0].text,
                icon: pages[0].icon,
              ),
              Tab(
                text: pages[1].text,
                icon: pages[1].icon,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AllOrder(id: widget.id),
          MyOrder(id: widget.id),
        ],
      ),
    );
  }
}
