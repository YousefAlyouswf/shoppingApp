import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:maps_launcher/maps_launcher.dart';
import 'package:url_launcher/url_launcher.dart';

class MyOrder extends StatefulWidget {
  final String id;
  final String name;

  const MyOrder({Key key, this.id, this.name}) : super(key: key);

  @override
  _MyOrderState createState() => _MyOrderState();
}

class _MyOrderState extends State<MyOrder> {
  @override
  Widget build(BuildContext context) {
    double heigh = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
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
                    Container(
                      height: heigh < 700 ? heigh * 0.3 : heigh * 0.22,
                      color: Colors.grey,
                      child: InkWell(
                        onTap: () {},
                        child: Card(
                          color: status == '3'
                              ? Colors.green[200]
                              : Colors.yellow[200],
                          child: InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => Container(
                                  color: Colors.grey[100],
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: EdgeInsets.all(width * 0.025),
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
                                                    .updateData(
                                                        {'driverID': ''});

                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                "إلغاء الطلبية",
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                            InkWell(
                                              onTap: () {
                                                Clipboard.setData(
                                                    new ClipboardData(
                                                        text: ds['orderID']));
                                                Scaffold.of(context)
                                                  ..showSnackBar(
                                                    new SnackBar(
                                                      duration:
                                                          Duration(seconds: 1),
                                                      content:
                                                          new Text("تم النسخ"),
                                                    ),
                                                  );
                                              },
                                              child: Text(
                                                "رقم الطلب: ${ds['orderID']}",
                                                textDirection:
                                                    TextDirection.rtl,
                                                style: TextStyle(
                                                    fontSize: width * 0.05),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          formatted,
                                        ),
                                        SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                            "لدعم الفني ومشاكل الطلبات اضغط على علامه الواتساب"),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () async {
                                            String url =
                                                'https://api.whatsapp.com/send?phone=966546306772&text=السلام عليكم,,\nأسمي ${ds['driverName']}\nرقم الهويه ${ds['driverID']}\nرقم الطلب: ${ds['orderID']}\n\n';
                                            if (await canLaunch(url)) {
                                              await launch(url);
                                            } else {
                                              throw 'Could not launch $url';
                                            }
                                          },
                                          child: Container(
                                            height: heigh * 0.1,
                                            width: heigh * 0.1,
                                            decoration: BoxDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                  "https://i.pinimg.com/originals/79/dc/31/79dc31280371b8ffbe56ec656418e122.png",
                                                ),
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
                            child: Column(
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(width * 0.025),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Align(
                                          alignment: Alignment(0, -0.3),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(50),
                                                  ),
                                                ),
                                                child:
                                                    Icon(Icons.directions_car),
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
                                                        isEqualTo:
                                                            ds['orderID'])
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
                                                    FlatButton(
                                                      onPressed: () => launch(
                                                          "tel://${ds['phone']}"),
                                                      child: Container(
                                                        padding: EdgeInsets.all(
                                                            width * 0.025),
                                                        decoration: BoxDecoration(
                                                            color:
                                                                Colors.blueGrey,
                                                            border:
                                                                Border.all(),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            15))),
                                                        child: Text(
                                                          "الإتصال بالعميل",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  width * 0.03,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    ds['payment'] == "cash"
                                                        ? Text(
                                                            '${ds['total']} ر.س',
                                                            style: TextStyle(
                                                              fontSize:
                                                                  width * 0.03,
                                                            ),
                                                          )
                                                        : Container(),
                                                    Text(
                                                      ds['payment'] == "cash"
                                                          ? 'الدفع كاش '
                                                          : 'تم الدفع',
                                                      style: TextStyle(
                                                          fontSize:
                                                              width * 0.04,
                                                          fontFamily:
                                                              "MainFont",
                                                          color: Colors.red),
                                                    ),
                                                  ],
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    MapsLauncher
                                                        .launchCoordinates(
                                                      double.parse(ds['lat']),
                                                      double.parse(
                                                        ds['long'],
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal: 8.0),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Colors.grey[200],
                                                          border: Border.all()),
                                                      child:
                                                          Text("موقع التوصيل")),
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
