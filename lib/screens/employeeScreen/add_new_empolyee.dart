import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/widgets/widgets.dart';

class Post {
  final String body;

  Post(this.body);
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      json['body'],
    );
  }
}

class AddNewEmployee extends StatefulWidget {
  @override
  _AddNewEmployeeState createState() => _AddNewEmployeeState();
}

class _AddNewEmployeeState extends State<AddNewEmployee> {
  TextEditingController name = TextEditingController();
  TextEditingController phone = TextEditingController();
  TextEditingController id = TextEditingController();
  TextEditingController pass = TextEditingController();
  TextEditingController city = TextEditingController();
  TextEditingController iban = TextEditingController();
  bool isloading = false;
  bool checkedValue = false;
  String terms;
  @override
  Widget build(BuildContext context) {
    terms =
        "أتعهد أنا ${name.text} رقم الهوية ${id.text} على صحة جميع بياناتي المذكوره اعلاه وفي حال ثبت عكس ذلك يحق لمؤسسة ألوان ولمسات بإتخاذ الاجراءات القانونية حيال ذلك";
    return Scaffold(
      //   appBar: appBar(text: "تسجيل مندوب جديد"),
      appBar: AppBar(
        title: Text("تسجيل مندوب جديد"),
      ),
      body: isloading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : Container(
              height: MediaQuery.of(context).size.height,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormFieldAccount(
                                  editingController: name,
                                  hintText: "الأسم كامل",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormFieldAccount(
                                  editingController: phone,
                                  isNumber: true,
                                  hintText: "رقم الجوال",
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormFieldAccount(
                                  editingController: city,
                                  hintText: "المدينة",
                                ),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: MyTextFormFieldAccount(
                                  editingController: pass,
                                  hintText: "كلمة المرور",
                                ),
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            child: MyTextFormFieldAccount(
                              editingController: id,
                              isNumber: true,
                              hintText: "رقم الهوية",
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            child: MyTextFormFieldAccount(
                              editingController: iban,
                              hintText: "رقم الايبان لا تكتب SA",
                              isNumber: true,
                              helper: "SA0000000000000000000000",
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                forImage("صورة الهوية", idImage, idFile),
                                forImage("صورة الرخصة", idLicImage, idLic),
                                forImage("صورة الإستمارة", idCarImage, idCar),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.all(8.0),
                            padding: EdgeInsets.all(8.0),
                            width: double.infinity,
                            child: Card(
                              child: Column(
                                children: [
                                  Text(
                                    "تعهد",
                                    style: TextStyle(
                                      fontFamily: "MainFont",
                                      fontSize: 22,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(terms),
                                  ),
                                  CheckboxListTile(
                                    title: Text("قبول التعهد"),
                                    value: checkedValue,
                                    onChanged: (newValue) {
                                      setState(() {
                                        checkedValue = newValue;
                                      });
                                    },
                                    controlAffinity: ListTileControlAffinity
                                        .leading, //  <-- leading Checkbox
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(8.0),
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        if (name.text.length < 5) {
                          errorToast("أكتب أسمك كامل");
                        } else if (phone.text.length < 10 ||
                            phone.text.length > 10) {
                          errorToast("رقم الجوال يجب ان يكون من عشرة خانات");
                        } else if (id.text.length < 10 || id.text.length > 10) {
                          errorToast("رقم الهوية مكون من عشرة أرقام فقط");
                        } else if (pass.text.length < 6) {
                          errorToast("كلمة المرور يجب ان تتكون من 6 خانات");
                        } else if (city.text.length < 2) {
                          errorToast("أكتب أسم المدينة المتواجد فيها");
                        } else if (iban.text.length < 22) {
                          errorToast("أكتب رقم IBAN بشكل الصحيح 22 رقم");
                        } else if (!checkedValue) {
                          errorToast("يجب قبول التعهد");
                        } else {
                          checkIDs().then((value) {
                            if (value) {
                              errorToast("رقم الهوية مسجل من قبل");
                            } else {
                              setState(() {
                                isloading = true;
                              });
                              uploadids();
                            }
                          });
                        }
                      },
                      child: Center(
                        child: Text(
                          "إرسل الطلب",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<bool> checkIDs() async {
    bool x = false;
    await Firestore.instance
        .collection("employee")
        .where('id', isEqualTo: id.text)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) {
        setState(() {
          x = true;
        });
      });
    });
    if (x) {
      return Future.value(true);
    } else {
      return Future.value(false);
    }
  }

  final picker = ImagePicker();
  File idFile;
  String idURL;
  idImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 600);
    setState(() {
      try {
        idFile = File(pickedFile.path);
      } catch (e) {}
    });
  }

  File idLic;
  String licURL;
  idLicImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 600);
    setState(() {
      try {
        idLic = File(pickedFile.path);
      } catch (e) {}
    });
  }

  File idCar;
  String carURL;
  idCarImage() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 50, maxWidth: 600);
    setState(() {
      try {
        idCar = File(pickedFile.path);
      } catch (e) {}
    });
  }

  Future uploadids() async {
    try {
      String fileNameID = 'ID${DateTime.now()}.png';

      StorageReference firebaseStorage =
          FirebaseStorage.instance.ref().child(fileNameID);

      StorageUploadTask uploadTask = firebaseStorage.putFile(idFile);
      await uploadTask.onComplete;
      idURL = await firebaseStorage.getDownloadURL() as String;

      String fileNameLIC = 'LIC${DateTime.now()}.png';

      StorageReference firebaseStorageLIC =
          FirebaseStorage.instance.ref().child(fileNameLIC);

      StorageUploadTask uploadTaskLIC = firebaseStorageLIC.putFile(idLic);
      await uploadTaskLIC.onComplete;
      licURL = await firebaseStorageLIC.getDownloadURL() as String;

      String fileNameCar = 'Car${DateTime.now()}.png';

      StorageReference firebaseStorageCar =
          FirebaseStorage.instance.ref().child(fileNameCar);

      StorageUploadTask uploadTaskCar = firebaseStorageCar.putFile(idCar);
      await uploadTaskCar.onComplete;
      carURL = await firebaseStorageCar.getDownloadURL() as String;
      if (idURL.isNotEmpty && licURL.isNotEmpty && carURL.isNotEmpty) {
        Firestore.instance.collection('employee').add({
          'id': id.text,
          'pass': pass.text,
          'name': name.text,
          'phone': phone.text,
          'idImage': idURL,
          'licImage': licURL,
          'carImage': carURL,
          'accept': '0',
          'city': city.text,
          'iban': iban.text,
          'terms': terms,
        });
        addRequestToast("طلبك قيد الدراسة");
        Navigator.pop(context);
      } else {
        errorToast("صور");
      }
    } catch (e) {
      print("--------------------------->>>>>>$e");
      errorToast("يجب إظافة جميع الصور");
      setState(() {
        isloading = false;
      });
    }
  }

  addRequestToast(String text) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.blue[200],
        textColor: Colors.black,
        fontSize: 16.0);
  }

  Widget forImage(String label, Function takePic, File image) {
    return Container(
      height: 100,
      width: 100,
      decoration: image == null
          ? BoxDecoration(
              color: Colors.blueGrey,
            )
          : BoxDecoration(
              image:
                  DecorationImage(image: FileImage(image), fit: BoxFit.fill)),
      child: InkWell(
        onTap: takePic,
        child: Center(
          child: image != null
              ? Container()
              : Text(
                  label,
                  style: TextStyle(color: Colors.white),
                ),
        ),
      ),
    );
  }
}

class MyTextFormFieldAccount extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final bool isNumber;
  final Function isChanged;
  final bool isMultiLine;
  final String helper;
  final TextEditingController editingController;
  MyTextFormFieldAccount({
    this.hintText,
    this.isPassword = false,
    this.isNumber = false,
    this.editingController,
    this.isChanged,
    this.isMultiLine = false,
    this.helper,
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
          helperText: helper,
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        obscureText: isPassword ? true : false,
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiLine ? TextInputType.multiline : TextInputType.text,
      ),
    );
  }
}
