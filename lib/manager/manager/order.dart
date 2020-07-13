import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/models/myOrderModel.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shop_app/models/tabModels.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:maps_launcher/maps_launcher.dart';

class OrderManager extends StatefulWidget {
  @override
  _OrderManagerState createState() => _OrderManagerState();
}

class _OrderManagerState extends State<OrderManager>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<TabModels> pages = [
    TabModels(
      "إنتظار",
      Icon(Icons.add),
    ),
    TabModels(
      "قبول",
      Icon(Icons.dashboard),
    ),
    TabModels(
      "بريد",
      Icon(Icons.add),
    ),
  ];
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Container(),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: pages[0].text,
              ),
              Tab(
                text: pages[1].text,
              ),
              Tab(
                text: pages[2].text,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          orders(context, searchOrder, false, false),
          orders(context, searchOrder, true, false),
          orders(context, searchOrder, false, true),
        ],
      ),
    );
  }

  searchOrder(String search) {
    setState(() {
      orderNumber = search;
    });
  }
}

String orderNumber;
TextEditingController search = TextEditingController();
Widget orders(BuildContext context, Function searchOrder, bool withDelegate,
    bool outRiyadh) {
  return Container(
    height: MediaQuery.of(context).size.height,
    width: double.infinity,
    child: StreamBuilder(
        stream: Firestore.instance
            .collection('order')
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text("لا يوجد لديك طلبات"),
            );
          } else {
            List<MyOrderModel> myOrderList = [];

            for (var i = 0; i < snapshot.data.documents.length; i++) {
              DocumentSnapshot ds = snapshot.data.documents[i];

              for (var j = 0; j < ds['items'].length; j++) {
                if (outRiyadh) {
                  if (ds['city'] != "RIYADH,الرياض") {
                    myOrderList.add(
                      MyOrderModel(
                        name: ds['items'][j]['name'],
                        price: ds['items'][j]['sellPrice'],
                        quatity: ds['items'][j]['quantity'],
                        productID: ds['items'][j]['productID'],
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
                        address: ds['address'],
                        postal: ds['postCode'],
                      ),
                    );
                  }
                } else {
                  if (withDelegate) {
                    if (ds['driverID'] != "") {
                      myOrderList.add(
                        MyOrderModel(
                          name: ds['items'][j]['name'],
                          price: ds['items'][j]['sellPrice'],
                          quatity: ds['items'][j]['quantity'],
                          productID: ds['items'][j]['productID'],
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
                          address: ds['address'],
                          postal: ds['postCode'],
                        ),
                      );
                    }
                  } else {
                    if (ds['driverID'] == "") {
                      myOrderList.add(
                        MyOrderModel(
                          name: ds['items'][j]['name'],
                          price: ds['items'][j]['sellPrice'],
                          quatity: ds['items'][j]['quantity'],
                          productID: ds['items'][j]['productID'],
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
                          address: ds['address'],
                          postal: ds['postCode'],
                        ),
                      );
                    }
                  }
                }
              }
            }
            return Container(
              width: double.infinity,
              child: ListView.builder(
                  itemBuilder: (context, i) {
                    String status;
                    String formatted;

                    status = myOrderList[i].status;
                    DateTime orderDate = DateTime.parse(myOrderList[i].date);
                    var formatter = new intl.DateFormat('dd/MM/yyyy');
                    var timeFormat = new intl.DateFormat.jm();
                    String formatDate = formatter.format(orderDate);
                    String formatTime = timeFormat.format(orderDate);

                    formatted = "$formatDate  $formatTime";

                    double height = MediaQuery.of(context).size.height;
                    double width = MediaQuery.of(context).size.width;
                    return Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          height: height < 700 ? height * 0.4 : height * 0.3,
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            FlatButton(
                                              onPressed: () {
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
                                                                      child: Container(
                                                                          child:
                                                                              Text("سوف يتم الغاء طلبك")),
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceAround,
                                                                      children: [
                                                                        FlatButton(
                                                                          onPressed:
                                                                              () {
                                                                            Firestore.instance.collection('order').where('orderID', isEqualTo: myOrderList[i].orderID).where('userID', isEqualTo: myOrderList[i].docID).getDocuments().then((value) {
                                                                              value.documents.forEach((element) {
                                                                                Firestore.instance.collection('order').document(element.documentID).delete();
                                                                              });
                                                                            });
                                                                            Navigator.pop(context);
                                                                          },
                                                                          child:
                                                                              Text(
                                                                            'تأكيد',
                                                                            style:
                                                                                TextStyle(fontSize: 18.0),
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
                                                                                TextStyle(fontSize: 18.0),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ));
                                              },
                                              child: Text(
                                                "الغاء الطلب",
                                                style: TextStyle(
                                                    fontSize: width * 0.03),
                                              ),
                                            ),
                                            FlatButton(
                                              onPressed: () => launch(
                                                  "tel://${myOrderList[i].phone}"),
                                              child: Text(
                                                myOrderList[i].phone,
                                                style: TextStyle(
                                                    fontSize: width * 0.03),
                                              ),
                                            ),
                                            FlatButton(
                                              onPressed: () {
                                                MapsLauncher.launchCoordinates(
                                                    double.parse(
                                                        myOrderList[i].lat),
                                                    double.parse(
                                                        myOrderList[i].long));
                                              },
                                              child: Text(
                                                "موقع التوصيل",
                                                style: TextStyle(
                                                    fontSize: width * 0.03),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          myOrderList[i].address,
                                          style: TextStyle(
                                            fontSize: width * 0.03,
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            Text(
                                              myOrderList[i].city,
                                              style: TextStyle(
                                                fontSize: width * 0.03,
                                              ),
                                            ),
                                            Text(
                                              myOrderList[i].postal,
                                              style: TextStyle(
                                                fontSize: width * 0.03,
                                              ),
                                            ),
                                          ],
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
                                                          child: Column(
                                                            children: [
                                                              Text(myOrderList[
                                                                      index]
                                                                  .name),
                                                              Text(
                                                                myOrderList[
                                                                        index]
                                                                    .productID,
                                                              ),
                                                            ],
                                                          ),
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
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            child: Card(
                              color: status != '3'
                                  ? withDelegate
                                      ? Colors.green[100]
                                      : outRiyadh
                                          ? Colors.blue[100]
                                          : Colors.red[100]
                                  : Colors.white,
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () {
                                      Clipboard.setData(new ClipboardData(
                                          text: myOrderList[i].orderID));
                                      Scaffold.of(context)
                                        ..showSnackBar(
                                          new SnackBar(
                                            duration: Duration(seconds: 1),
                                            content: new Text("تم النسخ"),
                                          ),
                                        );
                                    },
                                    child: Text(
                                      "رقم الطلب: ${myOrderList[i].orderID}",
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
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            InkWell(
                                              onLongPress: () {
                                                Firestore.instance
                                                    .collection('order')
                                                    .where('orderID',
                                                        isEqualTo:
                                                            myOrderList[i]
                                                                .orderID)
                                                    .getDocuments()
                                                    .then((value) {
                                                  value.documents
                                                      .forEach((element) {
                                                    Firestore.instance
                                                        .collection('order')
                                                        .document(
                                                            element.documentID)
                                                        .updateData(
                                                            {'status': '0'});
                                                  });
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: status == "0"
                                                            ? [
                                                                Colors
                                                                    .lightGreen,
                                                                Colors
                                                                    .green[800]
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
                                            ),
                                            InkWell(
                                              onLongPress: () {
                                                Firestore.instance
                                                    .collection('order')
                                                    .where('orderID',
                                                        isEqualTo:
                                                            myOrderList[i]
                                                                .orderID)
                                                    .getDocuments()
                                                    .then((value) {
                                                  value.documents
                                                      .forEach((element) {
                                                    Firestore.instance
                                                        .collection('order')
                                                        .document(
                                                            element.documentID)
                                                        .updateData(
                                                            {'status': '1'});
                                                  });
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: status == "1"
                                                            ? [
                                                                Colors
                                                                    .lightGreen,
                                                                Colors
                                                                    .green[800]
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
                                                            myOrderList[i]
                                                                .orderID)
                                                    .getDocuments()
                                                    .then((value) {
                                                  value.documents
                                                      .forEach((element) {
                                                    Firestore.instance
                                                        .collection('order')
                                                        .document(
                                                            element.documentID)
                                                        .updateData(
                                                            {'status': '2'});
                                                  });
                                                });
                                              },
                                              child: Column(
                                                children: [
                                                  Container(
                                                    height: 50,
                                                    width: 50,
                                                    decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                        colors: status == "2"
                                                            ? [
                                                                Colors
                                                                    .lightGreen,
                                                                Colors
                                                                    .green[800]
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
                                            ),
                                            InkWell(
                                              onLongPress: () {
                                                Firestore.instance
                                                    .collection('order')
                                                    .where('orderID',
                                                        isEqualTo:
                                                            myOrderList[i]
                                                                .orderID)
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
                                                                Colors
                                                                    .lightGreen,
                                                                Colors
                                                                    .green[800]
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
                                                  Text(myOrderList[i].name),
                                                  Text(
                                                    '${myOrderList[i].total} ر.س',
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style:
                                                        TextStyle(fontSize: 22),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                formatted,
                                                textDirection:
                                                    TextDirection.rtl,
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  Text(
                                                    myOrderList[i].driverID,
                                                  ),
                                                  Text(
                                                    myOrderList[i].driverName,
                                                  ),
                                                ],
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
                  itemCount: myOrderList.length),
            );
          }
        }),
  );
}
