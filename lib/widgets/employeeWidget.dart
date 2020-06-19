import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shop_app/manager/gmapManager.dart';
import 'package:shop_app/models/myOrderModel.dart';
import 'package:url_launcher/url_launcher.dart';

Widget employeeList() {
  return Container(
    child: StreamBuilder(
        stream: Firestore.instance
            .collection('employee')
            .orderBy('accept')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text("لا يوجد مندوب"),
            );
          } else {
            return ListView.separated(
                itemBuilder: (context, i) {
                  DocumentSnapshot ds = snapshot.data.documents[i];
                  String status;
                  if (ds['accept'] == '0') {
                    status = "إنتظار";
                  } else if (ds['accept'] == '1') {
                    status = "قبول";
                  } else {
                    status = "مرفوض";
                  }
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Dismissible(
                      key: Key(ds['id']),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        color: Colors.red,
                        child: Icon(
                          Icons.delete,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (d) {
                        Firestore.instance
                            .collection('employee')
                            .where('id', isEqualTo: ds['id'])
                            .getDocuments()
                            .then((value) {
                          value.documents.forEach((element) {
                            Firestore.instance
                                .collection('employee')
                                .document(element.documentID)
                                .delete();
                          });
                        });
                      },
                      child: Container(
                        color: ds['accept'] == "1"
                            ? Colors.green[100]
                            : ds['accept'] == "2"
                                ? Colors.red[100]
                                : Colors.yellow[100],
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text("الأسم: ${ds['name']}",
                                        textDirection: TextDirection.rtl),
                                    Text("الجوال: ${ds['phone']}",
                                        textDirection: TextDirection.rtl),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text("الهوية: ${ds['id']}",
                                        textDirection: TextDirection.rtl),
                                    Text("كلمة المرور: ${ds['pass']}",
                                        textDirection: TextDirection.rtl),
                                    Text("الحالة: $status",
                                        textDirection: TextDirection.rtl),
                                  ],
                                ),
                              ],
                            ),
                            Text("${ds['city']}"),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RaisedButton(
                                      onPressed: () {
                                        Firestore.instance
                                            .collection('employee')
                                            .where('id', isEqualTo: ds['id'])
                                            .getDocuments()
                                            .then((value) {
                                          value.documents.forEach((element) {
                                            Firestore.instance
                                                .collection('employee')
                                                .document(element.documentID)
                                                .updateData(
                                              {'accept': '2'},
                                            );
                                          });
                                        });
                                      },
                                      color: Colors.red,
                                      child: Text("رفض"),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        Firestore.instance
                                            .collection('employee')
                                            .where('id', isEqualTo: ds['id'])
                                            .getDocuments()
                                            .then((value) {
                                          value.documents.forEach((element) {
                                            Firestore.instance
                                                .collection('employee')
                                                .document(element.documentID)
                                                .updateData(
                                              {'accept': '1'},
                                            );
                                          });
                                        });
                                      },
                                      color: Colors.green,
                                      child: Text("قبول"),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    RaisedButton(
                                      onPressed: () {
                                        showImageinSheet(
                                            context, ds['idImage']);
                                      },
                                      child: Text("الهوية"),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        showImageinSheet(
                                            context, ds['licImage']);
                                      },
                                      child: Text("الرخصة"),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        showImageinSheet(
                                            context, ds['carImage']);
                                      },
                                      child: Text("الأستمارة"),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, i) {
                  return Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey,
                  );
                },
                itemCount: snapshot.data.documents.length);
          }
        }),
  );
}

Widget images(String image) {
  return Container(
    height: 100,
    width: 100,
    decoration: BoxDecoration(
        image: DecorationImage(
      image: NetworkImage(image),
      fit: BoxFit.fill,
    )),
  );
}

void showImageinSheet(BuildContext context, String image) {
  showBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: NetworkImage(image), fit: BoxFit.fill),
            ),
          ));
}

