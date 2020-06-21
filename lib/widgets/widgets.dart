import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/manager/homePage.dart';
import 'package:shop_app/manager/mainPage.dart';
import 'package:shop_app/models/appInfo.dart';
import 'package:shop_app/models/drawerbody.dart';
import 'package:shop_app/screens/cart.dart';
import 'package:shop_app/screens/myAccount.dart';
import 'package:shop_app/screens/myOrder.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();

List<String> english = [
  'Home',
  'deliver',
  'Cart',
  'My Order',
  'Categories',
  "a",
  'Settings',
  'Dark Mode',
  'App Info',
  'Guest',
  'اللغة العربية',
  'Shopping Cart',
  'Items',
  'Edit',
  'To delete drag to left',
  'R.S.',
  'Buy R.S',
  "Continue Shopping",
  "Shipping Info",
  "Choose Your Address",
  "New Address",
  "Continue",
  "Personal Info",
  "Full Name",
  "Phone",
  "Address",
  "Type your national Address",
  "Select from map",
  "OR",
  "City",
  "District",
  "Street",
  "House Number",
  "Type Full Name",
  "Phone Number 10 Digits",
  "Correct your Address",
];
List<String> arabic = [
  'الرئيسية',
  'المندوب',
  'السلة',
  'طلباتي',
  'الأقسام',
  "a",
  'الإعدادات',
  'وضع الداكن',
  'معلومات التطبيق',
  'زائر',
  'English',
  'سلة التسوق',
  'المحتويات',
  'تعديل',
  "للحذف إسحب إلى اليسار",
  'ر.س.',
  'ر.س  شراء',
  "الرجوع للتسوق",
  "معلومات الشحن",
  "أختر عنوانك",
  "عنوان جديد",
  "متابعه",
  "البيانات الشخصية",
  "الأسم كامل",
  "رقم الجوال",
  "العنوان",
  "أدخل عنوانك الوطني هنا",
  "حدد من الخريطة",
  "أو",
  "المدينة",
  "الحي",
  "الشارع",
  "رقم المنزل",
  "أكتب الأسم كامل",
  "رقم الجوال 10 أرقام",
  "أكتب العنوان بالشكل الصحيح",
];
List<AppInfoModel> appInfo = [];
AppBar appBar(
    {String text = "تنوتو",
    bool search = false,
    bool cart = false,
    BuildContext context}) {
  return AppBar(
    elevation: 0,
    title: Text(text),
    actions: <Widget>[
      search
          ? IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
              ),
              onPressed: () {},
            )
          : Container(),
      cart
          ? IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Cart()),
                );
              },
            )
          : Container()
    ],
  );
}

bool isEnglish = false;
Drawer drawer(BuildContext context, Function onThemeChanged,
    {Function changeLangauge, Function fetchMyCart}) {
  List<Widget> drawerBody;
  List<DrawerBodyModel> drawerModel = [
    DrawerBodyModel(
      isEnglish ? english[0] : arabic[0],
      Icon(
        Icons.home,
        color: Colors.red,
      ),
    ),
    DrawerBodyModel(
      isEnglish ? english[2] : arabic[2],
      Icon(
        Icons.shopping_cart,
        color: Colors.red,
      ),
    ),
    DrawerBodyModel(
      isEnglish ? english[3] : arabic[3],
      Icon(
        Icons.shopping_basket,
        color: Colors.red,
      ),
    ),
    DrawerBodyModel(
      isEnglish ? english[4] : arabic[4],
      Icon(
        Icons.dashboard,
        color: Colors.red,
      ),
    ),
    DrawerBodyModel(
      isEnglish ? english[1] : arabic[1],
      Icon(
        Icons.person,
        color: Colors.red,
      ),
    ),
  ];
  drawerBody = new List();
  for (var i = 0; i < drawerModel.length; i++) {
    drawerBody.add(ListTile(
      title: Text(drawerModel[i].text),
      leading: drawerModel[i].icon,
      onTap: () {
        String basketWord = isEnglish ? english[2] : arabic[2];
        String homeWord = isEnglish ? english[0] : arabic[0];
        String myAccountWord = isEnglish ? english[1] : arabic[1];
        String myOrderWord = isEnglish ? english[3] : arabic[3];
        if (drawerModel[i].text == basketWord) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Cart()),
          );
        } else if (drawerModel[i].text == homeWord) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (drawerModel[i].text == myAccountWord) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyAccount()),
          );
        }else if(drawerModel[i].text == myOrderWord){
           Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MyOrder()),
          );
        }
      },
    ));
  }

  return Drawer(
    child: Column(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(isEnglish ? english[9] : arabic[9]),
          accountEmail: Text("yousef.alyouswf1989@gmail.com"),
          currentAccountPicture: GestureDetector(
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          decoration: BoxDecoration(color: Colors.pink),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: drawerBody.length,
            itemBuilder: (context, i) {
              return drawerBody[i];
            },
          ),
        ),
        Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text(isEnglish ? english[6] : arabic[6]),
          leading: Icon(
            Icons.settings,
          ),
          onTap: () {
            showModalBottomSheet(
              backgroundColor: Colors.transparent,
              context: context,
              builder: (context) => StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(40),
                        topLeft: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      children: [
                        FlatButton(
                          onPressed: () {
                            changeLangauge();
                            fetchMyCart();
                          },
                          child: Text(isEnglish ? english[10] : arabic[10]),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          },
        ),
        ListTile(
          title: Text(isEnglish ? english[7] : arabic[7]),
          leading: Icon(
            Icons.lightbulb_outline,
          ),
          onTap: onThemeChanged,
        ),
        ListTile(
          title: Text(isEnglish ? english[8] : arabic[8]),
          leading: Icon(
            Icons.help,
          ),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: "تنوتو",
              applicationVersion: "0.0.6",
              applicationLegalese: "Developed by Yousef Al Yousef",
              useRootNavigator: false,
              children: [Icon(Icons.developer_board)],
              applicationIcon: InkWell(
                child: Icon(Icons.shopping_basket),
                onDoubleTap: () {
                  HelperFunction.getManagerLogin().then((value) {
                    if (value == null) {
                      value = false;
                    }
                    if (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePageManager()),
                      );
                    }
                  });
                },
              ),
            );
          },
        ),
        SizedBox(
          height: 30,
        )
      ],
    ),
  );
}

//Image in the Header

List<NetworkImage> networkImage;
List<NetworkImage> networkImage2;
NetworkImage imageNetwork;
Widget imageCarousel(double height, Function imageOnTap) {
  return networkImage2.length == 0
      ? Container(
          height: 100,
          width: 100,
          child: Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.blue,
            ),
          ),
        )
      : Container(
          height: height,
          child: Carousel(
            boxFit: BoxFit.cover,
            images: networkImage2,
            animationCurve: Curves.easeInExpo,
            animationDuration: Duration(seconds: 1),
            autoplay: true,
            autoplayDuration: Duration(seconds: 5),
            onImageTap: imageOnTap,
            indicatorBgPadding: 10,
          ),
        );
}

//End Image in the Header

Widget continaer(String text, Color color) {
  return Padding(
    padding:
        const EdgeInsets.only(top: 100, bottom: 16.0, left: 16.0, right: 16.0),
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: FlatButton(
        onPressed: () {},
        child: Text(text),
      ),
    ),
  );
}

Widget managerBody() {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Scaffold(),
      ),
    ),
  );
}









errorToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 16.0);
}

infoToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.yellow[100],
      textColor: Colors.black,
      fontSize: 16.0);
}
