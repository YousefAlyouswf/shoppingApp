import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/widgets.dart';

import 'package:translator/translator.dart';
import 'package:device_info/device_info.dart';

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
      });
    }
  }

  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosDeviceInfo;
  @override
  void initState() {
    fetchMyCart();
    super.initState();
    deviceID();
  }

  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    }
  }

  @override
  Widget build(BuildContext context) {
    print(androidInfo.androidId);
    return Scaffold(
      appBar: appBar(),
      drawer: drawer(context, widget.onThemeChanged,
          changeLangauge: widget.changeLangauge),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width / 3,
          height: 50,
          decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: InkWell(
            onTap: () {
              Firestore.instance.collection('order').add({
                'address': widget.address,
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
    );
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
