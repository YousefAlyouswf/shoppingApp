import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class MyOrder extends StatefulWidget {
  final String id;

  const MyOrder({Key key, this.id}) : super(key: key);

  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  Widget checkDriverStatuse() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('employee')
            .where('id', isEqualTo: widget.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          if (snapshot.data.documents[0]['accept'] != '1') {
            Navigator.pop(context);
          }
          return Container();
        });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('order')
          .where('driverID', isEqualTo: widget.id)
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
          return Container(
            width: double.infinity,
            child: ListView.builder(
              itemBuilder: (context, i) {
                DocumentSnapshot ds = snapshot.data.documents[i];

                String status = ds['status'];
                DateTime orderDate = DateTime.parse(ds['date']);
                var formatter = new intl.DateFormat('dd/MM/yyyy');
                var timeFormat = new intl.DateFormat.jm();
                String formatDate = formatter.format(orderDate);
                String formatTime = timeFormat.format(orderDate);

                String formatted = "تاريخ الطلب $formatDate  $formatTime";

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    checkDriverStatuse(),
                    Container(
                      height: 300,
                      color: Colors.grey,
                      child: InkWell(
                        onTap: () {},
                        child: Card(
                          color:
                              status != '3' ? Colors.green[200] : Colors.white,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      await Firestore.instance
                                          .collection("order")
                                          .document(ds.documentID)
                                          .updateData({'driverID': ''});
                                    },
                                    child: Text(
                                      "إلغاء الطلبية",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(new ClipboardData(
                                          text: ds['orderID']));
                                      Scaffold.of(context)
                                        ..showSnackBar(
                                          new SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: new Text("تم النسخ"),
                                          ),
                                        );
                                    },
                                    child: Text(
                                      "رقم الطلب: ${ds['orderID']}",
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(fontSize: 19),
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: Align(
                                        alignment: Alignment(0, -0.3),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16.0),
                                          child: Container(
                                            height: 3,
                                            width: double.infinity,
                                            color: Colors.black45,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: status == "0"
                                                      ? [
                                                          Colors.lightGreen,
                                                          Colors.green[800]
                                                        ]
                                                      : [
                                                          Colors.grey,
                                                          Colors.white
                                                        ],
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(50),
                                                ),
                                              ),
                                              child: Icon(Icons.store),
                                            ),
                                            Text(
                                              "أستلمنا طلبك",
                                              style: TextStyle(
                                                color: status == "0"
                                                    ? Colors.black
                                                    : Colors.grey,
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: status == "1"
                                                      ? [
                                                          Colors.lightGreen,
                                                          Colors.green[800]
                                                        ]
                                                      : [
                                                          Colors.grey,
                                                          Colors.white
                                                        ],
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(50),
                                                ),
                                              ),
                                              child:
                                                  Icon(Icons.shopping_basket),
                                            ),
                                            Text(
                                              "جاهز للتوصيل",
                                              style: TextStyle(
                                                color: status == "1"
                                                    ? Colors.black
                                                    : Colors.grey,
                                              ),
                                            )
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              width: 50,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: status == "2"
                                                      ? [
                                                          Colors.lightGreen,
                                                          Colors.green[800]
                                                        ]
                                                      : [
                                                          Colors.grey,
                                                          Colors.white
                                                        ],
                                                ),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(50),
                                                ),
                                              ),
                                              child: Icon(Icons.directions_car),
                                            ),
                                            Text(
                                              "طلبك فالطريق",
                                              style: TextStyle(
                                                color: status == "2"
                                                    ? Colors.black
                                                    : Colors.grey,
                                              ),
                                            )
                                          ],
                                        ),
                                        InkWell(
                                          onLongPress: () {
                                            if (ds['status'] == '2') {
                                              Firestore.instance
                                                  .collection('order')
                                                  .where('orderID',
                                                      isEqualTo: ds['orderID'])
                                                  .getDocuments()
                                                  .then((value) {
                                                value.documents
                                                    .forEach((element) {
                                                  Firestore.instance
                                                      .collection('order')
                                                      .document(
                                                          element.documentID)
                                                      .updateData(
                                                          {'status': '3'});
                                                });
                                              });
                                            }
                                          },
                                          child: Column(
                                            children: [
                                              Container(
                                                height: 50,
                                                width: 50,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    colors: status == "3"
                                                        ? [
                                                            Colors.lightGreen,
                                                            Colors.green[800]
                                                          ]
                                                        : [
                                                            Colors.grey,
                                                            Colors.white
                                                          ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(50),
                                                  ),
                                                ),
                                                child: Icon(Icons.home),
                                              ),
                                              Text(
                                                "تم التوصيل",
                                                style: TextStyle(
                                                  color: status == "3"
                                                      ? Colors.black
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              Column(
                                                children: [
                                                  Text(
                                                    "${ds['firstName']} ${ds['lastName']}",
                                                  ),
                                                  FlatButton(
                                                    onPressed: () => launch(
                                                        "tel://${ds['phone']}"),
                                                    child: Text(
                                                      ds['phone'],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${ds['total']} ر.س',
                                                textDirection:
                                                    TextDirection.rtl,
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              FlatButton.icon(
                                                onPressed: () {
                                                  MapsLauncher
                                                      .launchCoordinates(
                                                    double.parse(ds['lat']),
                                                    double.parse(
                                                      ds['long'],
                                                    ),
                                                  );
                                                },
                                                icon: Icon(Icons.map),
                                                label: Text("موقع التوصيل"),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            formatted,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              itemCount: snapshot.data.documents.length,
            ),
          );
        }
      },
    );
  }
}
