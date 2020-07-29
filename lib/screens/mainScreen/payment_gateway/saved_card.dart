import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart';
import 'package:shop_app/database/local_db.dart';
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
                'id': item['id'],
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

  bool delete = false;
  bool sendToWeb = false;
  String webviewUrl = '';
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFF834F),
        elevation: 0,
        centerTitle: true,
        title: Text(
          sendToWeb ? "أدخل الرقم السري" : "أختر بطاقتك",
          style: TextStyle(
              fontFamily: isEnglish ? 'EN' : "MainFont", color: Colors.white),
        ),
        actions: [
          !sendToWeb
              ? IconButton(
                  icon: Icon(
                    Icons.delete,
                    size: 30,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      delete = !delete;
                    });
                  })
              : Container(),
          IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.pop(context);
              })
        ],
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
                          child: Stack(
                            children: [
                              Directionality(
                                textDirection: TextDirection.ltr,
                                child: CreditCardWidget(
                                  width: double.infinity,
                                  cardNumber: cards[i]['cardNumber'],
                                  expiryDate: cards[i]['expiryDate'],
                                  cardHolderName: cards[i]['cardHolderName'],
                                  cvvCode: cards[i]['cvvCode'],
                                  showBackView: false,
                                ),
                              ),
                              delete
                                  ? Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: Container(
                                          height: 65,
                                          width: 65,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(50)),
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: NetworkImage(
                                                  "https://images.squarespace-cdn.com/content/v1/51abe1dae4b08f6a770bf7d0/1569943355220-16CIDPEPYIKJX10EW2ZC/ke17ZwdGBToddI8pDm48kLxnK526YWAH1qleWz-y7AFZw-zPPgdn4jUwVcJE1ZvWEtT5uBSRWt4vQZAgTJucoTqqXjS3CfNDSuuf31e0tVH-2yKxPTYak0SCdSGNKw8A2bnS_B4YtvNSBisDMT-TGt1lH3P2bFZvTItROhWrBJ0/delete.gif"),
                                            ),
                                          ),
                                          child: InkWell(
                                            onTap: () {
                                              int x = cards[i]['id'];
                                              print(x);
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12.0),
                                                  ),
                                                  child: Container(
                                                    height: 300.0,
                                                    width: double.infinity,
                                                    child: Column(
                                                      children: <Widget>[
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 16.0,
                                                                  top: 8.0),
                                                          child: Row(
                                                            children: [
                                                              FaIcon(
                                                                FontAwesomeIcons
                                                                    .trashAlt,
                                                                size: 30,
                                                              ),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                              Text(
                                                                "حذف البطاقه",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      "MainFont",
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        Divider(
                                                          thickness: 2,
                                                          color:
                                                              Colors.grey[200],
                                                        ),
                                                        Expanded(
                                                          child: Center(
                                                            child: Text(
                                                              "هل أنت متأكد من الحذف؟",
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontFamily:
                                                                    "MainFont",
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: InkWell(
                                                            onTap: () {
                                                              DBHelper
                                                                  .deleteCard(
                                                                      "card",
                                                                      x);
                                                              fetchCards();
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: double
                                                                  .infinity,
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                                color: Theme.of(
                                                                        context)
                                                                    .unselectedWidgetColor,
                                                              ),
                                                              child: Text(
                                                                "حذف",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        15,
                                                                    fontFamily:
                                                                        "MainFont",
                                                                    color: Colors
                                                                        .white),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: InkWell(
                                                            onTap: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: Container(
                                                              height: 50,
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: double
                                                                  .infinity,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border: Border
                                                                    .all(),
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            5)),
                                                              ),
                                                              child: Text(
                                                                "إلغاء",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 15,
                                                                  fontFamily:
                                                                      "MainFont",
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ],
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
