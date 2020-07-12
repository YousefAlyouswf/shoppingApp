import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:twilio_flutter/twilio_flutter.dart' as tw;
import 'package:sms_autofill/sms_autofill.dart';
import 'package:uuid/uuid.dart';

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

  String accountSid;
  String authToken;
  String twilioNumber;
  tw.TwilioFlutter twilioFlutter;
  @override
  void initState() {
    super.initState();
    twilioInfo();
    listenSMS();
  }

  twilioInfo() async {
    await Firestore.instance.collection("twilio").getDocuments().then((v) {
      v.documents.forEach((e) {
        setState(() {
          accountSid = e['accountSid'];
          authToken = e['authToken'];
          twilioNumber = e['twilioNumber'];
        });
      });
    });
    twilioFlutter = tw.TwilioFlutter(
      accountSid: accountSid,
      authToken: authToken,
      twilioNumber: '+12054966662',
    );
  }

  void listenSMS() async {
    await SmsAutoFill().listenForCode;
  }

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
                          checkIDs().then((value) async {
                            if (value) {
                              errorToast("رقم الهوية مسجل من قبل");
                            } else {
                              setState(() {
                                isloading = true;
                              });

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

                              uploadids();

                              showDialog(
                                context: context,
                                builder: (BuildContext context) =>
                                    StatefulBuilder(
                                  builder: (BuildContext context,
                                      StateSetter setState) {
                                    return Dialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: Container(
                                        height: 350.0,
                                        width: 300.0,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 16.0),
                                              child: Center(
                                                child: Text(
                                                  "أكتب رمز التحقق",
                                                  style:
                                                      TextStyle(fontSize: 15),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 50),
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
                                                  Navigator.pop(context);
                                                } else {
                                                  errorToast("رمز التحقق خطأ");
                                                }
                                              },
                                              child: Text(
                                                "تحقق",
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

  String codeInput;
  String codeID;
  String signCode;
  formatPhoneNumber() {
    String phoneSMS = '';
    setState(() {
      if (phone.text.substring(0, 2) == "05") {
        phoneSMS = phone.text.substring(1);

        phoneSMS = "+966$phoneSMS";
      } else {
        phoneSMS = "+1${phone.text}";
      }
    });

    print("Controller ----> ${phone.text}");
    print('PhoneSms ------>> $phoneSMS');
    twilioFlutter.sendSMS(
        toNumber: phoneSMS,
        messageBody: ' ألوان ولمسات \n الكود هو $codeID \n $signCode');
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
