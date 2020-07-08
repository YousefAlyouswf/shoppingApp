import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/manager/manager/addItem.dart';
import 'package:shop_app/models/addressModel.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/screens/mainScreen/payment.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:uuid/uuid.dart';

TextEditingController name = TextEditingController();
TextEditingController phone = TextEditingController();
TextEditingController email = TextEditingController();
String firstName;
String lastName;

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
            word("choose_address", context),
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 22,
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
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
                              firstName: firstName,
                              lastName: lastName,
                              email: email.text,
                              phone: addressList[index].phone,
                              address: addressList[index].address,
                              lat: addressList[index].lat,
                              long: addressList[index].long,
                            ),
                          ),
                        );
                      },
                      title: Text(
                          "${addressList[index].firstName} ${addressList[index].lastName}"),
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
                          Text("${addressList[index].email}"),
                          Text(word("address_msg_from_map", context)),
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
            word("personal_info_address", context),
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
                  hintText: word("full_name", context),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2,
                child: MyTextFormField(
                  editingController: phone,
                  hintText: word("phone_number", context),
                  isNumber: true,
                ),
              ),
            ],
          ),
          Container(
            width: MediaQuery.of(context).size.width / 1.5,
            child: MyTextFormField(
              editingController: email,
              isEmail: true,
              hintText: word("email", context),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Divider(
            thickness: 3,
            color: Colors.black,
          ),
          Text(
            word("address_info", context),
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
                  splashColor: Colors.transparent,
                  onTap: () {
                    moveToMapScreen(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Text(
                      word("open_map", context),
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
                            word("confirm_address", context),
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

String signCode;
String codeID;
String codeInput;
Widget buttonsBoth(
  BuildContext context,
  String totalAfterTax,
  String price,
  String buyPrice,
  Function onThemeChanged,
  Function changeLangauge,
  Function fetchAddress,
  Function toggelToAddAddress,
  Function formatPhoneNumber,
  Function spiltName,
) {
  return preAddress
      ? InkWell(
          onTap: toggelToAddAddress,
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width / 2,
            color: Theme.of(context).unselectedWidgetColor,
            child: Center(
              child: Text(
                word("new_address_botton", context),
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
          onTap: () async {
            spiltName();
            bool emailValid = RegExp(
                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                .hasMatch(email.text);
            if (firstName == "" || lastName == "") {
              errorToast(word("full_name_error", context));
            } else if (phone.text.length < 10) {
              errorToast(word("phone_error", context));
            } else if (!emailValid) {
              errorToast(word("email_error", context));
            } else {
              if (customerLocation != null) {
                Uuid uid = Uuid();
                codeID = uid.v1();
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
                signCode = await SmsAutoFill().getAppSignature;
                formatPhoneNumber();
                print("--------------->>>$codeID");

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
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Center(
                                  child: Text(
                                    word("toast_type_code", context),
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 50),
                                child: PinFieldAutoFill(
                                  decoration: UnderlineDecoration(
                                    textStyle: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                  ),
                                  onCodeChanged: (v) {
                                    codeInput = v;
                                  },
                                  codeLength: 4,
                                ),
                              ),
                              FlatButton(
                                onPressed: () async {
                                  if (codeInput == codeID) {
                                    DBHelper.insertAddress('address', {
                                      'Firstname': firstName,
                                      'LastName': lastName,
                                      'phone': phone.text,
                                      'email': email.text,
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
                                            firstName: firstName,
                                            lastName: lastName,
                                            email: email.text,
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
                                    errorToast(word("code_error", context));
                                  }
                                },
                                child: Text(
                                  word("sure", context),
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .unselectedWidgetColor,
                                      fontSize: 18.0),
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
                errorToast(word("choose_address_error", context));
              }
            }
          },
          child: Container(
            height: 50,
            width: MediaQuery.of(context).size.width / 2,
            color: Colors.blue,
            child: Center(
              child: Text(
                word("confirm_number", context),
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
              hintText: word('full_name', context),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2,
            child: MyTextFormField(
              editingController: phone,
              hintText: word("phone_number", context),
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
                  firstName: firstName,
                  lastName: lastName,
                  email: email.text,
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
              word("continue", context),
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
