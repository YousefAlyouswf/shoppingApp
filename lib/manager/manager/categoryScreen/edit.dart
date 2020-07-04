import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/models/sizeListModel.dart';

import '../addItem.dart';

class EditItem extends StatefulWidget {
  final String name;
  final String nameEn;
  final String image;
  final String price;
  final String des;
  final String imageID;
  final bool show;
  final String category;
  final String buyPrice;
  final String totalQuantity;
  final List<SizeListModel> size;
  final String priceOld;

  const EditItem(
    this.name,
    this.nameEn,
    this.image,
    this.price,
    this.des,
    this.imageID,
    this.show,
    this.category,
    this.buyPrice,
    this.size,
    this.totalQuantity,
    this.priceOld,
  );
  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  TextEditingController name = TextEditingController();
  TextEditingController nameEn = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController des = TextEditingController();
  TextEditingController buyPrice = TextEditingController();
  TextEditingController totalQuantity = TextEditingController();
  TextEditingController priceOld = TextEditingController();
  @override
  void initState() {
    super.initState();
    name.text = widget.name;
    nameEn.text = widget.nameEn;
    price.text = widget.price;
    des.text = widget.des;
    buyPrice.text = widget.buyPrice;
    totalQuantity.text = widget.totalQuantity;
    priceOld.text = widget.priceOld;
    if (widget.size.length > 0) {
      checkedSize = true;
      if (widget.size.length == 5) {
        sizeWord = true;
        if (widget.size[0].value == true) {
          xs = true;
        }
        if (widget.size[1].value == true) {
          s = true;
        }
        if (widget.size[2].value == true) {
          m = true;
        }
        if (widget.size[3].value == true) {
          l = true;
        }
        if (widget.size[4].value == true) {
          xl = true;
        }
      } else {
        sizeNum = true;
        if (widget.size[0].value == true) {
          s35 = true;
        }
        if (widget.size[1].value == true) {
          s36 = true;
        }
        if (widget.size[2].value == true) {
          s37 = true;
        }
        if (widget.size[3].value == true) {
          s38 = true;
        }
        if (widget.size[4].value == true) {
          s39 = true;
        }
        if (widget.size[5].value == true) {
          s40 = true;
        }
        if (widget.size[6].value == true) {
          s41 = true;
        }
        if (widget.size[7].value == true) {
          s41 = true;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                child: Column(
                  children: [
                    InkWell(
                      onTap: () {
                        getImageForCatgory(
                            _takePictureForItems, _takeFromGalaryForItems);
                      },
                      child: Center(
                        child: Container(
                          height: 150,
                          width: 150,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                image: imageStoredItems == null
                                    ? NetworkImage(widget.image)
                                    : FileImage(imageStoredItems),
                                fit: BoxFit.fill),
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: MyTextFormField(
                            hintText: "أسم المنتج",
                            editingController: name,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: MyTextFormField(
                            hintText: "أسم المنتج انقلش",
                            editingController: nameEn,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: MyTextFormField(
                            hintText: "سعر البيع",
                            editingController: price,
                            isNumber: true,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: MyTextFormField(
                            hintText: "سعر الشراء",
                            editingController: buyPrice,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: MyTextFormField(
                            hintText: "سعر قبل الخصم",
                            editingController: priceOld,
                            isNumber: true,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: MyTextFormField(
                            hintText: "الكمية",
                            editingController: totalQuantity,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    MyTextFormField(
                      editingController: des,
                      isMultiLine: true,
                    ),
                    CheckboxListTile(
                      title: Text("يوجد مقاسات؟"),
                      value: checkedSize,
                      onChanged: checkBoxFuncation,
                      controlAffinity: ListTileControlAffinity
                          .leading, //  <-- leading Checkbox
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
                                    color: Colors.amber[100],
                                    border: Border.all()),
                                child: InkWell(
                                    onTap: chooseNumSized,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text("مقاس أرقام"),
                                    )),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.amber[100],
                                    border: Border.all()),
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
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
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () async {
                if (checkedSize) {
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
                  Map<String, dynamic> sizingMap = Map.fromIterable(widget.size,
                      key: (e) => e.sizeName, value: (e) => e.value);
                  Map<String, dynamic> itemMapRemove = {
                    'buyPrice': widget.buyPrice,
                    'description': widget.des,
                    'image': widget.image,
                    'imageID': widget.imageID,
                    'name': widget.name,
                    'name_en': widget.nameEn,
                    'price': widget.price,
                    'show': widget.show,
                    'size': sizingMap,
                    'totalQuantity': widget.totalQuantity,
                    'priceOld': widget.priceOld,
                  };
                  Map<String, dynamic> itemMapAdd = {
                    'buyPrice': buyPrice.text,
                    'description': des.text,
                    'image': url == null ? widget.image : url,
                    'imageID': widget.imageID,
                    'name': name.text,
                    'name_en': nameEn.text,
                    'price': price.text,
                    'show': widget.show,
                    'size':
                        checkedSize ? sizeNum ? sizeNumMap : sizeWordMap : {},
                    'totalQuantity': totalQuantity.text,
                    'priceOld': priceOld.text,
                  };
                  FirestoreFunctions()
                      .upDateItems(widget.category, itemMapRemove, itemMapAdd)
                      .then((e) {
                    if (url != null)
                      FirestoreFunctions().deleteFirstImagesFormList(
                          widget.imageID, widget.image, url);
                  }).then((value) => Navigator.pop(context));
                } else {
                  Map<String, dynamic> itemMapRemove = {
                    'buyPrice': widget.buyPrice,
                    'description': widget.des,
                    'image': widget.image,
                    'imageID': widget.imageID,
                    'name': widget.name,
                    'name_en': widget.nameEn,
                    'price': widget.price,
                    'show': widget.show,
                    'size': {},
                    'totalQuantity': widget.totalQuantity,
                    'priceOld': widget.priceOld,
                  };
                  Map<String, dynamic> itemMapAdd = {
                    'buyPrice': buyPrice.text,
                    'description': des.text,
                    'image': url == null ? widget.image : url,
                    'imageID': widget.imageID,
                    'name': name.text,
                    'name_en': nameEn.text,
                    'price': price.text,
                    'show': widget.show,
                    'size': {},
                    'totalQuantity': totalQuantity.text,
                    'priceOld': priceOld.text,
                  };
                  FirestoreFunctions()
                      .upDateItems(widget.category, itemMapRemove, itemMapAdd)
                      .then((e) {
                    if (url != null)
                      FirestoreFunctions().deleteFirstImagesFormList(
                          widget.imageID, widget.image, url);
                  }).then((value) => Navigator.pop(context));
                }
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.all(Radius.circular(25))),
                child: Center(
                  child: Text(
                    "تــم",
                    style: TextStyle(fontSize: 27, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 30,
          )
        ],
      ),
    );
  }

  File imageStoredItems;
  String url;
  String urlImageItems;
  final picker = ImagePicker();
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

  Future uploadImageItems() async {
    String fileName = '${DateTime.now()}.png';

    StorageReference firebaseStorage =
        FirebaseStorage.instance.ref().child(fileName);

    StorageUploadTask uploadTask = firebaseStorage.putFile(imageStoredItems);
    await uploadTask.onComplete;
    urlImageItems = await firebaseStorage.getDownloadURL() as String;

    if (urlImageItems.isNotEmpty) {
      setState(() {
        url = urlImageItems;
      });
    }
  }

  getImageForCatgory(Function camera, Function gallery) {
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
  bool sizeNum = false;
  bool sizeWord = false;
  bool checkedSize = false;
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