String orderNumber;
TextEditingController search = TextEditingController();
Widget orders(BuildContext context, Function searchOrder) {
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
            child: TextField(
          autocorrect: false,
          decoration: InputDecoration(
            hintText: "رقم الطلب",
            suffixIcon: IconButton(
              icon: Icon(Icons.cancel),
              onPressed: () {
                search.clear();
                searchOrder("");
              },
            ),
          ),
          controller: search,
          textInputAction: TextInputAction.search,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
          onSubmitted: searchOrder,
        )),
      ),
      Expanded(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          child: StreamBuilder(
              stream: orderNumber == ""
                  ? Firestore.instance
                      .collection('order')
                      .orderBy('date', descending: true)
                      .snapshots()
                  : Firestore.instance
                      .collection('order')
                      .orderBy('date', descending: true)
                      .where('orderID', isEqualTo: orderNumber)
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

                          String formatted =
                              "تاريخ الطلب $formatDate  $formatTime";
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                height: 300,
                                color: Colors.grey,
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
                                              Table(
                                                columnWidths: {
                                                  0: FractionColumnWidth(0.5)
                                                },
                                                border: TableBorder.all(),
                                                textDirection:
                                                    TextDirection.rtl,
                                                children: [
                                                  TableRow(children: [
                                                    Center(
                                                        child: Text("المنتج")),
                                                    Center(
                                                        child: Text("العدد")),
                                                    Center(
                                                        child: Text("السعر")),
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
                                    color: status != '3'? Colors.red[100]:Colors.white,
                                    child: Column(
                                      children: [
                                        InkWell(
                                          onTap: () {
                                            Clipboard.setData(new ClipboardData(
                                                text: ds['orderID']));
                                            Scaffold.of(context)
                                              ..showSnackBar(
                                                new SnackBar(
                                                  duration:
                                                      Duration(seconds: 1),
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
                                                              .collection(
                                                                  'order')
                                                              .document(element
                                                                  .documentID)
                                                              .updateData({
                                                            'status': '0'
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
                                                              colors:
                                                                  status == "0"
                                                                      ? [
                                                                          Colors
                                                                              .lightGreen,
                                                                          Colors
                                                                              .green[800]
                                                                        ]
                                                                      : [
                                                                          Colors
                                                                              .grey,
                                                                          Colors
                                                                              .white
                                                                        ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  50),
                                                            ),
                                                          ),
                                                          child:
                                                              Icon(Icons.store),
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
                                                              .collection(
                                                                  'order')
                                                              .document(element
                                                                  .documentID)
                                                              .updateData({
                                                            'status': '1'
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
                                                              colors:
                                                                  status == "1"
                                                                      ? [
                                                                          Colors
                                                                              .lightGreen,
                                                                          Colors
                                                                              .green[800]
                                                                        ]
                                                                      : [
                                                                          Colors
                                                                              .grey,
                                                                          Colors
                                                                              .white
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
                                                              .collection(
                                                                  'order')
                                                              .document(element
                                                                  .documentID)
                                                              .updateData({
                                                            'status': '2'
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
                                                              colors:
                                                                  status == "2"
                                                                      ? [
                                                                          Colors
                                                                              .lightGreen,
                                                                          Colors
                                                                              .green[800]
                                                                        ]
                                                                      : [
                                                                          Colors
                                                                              .grey,
                                                                          Colors
                                                                              .white
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
                                                            color: status == "2"
                                                                ? Colors.black
                                                                : Colors.grey,
                                                          ),
                                                        )
                                                      ],
                                                    ),
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
                                                              .collection(
                                                                  'order')
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
                                                              colors:
                                                                  status == "3"
                                                                      ? [
                                                                          Colors
                                                                              .lightGreen,
                                                                          Colors
                                                                              .green[800]
                                                                        ]
                                                                      : [
                                                                          Colors
                                                                              .grey,
                                                                          Colors
                                                                              .white
                                                                        ],
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(
                                                              Radius.circular(
                                                                  50),
                                                            ),
                                                          ),
                                                          child:
                                                              Icon(Icons.home),
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
                                                        FlatButton.icon(
                                                          icon: Icon(
                                                            Icons.delete,
                                                            color:
                                                                Colors.red[300],
                                                          ),
                                                          onPressed: () {
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
                                                          },
                                                          label: Text(
                                                              "الغاء الطلب"),
                                                        ),
                                                        Text(
                                                          '${ds['total']} ر.س',
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          style: TextStyle(
                                                              fontSize: 22),
                                                        ),
                                                      ],
                                                    ),
                                                    Container(
                                                      width: double.infinity,
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Text(
                                                          "السعر شامل الضريبة والتوصيل"),
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
                                                        FlatButton.icon(
                                                          onPressed: () {
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        GmapManager(
                                                                  latLng:
                                                                      LatLng(
                                                                    double.parse(
                                                                        ds['lat']),
                                                                    double.parse(
                                                                        ds['long']),
                                                                  ),
                                                                ),
                                                              ),
                                                            );
                                                          },
                                                          icon: Icon(Icons.map),
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
      ),
    ],
  );
}
