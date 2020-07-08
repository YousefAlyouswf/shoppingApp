import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/widgets/widgets.dart';

import 'categoryScreen/category.dart';

class AddItemManager extends StatefulWidget {
  @override
  _AddItemManagerState createState() => _AddItemManagerState();
}

class _AddItemManagerState extends State<AddItemManager> {
  @override
  Widget build(BuildContext context) {
    return addItem(
      context,
      showItemTextFileds,
      _takePictureForCatgory,
      _takeFromGalaryForCatgory,
      _takePictureForItems,
      _takeFromGalaryForItems,
      switchToCategoryPage,
      checkBoxFuncation,
      chooseWordSized,
      chooseNumSized,
      changeXS,
      changeS,
      changeM,
      changeL,
      changeXL,
      change35,
      change36,
      change37,
      change38,
      change39,
      change40,
      change41,
      change42,
    );
  }

  showItemTextFileds() {
    setState(() {
      if (selectedCurrency != null) {
        showItemFileds = true;

        if (selectedCurrency == "New Category") {
          newCategory = true;
        } else {
          newCategory = false;
        }
      }
    });
  }

  final picker = ImagePicker();
  _takeFromGalaryForCatgory() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        imageStoredCategory = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageForCatefory();
  }

  _takePictureForCatgory() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        imageStoredCategory = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageForCatefory();
  }

  _takeFromGalaryForItems() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        imageStoredItems = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageItems();
  }

  _takePictureForItems() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        imageStoredItems = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageItems();
  }

  switchToCategoryPage() {
    setState(() {});

    if (categoryName.text.isNotEmpty) {
      catgoryName = categoryName.text;
    } else {
      catgoryName = selectedCurrency;
    }

    categoryName.clear();
    itemName.clear();
    itemPrice.clear();
    itemDis.clear();
    itemBuyPrice.clear();
    totalQuantity.clear();
    nameEn.clear();
    categoryNameEn.clear();

    checkedSize = false;
    imageStoredCategory = null;
    urlImageCategory = null;
    imageStoredItems = null;
    urlImageItems = null;
  }

  checkBoxFuncation(newValue) {
    setState(() {
      checkedSize = newValue;
    });
  }

  chooseWordSized() {
    setState(() {
      sizeWord = true;
      sizeNum = false;
    });
  }

  chooseNumSized() {
    setState(() {
      sizeNum = true;
      sizeWord = false;
    });
  }

  changeXS() {
    setState(() {
      xs = !xs;
    });
  }

  changeS() {
    setState(() {
      s = !s;
    });
  }

  changeM() {
    setState(() {
      m = !m;
    });
  }

  changeL() {
    setState(() {
      l = !l;
    });
  }

  changeXL() {
    setState(() {
      xl = !xl;
    });
  }
  //Numbers

  change35() {
    setState(() {
      s35 = !s35;
    });
  }

  change36() {
    setState(() {
      s36 = !s36;
    });
  }

  change37() {
    setState(() {
      s37 = !s37;
    });
  }

  change38() {
    setState(() {
      s38 = !s38;
    });
  }

  change39() {
    setState(() {
      s39 = !s39;
    });
  }

  change40() {
    setState(() {
      s40 = !s40;
    });
  }

  change41() {
    setState(() {
      s41 = !s41;
    });
  }

  change42() {
    setState(() {
      s42 = !s42;
    });
  }
}

var selectedCurrency;
bool showItemFileds = false;
bool showBtnPost = false;
bool newCategory = false;
TextEditingController itemName = TextEditingController();
TextEditingController itemPrice = TextEditingController();
TextEditingController itemDis = TextEditingController();
TextEditingController categoryName = TextEditingController();
TextEditingController categoryNameEn = TextEditingController();
TextEditingController itemBuyPrice = TextEditingController();
TextEditingController totalQuantity = TextEditingController();
TextEditingController nameEn = TextEditingController();

