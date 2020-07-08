import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code/country_code.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoder/geocoder.dart';
import 'package:mailer/mailer.dart' as mail;
import 'package:mailer/smtp_server.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

class Payment extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  final String firstName;
  final String lastName;
  final String phone;
  final String address;
  final String lat;
  final String long;
  final String buyPrice;
  final String price;
  final String totalAfterTax;
  final String email;
  final String delvierCost;
  final String discount;

  const Payment({
    Key key,
    this.onThemeChanged,
    this.changeLangauge,
    this.firstName,
    this.lastName,
    this.phone,
    this.address,
    this.lat,
    this.long,
    this.buyPrice,
    this.email,
    this.price,
    this.totalAfterTax,
    this.delvierCost,
    this.discount,
  }) : super(key: key);
  @override
  _PaymentState createState() => _PaymentState();
}

class _PaymentState extends State<Payment> {
  String orderID;
  String items;
  String quantity;
  String unitPrice;
  String city;
  String zipCode;
  String addressLine;
  String state;
  String country;
  String isoCode;
  Uuid idOrder;
  @override
  void initState() {
    super.initState();

    idOrder = Uuid();
    String uid = idOrder.v1();
    orderID = uid.substring(0, 13);
    deviceID();
    items = '';
    quantity = '';
    unitPrice = '';
    twilioInfo();
  }

  addThisOrderToFirestore() async {
    Firestore.instance.collection('order').add({
      'payment': '',
      'driverID': id,
      'driverName': name,
      'orderID': orderID,
      'date': '',
      'status': '0',
      'discount': widget.discount,
      'total': widget.totalAfterTax,
      'lat': widget.lat,
      'long': widget.long,
      'firstName': widget.firstName,
      'lastName': widget.lastName,
      'phone': widget.phone,
      'deliverCost': widget.delvierCost,
      'email': widget.email,
      'priceForSell': widget.price,
      'priceForBuy': widget.buyPrice,
      'items': FieldValue.arrayUnion(mapItems),
      'userID': androidInfo.androidId == null
          ? iosDeviceInfo.identifierForVendor
          : androidInfo.androidId,
    });
    paymantPage();
  }

  String accountSid;
  String authToken;
  String twilioNumber;
  String phone;
  TwilioFlutter twilioFlutter;
  twilioInfo() async {
    await Firestore.instance.collection("twilio").getDocuments().then((v) {
      v.documents.forEach((e) {
        setState(() {
          accountSid = e['accountSid'];
          authToken = e['authToken'];
          twilioNumber = e['twilioNumber'];
        });
      });
    });
    twilioFlutter = TwilioFlutter(
      accountSid: accountSid,
      authToken: authToken,
      twilioNumber: '+12054966662',
    );

    phone = widget.phone;
    if (phone.substring(0, 2) == "05") {
      phone = phone.substring(1);

      phone = "+966$phone";
    } else {
      phone = "+1$phone";
    }
  }

