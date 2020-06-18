import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/addressModel.dart';
import 'package:shop_app/screens/gmap.dart';
import 'package:shop_app/screens/payment.dart';
import 'package:shop_app/widgets/widgets.dart';

class Address extends StatefulWidget {
  final String amount;
  final Function onThemeChanged;
  final Function changeLangauge;
  final String buyPrice;
  final String price;
  const Address({
    Key key,
    this.amount,
    this.onThemeChanged,
    this.changeLangauge,
    this.buyPrice,
    this.price,
  }) : super(key: key);

  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  TextEditingController city = TextEditingController();
  TextEditingController ditrict = TextEditingController();
  TextEditingController street = TextEditingController();
  TextEditingController house = TextEditingController();
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();

  List<AddressModel> addressList = new List();
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

  LatLng customerLocation;
  bool preAddress = false;
  @override
  void initState() {
    super.initState();
    fetchAddress();
  }

  void updateLocation(LatLng location) {
    setState(() => customerLocation = location);
  }

  moveToMapScreen() async {
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
      drawer: drawer(context, widget.onThemeChanged,
          changeLangauge: widget.changeLangauge),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  Visibility(
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
                                              price: widget.price,
                                              buyPrice: widget.buyPrice,
                                              onThemeChanged:
                                                  widget.onThemeChanged,
                                              changeLangauge:
                                                  widget.changeLangauge,
                                              name: addressList[index].name,
                                              phone: addressList[index].phone,
                                              address:
                                                  addressList[index].address,
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
                                            DBHelper.deleteAddress("address",
                                                addressList[index].id);
                                            fetchAddress();
                                          }),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
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
                  ),
                  Visibility(
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
                                  hintText:
                                      isEnglish ? english[23] : arabic[23],
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormField(
                                  editingController: phone,
                                  hintText:
                                      isEnglish ? english[24] : arabic[24],
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
                                        child:
                                            Text("تم تحديد موقع التوصيل بنجاح"),
                                      ),
                              ),
                              InkWell(
                                onTap: moveToMapScreen,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Text(
                                    isEnglish ? english[27] : arabic[27],
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.white),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Container(
                                      height: 1,
                                      color: Colors.grey,
                                      width:
                                          MediaQuery.of(context).size.width / 3,
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
                                      width:
                                          MediaQuery.of(context).size.width / 3,
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
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: MyTextFormField(
                                        editingController: city,
                                        hintText: isEnglish
                                            ? english[29]
                                            : arabic[29],
                                      ),
                                    ),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: MyTextFormField(
                                        editingController: ditrict,
                                        hintText: isEnglish
                                            ? english[30]
                                            : arabic[30],
                                      ),
                                    ),
                                  ],
                                ),
                          customerLocation != null
                              ? Container()
                              : Row(
                                  children: [
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: MyTextFormField(
                                        editingController: street,
                                        hintText: isEnglish
                                            ? english[31]
                                            : arabic[31],
                                      ),
                                    ),
                                    Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: MyTextFormField(
                                        editingController: house,
                                        hintText: isEnglish
                                            ? english[32]
                                            : arabic[32],
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
          ),
          preAddress
              ? InkWell(
                  onTap: () {
                    setState(
                      () {
                        preAddress = !preAddress;
                      },
                    );
                  },
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
                      isEnglish
                          ? errorToast(english[33])
                          : errorToast(arabic[33]);
                    } else if (phone.text.length < 10) {
                      isEnglish
                          ? errorToast(english[34])
                          : errorToast(arabic[34]);
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
                                price: widget.price,
                                buyPrice: widget.buyPrice,
                                onThemeChanged: widget.onThemeChanged,
                                changeLangauge: widget.changeLangauge,
                                name: name.text,
                                phone: phone.text,
                                address: address,
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
                          print(customerLocation.latitude.toString());
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Payment(
                              price: widget.price,
                              buyPrice: widget.buyPrice,
                              onThemeChanged: widget.onThemeChanged,
                              changeLangauge: widget.changeLangauge,
                              name: name.text,
                              phone: phone.text,
                              lat: customerLocation.latitude.toString(),
                              long: customerLocation.longitude.toString(),
                            ),
                          ),
                        );
                      } else {
                        isEnglish
                            ? errorToast(english[35])
                            : errorToast(arabic[35]);
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
                ),
          SizedBox(
            height: 20,
          )
        ],
      ),
    );
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
