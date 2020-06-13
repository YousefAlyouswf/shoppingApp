import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/manager/mainPage.dart';
import 'package:shop_app/models/User.dart';

class HomePageManager extends StatefulWidget {
  @override
  _HomePageManagerState createState() => _HomePageManagerState();
}

class _HomePageManagerState extends State<HomePageManager> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PersistentBottomSheetController _sheetController;
  String _email;
  String _password;
  bool _loading = false;
  bool _autoValidate = false;
  String errorMsg = "";

  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color primaryColor = Theme.of(context).primaryColor;

    //button widgets
    Widget filledButton(String text, Color splashColor, Color highlightColor,
        Color fillColor, Color textColor, void function()) {
      return RaisedButton(
        highlightElevation: 0.0,
        splashColor: splashColor,
        highlightColor: highlightColor,
        elevation: 0.0,
        color: fillColor,
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(30.0)),
        child: Text(
          text,
          style: TextStyle(
              fontWeight: FontWeight.bold, color: textColor, fontSize: 20),
        ),
        onPressed: () {
          function();
        },
      );
    }

    final FirebaseAuth _auth = FirebaseAuth.instance;
    User _userFromFirebaseUser(FirebaseUser user) {
      return user != null ? User(userID: user.uid) : null;
    }

    Future signinWithEmailAndPassword({String email, String password}) async {
      try {
        AuthResult result = await _auth.signInWithEmailAndPassword(
            email: email, password: password);
        FirebaseUser firebaseUser = result.user;
        return _userFromFirebaseUser(firebaseUser).userID;
      } on PlatformException catch (e) {
        return e.code;
      }
    }

    void _validateLoginInput() async {
      final FormState form = _formKey.currentState;
      if (_formKey.currentState.validate()) {
        form.save();
        _sheetController.setState(() {
          _loading = true;
        });

        signinWithEmailAndPassword(email: _email, password: _password)
            .then((value) async {
          switch (value) {
            case "ERROR_USER_NOT_FOUND":
              {
                _sheetController.setState(() {
                  errorMsg =
                      "There is no user with such entries. Please try again.";

                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            case "ERROR_WRONG_PASSWORD":
              {
                _sheetController.setState(() {
                  errorMsg = "Password doesn\'t match your email.";
                  _loading = false;
                });
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Container(
                          child: Text(errorMsg),
                        ),
                      );
                    });
              }
              break;
            default:
              {
                _sheetController.setState(() {
                  errorMsg = "";
                });
              }
          }
          if (errorMsg == "") {
            HelperFunction.saveManagerLogin(true);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MainPage()),
            );
          }
        });
      } else {
        setState(() {
          _autoValidate = true;
        });
      }
    }

    String emailValidator(String value) {
      Pattern pattern =
          r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      RegExp regex = new RegExp(pattern);
      if (value.isEmpty) return '*Required';
      if (!regex.hasMatch(value))
        return '*Enter a valid email';
      else
        return null;
    }

    void loginSheet() {
      _sheetController = _scaffoldKey.currentState
          .showBottomSheet<void>((BuildContext context) {
        return DecoratedBox(
          decoration: BoxDecoration(color: Theme.of(context).canvasColor),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(40.0),
                topRight: Radius.circular(40.0)),
            child: Container(
              child: ListView(
                children: <Widget>[
                  Container(
                    child: Stack(
                      children: <Widget>[
                        Positioned(
                          left: 10,
                          top: 10,
                          child: IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _loading = false;
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.close,
                              size: 30.0,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        )
                      ],
                    ),
                    height: 50,
                    width: 50,
                  ),
                  SingleChildScrollView(
                      child: Form(
                    key: _formKey,
                    autovalidate: _autoValidate,
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 140,
                          child: Stack(
                            children: <Widget>[
                              Positioned(
                                child: Align(
                                  child: Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Theme.of(context).primaryColor),
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                              Positioned(
                                child: Container(
                                  child: Text(
                                    "LOGIN",
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                            padding: EdgeInsets.only(bottom: 20, top: 60),
                            child: CustomTextField(
                              onSaved: (input) {
                                _email = input;
                              },
                              validator: emailValidator,
                              icon: Icon(Icons.email),
                              hint: "EMAIL",
                            )),
                        Padding(
                            padding: EdgeInsets.only(bottom: 20),
                            child: CustomTextField(
                              icon: Icon(Icons.lock),
                              obsecure: true,
                              onSaved: (input) => _password = input,
                              validator: (input) =>
                                  input.isEmpty ? "*Required" : null,
                              hint: "PASSWORD",
                            )),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: MediaQuery.of(context).viewInsets.bottom),
                          child: _loading == true
                              ? CircularProgressIndicator(
                                  valueColor: new AlwaysStoppedAnimation<Color>(
                                      primaryColor),
                                )
                              : Container(
                                  child: filledButton(
                                      "LOGIN",
                                      Colors.white,
                                      primaryColor,
                                      primaryColor,
                                      Colors.white,
                                      _validateLoginInput),
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )),
                ],
              ),
              height: MediaQuery.of(context).size.height / 1.1,
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
            ),
          ),
        );
      });
    }

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).primaryColor,
        body: Column(
          children: <Widget>[
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.05,
            ),
            Padding(
              child: Container(
                child: filledButton("LOGIN", primaryColor, Colors.white,
                    Colors.white, primaryColor, loginSheet),
                height: 50,
              ),
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.05,
                  left: 20,
                  right: 20),
            ),
            Expanded(
              child: Align(
                child: ClipPath(
                  child: Container(
                    color: Colors.white,
                    height: 300,
                  ),
                  clipper: BottomWaveClipper(),
                ),
                alignment: Alignment.bottomCenter,
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.stretch,
        ));
  }
}

class BottomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(size.width, 0.0);
    path.lineTo(size.width, size.height);
    path.lineTo(0.0, size.height);
    path.lineTo(0.0, size.height + 5);
    var secondControlPoint = Offset(size.width - (size.width / 6), size.height);
    var secondEndPoint = Offset(size.width, 0.0);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class CustomTextField extends StatelessWidget {
  CustomTextField(
      {this.icon,
      this.hint,
      this.obsecure = false,
      this.validator,
      this.onSaved});
  final FormFieldSetter<String> onSaved;
  final Icon icon;
  final String hint;
  final bool obsecure;
  final FormFieldValidator<String> validator;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 20, right: 20),
      child: TextFormField(
        onSaved: onSaved,
        validator: validator,
        autofocus: true,
        keyboardType: TextInputType.emailAddress,
        obscureText: obsecure,
        style: TextStyle(
          fontSize: 20,
        ),
        decoration: InputDecoration(
            hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            hintText: hint,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 3,
              ),
            ),
            prefixIcon: Padding(
              child: IconTheme(
                data: IconThemeData(color: Theme.of(context).primaryColor),
                child: icon,
              ),
              padding: EdgeInsets.only(left: 30, right: 10),
            )),
      ),
    );
  }
}
