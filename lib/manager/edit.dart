import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/screens/address.dart';

class EditItem extends StatefulWidget {
  final String name;
  final String image;
  final String price;
  final String des;
  final String imageID;
  final bool show;
  final String category;

  const EditItem(this.name, this.image, this.price, this.des, this.imageID,
      this.show, this.category);
  @override
  _EditItemState createState() => _EditItemState();
}

class _EditItemState extends State<EditItem> {
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController des = TextEditingController();
  @override
  void initState() {
    super.initState();
    name.text = widget.name;
    price.text = widget.price;
    des.text = widget.des;
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
                            shape: BoxShape.circle,
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
                            editingController: name,
                          ),
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: MyTextFormField(
                            editingController: price,
                            isNumber: true,
                          ),
                        ),
                      ],
                    ),
                    MyTextFormField(
                      editingController: des,
                      isMultiLine: true,
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
                Map<String, dynamic> itemMapRemove = {
                  'description': widget.des,
                  'image': widget.image,
                  'imageID': widget.imageID,
                  'name': widget.name,
                  'price': widget.price,
                  'show': widget.show,
                };
                Map<String, dynamic> itemMapAdd = {
                  'description': des.text,
                  'image': url == null ? widget.image : url,
                  'imageID': widget.imageID,
                  'name': name.text,
                  'price': price.text,
                  'show': widget.show,
                };
                FirestoreFunctions()
                    .upDateItems(widget.category, itemMapRemove, itemMapAdd)
                    .then((e) {
                  if (url != null)
                    FirestoreFunctions().deleteFirstImagesFormList(
                        widget.imageID, widget.image, url);
                }).then((value) => Navigator.pop(context));
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
}
