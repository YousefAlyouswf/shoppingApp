import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/addressModel.dart';
import 'package:shop_app/screens/gmap.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/langauge.dart';
import 'package:shop_app/widgets/user/shipping.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:twilio_flutter/twilio_flutter.dart' as tw;

class Address extends StatefulWidget {
  final String totalAfterTax;
  final Function onThemeChanged;
  final Function changeLangauge;
  final String buyPrice;
  final String price;
  final bool isDeliver;
  const Address({
    Key key,
    this.totalAfterTax,
    this.onThemeChanged,
    this.changeLangauge,
    this.buyPrice,
    this.price,
    this.isDeliver,
  }) : super(key: key);

  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  Future<void> fetchAddress() async {
    addressList = new List();
    final dataList = await DBHelper.getDataAddress('address');
    setState(() {
      addressList = dataList
          .map(
            (item) => AddressModel(
              name: item['name'],
              phone: item['phone'],
              address: item['userAddress'],
              id: item['id'],
              lat: item['lat'],
              long: item['long'],
            ),
          )
          .toList();
    });

    if (addressList.length > 0) {
      setState(() {
        preAddress = true;
      });
    }
  }

  String accountSid;
  String authToken;
  String twilioNumber;
  tw.TwilioFlutter twilioFlutter;
  @override
  void initState() {
    super.initState();
    fetchAddress();

    twilioInfo();
  }

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
    twilioFlutter = tw.TwilioFlutter(
      accountSid: accountSid,
      authToken: authToken,
      twilioNumber: '+12054966662',
    );
  }

  void updateLocation(gmap.LatLng location) {
    setState(() => customerLocation = location);
  }

  moveToMapScreen(BuildContext context) async {
    final location = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Gmap()),
    );
    updateLocation(location);
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(isEnglish ? english[18] : arabic[18]),
        ),
        body: widget.isDeliver
            ? Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 30,
                          ),
                          storedAddress(
                              context,
                              widget.totalAfterTax,
                              widget.price,
                              widget.buyPrice,
                              widget.onThemeChanged,
                              widget.changeLangauge,
                              fetchAddress),
                          addAddress(context, moveToMapScreen),
                        ],
                      ),
                    ),
                  ),
                  buttonsBoth(
                    context,
                    widget.totalAfterTax,
                    widget.price,
                    widget.buyPrice,
                    widget.onThemeChanged,
                    widget.changeLangauge,
                    fetchAddress,
                    toggelToAddAddress,
                    formatPhoneNumber,
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              )
            : noDeliver(
                context,
                widget.totalAfterTax,
                widget.price,
                widget.buyPrice,
                widget.onThemeChanged,
                widget.changeLangauge,
              ));
  }

  toggelToAddAddress() {
    setState(
      () {
        preAddress = !preAddress;
      },
    );
  }

  goToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
    navIndex = 0;
    setState(() {});
  }

  formatPhoneNumber() {
    String phoneSMS = '';
    setState(() {
      if (phone.text.substring(0, 2) == "05") {
        phoneSMS = phone.text.substring(1);

        phoneSMS = "+966$phoneSMS";
      } else {
        phoneSMS = "+1${phone.text}";
      }
    });

    print("Controller ----> ${phone.text}");
    print('PhoneSms ------>> $phoneSMS');
    twilioFlutter.sendSMS(
        toNumber: phoneSMS, messageBody: 'رفوف\nالكود هو: $codeID');
  }
}

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final bool isNumber;
  final Function isChanged;
  final bool isMultiLine;
  final TextEditingController editingController;
  MyTextFormField({
    this.hintText,
    this.isPassword = false,
    this.isNumber = false,
    this.editingController,
    this.isChanged,
    this.isMultiLine = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        onChanged: isChanged,
        controller: editingController,
        decoration: InputDecoration(
          suffixIcon: editingController.text.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    editingController.clear();
                  }),
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey),
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          // fillColor: Colors.grey,
        ),
        minLines: isMultiLine ? 5 : 1,
        maxLines: isMultiLine ? 100 : 1,
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiLine ? TextInputType.multiline : TextInputType.text,
      ),
    );
  }
}
