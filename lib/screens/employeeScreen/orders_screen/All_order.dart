import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shop_app/models/employeeOrderList.dart';

class AllOrder extends StatefulWidget {
  final String id;

  const AllOrder({Key key, this.id}) : super(key: key);
  @override
  _AllOrderState createState() => _AllOrderState();
}

class _AllOrderState extends State<AllOrder> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[700],
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('order')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Container(
              height: 100,
              width: 100,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            List<EmployeeOrderList> orderList = [];
            for (var i = 0; i < snapshot.data.documents.length; i++) {
              String city = snapshot.data.documents[i]['city'];
              if ((snapshot.data.documents[i]['payment'] == "100" ||
                      snapshot.data.documents[i]['payment'] == "cash") &&
                  city.contains("RIYADH") &&
                  snapshot.data.documents[i]['driverID'] == "") {
                orderList.add(EmployeeOrderList(
                  date: snapshot.data.documents[i]['date'],
                  lat: snapshot.data.documents[i]['lat'],
                  long: snapshot.data.documents[i]['long'],
                  id: snapshot.data.documents[i].documentID,
                ));
              }
            }
//EmployeeOrderList
            return Container(
              width: double.infinity,
              child: ListView.builder(
                itemCount: orderList.length,
                itemBuilder: (context, i) {
                  DateTime orderDate = DateTime.parse(orderList[i].date);
                  var formatter = new intl.DateFormat('dd/MM/yyyy');
                  var timeFormat = new intl.DateFormat.jm();
                  String formatDate = formatter.format(orderDate);
                  String formatTime = timeFormat.format(orderDate);

                  String formatted = "$formatDate  $formatTime";
                  int numberOfOrder = i + 1;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      child: Container(
                        width: double.infinity,
                        color: Theme.of(context).unselectedWidgetColor,
                        child: Row(
                          children: [
                            Container(
                              margin: EdgeInsets.all(8.0),
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(100),
                                ),
                              ),
                              child: Text(
                                "$numberOfOrder",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FlatButton.icon(
                                    onPressed: () {
                                      MapsLauncher.launchCoordinates(
                                        double.parse(orderList[i].lat),
                                        double.parse(orderList[i].long),
                                      );
                                    },
                                    icon: Icon(Icons.map, color: Colors.white),
                                    label: Text(
                                      "موقع التوصيل",
                                      style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "MainFont"),
                                    ),
                                  ),
                                  Text(
                                    formatted,
                                    style: TextStyle(color: Colors.white),
                                  )
                                ],
                              ),
                            ),
                            Spacer(),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () async {
                                  await Firestore.instance
                                      .collection("order")
                                      .document(orderList[i].id)
                                      .updateData({'driverID': widget.id});
                                },
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: Colors.green,
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    "قبول",
                                    style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "MainFont"),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
