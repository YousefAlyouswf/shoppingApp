import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/addressModel.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class Address extends StatefulWidget {
  final String amount;
  final Function onThemeChanged;
  const Address({Key key, this.amount, this.onThemeChanged}) : super(key: key);

  @override
  _AddressState createState() => _AddressState();
}

class _AddressState extends State<Address> {
  TextEditingController nationalAddress = TextEditingController();
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
              item['name'],
              item['phone'],
              item['userAddress'],
              id: item['id'],
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

  bool preAddress = false;
  @override
  void initState() {
    super.initState();
    fetchAddress();
  }

  _launchURL() async {
    const url = 'https://maps.address.gov.sa/Home/Index?lang=en';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("معلومات الشحن"),
      ),
      drawer: drawer(context, widget.onThemeChanged),
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
                            "أختر عنوانك",
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
                                      onTap: () {},
                                      onLongPress: () {
                                        DBHelper.deleteAddress(
                                            "address", addressList[index].id);
                                        fetchAddress();
                                      },
                                      title: Text(addressList[index].name),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("${addressList[index].phone}"),
                                          Text("${addressList[index].address}")
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
                            "البيانات الشخصية",
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
                                  hintText: "الأسم كامل",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormField(
                                  editingController: phone,
                                  hintText: "رقم الجوال",
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
                            "العنوان",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width * .7,
                                child: MyTextFormField(
                                  editingController: nationalAddress,
                                  hintText: "أدخل عنوانك الوطني هنا",
                                ),
                              ),
                              InkWell(
                                onTap: _launchURL,
                                child: Container(
                                  padding: EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                      color: Colors.blueGrey,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                  child: Text(
                                    "إبحث",
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
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Container(
                                height: 1,
                                color: Colors.grey,
                                width: MediaQuery.of(context).size.width / 3,
                              ),
                              Text(
                                "أو",
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
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormField(
                                  editingController: city,
                                  hintText: "المدينة",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormField(
                                  editingController: ditrict,
                                  hintText: "الحي",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormField(
                                  editingController: street,
                                  hintText: "أسم الشارع",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormField(
                                  editingController: house,
                                  hintText: "رقم المنزل",
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
                        "عنوان جديد",
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
                      errorToast("أكتب الأسم كامل");
                    } else if (phone.text.length < 10) {
                      errorToast("رقم الجوال 10 أرقام");
                    } else {
                      if (nationalAddress.text.length > 10 ||
                          (city.text.isNotEmpty &&
                              ditrict.text.isNotEmpty &&
                              street.text.isNotEmpty &&
                              house.text.isNotEmpty)) {
                        if (nationalAddress.text.isEmpty) {
                          String address =
                              "المدينة ${city.text}- الحي ${ditrict.text}- الشارع ${street.text}- رقم المنزل ${house.text}";

                          DBHelper.insertAddress('address', {
                            'name': name.text,
                            'phone': phone.text,
                            'userAddress': address,
                          });
                        } else {
                          DBHelper.insertAddress('address', {
                            'name': name.text,
                            'phone': phone.text,
                            'userAddress': nationalAddress.text,
                          });
                        }
                      } else {
                        errorToast("أكتب العنوان بالشكل الصحيح");
                      }
                    }
                  },
                  child: Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width / 2,
                    color: Colors.blue,
                    child: Center(
                      child: Text(
                        "متابعه",
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
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiLine ? TextInputType.multiline : TextInputType.text,
      ),
    );
  }
}
