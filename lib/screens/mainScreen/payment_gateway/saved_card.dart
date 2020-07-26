import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/screens/mainScreen/payment.dart';
import 'package:shop_app/widgets/lang/appLocale.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../homePage.dart';
import 'moyasser.dart';

class SavedCard extends StatefulWidget {
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
  final String orderID;
  final String userIDPhone;
  final String zipCode;
  final String phonesms;
  final List<Map<String, dynamic>> mapItems;
  final Function takeOffFromSubcatgory;
  final Function sendSms;

  const SavedCard(
      {Key key,
      this.onThemeChanged,
      this.changeLangauge,
      this.firstName,
      this.lastName,
      this.phone,
      this.address,
      this.city,
      this.postCose,
      this.lat,
      this.long,
      this.buyPrice,
      this.price,
      this.totalAfterTax,
      this.email,
      this.delvierCost,
      this.discount,
      this.orderID,
      this.userIDPhone,
      this.zipCode,
      this.mapItems,
      this.takeOffFromSubcatgory,
      this.phonesms,
      this.sendSms})
      : super(key: key);
  @override
  _SavedCardState createState() => _SavedCardState();
}

class _SavedCardState extends State<SavedCard> {
  List cards = [];

  Future<void> fetchCards() async {
    final dataList = await DBHelper.getData('card');
    setState(() {
      cards = dataList
          .map((item) => {
                'cardNumber': item['cardNumber'],
                'expiryDate': item['expiryDate'],
                'cardHolderName': item['cardHolderName'],
                'cvvCode': item['cvvCode'],
                'backView': false,
              })
          .toList();
    });
  }

  double total;

  @override
  void initState() {
    super.initState();
    fetchCards();
    total = (double.parse(widget.totalAfterTax) +
            double.parse(widget.delvierCost)) *
        100;
  }

  bool sendToWeb = false;
  String webviewUrl = '';
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        AppLocale.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      theme: ThemeData(
        splashColor: Color(0xFFFF834F),
        unselectedWidgetColor: Color(0xFFFF834F),
        primarySwatch: Colors.grey,
        textSelectionHandleColor: Color(0xFFFF834F),
        textSelectionColor: Color(0xFFFF834F),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      supportedLocales: [
        Locale('en', ''),
      ],
      locale: Locale('en', ''),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFF834F),
          elevation: 0,
          centerTitle: true,
          title: Text(
            sendToWeb ? "أدخل الرقم السري" : "أختر بطاقتك",
            style: TextStyle(
                fontFamily: isEnglish ? 'EN' : "MainFont", color: Colors.white),
          ),
        ),
        body: sendToWeb
            ? WebView(
                // key: UniqueKey(),
                initialUrl: webviewUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onPageFinished: (url) async {
                  if (url.contains("Succeeded")) {
                    print("YEEEEESSS");
                    addThisOrderToFirestore('order').then((value) {
                      widget.takeOffFromSubcatgory();
                      FocusScope.of(context).requestFocus(FocusNode());
                      widget.sendSms();
                      //sendEmailToCustomer();
                      addCartToast(word("Succssful", context));
                      navIndex = 4;
                      DBHelper.deleteAllItem("cart");
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }).catchError((e) {
                      print(e);
                    });
                  } else {
                    print("NOOOOOOO");
                  }
                },
              )
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                        itemCount: cards.length,
                        itemBuilder: (context, i) {
                          return InkWell(
                            onTap: () async {
                              List<String> date =
                                  cards[i]['expiryDate'].split('/');
                              String cardNoSpaces = cards[i]['cardNumber']
                                  .replaceAll(new RegExp(r"\s+\b|\b\s"), "");

                              Response response = await post(
                                  "https://api.moyasar.com/v1/payments.html/",
                                  body: {
                                    'source[name]': cards[i]['cardHolderName'],
                                    'source[number]': cardNoSpaces,
                                    'source[cvc]': cards[i]['cvvCode'],
                                    'source[month]': date[0],
                                    'source[year]': '20${date[1]}',
                                    'source[type]': 'creditcard',
                                    'amount': total.toInt().toString(),
                                    'publishable_api_key':
                                        'pk_test_syTNfUUcx3UeXamEA848gchRP3rXAeMjj7o5cCa8',
                                    'callback_url':
                                        'https://www.tuvan.shop/payment',
                                  });

                              String htmlResponce = response.body;
                              List<String> urlAuth = htmlResponce.split('"');
                              setState(() {
                                webviewUrl = urlAuth[1];
                                sendToWeb = true;
                              });
                            },
                            child: CreditCardWidget(
                              cardNumber: cards[i]['cardNumber'],
                              expiryDate: cards[i]['expiryDate'],
                              cardHolderName: cards[i]['cardHolderName'],
                              cvvCode: cards[i]['cvvCode'],
                              showBackView: false,
                            ),
                          );
                        }),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => Moyasser(
                            totalAfterTax: widget.totalAfterTax,
                            price: widget.price,
                            sendSms: widget.sendSms,
                            orderID: widget.orderID,
                            phonesms: widget.phonesms,
                            userIDPhone: widget.userIDPhone,
                            buyPrice: widget.buyPrice,
                            onThemeChanged: widget.onThemeChanged,
                            changeLangauge: widget.changeLangauge,
                            firstName: widget.firstName,
                            lastName: widget.lastName,
                            email: widget.email,
                            phone: widget.phone,
                            lat: widget.lat,
                            long: widget.long,
                            delvierCost: widget.delvierCost,
                            discount: widget.discount,
                            address: widget.address,
                            city: widget.city,
                            postCose: widget.postCose,
                            zipCode: widget.zipCode,
                            mapItems: widget.mapItems,
                            takeOffFromSubcatgory: widget.takeOffFromSubcatgory,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.all(8.0),
                      width: double.infinity,
                      alignment: Alignment.center,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: Text(
                        "بطاقه جديدة",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: "MainFont"),
                      ),
                    ),
                  )
                ],
              ),
      ),
    );
  }

  Future<void> addThisOrderToFirestore(String collection) async {
    double total =
        double.parse(widget.totalAfterTax) + double.parse(widget.delvierCost);

    await Firestore.instance.collection(collection).add({
      'payment': '100',
      'driverID': '',
      'driverName': '',
      'orderID': widget.orderID,
      'date': DateTime.now().toString(),
      'status': '0',
      'address': widget.address,
      'city': widget.city,
      'postCode': widget.zipCode,
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
      'items': FieldValue.arrayUnion(widget.mapItems),
      'userID': widget.userIDPhone,
    });
  }
}
