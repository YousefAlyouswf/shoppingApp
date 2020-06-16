import 'dart:io';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/manager/homePage.dart';
import 'package:shop_app/manager/mainPage.dart';
import 'package:shop_app/models/appInfo.dart';
import 'package:shop_app/models/drawerbody.dart';
import 'package:shop_app/models/listHirzontalImage.dart';
import 'package:shop_app/screens/cart.dart';
import 'package:uuid/uuid.dart';

var uuid = Uuid();
List<String> english = [
  'Home',
  'My Account',
  'Cart',
  'My Order',
  'Categories',
  'Favorite',
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
  "Search",
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
  'حسابي',
  'السلة',
  'طلباتي',
  'الأقسام',
  'المفضلة',
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
  "إبحث",
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
    {String text = "الدباس",
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
      isEnglish ? english[1] : arabic[1],
      Icon(
        Icons.person,
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
      isEnglish ? english[5] : arabic[5],
      Icon(
        Icons.favorite,
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
        if (drawerModel[i].text == "السلة") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Cart()),
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
              applicationName: "SHOP APP",
              applicationVersion: "0.0.1",
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

Widget categores(Function selectCategory) {
  List<ListHirezontalImage> listImages;
  return Container(
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('categories').snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          int listLength =
              asyncSnapshot.data.documents[0].data['collection'].length;
          listImages = List();
          for (var i = 0; i < listLength; i++) {
            listImages.add(ListHirezontalImage(
              asyncSnapshot.data.documents[0].data['collection'][i]['name'],
              asyncSnapshot.data.documents[0].data['collection'][i]['image'],
            ));
          }

          return Container(
            color: Colors.black12,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listImages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onLongPress: () {
                        deleteCategoryDialog(context, listImages[index].name,
                            listImages[index].image);
                      },
                      onTap: () {
                        selectCategory(listImages[index].name);
                      },
                      child: Column(
                        children: <Widget>[
                          new Container(
                            width: 100,
                            height: 100,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image:
                                    new NetworkImage(listImages[index].image),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(listImages[index].name),
                        ],
                      ),
                    ),
                  );
                }),
          );
        } else if (asyncSnapshot.hasError) {
          return Text('There was an error...');
        } else {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    ),
  );
}

