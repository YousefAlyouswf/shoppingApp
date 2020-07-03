//Image in the Header

import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/widgets/langauge.dart';

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
