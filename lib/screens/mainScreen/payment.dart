import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';

import 'package:shop_app/widgets/widgets.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

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
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Future<void> _getPayTabs() async {
    const platform = MethodChannel('samples.flutter.dev/battery');
    if (zipCode == null) {
      zipCode = '00966';
    }
    try {
      Map<String, String> map = {
        'amount': widget.totalAfterTax,
        'phone': widget.phone,
        'orderID': orderID,
        'items': items,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'address': addressLine,
      };
      final Map result = await platform.invokeMethod('getPayTabs', map);
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
            elevation: 0,
            content: Text(
              result['pt_result'] == "Your transaction is succesfully completed"
                  ? "تمت عملية الدفع بنجاح"
                  : "فشلت عملية الدفع",
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.green),
      );
    } on PlatformException catch (e) {
      print(e);
    }
  }

  String orderID;
  String items;
  String quantity;
  String unitPrice;
  String city;
  String zipCode;
  String addressLine;
  String state;
  @override
  void initState() {
    super.initState();
    fetchMyCart();

    Uuid id = Uuid();
    String uid = id.v1();
    orderID = uid.substring(0, 13);

    items = '';
    quantity = '';
    unitPrice = '';
  }

  String a = '';
  static const ROOT = "http://geniusloop.co/payment/index.php";
  Future<String> paymantPage() async {
    try {
      Map<String, dynamic> map = {
        'amount': widget.totalAfterTax,
        'items': items,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'address': addressLine,
        'phone': widget.phone,
        'orderID': orderID,
        'firstName': widget.name,
      };
      setState(() {
        a = map.toString();
      });
      final response = await http.post(ROOT, body: map);
      if (200 == response.statusCode) {
        if (await canLaunch(response.body)) {
          await launch(response.body, forceWebView: false);
        } else {
          throw 'Could not launch ${response.body}';
        }

        return response.body;
      } else {}
    } catch (e) {}
    return null;
  }

  findAddress() async {
    final coordinates =
        new Coordinates(double.parse(widget.lat), double.parse(widget.long));
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    city = first.locality;
    zipCode = first.postalCode;
    addressLine = first.addressLine;
    state = first.adminArea;
    setState(() {});

    if (Platform.isAndroid) {
      _getPayTabs();
    } else {
      paymantPage();
    }
  }

  List<ItemShow> cart = [];
  List<Map<String, dynamic>> mapItems = [];
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
    for (var i = 0; i < mapItems.length; i++) {
      setState(() {
        items += "${mapItems[i]['name']}";
        quantity += "${mapItems[i]['quantity']}";
        unitPrice += "${mapItems[i]['sellPrice']}";
        if (mapItems.last['name'] != mapItems[i]['name']) {
          items += ' || ';
          quantity += ' || ';
          unitPrice += ' || ';
        }
      });
    }
    findAddress();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      //  appBar: appBar(),
      body: Container(
        child: Center(
          child: Text(" $a"),
        ),
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
    } catch (e) {}
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

/*
Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new StoredCard()));

            
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
                    'orderID': orderID,
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
                    twilioFlutter.sendSMS(
                        toNumber: phone,
                        messageBody:
                            'رفوف\nمرحبا ${widget.name} لقد تم أستلام طلبك\nرقم طلبك هو ${uid.substring(0, 13)}');
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
      ),*/

// All Funcation
/* 
  List<ItemShow> cart = [];
  List<String> englishItem = [];
  List<String> arabicItem = [];
  List<String> items = [];
  List<Map<String, dynamic>> mapItems = [];
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
  String phone;
  @override
  void initState() {
    fetchMyCart();
    super.initState();
    deviceID();
    uid = uuid.v1();
    getTheDeriver();

    twilioFlutter = TwilioFlutter(
        accountSid: '', // replace *** with Account SID
        authToken: '', // replace xxx with Auth Token
        twilioNumber: '+12054966662' // replace .... with Twilio Number
        );
    phone = widget.phone;
    if (phone.substring(0, 2) == "05") {
      phone = phone.substring(1);

      phone = "+966$phone";
    } else {
      phone = "+1$phone";
    }

    amount = double.parse(widget.totalAfterTax);
    amount = amount * 100;
    amountInt = amount.floor();
    StripeService.init();
  }

  double amount;
  int amountInt;
  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    }
  }

  TwilioFlutter twilioFlutter;
  onItemPress(BuildContext context, int i) async {
    switch (i) {
      case 0:
        var respose = await StripeService.payWithNewCard(
          amount: amountInt.toString(),
          currency: 'SAR',
        );
        Scaffold.of(context).showSnackBar(
          SnackBar(
            elevation: 0,
            content: Text(
              respose.message,
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 3),
            backgroundColor: respose.success == true
                ? Colors.green
                : respose.message == 'e' ? Colors.transparent : Colors.red,
          ),
        );
        break;
      case 1:
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => new StoredCard(
              amount: amountInt.toString(),
            ),
          ),
        );
        break;
      case 2:
        break;
    }
  }
*/

//all Widgets

/*
 Container(
          padding: EdgeInsets.all(20.0),
          child: ListView.separated(
              itemBuilder: (context, i) {
                Icon icon;
                Text text;

                switch (i) {
                  case 0:
                    icon = Icon(
                      Icons.add_circle,
                      color: Theme.of(context).primaryColor,
                    );
                    text = Text("بطاقة جديدة");
                    break;
                  case 1:
                    icon = Icon(
                      Icons.credit_card,
                      color: Theme.of(context).primaryColor,
                    );
                    text = Text("أستخدام بطاقتك السابقه");
                    break;
                  case 2:
                    icon = Icon(
                      Icons.attach_money,
                      color: Theme.of(context).primaryColor,
                    );
                    text = Text("دفع كاش");
                    break;
                }
                return Container(
                  child: ListTile(
                    onTap: () {
                      onItemPress(context, i);
                    },
                    leading: icon,
                    title: text,
                  ),
                );
              },
              separatorBuilder: (context, i) {
                return Divider(
                  color: Theme.of(context).primaryColor,
                );
              },
              itemCount: 3),
        )
*/