bool checkedSize = false;
bool sizeWord = false;
bool sizeNum = false;
Widget addItem(
  BuildContext context,
  Function showItemTextFileds,
  Function _takePictureForCatgory,
  Function _takeFromGalaryForCatgory,
  Function _takePictureForItems,
  Function _takeFromGalaryForItems,
  Function switchToCategoryPage,
  Function checkBoxFuncation,
  Function chooseWordSized,
  Function chooseNumSized,
  Function changeXS,
  Function changeS,
  Function changeM,
  Function changeL,
  Function changeXL,
  Function change35,
  Function change36,
  Function change37,
  Function change38,
  Function change39,
  Function change40,
  Function change41,
  Function change42,
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
                Row(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: MyTextFormField(
                        editingController: categoryName,
                        hintText: 'أسم القسم',
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: MyTextFormField(
                        editingController: categoryNameEn,
                        hintText: 'أسم القسم بالأنقلش',
                      ),
                    ),
                  ],
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
                        editingController: nameEn,
                        hintText: 'الأسم بالانقلش',
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
                Row(
                  children: [
                    Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: MyTextFormField(
                        editingController: totalQuantity,
                        hintText: 'الكمية',
                        isNumber: true,
                      ),
                    ),
                    Container(
                      alignment: Alignment.topCenter,
                      width: halfMediaWidth,
                      child: MyTextFormField(
                        editingController: itemDis,
                        isMultiLine: true,
                        hintText: 'الوصف',
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
                          width: 200,
                          height: 200,
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
                  height: 20,
                ),
                CheckboxListTile(
                  title: Text("يوجد مقاسات؟"),
                  value: checkedSize,
                  onChanged: checkBoxFuncation,
                  controlAffinity:
                      ListTileControlAffinity.leading, //  <-- leading Checkbox
                ),
                Visibility(
                  visible: checkedSize,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.amber[100], border: Border.all()),
                            child: InkWell(
                                onTap: chooseNumSized,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("مقاس أرقام"),
                                )),
                          ),
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.amber[100], border: Border.all()),
                            child: InkWell(
                                onTap: chooseWordSized,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text("مقاس حجم"),
                                )),
                          ),
                        ],
                      ),
                      Visibility(
                        visible: sizeWord,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buttonSize("XS", changeXS, xs),
                              buttonSize("S", changeS, s),
                              buttonSize("M", changeM, m),
                              buttonSize("L", changeL, l),
                              buttonSize("XL", changeXL, xl),
                            ],
                          ),
                        ),
                      ),
                      Visibility(
                        visible: sizeNum,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              buttonSize("35", change35, s35),
                              buttonSize("36", change36, s36),
                              buttonSize("37", change37, s37),
                              buttonSize("38", change38, s38),
                              buttonSize("39", change39, s39),
                              buttonSize("40", change40, s40),
                              buttonSize("41", change41, s41),
                              buttonSize("42", change42, s42),
                            ],
                          ),
                        ),
                      )
                    ],
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
                        itemBuyPrice.text.isEmpty ||
                        nameEn.text.isEmpty ||
                        imageStoredItems == null ||
                        (checkedSize && !xs && !s && !m && !l && !xl) &&
                            (checkedSize &&
                                !s35 &&
                                !s36 &&
                                !s37 &&
                                !s38 &&
                                !s39 &&
                                !s40 &&
                                !s41 &&
                                !s42) ||
                        urlImageItems == null ||
                        totalQuantity.text.isEmpty) {
                      if (itemName.text.isEmpty) {
                        errorToast("أسم المنتج");
                      } else if (nameEn.text.isEmpty) {
                        errorToast("الأسم بالإنقلش");
                      } else if (itemPrice.text.isEmpty) {
                        errorToast("سعر البيع");
                      } else if (itemBuyPrice.text.isEmpty) {
                        errorToast('سعر الشراء');
                      } else if (totalQuantity.text.isEmpty) {
                        errorToast('كمية البضاعه');
                      } else if (itemDis.text.isEmpty) {
                        errorToast("الوصف");
                      } else if (checkedSize && !xs && !s && !m && !l && !xl ||
                          checkedSize &&
                              !s35 &&
                              !s36 &&
                              !s37 &&
                              !s38 &&
                              !s39 &&
                              !s40 &&
                              !s41 &&
                              !s42) {
                        errorToast("أختر المقاسات");
                      } else {
                        errorToast("لا توجد صورة");
                      }
                    } else {
                      String uui = uuid.v1();
                      uui = uui.substring(0, 8);
                      Map<String, dynamic> sizeWordMap = {
                        'XS': xs,
                        'S': s,
                        'M': m,
                        'L': l,
                        'XL': xl,
                      };
                      Map<String, dynamic> sizeNumMap = {
                        '35': s35,
                        '36': s36,
                        '37': s37,
                        '38': s38,
                        '39': s39,
                        '40': s40,
                        '41': s41,
                        '42': s42,
                      };
                      Map<String, dynamic> itemMap = {
                        'totalQuantity': totalQuantity.text,
                        "name": itemName.text,
                        "name_en": nameEn.text,
                        "description": itemDis.text,
                        "price": itemPrice.text,
                        "image": urlImageItems,
                        "show": false,
                        "imageID": uui,
                        'buyPrice': itemBuyPrice.text,
                        'size': checkedSize
                            ? sizeNum ? sizeNumMap : sizeWordMap
                            : {},
                        'priceOld': '',
                      };
                      Map<String, dynamic> itemMapForNew = {
                        "category": categoryName.text,
                        "items": FieldValue.arrayUnion([itemMap])
                      };
                      Map<String, dynamic> catgoryMap = {
                        "name": categoryName.text,
                        "en_name": categoryNameEn.text,
                      };
                      if (selectedCurrency == "New Category") {
                        if (categoryName.text.isEmpty ||
                            categoryNameEn.text.isEmpty ||
                            imageStoredItems == null ||
                            urlImageItems == null) {
                          if (categoryName.text.isEmpty) {
                            errorToast("Enter Category name");
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
  final bool isEmail;
  final TextEditingController editingController;
  MyTextFormField({
    this.hintText,
    this.isPassword = false,
    this.isNumber = false,
    this.editingController,
    this.isChanged,
    this.isMultiLine = false,
    this.isEmail = false,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        onChanged: isChanged,
        autocorrect: false,
        controller: editingController,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
        ),
        obscureText: isPassword ? true : false,
        maxLines: null,
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiLine
                ? TextInputType.multiline
                : isEmail ? TextInputType.emailAddress : TextInputType.text,
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

Widget buttonSize(String label, Function toggle, bool size) {
  return Container(
    decoration: BoxDecoration(
      border: Border.all(),
      color: size ? Colors.green[200] : Colors.grey[200],
    ),
    child: InkWell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(label),
      ),
      onTap: toggle,
    ),
  );
}

bool s35 = false,
    s36 = false,
    s37 = false,
    s38 = false,
    s39 = false,
    s40 = false,
    s41 = false,
    s42 = false;

bool xs = false;
bool s = false;
bool m = false;
bool l = false;
bool xl = false;
