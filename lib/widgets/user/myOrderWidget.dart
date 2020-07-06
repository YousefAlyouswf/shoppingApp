import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shop_app/models/myOrderModel.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';

import '../widgets.dart';

class OrderWidget extends StatefulWidget {
  @override
  _OrderWidgetState createState() => _OrderWidgetState();
}

class _OrderWidgetState extends State<OrderWidget> {
  String userID;
  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosDeviceInfo;
  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
      userID = androidInfo.androidId;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
      userID = iosDeviceInfo.identifierForVendor;
    }
  }

  @override
  void initState() {
    super.initState();
    deviceID();
  }

  @override
  Widget build(BuildContext context) {
    return orderScreen(context, userID);
  }
}

Widget orderScreen(BuildContext context, String userID) {
  return Container(
    height: MediaQuery.of(context).size.height,
    width: double.infinity,
    child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('order')
            .where("userID", isEqualTo: userID)
            //.orderBy('date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(""),
            );
          } else {
            return Container(
              width: double.infinity,
              child: ListView.builder(
                  itemBuilder: (context, i) {
                    DocumentSnapshot ds = snapshot.data.documents[i];
                    List<MyOrderModel> myOrderList = [];
                    try {
                      for (var j = 0; j < ds['items'].length; j++) {
                        myOrderList.add(MyOrderModel(
                          name: ds['items'][j]['name'],
                          price: ds['items'][j]['sellPrice'],
                          quatity: ds['items'][j]['quantity'],
                        ));
                      }
                    } catch (e) {
                      print("ERROR in my orderScreen List length");
                    }

                    bool noDelvier;
                    if (ds['address'] == '' && ds['lat'] == '') {
                      noDelvier = true;
                    } else {
                      noDelvier = false;
                    }
                    String status;
                    DateTime orderDate;
                    var formatter;
                    var timeFormat;
                    String formatDate;
                    String formatTime;
                    try {
                      if (ds['date'] == "") {
                      } else {
                        status = ds['status'];
                        orderDate = DateTime.parse(ds['date']);
                        formatter = new intl.DateFormat('dd/MM/yyyy');
                        timeFormat = new intl.DateFormat.jm();
                        formatDate = formatter.format(orderDate);
                        formatTime = timeFormat.format(orderDate);
                      }
                    } catch (e) {
                      print("ERROR in my orderScreen date");
                    }

                    String formatted =
                        "${word("order_date", context)} $formatDate  $formatTime";
                    return ds['date'] == ""
                        ? Container()
                        : Column(
                            children: [
                              Container(
                                height: 120,
                                child: InkWell(
                                  onTap: () {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (context) => Container(
                                        color: Colors.grey[100],
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Column(
                                                    children: [
                                                      InkWell(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                            new ClipboardData(
                                                              text:
                                                                  ds['orderID'],
                                                            ),
                                                          );
                                                          addCartToast(word(
                                                              "copy", context));
                                                        },
                                                        child: Text(
                                                          "${word("order_num", context)} ${ds['orderID']}",
                                                          style: TextStyle(
                                                              fontSize: 19),
                                                        ),
                                                      ),
                                                      //Order Date
                                                      Text(
                                                        formatted,
                                                      ),
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        child: Text(
                                                          '${ds['total']} ${word("currancy", context)}',
                                                          style: TextStyle(
                                                              fontSize: 22),
                                                        ),
                                                      ),
                                                      Container(
                                                        child: noDelvier
                                                            ? Text(
                                                                word("tax_msg",
                                                                    context),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 9,
                                                                ),
                                                              )
                                                            : Text(
                                                                word(
                                                                    "tax_delivered_msg",
                                                                    context),
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 9,
                                                                ),
                                                              ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),

                                              Table(
                                                columnWidths: {
                                                  0: FractionColumnWidth(0.5)
                                                },
                                                border: TableBorder.all(),
                                                children: [
                                                  TableRow(children: [
                                                    Center(
                                                      child: Text(word(
                                                          "product", context)),
                                                    ),
                                                    Center(
                                                      child: Text(word(
                                                          "quantity", context)),
                                                    ),
                                                    Center(
                                                      child: Text(word(
                                                          "price", context)),
                                                    ),
                                                  ])
                                                ],
                                              ),

                                              Expanded(
                                                child: ListView.builder(
                                                    itemCount:
                                                        myOrderList.length,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Container(
                                                          child: Table(
                                                        columnWidths: {
                                                          0: FractionColumnWidth(
                                                              0.5)
                                                        },
                                                        border:
                                                            TableBorder.all(),
                                                        children: [
                                                          TableRow(children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Align(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
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
                                              //Delete order
                                              Container(
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.red),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                child: FlatButton.icon(
                                                  icon: Icon(
                                                    Icons.delete,
                                                    color: Colors.red[300],
                                                  ),
                                                  onPressed: () {
                                                    if (status == "0") {
                                                      showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                                context) =>
                                                            Dialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          ),
                                                          child: Container(
                                                            height: 300.0,
                                                            width: 300.0,
                                                            child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: <
                                                                  Widget>[
                                                                Center(
                                                                  child: Text(
                                                                    word(
                                                                        "cancel",
                                                                        context),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            20),
                                                                  ),
                                                                ),
                                                                Padding(
                                                                  padding: const EdgeInsets
                                                                          .symmetric(
                                                                      horizontal:
                                                                          16.0),
                                                                  child:
                                                                      Container(
                                                                    child: Text(
                                                                      word(
                                                                          "cancel_msg",
                                                                          context),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceAround,
                                                                  children: [
                                                                    FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        Firestore
                                                                            .instance
                                                                            .collection(
                                                                                'order')
                                                                            .where('orderID',
                                                                                isEqualTo: ds['orderID'])
                                                                            .where('userID', isEqualTo: ds['userID'])
                                                                            .getDocuments()
                                                                            .then((value) {
                                                                          value
                                                                              .documents
                                                                              .forEach((element) {
                                                                            Firestore.instance.collection('order').document(element.documentID).delete();
                                                                          });
                                                                        });
                                                                        Navigator.pop(
                                                                            context);
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        word(
                                                                            "sure",
                                                                            context),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.purple,
                                                                            fontSize: 18.0),
                                                                      ),
                                                                    ),
                                                                    FlatButton(
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      },
                                                                      child:
                                                                          Text(
                                                                        word(
                                                                            "exit",
                                                                            context),
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.purple,
                                                                            fontSize: 18.0),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    } else {
                                                      errorToast(
                                                        word("cant_cancel",
                                                            context),
                                                      );
                                                    }
                                                  },
                                                  label: Text(
                                                    word("cancel", context),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  child: Card(
                                    child: Column(
                                      children: [
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
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              //Order track
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
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: status ==
                                                                    "0"
                                                                ? [
                                                                    Colors
                                                                        .yellow,
                                                                    Colors.orange[
                                                                        800]
                                                                  ]
                                                                : [
                                                                    Colors.grey[
                                                                        200],
                                                                    Colors.white
                                                                  ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(50),
                                                          ),
                                                        ),
                                                        child: Icon(Icons.store,
                                                            color: status == "0"
                                                                ? Colors.black
                                                                : Colors
                                                                    .grey[200]),
                                                      ),
                                                      Text(
                                                        word("receive_order",
                                                            context),
                                                        style: TextStyle(
                                                          color: status == "0"
                                                              ? Colors.black
                                                              : Colors
                                                                  .grey[300],
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                  Column(
                                                    children: [
                                                      Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration:
                                                            BoxDecoration(
                                                          gradient:
                                                              LinearGradient(
                                                            colors: status ==
                                                                    "1"
                                                                ? [
                                                                    Colors.green[
                                                                        500],
                                                                    Colors
                                                                        .yellow,
                                                                  ]
                                                                : [
                                                                    Colors.grey[
                                                                        200],
                                                                    Colors.white
                                                                  ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(50),
                                                          ),
                                                        ),
                                                        child: Icon(
                                                          Icons.shopping_basket,
                                                          color: status == "1"
                                                              ? Colors.black
                                                              : Colors
                                                                  .grey[300],
                                                        ),
                                                      ),
                                                      Text(
                                                        noDelvier
                                                            ? word(
                                                                "ready_to_Pickup",
                                                                context)
                                                            : word(
                                                                'ready_to_deliver',
                                                                context),
                                                        style: TextStyle(
                                                          color: status == "1"
                                                              ? Colors.black
                                                              : Colors
                                                                  .grey[200],
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
                                                                              Colors.green[500],
                                                                            ]
                                                                          : [
                                                                              Colors.grey[200],
                                                                              Colors.white
                                                                            ],
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .all(
                                                                  Radius
                                                                      .circular(
                                                                          50),
                                                                ),
                                                              ),
                                                              child: Icon(
                                                                  Icons
                                                                      .directions_car,
                                                                  color: status == "2"
                                                                      ? Colors
                                                                          .black
                                                                      : Colors.grey[
                                                                          300]),
                                                            ),
                                                            Text(
                                                              word("on_its_way",
                                                                  context),
                                                              style: TextStyle(
                                                                color: status ==
                                                                        "2"
                                                                    ? Colors
                                                                        .black
                                                                    : Colors.grey[
                                                                        200],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                  Column(
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
                                                                    Colors.green[
                                                                        500],
                                                                    Colors
                                                                        .green,
                                                                  ]
                                                                : [
                                                                    Colors.grey[
                                                                        200],
                                                                    Colors.white
                                                                  ],
                                                          ),
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(50),
                                                          ),
                                                        ),
                                                        child: Icon(Icons.home,
                                                            color: status == "3"
                                                                ? Colors.black
                                                                : Colors
                                                                    .grey[300]),
                                                      ),
                                                      Text(
                                                        noDelvier
                                                            ? word("received",
                                                                context)
                                                            : word("delivered",
                                                                context),
                                                        style: TextStyle(
                                                          color: status == "3"
                                                              ? Colors.black
                                                              : Colors
                                                                  .grey[200],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                noDelvier
                                                    ? Container(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                                border: Border
                                                                    .all()),
                                                        child: InkWell(
                                                          onTap: () {
                                                            MapsLauncher
                                                                .launchCoordinates(
                                                              24.751945,
                                                              46.665222,
                                                            );
                                                          },
                                                          child: Text(
                                                            word(
                                                                "pickup_location",
                                                                context),
                                                          ),
                                                        ),
                                                      )
                                                    : Container(),
                                              ],
                                            ),
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
  );
}
