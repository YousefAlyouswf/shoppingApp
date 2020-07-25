import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
String addressLine = "";
String deliverCost = "";
Widget storedAddress(
  BuildContext context,
  String totalAfterTax,
  String price,
  String buyPrice,
  Function onThemeChanged,
  Function changeLangauge,
  Function fetchAddress,
  String discount,
  String costInRiyadh,
  String costOutRiyadh,
) {
  return Visibility(
    visible: preAddress,
    child: Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.grey[200],
      child: Column(
        children: [
          Text(
            word("choose_address", context),
            style: TextStyle(fontSize: 22, fontFamily: "MainFont"),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                String shippingCost;
                if (addressList[index].city == "RIYADH,الرياض") {
                  shippingCost = costInRiyadh;
                } else {
                  shippingCost = costOutRiyadh;
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
                              firstName: addressList[index].firstName,
                              lastName: addressList[index].lastName,
                              email: addressList[index].email,
                              phone: addressList[index].phone,
                              address: addressList[index].address,
                              lat: addressList[index].lat,
                              long: addressList[index].long,
                              delvierCost: shippingCost,
                              discount: discount == "" ? 0 : discount,
                              city: addressList[index].city,
                              postCose: addressList[index].postCode,
                            ),
                          ),
                        );
                      },
                      title: Text(
                          "${addressList[index].address} - ${addressList[index].city}"),
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
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                              "${word("deliverCost", context)} : $shippingCost ${word("currancy", context)}")
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

double total = 0;

int cost = 0;
Widget addAddress(
  BuildContext context,
  Function moveToMapScreen,
  String addressLineFromSa,
  String postalCoseSa,
  String cityFromSa,
  String mobileNumber,
) {
  return Visibility(
    visible: !preAddress,
    child: Container(
      width: double.infinity,
      child: Column(
        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.solidAddressCard),
                SizedBox(
                  width: 20,
                ),
                Text(
                  word("personal_info_address", context),
                  style: TextStyle(fontSize: 22, fontFamily: "MainFont"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: MyTextFormField(
                      editingController: name,
                      hintText: "أسمك و أسم العائلة",
                      labelText: word("full_name", context),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: MyTextFormField(
                      editingController: phone,
                      hintText: "05xxxxxxxx",
                      labelText: word("phone_number", context),
                      isNumber: true,
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 1.1,
                    child: MyTextFormField(
                      editingController: email,
                      isEmail: true,
                      hintText: "xxx@xxx.com",
                      labelText: word("email", context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FaIcon(FontAwesomeIcons.locationArrow),
                SizedBox(
                  width: 20,
                ),
                Text(
                  word("address_info", context),
                  style: TextStyle(fontSize: 22, fontFamily: "MainFont"),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                border: Border.all(),
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
              width: double.infinity,
              child: Column(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      moveToMapScreen(context);
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.2,
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: FlareActor(
                        'assets/maps.flr',
                        alignment: Alignment.center,
                        fit: BoxFit.fitWidth,
                        animation: "anim",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  addressLineFromSa == "" ||
                          customerLocation == null ||
                          cityFromSa == "" ||
                          postalCoseSa == ""
                      ? Container()
                      : Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Container(
                                padding: EdgeInsets.all(8.0),
                                decoration: BoxDecoration(border: Border.all()),
                                child: Text(
                                  "${word("address_info", context)}: $addressLineFromSa\n${word('city', context)}: $cityFromSa \n${word('post', context)}: $postalCoseSa",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "${word("deliverCost", context)}: $deliverCost",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.all(16.0),
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: Text(
                                "${word("total", context)}: $total ${word("currancy", context)}",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
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
  String discount,
  String addressLineFromSa,
  String cityFromSa,
  String postCodeFromSa,
) {
  return preAddress
      ? InkWell(
          onTap: toggelToAddAddress,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0),
            height: 50,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).unselectedWidgetColor,
              borderRadius: BorderRadius.all(
                Radius.circular(10),
              ),
            ),
            child: Center(
              child: Text(
                word("new_address_botton", context),
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: "MainFont",
                ),
              ),
            ),
          ),
        )
      : InkWell(
          onTap: () async {
            await spiltName();
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
              if (true) {
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
                //signCode = await SmsAutoFill().getAppSignature;
                // formatPhoneNumber();
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
                                      'deliverCost': cost.toString(),
                                      'address': addressLineFromSa,
                                      'city': cityFromSa,
                                      'postCode': postCodeFromSa,
                                    }).then((v) {
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
                                            delvierCost: cost.toString(),
                                            discount:
                                                discount == "" ? 0 : discount,
                                            address: addressLineFromSa,
                                            city: cityFromSa,
                                            postCose: postCodeFromSa,
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
            width: MediaQuery.of(context).size.width / 1.1,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Theme.of(context).unselectedWidgetColor,
            ),
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
