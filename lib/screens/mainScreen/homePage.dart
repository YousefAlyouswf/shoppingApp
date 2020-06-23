import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/user/cartWidget.dart';
import 'package:shop_app/widgets/user/categoroes.dart';
import 'package:shop_app/widgets/user/myOrderWidget.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:shop_app/widgets/widgets2.dart';
import 'package:shop_app/screens/showItem.dart';

class HomePage extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  const HomePage({Key key, this.onThemeChanged, this.changeLangauge})
      : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with TickerProviderStateMixin<HomePage> {
  ScrollController controller;
  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    getAppInfoFireBase();
    getAllimagesFromFireStore();
    controller.addListener(_scrollListener);
  }

  double showFloatingBtn = 0.0;
  _scrollListener() {
    setState(() {
      showFloatingBtn = controller.offset;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

/////////////////////////----------------------START
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double imageShowSize = height / 3;
    // var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    return Scaffold(
      drawer: drawer(context, widget.onThemeChanged, goToHome,
          changeLangauge: widget.changeLangauge),
      body: navIndex == 0
          ? CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                SliverAppBar(
                  iconTheme: new IconThemeData(color: Colors.white),
                  title: Text(
                    "رفوف",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontFamily: "MainFont"),
                  ),
                  backgroundColor: Colors.black38,
                  floating: false,
                  pinned: true,
                  elevation: 8,
                  expandedHeight: MediaQuery.of(context).size.height / 3,
                  flexibleSpace: FlexibleSpaceBar(
                    background: networkImage2 == null
                        ? Center(
                            child: Container(
                              height: 100,
                              width: 100,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : imageCarousel(imageShowSize, imageOnTap),
                  ),
                ),
                SliverFillRemaining(
                  child: Column(
                    children: [
                      // listViewHorznintal(selectCategory, controller),
                      // Expanded(child: subCatgoryCustomer(null, fetchToMyCart)),
                    ],
                  ),
                ),
              ],
            )
          : navIndex == 2
              ? Container(
                  child: Column(
                    children: [
                      header(showDeleteIcon),
                      invoiceTable(fetchToMyCart, emptyCartGoToCategory),
                      //  delvierText(chooseDeliver),
                      buttons(context, widget.onThemeChanged,
                          widget.changeLangauge, changeDelvierValue),
                    ],
                  ),
                )
              : navIndex == 3
                  ? orderScreen(context, userID)
                  : navIndex == 1
                      ? Container(
                          child: Column(
                            children: [
                              headerCatgory(
                                  selectedSection, categorySelectedColor),
                              seprater(),
                              subCollection(
                                context,
                                setFirstElemntInSubCollection,
                                fetchToMyCart,
                              ),
                            ],
                          ),
                        )
                      : Container(),
      bottomNavigationBar: bottomNavgation(bottomNavIndex),
    );
  }

