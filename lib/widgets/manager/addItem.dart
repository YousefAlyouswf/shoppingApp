import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';

import '../widgets.dart';

var selectedCurrency;
bool showItemFileds = false;
bool showBtnPost = false;
bool newCategory = false;
TextEditingController itemName = TextEditingController();
TextEditingController itemPrice = TextEditingController();
TextEditingController itemDis = TextEditingController();
TextEditingController categoryName = TextEditingController();
TextEditingController itemBuyPrice = TextEditingController();

Widget addItem(
  BuildContext context,
  Function showItemTextFileds,
  Function _takePictureForCatgory,
  Function _takeFromGalaryForCatgory,
  Function _takePictureForItems,
  Function _takeFromGalaryForItems,
  Function switchToCategoryPage,
) {
  final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
  return Container(
    child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          DropDownMen(showItemTextFileds: showItemTextFileds),
          Visibility(
            visible: newCategory,
            child: Column(
              children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        width: halfMediaWidth,
                        child: MyTextFormField(
                          editingController: categoryName,
                          hintText: 'أسم القسم',
                        ),
                      ),
                      imageStoredCategory != null
                          ? InkWell(
                              onTap: () {
                                getImageForCatgory(_takePictureForCatgory,
                                    _takeFromGalaryForCatgory, context);
                              },
                              child: Container(
                                width: 70,
                                height: 70,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.rectangle,
                                  image: new DecorationImage(
                                    fit: BoxFit.fill,
                                    image: new FileImage(imageStoredCategory),
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  getImageForCatgory(_takePictureForCatgory,
                                      _takeFromGalaryForCatgory, context);
                                },
                                child: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: new BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new AssetImage(
                                          "assets/images/addImage.png"),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
                Divider(
                  thickness: 5,
                )
              ],
            ),
          ),
          Visibility(
            visible: showItemFileds,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        width: halfMediaWidth,
                        child: MyTextFormField(
                          editingController: itemName,
                          hintText: 'أسم المنتج',
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        width: halfMediaWidth,
                        child: MyTextFormField(
                          editingController: itemPrice,
                          hintText: 'سعر البيع',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: MyTextFormField(
                        editingController: itemDis,
                        isMultiLine: true,
                        hintText: 'الوصف',
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: MyTextFormField(
                        editingController: itemBuyPrice,
                        hintText: 'سعر الشراء',
                        isNumber: true,
                      ),
                    ),
                  ],
                ),
                imageStoredItems != null
                    ? InkWell(
                        onTap: () {
                          getImageForCatgory(_takePictureForItems,
                              _takeFromGalaryForItems, context);
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: new BoxDecoration(
                            shape: BoxShape.rectangle,
                            image: new DecorationImage(
                              fit: BoxFit.fill,
                              image: new FileImage(imageStoredItems),
                            ),
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: InkWell(
                          onTap: () {
                            getImageForCatgory(_takePictureForItems,
                                _takeFromGalaryForItems, context);
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: new BoxDecoration(
                              shape: BoxShape.rectangle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image: new AssetImage(
                                    "assets/images/addImage.png"),
                              ),
                            ),
                          ),
                        ),
                      ),
                SizedBox(
                  height: 70,
                ),
                RaisedButton(
                  color: Colors.blueAccent,
                  onPressed: () {
                    if (itemName.text.isEmpty ||
                        itemPrice.text.isEmpty ||
                        itemDis.text.isEmpty ||
                        imageStoredItems == null ||
                        urlImageItems == null) {
                      if (itemName.text.isEmpty) {
                        errorToast("Enter Item Name");
                      } else if (itemPrice.text.isEmpty) {
                        errorToast("Enter Item Price");
                      } else if (itemDis.text.isEmpty) {
                        errorToast("Enter Item Desciption");
                      } else {
                        errorToast("Add Item Image");
                      }
                    } else {
                      String uui = uuid.v1();
                      Map<String, dynamic> itemMap = {
                        "name": itemName.text,
                        "description": itemDis.text,
                        "price": itemPrice.text,
                        "image": urlImageItems,
                        "show": false,
                        "imageID": uui,
                        'buyPrice': itemBuyPrice.text,
                      };
                      Map<String, dynamic> itemMapForNew = {
                        "category": categoryName.text,
                        "items": FieldValue.arrayUnion([itemMap])
                      };
                      Map<String, dynamic> catgoryMap = {
                        "name": categoryName.text,
                        "image": urlImageCategory,
                      };
                      if (selectedCurrency == "New Category") {
                        if (categoryName.text.isEmpty ||
                            imageStoredCategory == null ||
                            imageStoredItems == null ||
                            urlImageCategory == null ||
                            urlImageItems == null) {
                          if (categoryName.text.isEmpty) {
                            errorToast("Enter Category name");
                          } else if (imageStoredCategory == null ||
                              urlImageCategory == null) {
                            errorToast("Add Category Image");
                          } else {
                            errorToast("Add Item Image");
                          }
                        } else {
                          FirestoreFunctions().addNewItemToNewCategory(
                              catgoryMap, itemMapForNew, uui, urlImageItems);
                          showItemTextFileds();
                          switchToCategoryPage();
                        }
                      } else {
                        FirestoreFunctions().addNewItemRoExistCategory(
                            itemMap, selectedCurrency, uui, urlImageItems);
                        showItemTextFileds();
                        switchToCategoryPage();
                      }
                    }
                  },
                  child: Text(
                    'إظافة',
                    style: TextStyle(
                      color: Colors.white,
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
          hintText: hintText,
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        obscureText: isPassword ? true : false,
        maxLines: null,
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiLine ? TextInputType.multiline : TextInputType.text,
      ),
    );
  }
}

class DropDownMen extends StatefulWidget {
  final Function showItemTextFileds;

  const DropDownMen({Key key, this.showItemTextFileds}) : super(key: key);
  @override
  _DropDownMenState createState() => _DropDownMenState();
}

class _DropDownMenState extends State<DropDownMen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection("categories")
              .where("table", isEqualTo: "category")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Text("Loading.....");
            else {
              int listLength =
                  snapshot.data.documents[0].data['collection'].length;

              List<DropdownMenuItem> currencyItems = [];
              currencyItems.add(
                DropdownMenuItem(
                  child: Text(
                    "قسم جديد",
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.black),
                  ),
                  value: "New Category",
                ),
              );
              for (int i = 0; i < listLength; i++) {
                String snap =
                    snapshot.data.documents[0].data['collection'][i]['name'];
                currencyItems.add(
                  DropdownMenuItem(
                    child: Text(
                      snap,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    value: "$snap",
                  ),
                );
              }
              return Container(
                alignment: Alignment.center,
                width: double.infinity,
                child: DropdownButton(
                  items: currencyItems,
                  onChanged: (currencyValue) {
                    setState(() {
                      selectedCurrency = currencyValue;
                    });
                    widget.showItemTextFileds();
                  },
                  value: selectedCurrency,
                  elevation: 0,
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(Icons.menu),
                  ),
                  dropdownColor: Colors.grey[100],
                  isExpanded: false,
                  hint: new Text(
                    "أختر القسم",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              );
            }
          }),
    );
  }
}

