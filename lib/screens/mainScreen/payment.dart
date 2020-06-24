import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/mainScreen/paymentsScreens/storedCard.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:translator/translator.dart';
import 'package:device_info/device_info.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:uuid/uuid.dart';

class Payment extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  final String name;
  final String phone;
  final String address;
  final String lat;
  final String long;
  final String buyPrice;
  final String price;
  final String totalAfterTax;

  const Payment({
    Key key,
    this.onThemeChanged,
    this.changeLangauge,
    this.name,
    this.phone,
    this.address,
    this.lat,
    this.long,
    this.buyPrice,
    this.price,
    this.totalAfterTax,
  }) : super(key: key);
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  List<ItemShow> cart = [];
  List<String> englishItem = [];
  List<String> arabicItem = [];
  List<String> items = [];
  List<Map<String, dynamic>> mapItems = [];
  final translator = new GoogleTranslator();
  Future<void> fetchMyCart() async {
    final dataList = await DBHelper.getData('cart');
    setState(() {
      cart = dataList
          .map(
            (item) => ItemShow(
              id: item['id'],
              itemName: item['name'],
              itemPrice: item['price'],
              image: item['image'],
              itemDes: item['des'],
              quantity: item['q'],
              buyPrice: item['buyPrice'],
              sizeChose: item['size'],
              productID: item['productID'],
            ),
          )
          .toList();
    });

    for (var i = 0; i < cart.length; i++) {
      mapItems.add({
        'name': cart[i].itemName,
        'quantity': cart[i].quantity,
        'buyPrice': cart[i].buyPrice,
        'sellPrice': cart[i].itemPrice,
        'size': cart[i].sizeChose,
        'productID': cart[i].productID,
      });
    }
  }

  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosDeviceInfo;
  var uuid = Uuid();
  String uid;
  @override
  void initState() {
    fetchMyCart();
    super.initState();
    deviceID();
    uid = uuid.v1();
    getTheDeriver();

    twilioFlutter = TwilioFlutter(
        accountSid:
            '', // replace *** with Account SID
        authToken:
            '', // replace xxx with Auth Token
        twilioNumber: '+12054966662' // replace .... with Twilio Number
        );
  }

  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    }
  }

  TwilioFlutter twilioFlutter;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      drawer: drawer(context, widget.onThemeChanged, goToHome,
          changeLangauge: widget.changeLangauge),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              // Navigator.push(
              //     context,
              //     new MaterialPageRoute(
              //         builder: (context) => new StoredCard()));

              String phone = widget.phone;
              if (phone.substring(0, 2) == "05") {
                phone = phone.substring(1);

                phone = "+966$phone";
              
              } else {
                phone = "+1$phone";
              }
              twilioFlutter.sendSMS(
                  toNumber: phone,
                  messageBody:
                      'رفوف\nلقد تم أستلام طلبك\nرقم طلبك هو ${uid.substring(0, 13)}');
            },
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: Center(
                child: Text(
                  "بطاقه مخزنة",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    fontSize: 22,
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(
                Radius.circular(20),
              ),
            ),
            child: Center(
              child: Text(
                "بطاقه جديدة",
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 22,
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width / 2,
              height: 50,
              decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: InkWell(
                onTap: () {
                  Firestore.instance.collection('order').add({
                    'driverID': id,
                    'driverName': name,
                    'orderID': uid.substring(0, 13),
                    'date': DateTime.now().toString(),
                    'status': '0',
                    'address': widget.address,
                    'total': widget.totalAfterTax,
                    'lat': widget.lat,
                    'long': widget.long,
                    'name': widget.name,
                    'phone': widget.phone,
                    'priceForSell': widget.price,
                    'priceForBuy': widget.buyPrice,
                    'items': FieldValue.arrayUnion(mapItems),
                    'userID': androidInfo.androidId == null
                        ? iosDeviceInfo.identifierForVendor
                        : androidInfo.androidId,
                  }).then((value) {
                    paymentToast(
                        "تم إستلام طلبك يمكنك متابعه الطلب من قسم الطلبات");
                    DBHelper.deleteAllItem("cart");
                    Navigator.popUntil(context, (route) => route.isFirst);
                    navIndex = 3;
                  });
                },
                child: Center(
                    child: Text(
                  "الدفع كاش",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 22, color: Colors.white),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double min = 0.0;
  String name = '';
  String id = '';
  double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  getTheDeriver() async {
    try {
      double customerLat = double.parse(widget.lat);
      double customerLong = double.parse(widget.long);
      List<DriverModel> driverList = new List();
      await Firestore.instance
          .collection('employee')
          .getDocuments()
          .then((value) {
        value.documents.forEach((e) {
          if (e['accept'] == '1') {
            double deriverLat = e['lat'];
            double deriverLong = e['long'];
            List<dynamic> data = [
              {
                "lat": customerLat,
                "lng": customerLong,
              },
              {
                "lat": deriverLat,
                "lng": deriverLong,
              }
            ];
            double totalDistance = 0;
            for (var i = 0; i < data.length - 1; i++) {
              totalDistance += calculateDistance(data[i]["lat"], data[i]["lng"],
                  data[i + 1]["lat"], data[i + 1]["lng"]);
            }
            driverList.add(DriverModel(
                name: e['name'], id: e['id'], distance: totalDistance));
          }
        });

        for (var i = 0; i < driverList.length; i++) {
          if (min == 0.0) {
            min = driverList[i].distance;
            name = driverList[i].name;
            id = driverList[i].id;
          } else {
            if (min > driverList[i].distance) {
              min = driverList[i].distance;
              name = driverList[i].name;
              id = driverList[i].id;
            }
          }
        }
        setState(() {});
      });
    } catch (e) {
      print("Catched");
    }
  }

  goToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
    navIndex = 0;
    setState(() {});
  }
}

paymentToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}

class DriverModel {
  final String name;
  final String id;
  final double distance;

  DriverModel({this.name, this.id, this.distance});
}
