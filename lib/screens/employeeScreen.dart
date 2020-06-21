import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shop_app/models/myOrderModel.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

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
    return Scaffold(
      appBar: appBar(text: widget.name),
      body: Container(
        child: StreamBuilder(
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
                        List<MyOrderModel> myOrderList = [];
                        for (var j = 0; j < ds['items'].length; j++) {
                          myOrderList.add(MyOrderModel(
                            name: ds['items'][j]['name'],
                            price: ds['items'][j]['sellPrice'],
                            quatity: ds['items'][j]['quantity'],
                          ));
                        }
                        bool noDelvier;
                        if (ds['address'] == '' && ds['lat'] == '') {
                          noDelvier = true;
                        } else {
                          noDelvier = false;
                        }
                        String status = ds['status'];
                        DateTime orderDate = DateTime.parse(ds['date']);
                        var formatter = new intl.DateFormat('dd/MM/yyyy');
                        var timeFormat = new intl.DateFormat.jm();
                        String formatDate = formatter.format(orderDate);
                        String formatTime = timeFormat.format(orderDate);

                        String formatted =
                            "تاريخ الطلب $formatDate  $formatTime";
                        bool mapNavgation;
                        if (ds['lat'] == '' ||
                            ds['long'] == '' ||
                            ds['lat'] == null ||
                            ds['long'] == null) {
                          mapNavgation = false;
                        } else {
                          mapNavgation = true;
                        }
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            checkDriverStatuse(),
                            Container(
                              height: 300,
                              color: Colors.grey,
                              child: InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) => Container(
                                      color: Colors.grey[100],
                                      width: MediaQuery.of(context).size.width,
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Column(
                                          children: [
                                            Table(
                                              columnWidths: {
                                                0: FractionColumnWidth(0.5)
                                              },
                                              border: TableBorder.all(),
                                              textDirection: TextDirection.rtl,
                                              children: [
                                                TableRow(children: [
                                                  Center(child: Text("المنتج")),
                                                  Center(child: Text("العدد")),
                                                  Center(child: Text("السعر")),
                                                ])
                                              ],
                                            ),
                                            Expanded(
                                              child: ListView.builder(
                                                  itemCount: myOrderList.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Container(
                                                        child: Table(
                                                      columnWidths: {
                                                        0: FractionColumnWidth(
                                                            0.5)
                                                      },
                                                      border: TableBorder.all(),
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      children: [
                                                        TableRow(children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Align(
                                                              alignment: Alignment
                                                                  .centerRight,
                                                              child: Text(
                                                                  myOrderList[
                                                                          index]
                                                                      .name),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Center(
                                                              child: Text(
                                                                  myOrderList[
                                                                          index]
                                                                      .quatity),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Center(
                                                              child: Text(
                                                                  myOrderList[
                                                                          index]
                                                                      .price),
                                                            ),
                                                          ),
                                                        ])
                                                      ],
                                                    ));
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: Card(
                                  color: status != '3'
                                      ? Colors.red[50]
                                      : Colors.white,
                                  child: Column(
                                    children: [
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
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Stack(
                                          children: [
                                            Positioned.fill(
                                              child: Align(
                                                alignment: Alignment(0, -0.3),
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
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
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: status == "0"
                                                              ? [
                                                                  Colors
                                                                      .lightGreen,
                                                                  Colors.green[
                                                                      800]
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
                                                        gradient:
                                                            LinearGradient(
                                                          colors: status == "1"
                                                              ? [
                                                                  Colors
                                                                      .lightGreen,
                                                                  Colors.green[
                                                                      800]
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
                                                      child: Icon(Icons
                                                          .shopping_basket),
                                                    ),
                                                    Text(
                                                      noDelvier
                                                          ? "جاهز للإستلام"
                                                          : "جاهز للتوصيل",
                                                      style: TextStyle(
                                                        color: status == "1"
                                                            ? Colors.black
                                                            : Colors.grey,
                                                      ),
                                                    )
                                                  ],
                                                ),
                                                noDelvier
                                                    ? Container()
                                                    : Column(
                                                        children: [
                                                          Container(
                                                            height: 50,
                                                            width: 50,
                                                            decoration:
                                                                BoxDecoration(
                                                              gradient:
                                                                  LinearGradient(
                                                                colors:
                                                                    status ==
                                                                            "2"
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
                                                                  BorderRadius
                                                                      .all(
                                                                Radius.circular(
                                                                    50),
                                                              ),
                                                            ),
                                                            child: Icon(Icons
                                                                .directions_car),
                                                          ),
                                                          Text(
                                                            "طلبك فالطريق",
                                                            style: TextStyle(
                                                              color: status ==
                                                                      "2"
                                                                  ? Colors.black
                                                                  : Colors.grey,
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                InkWell(
                                                  onLongPress: () {
                                                    Firestore.instance
                                                        .collection('order')
                                                        .where('orderID',
                                                            isEqualTo:
                                                                ds['orderID'])
                                                        .getDocuments()
                                                        .then((value) {
                                                      value.documents
                                                          .forEach((element) {
                                                        Firestore.instance
                                                            .collection('order')
                                                            .document(element
                                                                .documentID)
                                                            .updateData({
                                                          'status': '3'
                                                        });
                                                      });
                                                    });
                                                  },
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: status ==
                                                                    "3"
                                                                ? [
                                                                    Colors
                                                                        .lightGreen,
                                                                    Colors.green[
                                                                        800]
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
                                                        noDelvier
                                                            ? "تم التسليم"
                                                            : "تم التوصيل",
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Column(
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      
                                                      Text(
                                                        '${ds['total']} ر.س',
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                               
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(ds['name']),
                                                      FlatButton(
                                                          onPressed: () => launch(
                                                              "tel://${ds['phone']}"),
                                                          child: Text(
                                                              ds['phone'])),
                                                      noDelvier
                                                          ? Container()
                                                          : FlatButton.icon(
                                                              onPressed: () {
                                                                if (mapNavgation) {
                                                                  MapsLauncher.launchCoordinates(
                                                                      double.parse(ds[
                                                                          'lat']),
                                                                      double.parse(
                                                                          ds['long']));
                                                                } else {
                                                                  showModalBottomSheet(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) =>
                                                                            Container(
                                                                      color: Colors
                                                                              .grey[
                                                                          100],
                                                                      width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width,
                                                                      child: Padding(
                                                                          padding: const EdgeInsets.all(8.0),
                                                                          child: Container(
                                                                            height:
                                                                                MediaQuery.of(context).size.height / 2,
                                                                            child:
                                                                                Text(
                                                                              ds['address'],
                                                                              textDirection: TextDirection.rtl,
                                                                              textAlign: TextAlign.end,
                                                                              style: TextStyle(fontSize: 22),
                                                                            ),
                                                                          )),
                                                                    ),
                                                                  );
                                                                }
                                                              },
                                                              icon: Icon(
                                                                  Icons.map),
                                                              label: Text(
                                                                  "موقع التوصيل"),
                                                            ),
                                                    ],
                                                  ),
                                                  Text(
                                                    formatted,
                                                    textDirection:
                                                        TextDirection.rtl,
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
                      itemCount: snapshot.data.documents.length),
                );
              }
            }),
      ),
    );
  }
}