File imageStoredCategory;
String urlImageCategory;
Future uploadImageForCatefory() async {
  String fileName = '${DateTime.now()}.png';

  StorageReference firebaseStorage =
      FirebaseStorage.instance.ref().child(fileName);

  StorageUploadTask uploadTask = firebaseStorage.putFile(imageStoredCategory);
  await uploadTask.onComplete;
  urlImageCategory = await firebaseStorage.getDownloadURL() as String;

  if (urlImageCategory.isNotEmpty) {}
}



File imageStoredItems;
String urlImageItems;
Future uploadImageItems() async {
  String fileName = '${DateTime.now()}.png';

  StorageReference firebaseStorage =
      FirebaseStorage.instance.ref().child(fileName);

  StorageUploadTask uploadTask = firebaseStorage.putFile(imageStoredItems);
  await uploadTask.onComplete;
  urlImageItems = await firebaseStorage.getDownloadURL() as String;

  if (urlImageItems.isNotEmpty) {}
}

getImageForCatgory(Function camera, Function gallery, BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Container(
        height: 150.0,
        width: 300.0,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlatButton.icon(
                  icon: Icon(Icons.camera),
                  onPressed: () {
                    camera();
                    Navigator.pop(context);
                  },
                  label: Text(
                    'Camera',
                    style: TextStyle(color: Colors.purple, fontSize: 18.0),
                  ),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.image),
                  onPressed: () {
                    gallery();
                    Navigator.pop(context);
                  },
                  label: Text(
                    'gallery',
                    style: TextStyle(color: Colors.purple, fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}