File getImageForlistFile;
String getImageForlistURL;
String catgoryName = "";
Widget subCatgory(
    Function takeImageGalaryForList, Function takeImageCameraForList) {
  List<ListHirezontalImage> listImages;

  return Container(
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('subCategory')
          .where('category', isEqualTo: catgoryName)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          try {
            int listLength =
                asyncSnapshot.data.documents[0].data['items'].length;
            listImages = List();
            for (var i = 0; i < listLength; i++) {
              listImages.add(ListHirezontalImage(
                asyncSnapshot.data.documents[0].data['items'][i]['name'],
                asyncSnapshot.data.documents[0].data['items'][i]['image'],
                description: asyncSnapshot.data.documents[0].data['items'][i]
                    ['description'],
                price: asyncSnapshot.data.documents[0].data['items'][i]
                    ['price'],
                show: asyncSnapshot.data.documents[0].data['items'][i]['show'],
                imageID: asyncSnapshot.data.documents[0].data['items'][i]
                    ['imageID'],
              ));
            }
          } catch (e) {
            return Center(
              child: Container(
                height: 100,
                width: 100,
                child: Text("Select From Catgory List"),
              ),
            );
          }

          return Container(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Text(
                    catgoryName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, childAspectRatio: 0.7),
                      itemCount: listImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            showBottomSheet(
                                backgroundColor: Colors.transparent,
                                context: context,
                                builder: (context) =>
                                    StatefulBuilder(builder: (BuildContext
                                            context,
                                        StateSetter
                                            setState /*You can rename this!*/) {
                                      return SingleChildScrollView(
                                        child: Container(
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(40),
                                              topLeft: Radius.circular(40),
                                            ),
                                          ),
                                          child: Column(
                                            children: [
                                              Container(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3,
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width /
                                                    3,
                                                decoration: BoxDecoration(
                                                  image: new DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: new NetworkImage(
                                                        listImages[index]
                                                            .image),
                                                  ),
                                                ),
                                              ),
                                             
                                              Container(
                                                height: 100,
                                                width: double.infinity,
                                                child: StreamBuilder(
                                                    stream: Firestore.instance
                                                        .collection("images")
                                                        .where("imageID",
                                                            isEqualTo:
                                                                listImages[
                                                                        index]
                                                                    .imageID)
                                                        .snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Text("Loading");
                                                      } else {
                                                        return ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: snapshot
                                                                .data
                                                                .documents[0]
                                                                .data['images']
                                                                .length,
                                                            itemBuilder:
                                                                (context, i) {
                                                              String listImage =
                                                                  snapshot
                                                                          .data
                                                                          .documents[
                                                                              0]
                                                                          .data[
                                                                      'images'][i];
                                                              print(listImage);
                                                              return InkWell(
                                                                onLongPress: (){
                                                                  FirestoreFunctions().deleteImagesForList(snapshot
                                                                .data
                                                                .documents[0]
                                                                .data['imageID'], listImage);
                                                                },
                                                                                                                              child: Padding(
                                                                  padding: const EdgeInsets.all(8.0),
                                                                  child: Container(
                                                                    height: 100,
                                                                    width: 100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                              fit: BoxFit.fill,
                                                                        image:
                                                                            NetworkImage(
                                                                          listImage,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      }
                                                    }),
                                              ),
                                              IconButton(
                                                  icon: Icon(
                                                    Icons.add,
                                                    size: 44,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    await getImageForCatgory(
                                                        takeImageCameraForList(
                                                            listImages[index]
                                                                .imageID),
                                                        takeImageGalaryForList(
                                                            listImages[index]
                                                                .imageID),
                                                        context);
                                                  }),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Text(
                                                      "${listImages[index].price} ر.س",
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Text(
                                                      listImages[index].name,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width /
                                                              1.5,
                                                      height: 200,
                                                      child:
                                                          SingleChildScrollView(
                                                        child: Card(
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .end,
                                                              children: [
                                                                Center(
                                                                  child: Text(
                                                                    "وصف المنتج",
                                                                    textDirection:
                                                                        TextDirection
                                                                            .rtl,
                                                                  ),
                                                                ),
                                                                Text(
                                                                  listImages[
                                                                          index]
                                                                      .description,
                                                                  textDirection:
                                                                      TextDirection
                                                                          .rtl,
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      listImages[index].show
                                                          ? Icons.cancel
                                                          : Icons.check_circle,
                                                      size: 40,
                                                      color:
                                                          listImages[index].show
                                                              ? Colors.red
                                                              : Colors.green,
                                                    ),
                                                    onPressed: () {
                                                      Map<String, dynamic>
                                                          itemMapRemove = {
                                                        "name":
                                                            listImages[index]
                                                                .name,
                                                        "description":
                                                            listImages[index]
                                                                .description,
                                                        "price":
                                                            listImages[index]
                                                                .price,
                                                        "image":
                                                            listImages[index]
                                                                .image,
                                                        "show": false,
                                                      };
                                                      Map<String, dynamic>
                                                          itemMapAdd = {
                                                        "name":
                                                            listImages[index]
                                                                .name,
                                                        "description":
                                                            listImages[index]
                                                                .description,
                                                        "price":
                                                            listImages[index]
                                                                .price,
                                                        "image":
                                                            listImages[index]
                                                                .image,
                                                        "show": true,
                                                      };
                                                      if (listImages[index]
                                                          .show) {
                                                        FirestoreFunctions()
                                                            .changeShowStatus(
                                                          catgoryName,
                                                          itemMapAdd,
                                                          itemMapRemove,
                                                        );
                                                      } else {
                                                        FirestoreFunctions()
                                                            .changeShowStatus(
                                                          catgoryName,
                                                          itemMapRemove,
                                                          itemMapAdd,
                                                        );
                                                      }

                                                      Navigator.pop(context);
                                                    },
                                                  )
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }));
                          },
                          onLongPress: () {
                            Map<String, dynamic> itemMap = {
                              "name": listImages[index].name,
                              "description": listImages[index].description,
                              "price": listImages[index].price,
                              "image": listImages[index].image,
                              'show': listImages[index].show,
                              'imageID': listImages[index].imageID,
                            };
                            deleteItemDialog(
                              context,
                              listImages[index].name,
                              catgoryName,
                              itemMap,
                              listImages[index].image,
                              listImages[index].price,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                new Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  height: 100,
                                  decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(
                                          listImages[index].image),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Text(listImages[index].name),
                                Text(listImages[index].price),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        } else if (asyncSnapshot.hasError) {
          return Text('There was an error...');
        } else if (!asyncSnapshot.hasData) {
          return Text("data");
        } else {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    ),
  );
}

Widget firstPage(
  Function selectCategory,
  Function takeImageGalaryForList,
  Function takeImageCameraForList,
) {
  return Column(
    children: [
      Container(height: 160, child: categores(selectCategory)),
      Divider(
        thickness: 5,
      ),
      Expanded(
          child: subCatgory(takeImageGalaryForList, takeImageCameraForList)),
    ],
  );
}

var selectedCurrency;
bool showItemFileds = false;
bool showBtnPost = false;
bool newCategory = false;
TextEditingController itemName = TextEditingController();
TextEditingController itemPrice = TextEditingController();
TextEditingController itemDis = TextEditingController();
TextEditingController categoryName = TextEditingController();
Widget secondPage(
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
                          hintText: 'Category Name',
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
                          hintText: 'Item Name',
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        width: halfMediaWidth,
                        child: MyTextFormField(
                          editingController: itemPrice,
                          hintText: 'Price',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                ),
                MyTextFormField(
                  editingController: itemDis,
                  isMultiLine: true,
                  hintText: 'Description',
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
                        "imageID": uui
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
                            catgoryMap,
                            itemMapForNew,
                            uui,
                          );
                          showItemTextFileds();
                          switchToCategoryPage();
                        }
                      } else {
                        FirestoreFunctions().addNewItemRoExistCategory(
                          itemMap,
                          selectedCurrency,
                          uui,
                        );
                        showItemTextFileds();
                        switchToCategoryPage();
                      }
                    }
                  },
                  child: Text(
                    'POST',
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

Future uploadImageForList(String imageID) async {
  String fileName = '${DateTime.now()}.png';

  StorageReference firebaseStorage =
      FirebaseStorage.instance.ref().child(fileName);

  StorageUploadTask uploadTask = firebaseStorage.putFile(getImageForlistFile);
  await uploadTask.onComplete;
  getImageForlistURL = await firebaseStorage.getDownloadURL() as String;

  if (getImageForlistURL.isNotEmpty) {
    await FirestoreFunctions().addImagesForList(imageID, getImageForlistURL);
  }
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

deleteItemDialog(
  BuildContext context,
  String itemTextName,
  String catgoryName,
  itemMap,
  String image,
  String price,
) {
  showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 300.0,
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        image,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            itemTextName,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "R.S. $price",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirestoreFunctions().deleteItem(catgoryName, itemMap);
                      Navigator.pop(context);
                    },
                    label: Text(
                      'OK',
                      style: TextStyle(color: Colors.purple, fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
          ));
}

deleteCategoryDialog(
  BuildContext context,
  String catgoryTextName,
  String image,
) {
  showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 300.0,
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        image,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        catgoryTextName,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirestoreFunctions()
                          .deleteCategory(catgoryTextName, image);
                      Navigator.pop(context);
                    },
                    label: Text(
                      'OK',
                      style: TextStyle(color: Colors.purple, fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
          ));
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
