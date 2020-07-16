import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/models/listHirzontalImage.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';

import 'categoryScreen/showItem.dart';

class Offer extends StatefulWidget {
  @override
  _OfferState createState() => _OfferState();
}

class _OfferState extends State<Offer> {
  List<ListHirezontalImage> discountOffer = new List();
  @override
  Widget build(BuildContext context) {
    double heigh = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      child: StreamBuilder(
        stream: Firestore.instance.collection('subCategory').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading");
          int listLength = snapshot.data.documents.length;
          discountOffer = [];
          for (var i = 0; i < listLength; i++) {
            int itemsLength = snapshot.data.documents[i].data['items'].length;
            List<String> sizes = [];
            for (var j = 0; j < itemsLength; j++) {
              if (snapshot.data.documents[i].data['items'][j]['priceOld'] !=
                  "") {
                if (snapshot
                        .data.documents[i].data['items'][j]['size'].length !=
                    0) {
                  sizes = [];
                  if (snapshot
                          .data.documents[i].data['items'][j]['size'].length ==
                      8) {
                    for (var k = 35;
                        k <
                            snapshot.data.documents[i].data['items'][j]['size']
                                    .length +
                                35;
                        k++) {
                      var value = snapshot.data.documents[i].data['items'][j]
                          ['size'][k.toString()];
                      if (value) {
                        sizes.add(k.toString());
                      }
                    }
                  } else {
                    List<String> sizeWord = ['XS', 'S', 'M', 'L', 'XL'];
                    for (var k = 0; k < 5; k++) {
                      var value = snapshot.data.documents[i].data['items'][j]
                          ['size'][sizeWord[k]];
                      if (value) {
                        sizes.add(sizeWord[k]);
                      }
                    }
                  }
                }
                String price =
                    snapshot.data.documents[i].data['items'][j]['price'];
                String priceOld =
                    snapshot.data.documents[i].data['items'][j]['priceOld'];

                double decrease = double.parse(priceOld) - double.parse(price);
                decrease = decrease / int.parse(priceOld) * 100;
                int percentage = decrease.round();

                discountOffer.add(ListHirezontalImage(
                  buyPrice: snapshot.data.documents[i].data['items'][j]
                      ['buyPrice'],
                  category: "",
                  description: snapshot.data.documents[i].data['items'][j]
                      ['description'],
                  image: snapshot.data.documents[i].data['items'][j]['image'],
                  imageID: snapshot.data.documents[i].data['items'][j]
                      ['productID'],
                  name: snapshot.data.documents[i].data['items'][j]['name'],
                  nameEn: snapshot.data.documents[i].data['items'][j]
                      ['name_en'],
                  price: price,
                  priceOld: priceOld,
                  size: sizes,
                  // totalQuantity: snapshot.data.documents[i].data['items']
                  //     [j]['totalQuantity'],
                  percentage: percentage,
                ));
              }
            }
          }
          discountOffer.sort((b, a) => a.percentage.compareTo(b.percentage));

          return discountOffer.length == 0
              ? Container()
              : GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.5,
                    mainAxisSpacing: 2.0,
                  ),
                  itemCount: discountOffer.length,
                  itemBuilder: (context, i) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            new BoxShadow(
                              color: Colors.black,
                              offset: new Offset(5.0, 5.0),
                              blurRadius: 5.0,
                            )
                          ],
                        ),
                        width: width < 351 ? 130 : 175,
                        child: Stack(
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowItem(
                                      image: discountOffer[i].image,
                                      name: discountOffer[i].name,
                                      nameEn: discountOffer[i].nameEn,
                                      des: discountOffer[i].description,
                                      price: discountOffer[i].price,
                                      priceOld: discountOffer[i].priceOld,
                                      imageID: discountOffer[i].imageID,
                                      buyPrice: discountOffer[i].buyPrice,
                                      size: discountOffer[i].size,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: heigh < 700 ? 180 : 240,
                                    width: 175,
                                    child: Image.network(
                                      discountOffer[i].image,
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      children: <TextSpan>[
                                        new TextSpan(
                                          text:
                                              '${discountOffer[i].priceOld} ${word("currancy", context)}',
                                          style: new TextStyle(
                                            color: Colors.grey,
                                            decoration:
                                                TextDecoration.lineThrough,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    "${discountOffer[i].price} ${word("currancy", context)} ${discountOffer[i].percentage > 19 ? '🔥' : ''}",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 20,
                                  )
                                ],
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color:
                                      Theme.of(context).unselectedWidgetColor,
                                  // borderRadius: BorderRadius.only(
                                  //   bottomLeft: isEnglish
                                  //       ? Radius.circular(0)
                                  //       : Radius.circular(10),
                                  //   bottomRight: isEnglish
                                  //       ? Radius.circular(10)
                                  //       : Radius.circular(0),
                                  // ),
                                ),
                                child: Text(
                                  "${word("off", context)} %${discountOffer[i].percentage}",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
        },
      ),
    );
  }
}
