import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_app/models/myOrderModel.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:intl/intl.dart' as intl;

class MyOrder extends StatefulWidget {
  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosDeviceInfo;
  String userID;
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
    return Scaffold(
      appBar: appBar(),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: StreamBuilder(
            stream: Firestore.instance
                .collection('order')
                .where("userID", isEqualTo: userID)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: Text("لا يوجد لديك طلبات"),
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
                        String status = ds['status'];
                        DateTime orderDate = DateTime.parse(ds['date']);
                        var formatter = new intl.DateFormat('dd/MM/yyyy');
                        var timeFormat = new intl.DateFormat.jm();
                        String formatDate = formatter.format(orderDate);
                        String formatTime = timeFormat.format(orderDate);

                        String formatted="تاريخ الطلب $formatDate\n $formatTime";
                        return Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Container(
                              height: 240,
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
                                                        gradient:
                                                            LinearGradient(
                                                          colors: status == "2"
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
                                                      child: Icon(
                                                          Icons.directions_car),
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
                                                Column(
                                                  children: [
                                                    Container(
                                                      height: 50,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        gradient:
                                                            LinearGradient(
                                                          colors: status == "3"
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
                                                      "تم التوصيل",
                                                      style: TextStyle(
                                                        color: status == "3"
                                                            ? Colors.black
                                                            : Colors.grey,
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
                                                   Text(formatted),
                                                      Text(
                                                        '${ds['total']} ر.س',
                                                        textDirection:
                                                            TextDirection.rtl,
                                                        style: TextStyle(
                                                            fontSize: 22),
                                                      ),
                                                    ],
                                                  ),
                                                  Padding(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                           FlatButton.icon(
                                                        icon: Icon(
                                                          Icons.delete,
                                                          color:
                                                              Colors.red[300],
                                                        ),
                                                        onPressed: () {
                                                          if (status == "0") {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (BuildContext
                                                                            context) =>
                                                                        Dialog(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(12.0),
                                                                          ),
                                                                          child:
                                                                              Container(
                                                                            height:
                                                                                300.0,
                                                                            width:
                                                                                300.0,
                                                                            child:
                                                                                Column(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: <Widget>[
                                                                                Center(
                                                                                  child: Text(
                                                                                    "إلغاء الطلب",
                                                                                    style: TextStyle(fontSize: 20),
                                                                                  ),
                                                                                ),
                                                                                Padding(
                                                                                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                                                                  child: Container(child: Text("سوف يتم الغاء طلبك")),
                                                                                ),
                                                                                Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                  children: [
                                                                                    FlatButton(
                                                                                      onPressed: () {
                                                                                        Firestore.instance.collection('order').where('orderID', isEqualTo: ds['orderID']).where('userID', isEqualTo: ds['userID']).getDocuments().then((value) {
                                                                                          value.documents.forEach((element) {
                                                                                            Firestore.instance.collection('order').document(element.documentID).delete();
                                                                                          });
                                                                                        });
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Text(
                                                                                        'تأكيد',
                                                                                        style: TextStyle(color: Colors.purple, fontSize: 18.0),
                                                                                      ),
                                                                                    ),
                                                                                    FlatButton(
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Text(
                                                                                        'خروج',
                                                                                        style: TextStyle(color: Colors.purple, fontSize: 18.0),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ));
                                                          } else {
                                                            errorToast(
                                                                "لا يكمنك إلغاء الطلب");
                                                          }
                                                        },
                                                        label:
                                                            Text("الغاء الطلب"),
                                                      ),
                                                        Container(
                                                         
                                                          alignment:
                                                              Alignment.centerRight,
                                                          child: Text(
                                                              "السعر شامل الضريبة والتوصيل"),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
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