  String webviewUrl = "";
  static const ROOT = "http://geniusloop.co/payment/index.php";
  Future<String> paymantPage() async {
    double total = double.parse(widget.totalAfterTax) +
        double.parse(widget.delvierCost) +
        double.parse(widget.discount);

    try {
      Map<String, dynamic> map = {
        'amount': total.toString(),
        'items': items,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'city': city,
        'state': state,
        'zipCode': zipCode,
        'address': addressLine,
        'phone': widget.phone,
        'email': widget.email,
        'orderID': orderID,
        'discount': widget.discount,
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'language': isEnglish ? "English" : "Arabic",
        'country': country,
        'ISO': isoCode,
        'deliverCost': widget.delvierCost
      };
      print(map);
      final response = await http.post(ROOT, body: map);
      if (200 == response.statusCode) {
        setState(() {
          webviewUrl = response.body;
        });
        print("--------------> ${response.body}");
        return response.body;
      } else {}
    } catch (e) {
      print(e);
    }
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
    country = first.countryName;
    var code = CountryCode.tryParse(first.countryCode);
    isoCode = code.alpha3;

    setState(() {});
    addThisOrderToFirestore();
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
    setState(() {});
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

  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosDeviceInfo;
  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    }
    fetchMyCart();
  }

  @override
  Widget build(BuildContext context) {
    // print("----------->>>>>$webviewUrl");

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        elevation: 0,
        title: Text(
          word("appName", context),
          style: TextStyle(
            fontFamily: isEnglish ? 'EN' : "MainFont",
          ),
        ),
        actions: [
          IconButton(
              icon: Icon(Icons.share),
              onPressed: () {
                print(webviewUrl);
              })
        ],
      ),
      body: webviewUrl == ""
          ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(
                    "https://cdn.dribbble.com/users/2129935/screenshots/8868815/media/cfc18f3a1bb266b52c8d3f2677c999e4.gif",
                  ),
                ),
              ),
            )
          : WebView(
              key: UniqueKey(),
              initialUrl: webviewUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (url) async {
                if (url == "http://geniusloop.co/payment/succed.php") {
                  FocusScope.of(context).requestFocus(FocusNode());
                  twilioFlutter.sendSMS(
                      toNumber: phone,
                      messageBody:
                          'رفوف\nمرحبا ${widget.firstName} لقد تم أستلام طلبك\nرقم طلبك هو $orderID');
                  sendEmailToCustomer();
                  addCartToast(word("Succssful", context));
                  navIndex = 3;
                  DBHelper.deleteAllItem("cart");
                  Navigator.popUntil(context, (route) => route.isFirst);
                } else if (url == "http://geniusloop.co/payment/failed.php") {
                  FocusScope.of(context).requestFocus(FocusNode());
                  errorToast(word("Failed", context));
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Payment(
                        totalAfterTax: widget.totalAfterTax,
                        price: widget.price,
                        buyPrice: widget.buyPrice,
                        onThemeChanged: widget.onThemeChanged,
                        changeLangauge: widget.changeLangauge,
                        firstName: widget.firstName,
                        lastName: widget.lastName,
                        phone: widget.phone,
                        lat: widget.lat,
                        long: widget.long,
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }

  void sendEmailToCustomer() async {
    String username = "api.chc1989@gmail.com";
    String password = "Yy147963";

    final smtpServer = gmail(username, password);
    // Creating the Gmail server

    // Create our email message.
    final message = mail.Message()
      ..from = mail.Address(username, 'Your name')
      ..recipients.add(widget.email) //recipent email
      // ..ccRecipients.addAll([
      //   'destCc1@example.com',
      //   'destCc2@example.com'
      // ]) //cc Recipents emails
      // ..bccRecipients.add(Address(
      //     'bccAddress@example.com')) //bcc Recipents emails
      ..subject = word("subject_email", context) //subject of the email
      ..html =
          '<h1>${word('body_email', context)} </h1><h1 style="color:pink">$orderID</h1> <br> <table cellpadding="0" cellspacing="0" class="sc-gPEVay eQYmiW" style="vertical-align: -webkit-baseline-middle; font-size: medium; font-family: Arial;"><tbody><tr><td><table cellpadding="0" cellspacing="0" class="sc-gPEVay eQYmiW" style="vertical-align: -webkit-baseline-middle; font-size: medium; font-family: Arial;"><tbody><tr><td style="padding: 0px; vertical-align: middle;"><h3 color="#000000" class="sc-fBuWsC eeihxG" style="margin: 0px; font-size: 18px; color: rgb(0, 0, 0);"><span>Yousef</span><span>&nbsp;</span><span>Alyousef</span></h3><p color="#000000" font-size="medium" class="sc-fMiknA bxZCMx" style="margin: 0px; color: rgb(0, 0, 0); font-size: 14px; line-height: 22px;"><span>Supplier</span></p><p color="#000000" font-size="medium" class="sc-dVhcbM fghLuF" style="margin: 0px; font-weight: 500; color: rgb(0, 0, 0); font-size: 14px; line-height: 22px;"><span>Marketing</span><span>&nbsp;|&nbsp;</span><span>Rfoof Store</span></p><table cellpadding="0" cellspacing="0" class="sc-gPEVay eQYmiW" style="vertical-align: -webkit-baseline-middle; font-size: medium; font-family: Arial; width: 100%;"><tbody><tr><td height="30"></td></tr><tr><td color="#F2547D" direction="horizontal" height="1" class="sc-jhAzac hmXDXQ" style="width: 100%; border-bottom: 1px solid rgb(242, 84, 125); border-left: none; display: block;"></td></tr><tr><td height="30"></td></tr></tbody></table><table cellpadding="0" cellspacing="0" class="sc-gPEVay eQYmiW" style="vertical-align: -webkit-baseline-middle; font-size: medium; font-family: Arial;"><tbody><tr height="25" style="vertical-align: middle;"><td width="30" style="vertical-align: middle;"><table cellpadding="0" cellspacing="0" class="sc-gPEVay eQYmiW" style="vertical-align: -webkit-baseline-middle; font-size: medium; font-family: Arial;"><tbody><tr><td style="vertical-align: bottom;"><span color="#F2547D" width="11" class="sc-jlyJG bbyJzT" style="display: block; background-color: rgb(242, 84, 125);"><img src="https://cdn2.hubspot.net/hubfs/53/tools/email-signature-generator/icons/phone-icon-2x.png" color="#F2547D" width="13" class="sc-iRbamj blSEcj" style="display: block; background-color: rgb(242, 84, 125);"></span></td></tr></tbody></table></td><td style="padding: 0px; color: rgb(0, 0, 0);"><a href="tel:+18126827296" color="#000000" class="sc-gipzik iyhjGb" style="text-decoration: none; color: rgb(0, 0, 0); font-size: 12px;"><span>+18126827296</span></a> | <a href="tel:+8126827296" color="#000000" class="sc-gipzik iyhjGb" style="text-decoration: none; color: rgb(0, 0, 0); font-size: 12px;"><span>+8126827296</span></a></td></tr><tr height="25" style="vertical-align: middle;"><td width="30" style="vertical-align: middle;"><table cellpadding="0" cellspacing="0" class="sc-gPEVay eQYmiW" style="vertical-align: -webkit-baseline-middle; font-size: medium; font-family: Arial;"><tbody><tr><td style="vertical-align: bottom;"><span color="#F2547D" width="11" class="sc-jlyJG bbyJzT" style="display: block; background-color: rgb(242, 84, 125);"><img src="https://cdn2.hubspot.net/hubfs/53/tools/email-signature-generator/icons/email-icon-2x.png" color="#F2547D" width="13" class="sc-iRbamj blSEcj" style="display: block; background-color: rgb(242, 84, 125);"></span></td></tr></tbody></table></td><td style="padding: 0px;"><a href="mailto:api.chc1989@gmail.com" color="#000000" class="sc-gipzik iyhjGb" style="text-decoration: none; color: rgb(0, 0, 0); font-size: 12px;"><span>api.chc1989@gmail.com</span></a></td></tr><tr height="25" style="vertical-align: middle;"><td width="30" style="vertical-align: middle;"><table cellpadding="0" cellspacing="0" class="sc-gPEVay eQYmiW" style="vertical-align: -webkit-baseline-middle; font-size: medium; font-family: Arial;"><tbody><tr><td style="vertical-align: bottom;"><span color="#F2547D" width="11" class="sc-jlyJG bbyJzT" style="display: block; background-color: rgb(242, 84, 125);"><img src="https://cdn2.hubspot.net/hubfs/53/tools/email-signature-generator/icons/link-icon-2x.png" color="#F2547D" width="13" class="sc-iRbamj blSEcj" style="display: block; background-color: rgb(242, 84, 125);"></span></td></tr></tbody></table></td><td style="padding: 0px;"><a href="http://geniusloop.co/" color="#000000" class="sc-gipzik iyhjGb" style="text-decoration: none; color: rgb(0, 0, 0); font-size: 12px;"><span>http://geniusloop.co/</span></a></td></tr></tbody></table><table cellpadding="0" cellspacing="0" class="sc-gPEVay eQYmiW" style="vertical-align: -webkit-baseline-middle; font-size: medium; font-family: Arial;"><tbody><tr><td height="30"></td></tr></tbody></table><a href="https://www.hubspot.com/email-signature-generator?utm_source=create-signature" target="_blank" rel="noopener noreferrer" class="sc-gisBJw kDlVKO" style="font-size: 12px; display: block; color: rgb(0, 0, 0);"></a></td></tr></tbody></table></td></tr></tbody></table>';

    try {
      final sendReport = await mail.send(message, smtpServer);
      print('Message sent: ' +
          sendReport.toString()); //print if the email is sent
    } on mail.MailerException catch (e) {
      print('Message not sent. \n' +
          e.toString()); //print if the email is not sent
      // e.toString() will show why the email is not sending
    }
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
