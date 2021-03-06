import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import 'package:http/http.dart';
import 'package:mobile_number/mobile_number.dart';
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
  final String discount;
  const Address({
    Key key,
    this.totalAfterTax,
    this.onThemeChanged,
    this.changeLangauge,
    this.buyPrice,
    this.price,
    this.discount,
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
              address: item['address'],
              id: item['id'],
              lat: item['lat'],
              long: item['long'],
              deliverCost: item['deliverCost'],
              city: item['city'],
              postCode: item['postCode'],
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
  String _mobileNumber = '';
  bool mobileChange = false;
  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    String mobileNumber = '';
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      mobileNumber = await MobileNumber.mobileNumber;
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _mobileNumber = mobileNumber;
    });
    List<String> numberList = _mobileNumber.split('');
    bool getNum = false;
    for (var i = 0; i < numberList.length; i++) {
      if (numberList[i] == '5' && !getNum) {
        setState(() {
          getNum = true;
          _mobileNumber = '0';
        });
      }
      if (getNum) {
        _mobileNumber += numberList[i];
      }
    }

    if (mobileNumber != '' && !mobileChange) {
      phone.text = mobileNumber;
      setState(() {
        mobileChange = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAddress();
    twilioInfo();
    listenSMS();
    getDeliverPrice();
    initMobileNumberState();
  }

  int costInRiyadh = 0;
  int costOutRiyadh = 0;
  getDeliverPrice() async {
    await Firestore.instance.collection('app').getDocuments().then(
          (value) => value.documents.forEach(
            (e) {
              setState(() {
                costInRiyadh = e['inRiyadh'];
                costOutRiyadh = e['outRiyadh'];
              });
            },
          ),
        );
    print("-------------->..$costOutRiyadh");
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

  Future<gmap.LatLng> updateLocation(gmap.LatLng location) {
    try {
      setState(() => customerLocation = location);

      FocusScope.of(context).requestFocus(FocusNode());

      return Future.value(customerLocation);
    } catch (e) {
      return null;
    }
  }

  moveToMapScreen(BuildContext context) async {
    try {
      final location = await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Gmap()),
      );
      updateLocation(location).then((v) async {
        await getNationalAddress(v.latitude.toString(), v.longitude.toString());
        calcualteDeliverCost();
      });
    } catch (e) {}
  }

  void listenSMS() async {
    await SmsAutoFill().listenForCode;
  }

  bool isLoading = false;
  getNationalAddress(String lat, String long) async {
    setState(() {
      isLoading = true;
      addressLineFromSa = "";
      postalCoseSa = "";
      cityFromSa = "";
    });
    final coordinates = new Coordinates(double.parse(lat), double.parse(long));
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    String url =
        "https://apina.address.gov.sa/NationalAddress/v3.1/Address/address-geocode?lat=$lat&long=$long&language=A&format=json&encode=utf8";
    String urlEN =
        "https://apina.address.gov.sa/NationalAddress/v3.1/Address/address-geocode?lat=$lat&long=$long&language=E&format=json&encode=utf8";

    Response response = await get(isEnglish ? urlEN : url,
        headers: {"api_key": "f2dae307076b4f79b4778f89807d4801"});
    setState(() {
      final jsonData = json.decode(response.body);

      if (jsonData['statusCode'] == 500) {
        var first = addresses.first;
        addressLineFromSa = first.addressLine;
        postalCoseSa = first.postalCode;
        cityFromSa = first.locality;
        if (postalCoseSa == null) {
          postalCoseSa = " ";
        }
        isLoading = false;
      } else {
        try {
          addressLineFromSa = jsonData['Addresses'][0]['Address1'];
          postalCoseSa = jsonData['Addresses'][0]['PostCode'];
          cityFromSa = jsonData['Addresses'][0]['City'];
          isLoading = false;
        } catch (e) {
          print("--------------------->>>>>$e");
          errorMapChosen(word("maperror", context));
          isLoading = false;
        }
      }
    });
  }

  String addressLineFromSa = "";
  String postalCoseSa = "";
  String cityFromSa = "";
  @override
  Widget build(BuildContext context) {
    var keyboard = MediaQuery.of(context).viewInsets.bottom;

    return new Scaffold(
        floatingActionButton: keyboard != 0.0
            ? FloatingActionButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                },
                child: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                ),
                backgroundColor: Colors.black,
              )
            : null,
        backgroundColor: Colors.white,
        appBar: new AppBar(
          backgroundColor: Colors.grey[200],
          elevation: 0,
          title: Text(
            word("address_appBar", context),
            style: TextStyle(fontFamily: "MainFont"),
          ),
        ),
        body: isLoading
            ? Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.5,
                  height: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        "https://mk0analyticsindf35n9.kinstacdn.com/wp-content/uploads/2019/04/d7ae0170d3d5ffcbaa7f02fdda387a3b.gif",
                      ),
                    ),
                  ),
                ),
              )
            : Container(
                color: Colors.grey[200],
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            storedAddress(
                              context,
                              widget.totalAfterTax,
                              widget.price,
                              widget.buyPrice,
                              widget.onThemeChanged,
                              widget.changeLangauge,
                              fetchAddress,
                              widget.discount,
                              costInRiyadh.toString(),
                              costOutRiyadh.toString(),
                            ),
                            addAddress(
                              context,
                              moveToMapScreen,
                              addressLineFromSa,
                              postalCoseSa,
                              cityFromSa,
                              _mobileNumber,
                            ),
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
                      widget.discount,
                      addressLineFromSa,
                      cityFromSa,
                      postalCoseSa,
                    ),
                    SizedBox(
                      height: 20,
                    )
                  ],
                ),
              ));
  }

  calcualteDeliverCost() async {
    total = double.parse(widget.totalAfterTax);
    cost = 0;
    final coordinates =
        new Coordinates(customerLocation.latitude, customerLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    String city = first.locality;
    print("//////////////////////////$city");
    if (city == "Riyadh" || city == "الرياض") {
      setState(() {
        cost = costInRiyadh;
        deliverCost = "$costInRiyadh ${word("currancy", context)}";
      });
    } else {
      setState(() {
        cost = costOutRiyadh;
        deliverCost = "$costOutRiyadh ${word("currancy", context)}";
      });
    }
    setState(() {
      total = double.parse(widget.totalAfterTax) + cost;
    });

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
        messageBody: ' ${word("codeMsg", context)} $codeID \n $signCode');
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
