import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/addressModel.dart';
import 'package:shop_app/screens/mainScreen/address.dart';
import 'package:shop_app/screens/mainScreen/payment.dart';

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                width: 100,
                height: 100,
                child: customerLocation == null
                    ? Container()
                    : Center(
                        child: Text("تم تحديد موقع التوصيل بنجاح"),
                      ),
              ),
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
            ],
          ),
          SizedBox(
            height: 30,
          ),
          customerLocation != null
              ? Container()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Container(
                      height: 1,
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width / 3,
                    ),
                    Text(
                      isEnglish ? english[28] : arabic[28],
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    Container(
                      height: 1,
                      color: Colors.grey,
                      width: MediaQuery.of(context).size.width / 3,
                    )
                  ],
                ),
          SizedBox(
            height: 30,
          ),
          customerLocation != null
              ? Container()
              : Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: MyTextFormField(
                        editingController: city,
                        hintText: isEnglish ? english[29] : arabic[29],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: MyTextFormField(
                        editingController: ditrict,
                        hintText: isEnglish ? english[30] : arabic[30],
                      ),
                    ),
                  ],
                ),
          customerLocation != null
              ? Container()
              : Row(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: MyTextFormField(
                        editingController: street,
                        hintText: isEnglish ? english[31] : arabic[31],
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width / 2,
                      child: MyTextFormField(
                        editingController: house,
                        hintText: isEnglish ? english[32] : arabic[32],
                      ),
                    ),
                  ],
                ),
        ],
      ),
    ),
  );
}

Widget buttonsBoth(
    BuildContext context,
    String totalAfterTax,
    String price,
    String buyPrice,
    Function onThemeChanged,
    Function changeLangauge,
    Function fetchAddress,
    Function toggelToAddAddress) {
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
              if (customerLocation != null ||
                  (city.text.isNotEmpty &&
                      ditrict.text.isNotEmpty &&
                      street.text.isNotEmpty &&
                      house.text.isNotEmpty)) {
                if (customerLocation == null) {
                  String address = isEnglish
                      ? "City ${city.text} - District ${ditrict.text} - Street ${street.text} - House# ${house.text}"
                      : "المدينة ${city.text} - الحي ${ditrict.text} - الشارع ${street.text} - رقم المنزل ${house.text}";

                  DBHelper.insertAddress('address', {
                    'name': name.text,
                    'phone': phone.text,
                    'userAddress': address,
                    'lat': '',
                    'long': '',
                  });
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
                        address: address,
                        lat: '',
                        long: '',
                      ),
                    ),
                  );
                } else {
                  DBHelper.insertAddress('address', {
                    'name': name.text,
                    'phone': phone.text,
                    'userAddress': '',
                    'lat': customerLocation.latitude.toString(),
                    'long': customerLocation.longitude.toString(),
                  });
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
                        lat: customerLocation.latitude.toString(),
                        long: customerLocation.longitude.toString(),
                      ),
                    ),
                  );
                }
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
