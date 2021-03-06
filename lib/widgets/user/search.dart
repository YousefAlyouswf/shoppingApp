import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/models/listHirzontalImage.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';

import '../widgets.dart';
import 'categoryScreen/showItem.dart';

class Searching extends StatefulWidget {
  final String text;

  const Searching({Key key, this.text}) : super(key: key);
  @override
  _SearchingState createState() => _SearchingState();
}

class _SearchingState extends State<Searching> {
  String sizeChose = '';
  double height;
  double width;
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

  Widget imageCarouselItemShow(double height) {
    return networkItemShow.length == 0
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
            decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            )),
            child: Carousel(
              boxFit: BoxFit.fitHeight,
              images: networkItemShow,
              animationCurve: Curves.easeInExpo,
              // animationDuration: Duration(seconds: 1),
              overlayShadow: true,
              overlayShadowSize: 0.2,
              autoplay: false,
              // autoplayDuration: Duration(seconds: 5),
              indicatorBgPadding: 10,
              dotSize: 5,
              dotBgColor: Colors.transparent,
              dotColor: Colors.white,
              dotIncreasedColor: Theme.of(context).unselectedWidgetColor,
            ),
          );
  }

  Future<void> getImagesToShowItems(String imageID) async {
    networkItemShow = [];
    await Firestore.instance
        .collection("images")
        .where("imageID", isEqualTo: imageID)
        .getDocuments()
        .then(
          (value) => {
            value.documents.forEach(
              (e) {
                for (var i = 0; i < e['images'].length; i++) {
                  setState(() {
                    networkItemShow.add(NetworkImage(e['images'][i]));
                  });
                }
              },
            )
          },
        );
  }

  List<ItemShow> cart = [];
  Future<int> fetchToMyCart() async {
    final dataList = await DBHelper.getData('cart');
    setState(
      () {
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
      },
    );
    int count = 0;
    for (var i = 0; i < cart.length; i++) {
      setState(() {});
      count += int.parse(cart[i].quantity);
    }
    return count;
  }

  @override
  void initState() {
    super.initState();
    fetchToMyCart();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColorLight,
        title: Text(
          widget.text,
          style: TextStyle(fontFamily: "MainFont"),
        ),
      ),
      body: subCollection(context),
    );
  }

  List<String> sizes = [];
  Widget subCollection(
    BuildContext context,
  ) {
    List<ListHirezontalImage> listImages;
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance.collection('subCategory').snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            try {
              int listLength =
                  asyncSnapshot.data.documents[0].data['items'].length;
              listImages = List();

              for (var i = 0; i < listLength; i++) {
                sizes = [];

                if (asyncSnapshot
                        .data.documents[0].data['items'][i]['size'].length !=
                    0) {
                  sizes = [];
                  if (asyncSnapshot
                          .data.documents[0].data['items'][i]['size'].length ==
                      8) {
                    for (var j = 35;
                        j <
                            asyncSnapshot.data.documents[0]
                                    .data['items'][i]['size'].length +
                                35;
                        j++) {
                      var value = asyncSnapshot.data.documents[0].data['items']
                          [i]['size'][j.toString()];
                      if (value) {
                        sizes.add(j.toString());
                      }
                    }
                  } else {
                    List<String> sizeWord = ['XS', 'S', 'M', 'L', 'XL'];
                    for (var j = 0; j < 5; j++) {
                      var value = asyncSnapshot.data.documents[0].data['items']
                          [i]['size'][sizeWord[j]];
                      if (value) {
                        sizes.add(sizeWord[j]);
                      }
                    }
                  }
                }
                String itemName = asyncSnapshot
                    .data.documents[0].data['items'][i]['name']
                    .toLowerCase();
                String itemDes = asyncSnapshot
                    .data.documents[0].data['items'][i]['description']
                    .toLowerCase();
                String itemNameEn = asyncSnapshot
                    .data.documents[0].data['items'][i]['name_en']
                    .toLowerCase();
                String searchText = widget.text.toLowerCase();
                if (itemName.contains(searchText) ||
                    itemDes.contains(searchText) ||
                    itemNameEn.contains(searchText)) {
                  listImages.add(
                    ListHirezontalImage(
                      name: asyncSnapshot.data.documents[0].data['items'][i]
                          ['name'],
                      nameEn: asyncSnapshot.data.documents[0].data['items'][i]
                          ['name_en'],
                      image: asyncSnapshot.data.documents[0].data['items'][i]
                          ['image'],
                      description: asyncSnapshot.data.documents[0].data['items']
                          [i]['description'],
                      price: asyncSnapshot.data.documents[0].data['items'][i]
                          ['price'],
                      imageID: asyncSnapshot.data.documents[0].data['items'][i]
                          ['productID'],
                      buyPrice: asyncSnapshot.data.documents[0].data['items'][i]
                          ['buyPrice'],
                      size: sizes,
                      priceOld: asyncSnapshot.data.documents[0].data['items'][i]
                          ['priceOld'],
                    ),
                  );
                }
              }
            } catch (e) {
              return Center(
                child: Container(
                    height: 200,
                    width: width * .9,
                    child: CircularProgressIndicator()),
              );
            }

            // print(height);
            return Container(
              child: listImages.length == 0
                  ? Center(child: Text("البضاعه المطلوبه غير متوفره"))
                  : Column(
                      children: [
                        Expanded(
                          child: GridView.builder(
                            shrinkWrap: true,
                            primary: false,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              mainAxisSpacing: 2.0,
                            ),
                            itemCount: listImages.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(2.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey[300],
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(15),
                                        ),
                                      ),
                                      child: InkWell(
                                        onTap: () async {
                                          await getQuantityForThis(
                                            listImages[index].imageID,
                                          );
                                          if (quantity <= 1) {
                                            errorToast(
                                                word("outOfStock", context));
                                          } else {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ShowItem(
                                                  image:
                                                      listImages[index].image,
                                                  name: listImages[index].name,
                                                  nameEn:
                                                      listImages[index].nameEn,
                                                  des: listImages[index]
                                                      .description,
                                                  price:
                                                      listImages[index].price,
                                                  imageID:
                                                      listImages[index].imageID,
                                                  buyPrice: listImages[index]
                                                      .buyPrice,
                                                  size: listImages[index].size,
                                                  priceOld: listImages[index]
                                                      .priceOld,
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: <Widget>[
                                              new Container(
                                                height: height < 700
                                                    ? height * 0.26
                                                    : height * 0.23,
                                                decoration: new BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8)),
                                                  image: new DecorationImage(
                                                    fit: BoxFit.fill,
                                                    image: new NetworkImage(
                                                        listImages[index]
                                                            .image),
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                    horizontal: 8.0),
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: AutoSizeText(
                                                  isEnglish
                                                      ? listImages[index].nameEn
                                                      : listImages[index].name,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.grey[600]),
                                                  maxLines: 1,
                                                ),
                                              ),
                                              Container(
                                                margin: EdgeInsets.symmetric(
                                                  horizontal: 8.0,
                                                ),
                                                width: double.infinity,
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Row(
                                                  mainAxisAlignment:
                                                      listImages[index]
                                                                  .priceOld ==
                                                              ""
                                                          ? MainAxisAlignment
                                                              .start
                                                          : MainAxisAlignment
                                                              .spaceAround,
                                                  children: [
                                                    listImages[index]
                                                                .priceOld ==
                                                            ""
                                                        ? Container()
                                                        : AutoSizeText.rich(
                                                            TextSpan(
                                                              children: <
                                                                  TextSpan>[
                                                                new TextSpan(
                                                                  text:
                                                                      '${listImages[index].priceOld} ${word("currancy", context)}',
                                                                  style:
                                                                      new TextStyle(
                                                                    fontSize:
                                                                        width *
                                                                            0.025,
                                                                    color: Colors
                                                                        .grey,
                                                                    decoration:
                                                                        TextDecoration
                                                                            .lineThrough,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            maxLines: 1,
                                                          ),
                                                    AutoSizeText(
                                                      "${listImages[index].price} ${word("currancy", context)}",
                                                      style: TextStyle(
                                                        color: Colors.teal,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: width * 0.05,
                                                      ),
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              InkWell(
                                                onTap: () async {
                                                  await getImagesToShowItems(
                                                    listImages[index].imageID,
                                                  );
                                                  await getQuantityForThis(
                                                    listImages[index].imageID,
                                                  );
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext
                                                            context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                      return Dialog(
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                            10.0,
                                                          ),
                                                        ),
                                                        child: Container(
                                                          height: listImages[
                                                                          index]
                                                                      .size
                                                                      .length ==
                                                                  0
                                                              ? height * 0.6
                                                              : height * 0.7,
                                                          width: width,
                                                          child: Stack(
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        SingleChildScrollView(
                                                                      child:
                                                                          Container(
                                                                        child:
                                                                            Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: <
                                                                              Widget>[
                                                                            imageCarouselItemShow(
                                                                              MediaQuery.of(context).size.height / 3,
                                                                            ),
                                                                            Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(
                                                                                isEnglish ? listImages[index].nameEn : listImages[index].name,
                                                                                style: TextStyle(
                                                                                  fontSize: 15,
                                                                                  fontFamily: "MainFont",
                                                                                ),
                                                                              ),
                                                                            ),
                                                                            quantity < 5
                                                                                ? Container(
                                                                                    margin: EdgeInsets.symmetric(horizontal: 16.0),
                                                                                    child: Text(
                                                                                      quantity == 1 ? word("lastOne", context) : quantity == 2 ? word("lastTwo", context) : word("almostOutOfStock", context),
                                                                                      textDirection: TextDirection.rtl,
                                                                                      style: TextStyle(color: Colors.red),
                                                                                    ),
                                                                                  )
                                                                                : Container(),
                                                                            Container(
                                                                              margin: EdgeInsets.symmetric(
                                                                                horizontal: 8.0,
                                                                              ),
                                                                              width: double.infinity,
                                                                              alignment: Alignment.bottomRight,
                                                                              child: Row(
                                                                                mainAxisAlignment: listImages[index].priceOld == "" ? MainAxisAlignment.start : MainAxisAlignment.spaceAround,
                                                                                children: [
                                                                                  listImages[index].priceOld == ""
                                                                                      ? Container()
                                                                                      : AutoSizeText.rich(
                                                                                          TextSpan(
                                                                                            children: <TextSpan>[
                                                                                              new TextSpan(
                                                                                                text: '${listImages[index].priceOld} ${word("currancy", context)}',
                                                                                                style: new TextStyle(
                                                                                                  fontSize: width * 0.025,
                                                                                                  color: Colors.grey,
                                                                                                  decoration: TextDecoration.lineThrough,
                                                                                                ),
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                          maxLines: 1,
                                                                                        ),
                                                                                  AutoSizeText(
                                                                                    "${listImages[index].price} ${word("currancy", context)}",
                                                                                    style: TextStyle(
                                                                                      color: Colors.teal,
                                                                                      fontWeight: FontWeight.bold,
                                                                                      fontSize: width * 0.05,
                                                                                    ),
                                                                                    maxLines: 1,
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                            listImages[index].size.length == 0
                                                                                ? Container()
                                                                                : Column(
                                                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                                                    children: [
                                                                                      Padding(
                                                                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                                                        child: Container(
                                                                                          width: double.infinity,
                                                                                          child: Text(
                                                                                            word("size", context),
                                                                                            textAlign: TextAlign.center,
                                                                                            style: TextStyle(fontSize: width * 0.04, fontFamily: "MainFont"),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Container(
                                                                                        height: 75,
                                                                                        alignment: Alignment.center,
                                                                                        margin: EdgeInsets.all(0.0),
                                                                                        padding: EdgeInsets.symmetric(vertical: 16.0),
                                                                                        child: ListView.builder(
                                                                                            scrollDirection: Axis.horizontal,
                                                                                            itemCount: listImages[index].size.length,
                                                                                            itemBuilder: (context, i) {
                                                                                              return Container(
                                                                                                width: MediaQuery.of(context).size.width * .18,
                                                                                                margin: EdgeInsets.symmetric(horizontal: 0.0),
                                                                                                decoration: BoxDecoration(
                                                                                                  shape: BoxShape.circle,
                                                                                                  color: sizeChose == listImages[index].size[i] ? Color(0xFFFF834F) : null,
                                                                                                  border: Border.all(color: Colors.grey[300]),
                                                                                                ),
                                                                                                child: InkWell(
                                                                                                  splashColor: Colors.transparent,
                                                                                                  highlightColor: Colors.transparent,
                                                                                                  onTap: () {
                                                                                                    setState(() {
                                                                                                      sizeChose = listImages[index].size[i];
                                                                                                    });
                                                                                                  },
                                                                                                  child: Padding(
                                                                                                    padding: const EdgeInsets.symmetric(horizontal: 0.0),
                                                                                                    child: Center(
                                                                                                      child: Text(
                                                                                                        listImages[index].size[i],
                                                                                                        style: TextStyle(color: sizeChose == listImages[index].size[i] ? Colors.white : null),
                                                                                                      ),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              );
                                                                                            }),
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  InkWell(
                                                                    onTap:
                                                                        () async {
                                                                      await fetchToMyCart();
                                                                      if (listImages[index]
                                                                              .size
                                                                              .length ==
                                                                          0) {
                                                                        int q =
                                                                            0;
                                                                        int id;

                                                                        for (var i =
                                                                                0;
                                                                            i < cart.length;
                                                                            i++) {
                                                                          if (cart[i].itemName == listImages[index].name &&
                                                                              cart[i].itemPrice == listImages[index].price &&
                                                                              cart[i].itemDes == listImages[index].description) {
                                                                            id =
                                                                                cart[i].id;
                                                                            q = int.parse(cart[i].quantity);
                                                                          }
                                                                        }
                                                                        q++;
                                                                        if (q ==
                                                                            1) {
                                                                          await DBHelper
                                                                              .insert(
                                                                            'cart',
                                                                            {
                                                                              'name': listImages[index].name,
                                                                              'price': listImages[index].price,
                                                                              'image': listImages[index].image,
                                                                              'des': listImages[index].description,
                                                                              'q': q.toString(),
                                                                              'buyPrice': listImages[index].buyPrice,
                                                                              'size': '',
                                                                              'productID': listImages[index].imageID,
                                                                              'nameEn': listImages[index].nameEn,
                                                                              'totalQ': quantity.toString(),
                                                                              'priceOld': listImages[index].priceOld,
                                                                            },
                                                                          ).whenComplete(() =>
                                                                              addCartToast("تم وضعها في سلتك"));
                                                                        } else {
                                                                          int totalQint =
                                                                              quantity;

                                                                          if (q >
                                                                              totalQint) {
                                                                            errorToast(word("outOfStock",
                                                                                context));
                                                                          } else {
                                                                            await DBHelper.updateData(
                                                                                    'cart',
                                                                                    {
                                                                                      'name': listImages[index].name,
                                                                                      'price': listImages[index].price,
                                                                                      'image': listImages[index].image,
                                                                                      'des': listImages[index].description,
                                                                                      'q': q.toString(),
                                                                                      'buyPrice': listImages[index].buyPrice,
                                                                                      'size': '',
                                                                                      'productID': listImages[index].imageID,
                                                                                      'nameEn': listImages[index].nameEn,
                                                                                      'totalQ': quantity.toString(),
                                                                                      'priceOld': listImages[index].priceOld,
                                                                                    },
                                                                                    id)
                                                                                .whenComplete(() => addCartToast("تم وضعها في سلتك"));
                                                                          }
                                                                        }
                                                                        Navigator.pop(
                                                                            context);
                                                                      } else {
                                                                        if (sizeChose ==
                                                                            '') {
                                                                          errorToast(
                                                                              "أختر المقاس");
                                                                        } else {
                                                                          int q =
                                                                              0;
                                                                          int id;
                                                                          for (var i = 0;
                                                                              i < cart.length;
                                                                              i++) {
                                                                            if (cart[i].itemName == listImages[index].name &&
                                                                                cart[i].itemPrice == listImages[index].price &&
                                                                                cart[i].itemDes == listImages[index].description &&
                                                                                cart[i].sizeChose == sizeChose) {
                                                                              id = cart[i].id;
                                                                              q = int.parse(cart[i].quantity);
                                                                            }
                                                                          }
                                                                          q++;
                                                                          if (q ==
                                                                              1) {
                                                                            await DBHelper
                                                                                .insert(
                                                                              'cart',
                                                                              {
                                                                                'name': listImages[index].name,
                                                                                'price': listImages[index].price,
                                                                                'image': listImages[index].image,
                                                                                'des': listImages[index].description,
                                                                                'q': q.toString(),
                                                                                'buyPrice': listImages[index].buyPrice,
                                                                                'size': sizeChose,
                                                                                'productID': listImages[index].imageID,
                                                                                'nameEn': listImages[index].nameEn,
                                                                                'totalQ': quantity.toString(),
                                                                                'priceOld': listImages[index].priceOld,
                                                                              },
                                                                            ).whenComplete(() =>
                                                                                addCartToast("تم وضعها في سلتك"));
                                                                          } else {
                                                                            int totalQint =
                                                                                quantity;

                                                                            if (q >
                                                                                totalQint) {
                                                                              errorToast(word("outOfStock", context));
                                                                            } else {
                                                                              await DBHelper.updateData(
                                                                                      'cart',
                                                                                      {
                                                                                        'name': listImages[index].name,
                                                                                        'price': listImages[index].price,
                                                                                        'image': listImages[index].image,
                                                                                        'des': listImages[index].description,
                                                                                        'q': q.toString(),
                                                                                        'buyPrice': listImages[index].buyPrice,
                                                                                        'size': sizeChose,
                                                                                        'productID': listImages[index].imageID,
                                                                                        'nameEn': listImages[index].nameEn,
                                                                                        'totalQ': quantity.toString(),
                                                                                        'priceOld': listImages[index].priceOld,
                                                                                      },
                                                                                      id)
                                                                                  .whenComplete(() => addCartToast("تم وضعها في سلتك"));
                                                                            }
                                                                          }
                                                                          Navigator.pop(
                                                                              context);
                                                                        }
                                                                      }
                                                                    },
                                                                    child:
                                                                        Container(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      width: double
                                                                          .infinity,
                                                                      height: height <
                                                                              700
                                                                          ? 40
                                                                          : 50,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.only(
                                                                          bottomLeft:
                                                                              Radius.circular(10),
                                                                          bottomRight:
                                                                              Radius.circular(10),
                                                                        ),
                                                                        color: Theme.of(context)
                                                                            .unselectedWidgetColor,
                                                                      ),
                                                                      child:
                                                                          Text(
                                                                        word(
                                                                            "addToCart",
                                                                            context),
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                15,
                                                                            fontFamily:
                                                                                "MainFont",
                                                                            color:
                                                                                Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              quantity <= 1
                                                                  ? Align(
                                                                      alignment:
                                                                          Alignment
                                                                              .center,
                                                                      child:
                                                                          Container(
                                                                        alignment:
                                                                            Alignment.center,
                                                                        height: MediaQuery.of(context)
                                                                            .size
                                                                            .height,
                                                                        width: double
                                                                            .infinity,
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          color:
                                                                              Colors.white70,
                                                                          borderRadius:
                                                                              BorderRadius.all(
                                                                            Radius.circular(8),
                                                                          ),
                                                                        ),
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Container(
                                                                            width:
                                                                                double.infinity,
                                                                            color:
                                                                                Colors.black,
                                                                            child:
                                                                                Padding(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              child: Text(
                                                                                word("outOfStock", context),
                                                                                textAlign: TextAlign.center,
                                                                                style: TextStyle(
                                                                                  color: Colors.white,
                                                                                  fontWeight: FontWeight.bold,
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : Container(),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                                  );
                                                },
                                                child: Container(
                                                  width: 150,
                                                  height: 35,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Colors.grey),
                                                    borderRadius:
                                                        BorderRadius.all(
                                                      Radius.circular(20),
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      word("fast", context),
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        fontSize: width * 0.03,
                                                        fontFamily: "MainFont",
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            );
          } else if (asyncSnapshot.hasError) {
            return Text('There was an error...');
          } else if (!asyncSnapshot.hasData) {
            return Center(
              child: Container(),
            );
          } else {
            return Center(
              child: Container(),
            );
          }
        },
      ),
    );
  }
}
