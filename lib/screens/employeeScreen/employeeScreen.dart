import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_app/screens/employeeScreen/orders_screen/my_order.dart';

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

class _EmployeeScreenState extends State<EmployeeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  appBar: appBar(text: widget.name),
      body: Container(
        child: MyOrder(id: widget.id),
      ),
    );
  }
}
