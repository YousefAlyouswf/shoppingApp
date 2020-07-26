import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_credit_card/credit_card_model.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:http/http.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/widgets/lang/appLocale.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../homePage.dart';

class Moyasser extends StatefulWidget {
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

  const Moyasser(
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
      this.phonesms,
      this.mapItems,
      this.takeOffFromSubcatgory,
      this.sendSms})
      : super(key: key);
  @override
  _MoyasserState createState() => _MoyasserState();
}

class _MoyasserState extends State<Moyasser> {
  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  bool isCvvFocused = false;
  double total;
  @override
  void initState() {
    super.initState();
    setState(() {
      isEnglish = true;
    });
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
      supportedLocales: [
        Locale('en', ''),
      ],
      locale: Locale('en', ''),
      home: Scaffold(
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: sendToWeb
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
                  children: <Widget>[
                    CreditCardWidget(
                      cardNumber: cardNumber,
                      expiryDate: expiryDate,
                      cardHolderName: cardHolderName,
                      cvvCode: cvvCode,
                      showBackView: isCvvFocused,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: CreditCardForm2(
                          onCreditCardModelChange: onCreditCardModelChange,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () async {
                          List<String> date = expiryDate.split('/');
                          String cardNoSpaces = cardNumber.replaceAll(
                              new RegExp(r"\s+\b|\b\s"), "");
                          int month = 0;
                          print(cardNoSpaces.length);
                          try {
                            month = int.parse(date[0]);
                          } catch (e) {
                            errorToast("يوجد خطأ في معلومات البطاقه");
                          }

                          if (month > 12 ||
                              cardNoSpaces.length < 16 ||
                              cvvCode.isEmpty ||
                              cardHolderName.isEmpty) {
                            errorToast("يوجد خطأ في معلومات البطاقه");
                          } else {
                            Response response = await post(
                                "https://api.moyasar.com/v1/payments.html/",
                                body: {
                                  'source[name]': cardHolderName,
                                  'source[number]': cardNoSpaces,
                                  'source[cvc]': cvvCode,
                                  'source[month]': date[0],
                                  'source[year]': '20${date[1]}',
                                  'source[type]': 'creditcard',
                                  'amount': total.toInt().toString(),
                                  'publishable_api_key':
                                      'pk_test_syTNfUUcx3UeXamEA848gchRP3rXAeMjj7o5cCa8',
                                  'callback_url':
                                      'https://www.tuvan.shop/payment',
                                });

                            // print("------->>>${response.body}");
                            String htmlResponce = response.body;
                            List<String> urlAuth = htmlResponce.split('"');
                            Map<String, dynamic> data = {
                              'cardNumber': cardNumber,
                              'expiryDate': expiryDate,
                              'cardHolderName': cardHolderName,
                              'cvvCode': cvvCode,
                            };
                            DBHelper.insertCards('card', data);
                            setState(() {
                              webviewUrl = urlAuth[1];
                              sendToWeb = true;
                            });
                          }
                        },
                        child: Container(
                          height: 50,
                          color: Theme.of(context).unselectedWidgetColor,
                          alignment: Alignment.center,
                          width: double.infinity,
                          child: Text(
                            'إتمام عملية الدفع',
                            style: TextStyle(
                                fontSize: 20,
                                fontFamily: "MainFont",
                                color: Colors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
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

class CreditCardForm2 extends StatefulWidget {
  const CreditCardForm2({
    Key key,
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.cvvCode,
    @required this.onCreditCardModelChange,
    this.themeColor,
    this.textColor = Colors.black,
    this.cursorColor,
  }) : super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final Color themeColor;
  final Color textColor;
  final Color cursorColor;

  @override
  _CreditCardForm2State createState() => _CreditCardForm2State();
}

class _CreditCardForm2State extends State<CreditCardForm2> {
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused = false;
  Color themeColor;

  void Function(CreditCardModel) onCreditCardModelChange;
  CreditCardModel creditCardModel;

  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  final TextEditingController _cvvCodeController =
      MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber ?? '';
    expiryDate = widget.expiryDate ?? '';
    cardHolderName = widget.cardHolderName ?? '';
    cvvCode = widget.cvvCode ?? '';

    creditCardModel = CreditCardModel(
        cardNumber, expiryDate, cardHolderName, cvvCode, isCvvFocused);
  }

  @override
  void initState() {
    super.initState();

    createCreditCardModel();

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);

    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel.cardNumber = cardNumber;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
        onCreditCardModelChange(creditCardModel);
      });
    });
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor ?? Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: themeColor.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Form(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
              child: TextFormField(
                controller: _cardNumberController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'رقم البطاقه',
                  hintText: 'xxxx xxxx xxxx xxxx',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextFormField(
                controller: _expiryDateController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'تاريخ الإنتهاء',
                    hintText: 'MM/YY'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextField(
                focusNode: cvvFocusNode,
                controller: _cvvCodeController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: ' CVV رمز',
                  hintText: 'XXXX',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onChanged: (String text) {
                  setState(() {
                    cvvCode = text;
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextFormField(
                controller: _cardHolderNameController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'أسم حامل البطاقه',
                ),
                keyboardType: TextInputType.visiblePassword,
                textInputAction: TextInputAction.next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