/////////////////////////----------------------END
  selectCategory(String name) {
    setState(() {});
    catgoryNameCustomer = name;
  }

  //--------------> Sections Category New Screen
  selectedSection(String name) {
    setState(() {});
    categoryNameSelected = name;
  }

  categorySelectedColor(int j) {
    setState(() {
      for (var i = 0; i < 20; i++) {
        if (j == i) {
          selected[i] = true;
        } else {
          selected[i] = false;
        }
      }
    });
  }

  setFirstElemntInSubCollection() async {
    await Firestore.instance
        .collection('categories')
        .getDocuments()
        .then((value) {
      value.documents.forEach((e) {
        setState(() {
          categoryNameSelected = e['collection'][0]['name'];
        });
      });
    });
    categorySelectedColor(0);
  }

  ///----------->>> CART Start
  showDeleteIcon() {
    setState(() {
      deleteIcon = !deleteIcon;
    });
  }

  chooseDeliver(value) {
    setState(() {
      isDeliver = value;
    });
    fetchMyCart();
  }

  changeDelvierValue() {
    setState(() {
      isDeliver = !isDeliver;
    });
    fetchToMyCart();
  }

  double sumPrice = 0;
  Future<void> fetchMyCart() async {
    cartToCheck = new List();
    final dataList = await DBHelper.getData('cart');
    setState(() {
      cartToCheck = dataList
          .map(
            (item) => ItemShow(
              id: item['id'],
              itemName: item['name'],
              itemPrice: item['price'],
              itemDes: item['des'],
              quantity: item['q'],
            ),
          )
          .toList();
    });
  }

  Future<void> fetchToMyCart() async {
    sumPrice = 0;
    sumBuyPrice = 0;
    final dataList = await DBHelper.getData('cart');
    setState(() {
      cart = dataList
          .map(
            (item) => ItemShow(
              id: item['id'],
              itemName: item['name'],
              itemPrice: item['price'],
              image: item['image'],
              itemDes: item['des'],
              quantity: item['q'],
              buyPrice: item['buyPrice'],
              sizeChose: item['size'],
              productID: item['productID'],
            ),
          )
          .toList();
    });

    for (var i = 0; i < cart.length; i++) {
      eachPrice =
          double.parse(cart[i].quantity) * double.parse(cart[i].itemPrice);
      eachBuyPrice =
          double.parse(cart[i].quantity) * double.parse(cart[i].buyPrice);
    }

    for (var i = 0; i < cart.length; i++) {
      sumPrice +=
          double.parse(cart[i].quantity) * double.parse(cart[i].itemPrice);
    }
    for (var i = 0; i < cart.length; i++) {
      sumBuyPrice +=
          double.parse(cart[i].quantity) * double.parse(cart[i].buyPrice);
    }
    quantity = 0;
    for (var i = 0; i < cart.length; i++) {
      quantity += int.parse(cart[i].quantity);
    }
    if (!isEnglish) {
      arabicItem = [];
      items = [];
      for (var i = 0; i < cart.length; i++) {
        arabicItem.add(cart[i].itemName);
      }
      setState(() {});
      items = arabicItem;
    } else {
      englishItem = [];
      items = [];
      for (var i = 0; i < cart.length; i++) {
        await translator
            .translate(cart[i].itemName, from: 'ar', to: 'en')
            .then((s) {
          englishItem.add(s);
        });
      }
      setState(() {});
      items = englishItem;
    }

    if (isDeliver) {
      totalAfterTax = sumPrice * tax / 100 + sumPrice + delivery;
    } else {
      totalAfterTax = sumPrice * tax / 100 + sumPrice;
    }
    if (totalAfterTax == delivery) {
      totalAfterTax = 0.0;
    }
  }

  getTaxAndDeliveryPrice() async {
    await Firestore.instance.collection('app').getDocuments().then((value) {
      value.documents.forEach((element) {
        setState(() {
          tax = element['tax'];
          delivery = element['delivery'];
        });
      });
    });
    fetchToMyCart();
  }

  emptyCartGoToCategory() {
    navIndex = 1;
    setState(() {});
  }

///////////----------------->>> CART End
  imageOnTap(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowItem(
          image: itemShow[i].image,
          name: itemShow[i].itemName,
          des: itemShow[i].itemDes,
          price: itemShow[i].itemPrice,
          fetchToMyCart: fetchToMyCart,
          imageID: itemShow[i].imageID,
          buyPrice: itemShow[i].buyPrice,
          size: itemShow[i].size,
          totalQuantity: itemShow[i].totalQuantity,
        ),
      ),
    );
    setState(() {});
  }

  List<ItemShow> itemShow = new List();
  getAllimagesFromFireStore() async {
    try {
      itemShow = new List();
      networkImage = new List();
      await FirestoreFunctions().getAllImages().then((value) {
        int listLength = value.length;
        for (var i = 0; i < listLength; i++) {
          networkImage.add(NetworkImage(value[i].image));
          itemShow.add(value[i]);
        }

        setState(() {});
        networkImage2 = networkImage;
      });
    } catch (e) {}
  }

  getAppInfoFireBase() async {
    await FirestoreFunctions().getAppInfo().then((value) {
      setState(() {});
      appInfo = value;
    });
  }

  //----------------->>> My Order Start
  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosDeviceInfo;
  String userID;
  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
      userID = androidInfo.androidId;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
      userID = iosDeviceInfo.identifierForVendor;
    }
  }
  //------------------>>> MY ORDER END

  bottomNavIndex(int i) {
    setState(() {
      navIndex = i;
    });
    if (i == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (i == 1) {
    } else if (i == 2) {
      getTaxAndDeliveryPrice();
    } else if (i == 3) {
      deviceID();
    }
  }

  goToHome() {
    Navigator.popUntil(context, (route) => route.isFirst);
    navIndex = 0;
    setState(() {});
  }
}
