import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shop_app/models/myOrderModel.dart';

import '../widgets.dart';

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

                    String formatted = "تاريخ الطلب $formatDate  $formatTime";
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          height: 240,
                          color: Colors.teal,
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
                                        //Order Date
                                        Text(
                                          formatted,
                                          textDirection: TextDirection.rtl,
                                        ),

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
                                              itemBuilder: (context, index) {
                                                return Container(
                                                    child: Table(
                                                  columnWidths: {
                                                    0: FractionColumnWidth(0.5)
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
                                                              myOrderList[index]
                                                                  .name),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Center(
                                                          child: Text(
                                                              myOrderList[index]
                                                                  .quatity),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Center(
                                                          child: Text(
                                                              myOrderList[index]
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
                                              border:
                                                  Border.all(color: Colors.red),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10))),
                                          child: FlatButton.icon(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red[300],
                                            ),
                                            onPressed: () {
                                              if (status == "0") {
                                                showDialog(
                                                    context: context,
                                                    builder:
                                                        (BuildContext
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
                                                                      child:
                                                                          Text(
                                                                        "إلغاء الطلب",
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
                                                                        child:
                                                                            Text(
                                                                          "سوف يتم الغاء طلبك",
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
                                                                            Firestore.instance.collection('order').where('orderID', isEqualTo: ds['orderID']).where('userID', isEqualTo: ds['userID']).getDocuments().then((value) {
                                                                              value.documents.forEach((element) {
                                                                                Firestore.instance.collection('order').document(element.documentID).delete();
                                                                              });
                                                                            });
                                                                            Navigator.pop(context);
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'تأكيد',
                                                                            style:
                                                                                TextStyle(color: Colors.purple, fontSize: 18.0),
                                                                          ),
                                                                        ),
                                                                        FlatButton(
                                                                          onPressed:
                                                                              () {
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'خروج',
                                                                            style:
                                                                                TextStyle(color: Colors.purple, fontSize: 18.0),
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
                                            label: Text("الغاء الطلب"),
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Container(
                                                height: 3,
                                                width: double.infinity,
                                                color: Colors.black45,
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
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(50),
                                                    ),
                                                  ),
                                                  child: Icon(
                                                      Icons.shopping_basket),
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
                                                            colors: status ==
                                                                    "2"
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
                                                            .directions_car),
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
                                                padding: EdgeInsets.all(8.0),
                                                decoration: BoxDecoration(
                                                  border:Border.all()
                                                ),
                                                child: InkWell(
                                                    onTap: () {
                                                      MapsLauncher
                                                          .launchCoordinates(
                                                        24.751945,
                                                        46.665222,
                                                      );
                                                    },
                                                    child: Text("موقع الإستلام")),
                                              )
                                              : Container(),
                                          Column(
                                            children: [
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  '${ds['total']} ر.س',
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style:
                                                      TextStyle(fontSize: 22),
                                                ),
                                              ),
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: noDelvier
                                                    ? Text(
                                                        "السعر شامل الضريبة",
                                                        style: TextStyle(
                                                            fontSize: 9),
                                                      )
                                                    : Text(
                                                        "السعر شامل الضريبة والتوصيل",
                                                        style: TextStyle(
                                                            fontSize: 9)),
                                              ),
                                            ],
                                          ),
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
