import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/addressModel.dart';
import 'package:shop_app/screens/mainScreen/address.dart';
import 'package:shop_app/screens/mainScreen/payment.dart';
import 'package:uuid/uuid.dart';

import '../langauge.dart';
import '../widgets.dart';

TextEditingController city = TextEditingController();
TextEditingController ditrict = TextEditingController();
TextEditingController street = TextEditingController();
TextEditingController house = TextEditingController();
TextEditingController name = TextEditingController();
TextEditingController phone = TextEditingController();

List<AddressModel> addressList = new List();
LatLng customerLocation;
bool preAddress = false;

Widget storedAddress(
    BuildContext context,
    String totalAfterTax,
    String price,
    String buyPrice,
    Function onThemeChanged,
    Function changeLangauge,
    Function fetchAddress) {
  return Visibility(
    visible: preAddress,
    child: Container(
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          Text(
            isEnglish ? english[19] : arabic[19],
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                String address = addressList[index].address;

                if (address == "") {
                  address = "العنوان من الخريطة";
                }
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Payment(
                              totalAfterTax: totalAfterTax,
                              price: price,
                              buyPrice: buyPrice,
                              onThemeChanged: onThemeChanged,
                              changeLangauge: changeLangauge,
                              name: addressList[index].name,
                              phone: addressList[index].phone,
                              address: addressList[index].address,
                              lat: addressList[index].lat,
                              long: addressList[index].long,
                            ),
                          ),
                        );
                      },
                      title: Text(addressList[index].name),
                      trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            DBHelper.deleteAddress(
                                "address", addressList[index].id);
                            fetchAddress();
                          }),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${addressList[index].phone}"),
                          Text("$address")
                        ],
                      ),
                    ),
                  ),
                );
              },
              separatorBuilder: (context, index) => Divider(),
              itemCount: addressList.length,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget addAddress(BuildContext context, Function moveToMapScreen) {
  return Visibility(
    visible: !preAddress,
    child: Container(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Text(
            isEnglish ? english[22] : arabic[22],
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2,
                child: MyTextFormField(
                  editingController: name,
                  hintText: isEnglish ? english[23] : arabic[23],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                child: MyTextFormField(
                  editingController: phone,
                  hintText: isEnglish ? english[24] : arabic[24],
                  isNumber: true,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 30,
          ),
          Divider(
            thickness: 3,
            color: Colors.black,
          ),
          Text(
            isEnglish ? english[25] : arabic[25],
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          Container(
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                InkWell(
                  onTap: moveToMapScreen,
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Text(
                      isEnglish ? english[27] : arabic[27],
                      textDirection: TextDirection.rtl,
                      style: TextStyle(fontSize: 22, color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  child: customerLocation == null
                      ? Container()
                      : Center(
                          child: Text(
                            "تم تحديد موقع التوصيل بنجاح",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

TextEditingController codeOneController = TextEditingController();
TextEditingController codeTwoController = TextEditingController();
TextEditingController codeThreeController = TextEditingController();
TextEditingController codeFourController = TextEditingController();
Widget buttonsBoth(
    BuildContext context,
    String totalAfterTax,
    String price,
    String buyPrice,
    Function onThemeChanged,
    Function changeLangauge,
    Function fetchAddress,
    Function toggelToAddAddress,
    twilioFlutter) {
  return preAddress
      ? InkWell(
          onTap: toggelToAddAddress,
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width / 2,
            color: Colors.blue,
            child: Center(
              child: Text(
                isEnglish ? english[20] : arabic[20],
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        )
      : InkWell(
          onTap: () {
            if (name.text.length < 5) {
              isEnglish ? errorToast(english[33]) : errorToast(arabic[33]);
            } else if (phone.text.length < 10) {
              isEnglish ? errorToast(english[34]) : errorToast(arabic[34]);
            } else {
              if (customerLocation != null) {
                codeOneController.clear();
                codeTwoController.clear();
                codeThreeController.clear();
                codeFourController.clear();
                Uuid uid = Uuid();
                String codeID = uid.v1();
                List<String> list = codeID.split('');

                int four = 0;
                codeID = '';
                for (var i = 0; i < list.length; i++) {
                  if (list[i].startsWith(RegExp(r'[0-9]'))) {
                    if (four < 4) {
                      codeID += list[i];
                      four++;
                    }
                  }
                }
                String phoneSMS;
                if (phone.text.substring(0, 2) == "05") {
                  phoneSMS = phone.text.substring(1);

                  phoneSMS = "+966$phoneSMS";
                } else {
                  phoneSMS = "+1$phoneSMS";
                }
                print("--------------->>>$codeID");
                // twilioFlutter.sendSMS(
                //     toNumber: "phoneSMS",
                //     messageBody: 'رفوف\nالكود هو: $codeID');
                showDialog(
                  context: context,
                  builder: (BuildContext context) => StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Container(
                          height: 350.0,
                          width: 300.0,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "أدخل الكود المرسل الى رقم جوالك",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                              O2Screen(
                                codeOneController: codeOneController,
                                codeTwoController: codeTwoController,
                                codeThreeController: codeThreeController,
                                codeFourController: codeFourController,
                              ),
                              FlatButton(
                                onPressed: () async {
                                  String codeInput =
                                      "${codeOneController.text}${codeTwoController.text}${codeThreeController.text}${codeFourController.text}";
                                  if (codeInput == codeID) {
                                    DBHelper.insertAddress('address', {
                                      'name': name.text,
                                      'phone': phone.text,
                                      'userAddress': '',
                                      'lat':
                                          customerLocation.latitude.toString(),
                                      'long':
                                          customerLocation.longitude.toString(),
                                    }).then((value) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => Payment(
                                            totalAfterTax: totalAfterTax,
                                            price: price,
                                            buyPrice: buyPrice,
                                            onThemeChanged: onThemeChanged,
                                            changeLangauge: changeLangauge,
                                            name: name.text,
                                            phone: phone.text,
                                            lat: customerLocation.latitude
                                                .toString(),
                                            long: customerLocation.longitude
                                                .toString(),
                                          ),
                                        ),
                                      );
                                    });

                                    Navigator.pop(context);
                                  } else {
                                    errorToast("رمز التحقق خطأ");
                                  }
                                },
                                child: Text(
                                  'تأكيد',
                                  style: TextStyle(
                                      color: Colors.purple, fontSize: 18.0),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                isEnglish ? errorToast(english[35]) : errorToast(arabic[35]);
              }
            }
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width / 2,
            color: Colors.blue,
            child: Center(
              child: Text(
                isEnglish ? english[21] : arabic[21],
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
}


Widget noDeliver(
  BuildContext context,
  String totalAfterTax,
  String price,
  String buyPrice,
  Function onThemeChanged,
  Function changeLangauge,
) {
  return Column(
    children: [
      Container(
        child: Center(
          child: Text(
            "موقعنا الرياض المملكة العربية السعودية",
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      Container(
        child: Center(
          child: Text(
            "في حال إتمام الشراء سوف يظهر لديكم الموقع في الخريطة",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
      Row(
        children: [
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: MyTextFormField(
              editingController: name,
              hintText: isEnglish ? english[23] : arabic[23],
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: MyTextFormField(
              editingController: phone,
              hintText: isEnglish ? english[24] : arabic[24],
              isNumber: true,
            ),
          ),
        ],
      ),
      SizedBox(
        height: 30,
      ),
      InkWell(
        onTap: () {
          if (name.text.length < 3 || phone.text.length < 10) {
            errorToast("أكتب بياناتك بالشكل الصحيح");
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Payment(
                  totalAfterTax: totalAfterTax,
                  price: price,
                  buyPrice: buyPrice,
                  onThemeChanged: onThemeChanged,
                  changeLangauge: changeLangauge,
                  name: name.text,
                  phone: phone.text,
                  address: '',
                  lat: '',
                  long: '',
                ),
              ),
            );
          }
        },
        child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width / 2,
          color: Colors.blue,
          child: Center(
            child: Text(
              isEnglish ? english[21] : arabic[21],
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 20,
      ),
      InkWell(
        onTap: () => Navigator.pop(context),
        child: Text(
          "العودة إلى السلة",
          style: TextStyle(decoration: TextDecoration.underline),
        ),
      )
    ],
  );
}

class O2Screen extends StatefulWidget {
  final TextEditingController codeOneController;
  final TextEditingController codeTwoController;
  final TextEditingController codeThreeController;
  final TextEditingController codeFourController;

  const O2Screen(
      {Key key,
      this.codeOneController,
      this.codeTwoController,
      this.codeThreeController,
      this.codeFourController})
      : super(key: key);
  @override
  _O2ScreenState createState() => _O2ScreenState();
}

class _O2ScreenState extends State<O2Screen> {
  FocusNode firstFocus = FocusNode();
  FocusNode secondFocus = FocusNode();
  FocusNode thirdFocus = FocusNode();
  FocusNode fourthFocus = FocusNode();
  var outLineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
  );
  int pinIndex = 0;
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PinNumber(
            outLineInputBorder: outLineInputBorder,
            textEditingController: widget.codeOneController,
            enabled: true,
            firstFocus: firstFocus,
            secondFocus: secondFocus,
          ),
          PinNumber(
            outLineInputBorder: outLineInputBorder,
            textEditingController: widget.codeTwoController,
            enabled: true,
            firstFocus: secondFocus,
            secondFocus: thirdFocus,
          ),
          PinNumber(
            outLineInputBorder: outLineInputBorder,
            textEditingController: widget.codeThreeController,
            enabled: true,
            firstFocus: thirdFocus,
            secondFocus: fourthFocus,
          ),
          PinNumber(
            outLineInputBorder: outLineInputBorder,
            textEditingController: widget.codeFourController,
            enabled: true,
            firstFocus: fourthFocus,
          )
        ],
      ),
    );
  }
}

class PinNumber extends StatelessWidget {
  final OutlineInputBorder outLineInputBorder;
  final TextEditingController textEditingController;
  final FocusNode firstFocus;
  final FocusNode secondFocus;
  final bool enabled;
  const PinNumber(
      {Key key,
      this.outLineInputBorder,
      this.textEditingController,
      this.enabled,
      this.firstFocus,
      this.secondFocus})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      child: TextField(
        focusNode: firstFocus,
        controller: textEditingController,
        enabled: enabled,
        autofocus: true,
        maxLength: 1,
        onChanged: (v) {
          if (textEditingController.text.length > 0) {
            firstFocus.unfocus();
            FocusScope.of(context).requestFocus(secondFocus);
          }
        },
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.all(16.0),
          border: outLineInputBorder,
          filled: true,
          fillColor: Colors.grey,
        ),
        cursorColor: Colors.white,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: 21, color: Colors.white),
      ),
    );
  }
}
