import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/addressModel.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:twilio_flutter/twilio_flutter.dart' as tw;

import '../homePage.dart';
import 'gmap.dart';
import 'shipping.dart';

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
              firstName: item['Firstname'],
              lastName: item['LastName'],
              phone: item['phone'],
              email: item['email'],
              address: item['userAddress'],
              id: item['id'],
              lat: item['lat'],
              long: item['long'],
              deliverCost: item['deliverCost'],
            ),
          )
          .toList();
    });
    for (var i = 0; i < addressList.length; i++) {
      final coordinates = new Coordinates(
          double.parse(addressList[i].lat), double.parse(addressList[i].long));
      var addresses =
          await Geocoder.local.findAddressesFromCoordinates(coordinates);
      var first = addresses.first;
      addressLine = first.addressLine;
    }
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
    listenSMS();
  }

  @override
  void dispose() {
    SmsAutoFill().unregisterListener();
    super.dispose();
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
    try {
      setState(() => customerLocation = location);
      calcualteDeliverCost();
    } catch (e) {}
  }

  moveToMapScreen(BuildContext context) async {
    try {
      final location = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Gmap()),
      );
      updateLocation(location);
    } catch (e) {}
  }

  void listenSMS() async {
    await SmsAutoFill().listenForCode;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          title: new Text(word("address_appBar", context)),
        ),
        body: Column(
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
              spiltName,
            ),
            SizedBox(
              height: 20,
            )
          ],
        ));
  }

  calcualteDeliverCost() async {
    total = 0.0;
    final coordinates =
        new Coordinates(customerLocation.latitude, customerLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    String city = first.locality;
    setState(() {});
    if (city == "Riyadh") {
      cost = 40;
      deliverCost = "40 ${word("currancy", context)}";
    } else {
      cost = 70;
      deliverCost = "70 ${word("currancy", context)}";
    }
    total = double.parse(widget.totalAfterTax) + cost;
    print(total);
  }

  toggelToAddAddress() {
    setState(
      () {
        preAddress = !preAddress;
      },
    );
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
        toNumber: phoneSMS,
        messageBody: ' متجر رفوف \n الكود هو $codeID \n $signCode');
  }

  spiltName() {
    if (name.text.length == 0) {
      errorToast(word("full_name_error", context));
    } else {
      setState(() {
        firstName = '';
        lastName = '';
        var n = 0;
        bool isFrist = true;
        if (name.text[0] == " ") {
          n = 1;
        }
        if (name.text[1] == " ") {
          n = 2;
        }
        for (var i = n; i < name.text.length; i++) {
          if (name.text[i] == " ") {
            isFrist = false;
          } else {
            if (isFrist) {
              firstName += name.text[i];
            } else {
              lastName += name.text[i];
            }
          }
        }
      });
    }
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
