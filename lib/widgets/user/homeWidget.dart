//Image in the Header

import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/models/listHirzontalImage.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';

import '../widgets.dart';
import 'categoryScreen/showItem.dart';

class HomeWidget extends StatefulWidget {
  final Function goToCategoryPage;
  final Function darwerPressdAnimation;
  final bool toogel;

  const HomeWidget(
      {Key key, this.goToCategoryPage, this.darwerPressdAnimation, this.toogel})
      : super(key: key);
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
          nameEn: itemShow[i].nameEn,
          des: itemShow[i].itemDes,
          price: itemShow[i].itemPrice,
          priceOld: itemShow[i].preiceOld,
          imageID: itemShow[i].imageID,
          buyPrice: itemShow[i].buyPrice,
          size: itemShow[i].size,
        ),
      ),
    );
  }

  ScrollController _controllerGridViewCatgories, scrollController;
  @override
  void initState() {
    _controllerGridViewCatgories = ScrollController();
    _controllerGridViewCatgories.addListener(_scrollListener);
    super.initState();
    getAllimagesFromFireStore();
    scrollController = ScrollController();
  }

  _scrollListener() {
    if (_controllerGridViewCatgories.offset >=
            _controllerGridViewCatgories.position.maxScrollExtent &&
        !_controllerGridViewCatgories.position.outOfRange) {
      setState(() {
        print("reach the bottom");
      });
    }
    if (_controllerGridViewCatgories.offset <=
            _controllerGridViewCatgories.position.minScrollExtent &&
        !_controllerGridViewCatgories.position.outOfRange) {
      setState(() {
        print("reach the top");
        scrollController.animateTo(180.0,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    }
  }

  double heigh;
  double width;
  @override
  Widget build(BuildContext context) {
    heigh = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    double imageShowSize = heigh / 2.5;
    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          ourNewProduct(imageShowSize, widget.darwerPressdAnimation),
          discountShow(context),
          labelAllCategories(),
          categories(),
        ],
      ),
    );
  }

  Widget discountShow(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.tag,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  word('discount', context),
                  style:
                      TextStyle(fontSize: width * 0.07, fontFamily: "MainFont"),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: heigh < 700 ? heigh * .38 : heigh * .3,
            width: double.infinity,
            child: StreamBuilder(
              stream: Firestore.instance.collection('subCategory').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Text("Loading");
                int listLength = snapshot.data.documents.length;
                List<ListHirezontalImage> discountOffer = [];
                for (var i = 0; i < listLength; i++) {
                  int itemsLength =
                      snapshot.data.documents[i].data['items'].length;
                  List<String> sizes = [];
                  for (var j = 0; j < itemsLength; j++) {
                    if (snapshot.data.documents[i].data['items'][j]
                            ['priceOld'] !=
                        "") {
                      if (snapshot.data.documents[i].data['items'][j]['size']
                              .length !=
                          0) {
                        sizes = [];
                        if (snapshot.data.documents[i].data['items'][j]['size']
                                .length ==
                            8) {
                          for (var k = 35;
                              k <
                                  snapshot.data.documents[i]
                                          .data['items'][j]['size'].length +
                                      35;
                              k++) {
                            var value = snapshot.data.documents[i].data['items']
                                [j]['size'][k.toString()];
                            if (value) {
                              sizes.add(k.toString());
                            }
                          }
                        } else {
                          List<String> sizeWord = ['XS', 'S', 'M', 'L', 'XL'];
                          for (var k = 0; k < 5; k++) {
                            var value = snapshot.data.documents[i].data['items']
                                [j]['size'][sizeWord[k]];
                            if (value) {
                              sizes.add(sizeWord[k]);
                            }
                          }
                        }
                      }
                      String price =
                          snapshot.data.documents[i].data['items'][j]['price'];
                      String priceOld = snapshot.data.documents[i].data['items']
                          [j]['priceOld'];

                      double decrease =
                          double.parse(priceOld) - double.parse(price);
                      decrease = decrease / int.parse(priceOld) * 100;
                      int percentage = decrease.round();

                      discountOffer.add(ListHirezontalImage(
                        buyPrice: snapshot.data.documents[i].data['items'][j]
                            ['buyPrice'],
                        category: "",
                        description: snapshot.data.documents[i].data['items'][j]
                            ['description'],
                        image: snapshot.data.documents[i].data['items'][j]
                            ['image'],
                        imageID: snapshot.data.documents[i].data['items'][j]
                            ['productID'],
                        name: snapshot.data.documents[i].data['items'][j]
                            ['name'],
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
                discountOffer
                    .sort((b, a) => a.percentage.compareTo(b.percentage));

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
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
                                      // totalQuantity:
                                      //     discountOffer[i].totalQuantity,
                                    ),
                                  ),
                                );
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: heigh < 700 ? 120 : 140,
                                    width: 175,
                                    child: Image.network(
                                      discountOffer[i].image,
                                      fit: BoxFit.fill,
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
                                    "${discountOffer[i].price} ${word("currancy", context)}",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
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
                                    fontSize: 12,
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
          )
        ],
      ),
    );
  }

  Widget ourNewProduct(double imageShowSize, darwerPressdAnimation) {
    return Container(
      margin: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FaIcon(
                  FontAwesomeIcons.tags,
                  color: Colors.grey,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  word('NEW_ARRIVAL', context),
                  style:
                      TextStyle(fontSize: width * 0.07, fontFamily: "MainFont"),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Container(
                    height: 3,
                    color: Colors.black45,
                  ),
                ),
              ],
            ),
          ),
          networkImage2 == null
              ? Center(
                  child: Container(
                    height: 100,
                    width: 100,
                    child: CircularProgressIndicator(),
                  ),
                )
              : imageCarousel(
                  imageShowSize,
                  imageOnTap,
                  darwerPressdAnimation,
                  widget.toogel,
                ),
        ],
      ),
    );
  }

  Widget labelAllCategories() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 3,
                  color: Colors.black38,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  word("all_categories", context),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    fontFamily: "MainFont",
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 3,
                  color: Colors.black38,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }

  Widget categories() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: double.infinity,
      child: StreamBuilder(
        stream: Firestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading");
          int categoryLength =
              snapshot.data.documents[0].data['collection'].length;

          return ScrollConfiguration(
            behavior: MyBehavior(),
            child: GridView.builder(
                controller: _controllerGridViewCatgories,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                ),
                itemCount: categoryLength,
                itemBuilder: (BuildContext context, int i) {
                  String nameAr =
                      snapshot.data.documents[0].data['collection'][i]['name'];
                  String nameEn = snapshot.data.documents[0].data['collection']
                      [i]['en_name'];
                  String image =
                      snapshot.data.documents[0].data['collection'][i]['image'];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      onTap: () {
                        navIndex = 1;
                        widget.goToCategoryPage(nameAr, i);
                      },
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        decoration: BoxDecoration(
                          border: Border.all(),
                          color: Theme.of(context).unselectedWidgetColor,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          ),
                          image: DecorationImage(
                              image: NetworkImage(
                                image,
                              ),
                              fit: BoxFit.fill),
                        ),
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            isEnglish ? nameEn : nameAr,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: "MainFont"),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          );
        },
      ),
    );
  }

  Widget imageCarousel(double height, Function imageOnTap,
      Function darwerPressdAnimation, bool toogel) {
    return networkImage2.length == 0
        ? Container(
            height: 100,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Theme.of(context).unselectedWidgetColor,
              ),
            ),
          )
        : StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Container(
                height: height,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Carousel(
                  boxFit: BoxFit.fill,
                  images: networkImage2,
                  animationCurve: Curves.easeInExpo,
                  animationDuration: Duration(seconds: 1),
                  autoplay: true,
                  autoplayDuration: Duration(seconds: 5),
                  onImageTap: (i) {
                    if (toogel) {
                      darwerPressdAnimation();
                    } else {
                      imageOnTap(i);
                    }
                  },
                  showIndicator: false,
                ),
              );
            },
          );
  }
}

List<NetworkImage> networkImage;
List<NetworkImage> networkImage2;
NetworkImage imageNetwork;

//End Image in the Header
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
