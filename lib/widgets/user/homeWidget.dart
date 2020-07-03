//Image in the Header

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/showItem.dart';
import 'package:shop_app/widgets/langauge.dart';

import '../widgets.dart';

class HomeWidget extends StatefulWidget {
  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
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

  imageOnTap(int i) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowItem(
          image: itemShow[i].image,
          name: itemShow[i].itemName,
          des: itemShow[i].itemDes,
          price: itemShow[i].itemPrice,
          imageID: itemShow[i].imageID,
          buyPrice: itemShow[i].buyPrice,
          size: itemShow[i].size,
          totalQuantity: itemShow[i].totalQuantity,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    getAllimagesFromFireStore();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double imageShowSize = height / 3;
    return SingleChildScrollView(
      child: Column(
        children: [
          discountShow(context),
          Text(
            word('NEW_ARRIVAL', context),
            style: TextStyle(
                fontSize: 35, fontFamily: isEnglish ? "summer" : "MainFont"),
          ),
          networkImage2 == null
              ? Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(),
                  ),
                )
              : imageCarousel(imageShowSize, imageOnTap),
        ],
      ),
    );
  }
}

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
      : StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              height: height,
              child: Carousel(
                boxFit: BoxFit.cover,
                images: networkImage2,
                animationCurve: Curves.easeInExpo,
                animationDuration: Duration(seconds: 1),
                autoplay: true,
                autoplayDuration: Duration(seconds: 5),
                onImageTap: imageOnTap,
                showIndicator: false,
              ),
            );
          },
        );
}

//End Image in the Header

Widget discountShow(BuildContext context) {
  return Column(
    children: [
      Text(
        word('discount', context),
        style: TextStyle(fontSize: 35, fontFamily: "MainFont"),
      ),
      Container(
        height: MediaQuery.of(context).size.height / 3,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://www.freeiconspng.com/uploads/sale-tag-png-7.png',
            ),
          ),
        ),
      )
    ],
  );
}
