import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart' as intl;
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
            // .orderBy('date', descending: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text(""),
            );
          } else {
            List<MyOrderModel> myOrderList = [];
            List<ItemModel> itemsList = [];
            for (var i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot ds = snapshot.data.documents[i];
              itemsList = [];
              if (ds['userID'] == userID) {
                for (var j = 0; j < ds['items'].length; j++) {
                  itemsList.add(ItemModel(
                    price: ds['items'][j]['sellPrice'],
                    name: ds['items'][j]['name'],
                    quatity: ds['items'][j]['quantity'],
                    productID: ds['items'][j]['productID'],
                  ));
                }
                myOrderList.add(
                  MyOrderModel(
                    items: itemsList,
                    city: ds['city'],
                    date: ds['date'],
                    driverID: ds['driverID'],
                    driverName: ds['driverName'],
                    lat: ds['lat'],
                    long: ds['long'],
                    orderID: ds['orderID'],
                    payment: ds['payment'],
                    phone: ds['phone'],
                    status: ds['status'],
                    total: ds['total'].toString(),
                    docID: ds.documentID,
                    customerName: ds['firstName'],
                    address: ds['address'],
                    postal: ds['postCode'],
                  ),
                );
              }
            }

            return Container(
              width: double.infinity,
              child: ListView.builder(
                itemCount: myOrderList.length,
                itemBuilder: (context, i) {
                  String status;
                  DateTime orderDate;
                  var formatter;
                  var timeFormat;
                  String formatDate;
                  String formatTime;
                  status = myOrderList[i].status;
                  orderDate = DateTime.parse(myOrderList[i].date);
                  formatter = new intl.DateFormat('dd/MM/yyyy');
                  timeFormat = new intl.DateFormat.jm();
                  formatDate = formatter.format(orderDate);
                  formatTime = timeFormat.format(orderDate);

                  String formatted =
                      "${word("order_date", context)} $formatDate  $formatTime";
                  return Column(
                    children: [
                      Container(
                        height: 120,
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
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Column(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  Clipboard.setData(
                                                    new ClipboardData(
                                                      text: myOrderList[i]
                                                          .orderID,
                                                    ),
                                                  );
                                                  addCartToast(
                                                      word("copy", context));
                                                },
                                                child: Text(
                                                  "${word("order_num", context)} ${myOrderList[i].orderID}",
                                                  style:
                                                      TextStyle(fontSize: 19),
                                                ),
                                              ),
                                              //Order Date
                                              Text(
                                                formatted,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            child: Text(
                                              '${myOrderList[i].total} ${word("currancy", context)}',
                                              style: TextStyle(fontSize: 22),
                                            ),
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
                                              child: Text(
                                                  word("product", context)),
                                            ),
                                            Center(
                                              child: Text(
                                                  word("quantity", context)),
                                            ),
                                            Center(
                                              child:
                                                  Text(word("price", context)),
                                            ),
                                          ])
                                        ],
                                      ),

                                      Expanded(
                                        child: ListView.builder(
                                            itemCount:
                                                myOrderList[i].items.length,
                                            itemBuilder: (context, index) {
                                              print(
                                                  myOrderList[i].items.length);
                                              return Container(
                                                  child: Table(
                                                columnWidths: {
                                                  0: FractionColumnWidth(0.5)
                                                },
                                                border: TableBorder.all(),
                                                children: [
                                                  TableRow(children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Align(
                                                        alignment:
                                                            Alignment.center,
                                                        child: Text(
                                                            myOrderList[i]
                                                                .items[index]
                                                                .name),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                        child: Text(
                                                            myOrderList[i]
                                                                .items[index]
                                                                .quatity),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Center(
                                                        child: Text(
                                                            myOrderList[i]
                                                                .items[index]
                                                                .price),
                                                      ),
                                                    ),
                                                  ])
                                                ],
                                              ));
                                            }),
                                      ),
                                      //Delete order
                                      // Container(
                                      //   decoration: BoxDecoration(
                                      //       border:
                                      //           Border.all(color: Colors.red),
                                      //       borderRadius: BorderRadius.all(
                                      //           Radius.circular(10))),
                                      //   child: FlatButton.icon(
                                      //     icon: Icon(
                                      //       Icons.delete,
                                      //       color: Colors.red[300],
                                      //     ),
                                      //     onPressed: () {
                                      //       if (status == "0") {
                                      //         showDialog(
                                      //           context: context,
                                      //           builder:
                                      //               (BuildContext context) =>
                                      //                   Dialog(
                                      //             shape: RoundedRectangleBorder(
                                      //               borderRadius:
                                      //                   BorderRadius.circular(
                                      //                       12.0),
                                      //             ),
                                      //             child: Container(
                                      //               height: 300.0,
                                      //               width: 300.0,
                                      //               child: Column(
                                      //                 mainAxisAlignment:
                                      //                     MainAxisAlignment
                                      //                         .spaceAround,
                                      //                 children: <Widget>[
                                      //                   Center(
                                      //                     child: Text(
                                      //                       word("cancel",
                                      //                           context),
                                      //                       style: TextStyle(
                                      //                           fontSize: 20),
                                      //                     ),
                                      //                   ),
                                      //                   Padding(
                                      //                     padding:
                                      //                         const EdgeInsets
                                      //                                 .symmetric(
                                      //                             horizontal:
                                      //                                 16.0),
                                      //                     child: Container(
                                      //                       child: Text(
                                      //                         word("cancel_msg",
                                      //                             context),
                                      //                       ),
                                      //                     ),
                                      //                   ),
                                      //                   Row(
                                      //                     mainAxisAlignment:
                                      //                         MainAxisAlignment
                                      //                             .spaceAround,
                                      //                     children: [
                                      //                       FlatButton(
                                      //                         onPressed: () {
                                      //                           // Firestore
                                      //                           //     .instance
                                      //                           //     .collection(
                                      //                           //         'order')
                                      //                           //     .where(
                                      //                           //         'orderID',
                                      //                           //         isEqualTo: ds[
                                      //                           //             'orderID'])
                                      //                           //     .where(
                                      //                           //         'userID',
                                      //                           //         isEqualTo: ds[
                                      //                           //             'userID'])
                                      //                           //     .getDocuments()
                                      //                           //     .then(
                                      //                           //         (value) {
                                      //                           //   value
                                      //                           //       .documents
                                      //                           //       .forEach(
                                      //                           //           (element) {
                                      //                           //     Firestore
                                      //                           //         .instance
                                      //                           //         .collection(
                                      //                           //             'order')
                                      //                           //         .document(
                                      //                           //             element.documentID)
                                      //                           //         .delete();
                                      //                           //   });
                                      //                           // });
                                      //                           // Navigator.pop(
                                      //                           //     context);
                                      //                           // Navigator.pop(
                                      //                           //     context);
                                      //                         },
                                      //                         child: Text(
                                      //                           word("sure",
                                      //                               context),
                                      //                           style: TextStyle(
                                      //                               color: Colors
                                      //                                   .purple,
                                      //                               fontSize:
                                      //                                   18.0),
                                      //                         ),
                                      //                       ),
                                      //                       FlatButton(
                                      //                         onPressed: () {
                                      //                           Navigator.pop(
                                      //                               context);
                                      //                         },
                                      //                         child: Text(
                                      //                           word("exit",
                                      //                               context),
                                      //                           style: TextStyle(
                                      //                               color: Colors
                                      //                                   .purple,
                                      //                               fontSize:
                                      //                                   18.0),
                                      //                         ),
                                      //                       ),
                                      //                     ],
                                      //                   ),
                                      //                 ],
                                      //               ),
                                      //             ),
                                      //           ),
                                      //         );
                                      //       } else {
                                      //         errorToast(
                                      //           word("cant_cancel", context),
                                      //         );
                                      //       }
                                      //     },
                                      //     label: Text(
                                      //       word("cancel", context),
                                      //     ),
                                      //   ),
                                      // ),
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
                                            padding: const EdgeInsets.symmetric(
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
                                                            Colors.yellow,
                                                            Colors.orange[800]
                                                          ]
                                                        : [
                                                            Colors.grey[200],
                                                            Colors.white
                                                          ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(50),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: FaIcon(
                                                      FontAwesomeIcons.storeAlt,
                                                      color: status == "0"
                                                          ? Colors.black
                                                          : Colors.grey[200]),
                                                ),
                                              ),
                                              Text(
                                                word("receive_order", context),
                                                style: TextStyle(
                                                  color: status == "0"
                                                      ? Colors.black
                                                      : Colors.grey[300],
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
                                                            Colors.green[500],
                                                            Colors.yellow,
                                                          ]
                                                        : [
                                                            Colors.grey[200],
                                                            Colors.white
                                                          ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(50),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .shoppingBasket,
                                                    color: status == "1"
                                                        ? Colors.black
                                                        : Colors.grey[200],
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                word('ready_to_deliver',
                                                    context),
                                                style: TextStyle(
                                                  color: status == "1"
                                                      ? Colors.black
                                                      : Colors.grey[200],
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
                                                            Colors.green[500],
                                                          ]
                                                        : [
                                                            Colors.grey[200],
                                                            Colors.white
                                                          ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(50),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: FaIcon(
                                                    FontAwesomeIcons
                                                        .shippingFast,
                                                    color: status == "2"
                                                        ? Colors.black
                                                        : Colors.grey[300],
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                word("on_its_way", context),
                                                style: TextStyle(
                                                  color: status == "2"
                                                      ? Colors.black
                                                      : Colors.grey[200],
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
                                                    colors: status == "3"
                                                        ? [
                                                            Colors.green[500],
                                                            Colors.green,
                                                          ]
                                                        : [
                                                            Colors.grey[200],
                                                            Colors.white
                                                          ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(50),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: FaIcon(
                                                      FontAwesomeIcons.thumbsUp,
                                                      color: status == "3"
                                                          ? Colors.black
                                                          : Colors.grey[200]),
                                                ),
                                              ),
                                              Text(
                                                word("delivered", context),
                                                style: TextStyle(
                                                  color: status == "3"
                                                      ? Colors.black
                                                      : Colors.grey[200],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
              ),
            );
          }
        }),
  );
}
