import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_network_image/meet_network_image.dart';
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

List<ItemShow> itemShow = new List();

class _HomeWidgetState extends State<HomeWidget> {
  int quantity = 0;
  Future<void> getQuantityForThis(imageID) async {
    await Firestore.instance
        .collection('quantityItem')
        .where('id', isEqualTo: imageID)
        .getDocuments()
        .then(
          (value) => value.documents.forEach(
            (e) {
              setState(() {
                quantity = int.parse(e['number']);
              });
            },
          ),
        );
  }

  imageOnTap(int i) async {
    await getQuantityForThis(itemShow[i].imageID).then((value) {
      if (quantity <= 1) {
        if (showMsg) {
          errorToast(word("outOfStock", context));
          setState(() {
            showMsg = false;
            checkI = i;
          });
        } else if (checkI != i) {
          setState(() {
            showMsg = true;
            checkI = i;
            errorToast(word("outOfStock", context));
          });
        }
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ShowItem(
              image: itemShow[i].image,
              name: itemShow[i].itemName,
              nameEn: itemShow[i].nameEn,
              des: itemShow[i].itemDes,
              desEn: itemShow[i].itemDesEn,
              price: itemShow[i].itemPrice,
              priceOld: itemShow[i].preiceOld,
              imageID: itemShow[i].imageID,
              buyPrice: itemShow[i].buyPrice,
              size: itemShow[i].size,
            ),
          ),
        );
      }
    });
  }

  bool showMsg = true;
  int checkI = 999;
  ScrollController _controllerGridViewCatgories, scrollController;
  @override
  void initState() {
    _controllerGridViewCatgories = ScrollController();
    _controllerGridViewCatgories.addListener(_scrollListener);
    super.initState();
    //getAllimagesFromFireStore();
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
          message(),
          ourNewProduct(imageShowSize, widget.darwerPressdAnimation),
          discountShow(context),
          labelAllCategories(),
          categories(),
        ],
      ),
    );
  }

  Widget message() {
    return Container(
      child: StreamBuilder(
          stream: Firestore.instance.collection('header').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Text('No data');
            } else {
              return snapshot.data.documents[0].data['image'] == ""
                  ? Container()
                  : Container(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(
                                      snapshot.data.documents[0].data['image']),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              snapshot.data.documents[0].data['text'],
                              style: TextStyle(
                                  fontFamily: "afsaneh", fontSize: 35),
                            ),
                          ),
                        ],
                      ),
                    );
            }
          }),
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
                InkWell(
                  onTap: () {
                    setState(() {
                      navIndex = 1;
                    });
                  },
                  child: Text(
                    word('discount', context),
                    style: TextStyle(
                        fontSize: width * 0.07, fontFamily: "MainFont"),
                  ),
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
            height: heigh < 700 ? 220 : 300,
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
                        descriptionEn: snapshot.data.documents[i].data['items']
                            [j]['descriptionEn'],
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
                              onTap: () async {
                                await getQuantityForThis(
                                        discountOffer[i].imageID)
                                    .then((value) {
                                  if (quantity <= 1) {
                                    if (showMsg) {
                                      errorToast(word("outOfStock", context));
                                      setState(() {
                                        showMsg = false;
                                        checkI = i;
                                      });
                                    } else if (checkI != i) {
                                      setState(() {
                                        showMsg = true;
                                        checkI = i;
                                        errorToast(word("outOfStock", context));
                                      });
                                    }
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowItem(
                                          image: discountOffer[i].image,
                                          name: discountOffer[i].name,
                                          nameEn: discountOffer[i].nameEn,
                                          des: discountOffer[i].description,
                                          desEn: discountOffer[i].descriptionEn,
                                          price: discountOffer[i].price,
                                          imageID: discountOffer[i].imageID,
                                          buyPrice: discountOffer[i].buyPrice,
                                          size: discountOffer[i].size,
                                          priceOld: discountOffer[i].priceOld,
                                        ),
                                      ),
                                    );
                                  }
                                });
                              },
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Container(
                                    height: heigh < 700 ? 110 : 170,
                                    width: 175,
                                    child: Image.network(
                                      discountOffer[i].image,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      AutoSizeText(
                                        isEnglish
                                            ? discountOffer[i].nameEn
                                            : discountOffer[i].name,
                                        maxFontSize: 12,
                                      ),
                                      AutoSizeText.rich(
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
                                        maxFontSize: 12,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${discountOffer[i].price} ${word("currancy", context)}",
                                    style: TextStyle(
                                      color: Colors.teal,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
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
        : Container(
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
  }
}

List<MeetNetworkImage> networkImage;
List<MeetNetworkImage> networkImage2;
NetworkImage imageNetwork;

//End Image in the Header
class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
