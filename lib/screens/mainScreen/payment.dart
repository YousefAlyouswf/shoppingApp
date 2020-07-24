import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_code/country_code.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geocoder/geocoder.dart';
import 'package:http/http.dart';
import 'package:mailer/mailer.dart' as mail;
import 'package:mailer/smtp_server.dart';
import 'package:share/share.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:twilio_flutter/twilio_flutter.dart';
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
  final String city;
  final String postCose;
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
    this.city,
    this.postCose,
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
    if (widget.postCose == "" || widget.postCose == null) {
      zipCode = "00966";
    } else {
      zipCode = widget.postCose;
    }
    total =
        double.parse(widget.totalAfterTax) + double.parse(widget.delvierCost);
    totalBeforeDiscount =
        double.parse(widget.totalAfterTax) + double.parse(widget.discount);
  }

  Future<void> addThisOrderToFirestore() async {
    double total =
        double.parse(widget.totalAfterTax) + double.parse(widget.delvierCost);
    String userIDPhone;
    if (androidInfo == null) {
      userIDPhone = iosDeviceInfo.identifierForVendor;
    } else {
      userIDPhone = androidInfo.androidId;
    }
    await Firestore.instance.collection('order').add({
      'payment': '100',
      'driverID': '',
      'driverName': '',
      'orderID': orderID,
      'date': DateTime.now().toString(),
      'status': '0',
      'address': widget.address,
      'city': widget.city,
      'postCode': zipCode,
      'discount': widget.discount,
      'total': total,
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
      'userID': userIDPhone,
    });
  }

  bool paymentMethodForRiyadh = false;
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
        'city': widget.city,
        'state': state,
        'zipCode': zipCode,
        'address': widget.address,
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
    if (city == "Riyadh" || city == "الرياض") {
      setState(() {
        paymentMethodForRiyadh = true;
      });
    } else {
      setState(() {
        credit = true;
      });
    }
    addressLine = first.addressLine;
    state = first.adminArea;
    country = first.countryName;
    var code = CountryCode.tryParse(first.countryCode);
    isoCode = code.alpha3;

    setState(() {});
    paymantPage();
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
  String userIDPhone2;
  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
    }
    fetchMyCart();
  }

  bool cash = false;
  bool credit = false;
  bool addFirestore = false;
  double total;
  double totalBeforeDiscount;
  bool cardSelected = false;
  bool loading = false;
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        elevation: 0,
        title: Text(
          word("appName", context),
          style: TextStyle(
            fontFamily: isEnglish ? 'EN' : "MainFont",
          ),
        ),
      ),
      body: cardSelected
          ? WebView(
              key: UniqueKey(),
              initialUrl: webviewUrl,
              javascriptMode: JavascriptMode.unrestricted,
              onPageFinished: (url) async {
                print('~~~~~~~~~~~~~>>>>> $url');
                if (url == "http://geniusloop.co/payment/succed.php") {
                  await addThisOrderToFirestore().then((value) {
                    takeOffFromSubcatgory();
                    FocusScope.of(context).requestFocus(FocusNode());
                    twilioFlutter.sendSMS(
                        toNumber: phone,
                        messageBody:
                            'الوان ولمسات\nمرحبا ${widget.firstName} لقد تم أستلام طلبك\nرقم طلبك هو $orderID');
                    //sendEmailToCustomer();
                    addCartToast(word("Succssful", context));
                    navIndex = 4;
                    DBHelper.deleteAllItem("cart");
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }).catchError((e) {
                    print(e);
                  });
                } else if (url == "http://geniusloop.co/payment/failed.php") {
                  FocusScope.of(context).requestFocus(FocusNode());
                  errorToast(word("Failed", context));
                }
              },
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * .6,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 5,
                            blurRadius: 7,
                            offset: Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Column(
                        children: <Widget>[
                          Image.asset(
                            'assets/images/logo.png',
                            height: MediaQuery.of(context).size.height * .05,
                          ),
                          Text(
                            word("appName", context),
                            style: TextStyle(fontFamily: "MainFont"),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("السعر:"),
                              Text(
                                  " $totalBeforeDiscount ${word('currancy', context)}"),
                            ],
                          ),
                          widget.discount == '0.0'
                              ? Container()
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text("الخصم:"),
                                    Text(
                                        "${widget.discount} ${word('currancy', context)}"),
                                  ],
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("التوصيل:"),
                              Text(
                                  "${widget.delvierCost}.0 ${word('currancy', context)}"),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Text("الإجمالي:"),
                              Text("$total ${word('currancy', context)}"),
                            ],
                          ),
                          height < 600
                              ? Container()
                              : SizedBox(
                                  height: 25,
                                ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    border: cash ? Border.all() : null,
                                    color: cash ? Colors.green[200] : null,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: FlatButton.icon(
                                    label: Text(
                                      "دفع نقدي",
                                      style: TextStyle(fontFamily: "MainFont"),
                                    ),
                                    icon:
                                        FaIcon(FontAwesomeIcons.moneyBillWave),
                                    onPressed: () {
                                      if (!paymentMethodForRiyadh) {
                                        errorToast(
                                            "الدفع نقدي داخل الرياض فقط");
                                      } else {
                                        setState(() {
                                          cash = true;
                                          credit = false;
                                        });
                                      }
                                    }),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  border: credit ? Border.all() : null,
                                  color: credit ? Colors.green[200] : null,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                ),
                                child: FlatButton.icon(
                                    label: Text(
                                      "بطاقة",
                                      style: TextStyle(fontFamily: "MainFont"),
                                    ),
                                    icon: FaIcon(FontAwesomeIcons.creditCard),
                                    onPressed: () {
                                      setState(() {
                                        cash = false;
                                        credit = true;
                                      });
                                    }),
                              ),
                            ],
                          ),
                          height < 600
                              ? Container()
                              : SizedBox(
                                  height: 25,
                                ),
                          credit
                              ? Image.network(
                                  "https://probot.io/static/payments-cards.png",
                                  height: 50,
                                )
                              : cash
                                  ? Image.network(
                                      "https://img.icons8.com/bubbles/2x/cash-in-hand.png",
                                      height: 70,
                                    )
                                  : Container(),
                          Spacer(),
                          InkWell(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Container(
                                width: double.infinity,
                                height: 50,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).unselectedWidgetColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Text(
                                  credit
                                      ? "أدخل بيانات البطاقه"
                                      : cash
                                          ? "إتمام الشراء"
                                          : "أختر طريقة الدفع",
                                  style: TextStyle(
                                      fontFamily: "MainFont",
                                      color: Colors.white,
                                      fontSize: 22),
                                ),
                              ),
                            ),
                            onTap: () async {
                              if (cash) {
                                try {
                                  double total =
                                      double.parse(widget.totalAfterTax) +
                                          double.parse(widget.delvierCost);

                                  String userIDPhone;
                                  if (androidInfo == null) {
                                    userIDPhone =
                                        iosDeviceInfo.identifierForVendor;
                                  } else {
                                    userIDPhone = androidInfo.androidId;
                                  }
                                  await Firestore.instance
                                      .collection('order')
                                      .add({
                                    'payment': 'cash',
                                    'driverID': '',
                                    'driverName': '',
                                    'orderID': orderID,
                                    'date': DateTime.now().toString(),
                                    'status': '0',
                                    'address': widget.address,
                                    'city': widget.city,
                                    'postCode': zipCode,
                                    'discount': widget.discount,
                                    'total': total,
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
                                    'userID': userIDPhone,
                                  }).then((value) {
                                    takeOffFromSubcatgory();
                                    FocusScope.of(context)
                                        .requestFocus(FocusNode());
                                    twilioFlutter.sendSMS(
                                        toNumber: phone,
                                        messageBody:
                                            'الوان ولمسات\nمرحبا ${widget.firstName} لقد تم أستلام طلبك\nرقم طلبك هو $orderID');
                                    sendEmailToCustomer();
                                    addCartToast(
                                        "تمت علمية الشراء يمكنك متابعه طلبك من هنا");
                                    navIndex = 4;
                                    DBHelper.deleteAllItem("cart");
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                  });
                                } catch (e) {
                                  print(e);
                                }
                              } else if (credit) {
                                setState(() {
                                  cardSelected = true;
                                });
                              } else {
                                errorToast("أختر طريقه الدفع");
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Spacer(),
                Text(
                  "هل تريد أحد من عائلتك أو صديقك يدفع الفاتوره؟",
                  style: TextStyle(
                    fontFamily: "MainFont",
                    color: Colors.black,
                    fontSize: 15,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "يمكنك مشاركة صفحة الدفع معهم أضغط على الزر التالي",
                    style: TextStyle(
                      fontFamily: "MainFont",
                      color: Colors.black,
                      fontSize: 15,
                    ),
                  ),
                ),
                loading
                    ? Image.network(
                        "https://flevix.com/wp-content/uploads/2019/07/Curve-Loading.gif",
                        height: 100,
                      )
                    : InkWell(
                        splashColor: Colors.transparent,
                        onTap: () async {
                          setState(() {
                            loading = true;
                          });
                          Response response = await post(
                              "http://geniusloop.co/shortlink/",
                              body: {
                                "link": webviewUrl,
                              });
                          print(response.statusCode);
                          if (response.statusCode == 200) {
                            Share.share(response.body);
                          }
                          setState(() {
                            loading = false;
                          });
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width * 0.4,
                          margin: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .unselectedWidgetColor
                                .withOpacity(0.6),
                            border: Border.all(),
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: Text(
                            "مشاركة",
                            style: TextStyle(
                                fontFamily: "MainFont",
                                color: Colors.white,
                                fontSize: 15),
                          ),
                        ),
                      )
              ],
            ),
    );
  }

  takeOffFromSubcatgory() async {
    await Firestore.instance
        .collection('quantityItem')
        .getDocuments()
        .then((v) {
      v.documents.forEach((e) async {
        for (var i = 0; i < cart.length; i++) {
          if (cart[i].productID == e['id']) {
            int oldQ = int.parse(e['number']);
            int result = oldQ - int.parse(cart[i].quantity);
            await Firestore.instance
                .collection("quantityItem")
                .document(e.documentID)
                .updateData({
              'number': result.toString(),
            });
          }
        }
      });
    });
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
    }
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
