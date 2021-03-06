import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/manager/manager/addItem.dart';

import 'package:shop_app/widgets/widgets.dart';

import '../../push_nofitications.dart';
import 'add_new_empolyee.dart';
import 'employeeScreen.dart';

class MyAccount extends StatefulWidget {
  @override
  _MyAccountState createState() => _MyAccountState();
}

class _MyAccountState extends State<MyAccount> {
  TextEditingController id = TextEditingController();
  TextEditingController pass = TextEditingController();
  bool loading = true;
  @override
  void initState() {
    super.initState();
    loginDirctory();
  }

  void loginDirctory() async {
    String id = await HelperFunction.getEmployeeLogin();
    String name = await HelperFunction.getEmployeeName();
    if (id == "" || id == null) {
      setState(() {
        loading = false;
      });
      return null;
    } else {
      await Firestore.instance
          .collection('employee')
          .where('id', isEqualTo: id)
          .getDocuments()
          .then((value) {
        value.documents.forEach((e) {
          if (e['accept'] == '1') {
            PushNotificationsManager().initEmployee();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => EmployeeScreen(
                  id: id,
                  name: name,
                ),
              ),
            );
          } else {
            errorToast("تم إلغاء عضويتك وشكرا على تعاونك");
          }
          setState(() {
            loading = false;
          });
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      floatingActionButton: keyboard != 0.0
          ? FloatingActionButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
              },
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white,
              ),
              backgroundColor: Colors.black,
            )
          : null,
      appBar: AppBar(
        title: Text("بوابة المندوب"),
      ),
      body: loading
          ? Container()
          : Container(
              height: MediaQuery.of(context).size.height / 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("تسجيل دخول المندوب"),
                  Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: MyTextFormFieldAccount(
                          editingController: pass,
                          hintText: "كلمة المرور",
                          isPassword: true,
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 2,
                        child: MyTextFormField(
                          editingController: id,
                          hintText: "رقم الهوية",
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: InkWell(
                      onTap: () async {
                        if (id.text.length < 10 || id.text.length > 10) {
                          errorToast("خطأ في عدد خانات الهوية");
                        } else {
                          login().then((value) async {
                            if (value) {
                              Firestore.instance
                                  .collection('employee')
                                  .where('id', isEqualTo: id.text)
                                  .where('pass', isEqualTo: pass.text)
                                  .getDocuments()
                                  .then((value) {
                                value.documents.forEach((e) {
                                  if (e['accept'] == '0') {
                                    infoToast("طلبك قيد الدراسة");
                                  } else if (e['accept'] == '2') {
                                    infoToast("تم رفض طلبك");
                                  } else {
                                    PushNotificationsManager().initEmployee();
                                    HelperFunction.emplyeeLogin(e['id']);
                                    HelperFunction.setEmplyeeName(e['name']);
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => EmployeeScreen(
                                                name: e['name'],
                                                phone: e['phone'],
                                                city: e['city'],
                                                accept: e['accept'],
                                                id: e['id'],
                                              )),
                                    );
                                  }
                                });
                              });
                            } else {
                              errorToast(
                                  "البيانات خاطئة يرجى التواصل مع الدعم الفني");
                            }
                          });
                        }
                      },
                      splashColor: Colors.transparent,
                      child: Center(
                        child: Text(
                          "دخـــول",
                          style: TextStyle(color: Colors.white, fontSize: 22),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Container(
                        height: 1,
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width / 3,
                      ),
                      Text("أو", style: TextStyle(fontSize: 22)),
                      Container(
                        height: 1,
                        color: Colors.grey,
                        width: MediaQuery.of(context).size.width / 3,
                      ),
                    ],
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => AddNewEmployee()),
                        );
                      },
                      child: Center(
                        child: Text(
                          "انضم الينا",
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

  Future<bool> login() async {
    bool x = false;
    await Firestore.instance
        .collection("employee")
        .where('id', isEqualTo: id.text)
        .where('pass', isEqualTo: pass.text)
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
}

class MyTextFormFieldAccount extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final bool isNumber;
  final Function isChanged;
  final bool isMultiLine;
  final TextEditingController editingController;
  MyTextFormFieldAccount({
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
        keyboardType: isNumber
            ? TextInputType.number
            : isMultiLine ? TextInputType.multiline : TextInputType.text,
      ),
    );
  }
}
