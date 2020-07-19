import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/models/listHirzontalImage.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';

import '../../widgets.dart';
import 'showItem.dart';

class CategoryWidget extends StatefulWidget {
  final Function heartBeat;

  const CategoryWidget({Key key, this.heartBeat}) : super(key: key);
  @override
  _CategoryWidgetState createState() => _CategoryWidgetState();
}

String categoryNameSelected = '';
double height;
double width;

class _CategoryWidgetState extends State<CategoryWidget>
    with SingleTickerProviderStateMixin {
  switchBetweenCategory(String name, int i) {
    setState(() {
      categoryNameSelected = name;
      for (var j = 0; j < 20; j++) {
        if (j == i) {
          selected[j] = true;
        } else {
          selected[j] = false;
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

  ScrollController _controller;

  @override
  void initState() {
    super.initState();

    fetchToMyCart();
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      print("TOP");
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      print("BOTTPM");
    }
  }

  bool iLikeIt = false;
  @override
  Widget build(BuildContext context) {
// Scroll to first selected item
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Container(
      child: Column(
        children: [
          headerCatgory(switchBetweenCategory),
          seprater(),
          subCollection(
            context,
            setFirstElemntInSubCollection,
          ),
        ],
      ),
    );
  }

  Widget headerCatgory(Function switchBetweenCategory) {
    catgoryEnglish = [];
    return Container(
      decoration: BoxDecoration(),
      height: 50,
      width: double.infinity,
      child: StreamBuilder(
        stream: Firestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading");

          return ListView.builder(
            controller: _controller,
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data.documents[0].data['collection'].length,
            itemBuilder: (context, i) {
              String categoryName = isEnglish
                  ? snapshot.data.documents[0].data['collection'][i]['en_name']
                  : snapshot.data.documents[0].data['collection'][i]['name'];
              String choseCategory =
                  snapshot.data.documents[0].data['collection'][i]['name'];
              return Container(
                width: 100,
                decoration: BoxDecoration(
                  //   borderRadius: BorderRadius.all(Radius.circular(5)),
                  border: Border(
                      bottom: BorderSide(
                    width: 5,
                    color: selected[i] ? Color(0xFFFF834F) : Colors.transparent,
                  )),
                ),
                child: InkWell(
                  onTap: () {
                    switchBetweenCategory(choseCategory, i);
                  },
                  child: Center(
                    child: Text(
                      categoryName,
                      style: TextStyle(
                          color: selected[i] ? Colors.teal : Colors.grey[600],
                          fontFamily: "MainFont"),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget subCollection(
    BuildContext context,
    Function setFirstElemntInSubCollection,
  ) {
    List<ListHirezontalImage> listImages;
    return Expanded(
      child: Container(
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('subCategory')
              .where('category', isEqualTo: categoryNameSelected)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
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
                    if (asyncSnapshot.data.documents[0].data['items'][i]['size']
                            .length ==
                        8) {
                      for (var j = 35;
                          j <
                              asyncSnapshot.data.documents[0]
                                      .data['items'][i]['size'].length +
                                  35;
                          j++) {
                        var value = asyncSnapshot.data.documents[0]
                            .data['items'][i]['size'][j.toString()];
                        if (value) {
                          sizes.add(j.toString());
                        }
                      }
                    } else {
                      List<String> sizeWord = ['XS', 'S', 'M', 'L', 'XL'];
                      for (var j = 0; j < 5; j++) {
                        var value = asyncSnapshot.data.documents[0]
                            .data['items'][i]['size'][sizeWord[j]];
                        if (value) {
                          sizes.add(sizeWord[j]);
                        }
                      }
                    }
                  }

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
                // listImages
                //     .sort((b, a) => a.totalQuantity.compareTo(b.totalQuantity));
              } catch (e) {
                setFirstElemntInSubCollection();
                return Center(
                  child: Container(
                      height: 200,
                      width: width * .9,
                      child: CircularProgressIndicator()),
                );
              }
////-------------------------------------- UI START HETE
///////-------------------------------------- UI START HETE
///////-------------------------------------- UI START HETE
///////-------------------------------------- UI START HETE
///////-------------------------------------- UI START HETE
              // print(height);
              return Container(
                child: Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        primary: false,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.5,
                          mainAxisSpacing: 2.0,
                        ),
                        itemCount: listImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          // int totalQuantity =
                          //     int.parse(listImages[index].totalQuantity);
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
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ShowItem(
                                            image: listImages[index].image,
                                            name: listImages[index].name,
                                            nameEn: listImages[index].nameEn,
                                            des: listImages[index].description,
                                            price: listImages[index].price,
                                            imageID: listImages[index].imageID,
                                            buyPrice:
                                                listImages[index].buyPrice,
                                            size: listImages[index].size,
                                            priceOld:
                                                listImages[index].priceOld,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: <Widget>[
                                          new Container(
                                            height: height < 700
                                                ? height * 0.35
                                                : height * 0.33,
                                            decoration: new BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                              image: new DecorationImage(
                                                fit: BoxFit.fitHeight,
                                                image: new NetworkImage(
                                                    listImages[index].image),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            alignment: Alignment.bottomRight,
                                            child: AutoSizeText(
                                              isEnglish
                                                  ? listImages[index].nameEn
                                                  : listImages[index].name,
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.grey[600]),
                                              maxLines: 1,
                                            ),
                                          ),
                                          Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 8.0,
                                            ),
                                            width: double.infinity,
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  listImages[index].priceOld ==
                                                          ""
                                                      ? MainAxisAlignment.start
                                                      : MainAxisAlignment
                                                          .spaceAround,
                                              children: [
                                                listImages[index].priceOld == ""
                                                    ? Container()
                                                    : AutoSizeText.rich(
                                                        TextSpan(
                                                          children: <TextSpan>[
                                                            new TextSpan(
                                                              text:
                                                                  '${listImages[index].priceOld} ${word("currancy", context)}',
                                                              style:
                                                                  new TextStyle(
                                                                fontSize:
                                                                    width *
                                                                        0.025,
                                                                color:
                                                                    Colors.grey,
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
                                                    fontWeight: FontWeight.bold,
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
                                                builder:
                                                    (BuildContext context) =>
                                                        StatefulBuilder(builder:
                                                            (context,
                                                                setState) {
                                                  return Dialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                        10.0,
                                                      ),
                                                    ),
                                                    child: Container(
                                                      height: listImages[index]
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
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: <
                                                                          Widget>[
                                                                        imageCarouselItemShow(
                                                                          MediaQuery.of(context).size.height /
                                                                              3,
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Text(
                                                                            isEnglish
                                                                                ? listImages[index].nameEn
                                                                                : listImages[index].name,
                                                                            style:
                                                                                TextStyle(
                                                                              fontSize: 15,
                                                                              fontFamily: "MainFont",
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        quantity <
                                                                                5
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
                                                                          margin:
                                                                              EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                8.0,
                                                                          ),
                                                                          width:
                                                                              double.infinity,
                                                                          alignment:
                                                                              Alignment.bottomRight,
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment: listImages[index].priceOld == ""
                                                                                ? MainAxisAlignment.start
                                                                                : MainAxisAlignment.spaceAround,
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
                                                                        listImages[index].size.length ==
                                                                                0
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
                                                                  if (listImages[
                                                                              index]
                                                                          .size
                                                                          .length ==
                                                                      0) {
                                                                    int q = 0;
                                                                    int id;

                                                                    for (var i =
                                                                            0;
                                                                        i < cart.length;
                                                                        i++) {
                                                                      if (cart[i].itemName == listImages[index].name &&
                                                                          cart[i].itemPrice ==
                                                                              listImages[index]
                                                                                  .price &&
                                                                          cart[i].itemDes ==
                                                                              listImages[index].description) {
                                                                        id = cart[i]
                                                                            .id;
                                                                        q = int.parse(
                                                                            cart[i].quantity);
                                                                      }
                                                                    }
                                                                    q++;
                                                                    if (q ==
                                                                        1) {
                                                                      await DBHelper
                                                                          .insert(
                                                                        'cart',
                                                                        {
                                                                          'name':
                                                                              listImages[index].name,
                                                                          'price':
                                                                              listImages[index].price,
                                                                          'image':
                                                                              listImages[index].image,
                                                                          'des':
                                                                              listImages[index].description,
                                                                          'q': q
                                                                              .toString(),
                                                                          'buyPrice':
                                                                              listImages[index].buyPrice,
                                                                          'size':
                                                                              '',
                                                                          'productID':
                                                                              listImages[index].imageID,
                                                                          'nameEn':
                                                                              listImages[index].nameEn,
                                                                          'totalQ':
                                                                              quantity.toString(),
                                                                          'priceOld':
                                                                              listImages[index].priceOld,
                                                                        },
                                                                      ).whenComplete(() =>
                                                                          addCartToast(
                                                                              "تم وضعها في سلتك"));
                                                                    } else {
                                                                      int totalQint =
                                                                          quantity;

                                                                      if (q >
                                                                          totalQint) {
                                                                        errorToast(word(
                                                                            "outOfStock",
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
                                                                      int q = 0;
                                                                      int id;
                                                                      for (var i =
                                                                              0;
                                                                          i < cart.length;
                                                                          i++) {
                                                                        if (cart[i].itemName == listImages[index].name &&
                                                                            cart[i].itemPrice ==
                                                                                listImages[index].price &&
                                                                            cart[i].itemDes == listImages[index].description &&
                                                                            cart[i].sizeChose == sizeChose) {
                                                                          id = cart[i]
                                                                              .id;
                                                                          q = int.parse(
                                                                              cart[i].quantity);
                                                                        }
                                                                      }
                                                                      q++;
                                                                      if (q ==
                                                                          1) {
                                                                        await DBHelper
                                                                            .insert(
                                                                          'cart',
                                                                          {
                                                                            'name':
                                                                                listImages[index].name,
                                                                            'price':
                                                                                listImages[index].price,
                                                                            'image':
                                                                                listImages[index].image,
                                                                            'des':
                                                                                listImages[index].description,
                                                                            'q':
                                                                                q.toString(),
                                                                            'buyPrice':
                                                                                listImages[index].buyPrice,
                                                                            'size':
                                                                                sizeChose,
                                                                            'productID':
                                                                                listImages[index].imageID,
                                                                            'nameEn':
                                                                                listImages[index].nameEn,
                                                                            'totalQ':
                                                                                quantity.toString(),
                                                                            'priceOld':
                                                                                listImages[index].priceOld,
                                                                          },
                                                                        ).whenComplete(() =>
                                                                            addCartToast("تم وضعها في سلتك"));
                                                                      } else {
                                                                        int totalQint =
                                                                            quantity;

                                                                        if (q >
                                                                            totalQint) {
                                                                          errorToast(word(
                                                                              "outOfStock",
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
                                                                  height:
                                                                      height <
                                                                              700
                                                                          ? 40
                                                                          : 50,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .only(
                                                                      bottomLeft:
                                                                          Radius.circular(
                                                                              10),
                                                                      bottomRight:
                                                                          Radius.circular(
                                                                              10),
                                                                    ),
                                                                    color: Theme.of(
                                                                            context)
                                                                        .unselectedWidgetColor,
                                                                  ),
                                                                  child: Text(
                                                                    word(
                                                                        "addToCart",
                                                                        context),
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            15,
                                                                        fontFamily:
                                                                            "MainFont",
                                                                        color: Colors
                                                                            .white),
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
                                                                        Alignment
                                                                            .center,
                                                                    height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height,
                                                                    width: double
                                                                        .infinity,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .white70,
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius.circular(
                                                                            8),
                                                                      ),
                                                                    ),
                                                                    child:
                                                                        Padding(
                                                                      padding:
                                                                          const EdgeInsets.all(
                                                                              8.0),
                                                                      child:
                                                                          Container(
                                                                        width: double
                                                                            .infinity,
                                                                        color: Colors
                                                                            .black38,
                                                                        child:
                                                                            Padding(
                                                                          padding:
                                                                              const EdgeInsets.all(8.0),
                                                                          child:
                                                                              Text(
                                                                            word("outOfStock",
                                                                                context),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
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
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(20),
                                                ),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "تسوق سريع",
                                                  textAlign: TextAlign.center,
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
                              Container(
                                padding: EdgeInsets.all(16.0),
                                height: 50,
                                width: 50,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      iLikeIt = !iLikeIt;
                                    });
                                  },
                                  child: FlareActor(
                                    'assets/like.flr',
                                    alignment: Alignment.center,
                                    fit: BoxFit.fitWidth,
                                    animation:
                                        iLikeIt ? "Favorite" : "Unfavorite",
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
      ),
    );
    ////-------------------------------------- UI END HERE
    ///////-------------------------------------- UI END HERE
    ///////-------------------------------------- UI END HERE
    ///////-------------------------------------- UI END HERE
    ///////-------------------------------------- UI END HERE
  }

  double buttonSize = 40;
  String productIDRotate = '';
  String sizeChose = '';
  int quantity;
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

  List<String> sizes = [];

  String sizeChoseCatgetory = '';
  Future<int> addToMyCartFromCategory(
    BuildContext context,
    List size,
    String name,
    String price,
    String des,
    String image,
    String imageID,
    String buyPrice,
    String nameEn,
    // String totalQ,
    String priceOld,
  ) async {
    int q = 0;
    if (size.length == 0) {
      await fetchToMyCart();

      int id;
      for (var i = 0; i < cart.length; i++) {
        if (cart[i].itemName == name &&
            cart[i].itemPrice == price &&
            cart[i].itemDes == des) {
          id = cart[i].id;
          q = int.parse(cart[i].quantity);
        }
      }
      q++;
      if (q == 1) {
        await DBHelper.insert(
          'cart',
          {
            'name': name,
            'price': price,
            'image': image,
            'des': des,
            'q': q.toString(),
            'buyPrice': buyPrice,
            'size': '',
            'productID': imageID,
            'nameEn': nameEn,
            // 'totalQ': totalQ,
            'priceOld': priceOld,
          },
        ).whenComplete(() => addCartToast("تم وضعها في سلتك"));
      } else {
        int totalQint = 45;
        //int.parse(totalQ);

        if (q > totalQint) {
          errorToast(word("outOfStock", context));
        } else {
          await DBHelper.updateData(
                  'cart',
                  {
                    'name': name,
                    'price': price,
                    'image': image,
                    'des': des,
                    'q': q.toString(),
                    'buyPrice': buyPrice,
                    'size': '',
                    'productID': imageID,
                    'nameEn': nameEn,
                    // 'totalQ': totalQ,
                    'priceOld': priceOld,
                  },
                  id)
              .whenComplete(() => addCartToast("تم وضعها في سلتك"));
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                height: 400.0,
                width: 300.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Text(
                            word("sizes", context),
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: "MainFont",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 3,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          height: 200,
                          alignment: Alignment.center,
                          margin: EdgeInsets.all(8.0),
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: ScrollConfiguration(
                            behavior: MyBehavior(),
                            child: GridView.builder(
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 1.5,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: size.length,
                              itemBuilder: (context, i) {
                                return Container(
                                  margin: EdgeInsets.symmetric(horizontal: 8.0),
                                  decoration: BoxDecoration(
                                      color: sizeChoseCatgetory == size[i]
                                          ? Theme.of(context)
                                              .unselectedWidgetColor
                                          : Colors.white,
                                      border: Border.all(),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(15))),
                                  child: InkWell(
                                    splashColor: Colors.transparent,
                                    onTap: () {
                                      setState(() {
                                        sizeChoseCatgetory = size[i];
                                      });
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      child: Center(
                                        child: Text(
                                          size[i],
                                          style: TextStyle(
                                            color: sizeChoseCatgetory != size[i]
                                                ? Colors.grey
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () async {
                          if (sizeChoseCatgetory == '') {
                            errorToast("أختر المقاس");
                          } else {
                            await fetchToMyCart();

                            int id;
                            for (var i = 0; i < cart.length; i++) {
                              if (cart[i].itemName == name &&
                                  cart[i].itemPrice == price &&
                                  cart[i].itemDes == des &&
                                  cart[i].sizeChose == sizeChoseCatgetory) {
                                id = cart[i].id;
                                q = int.parse(cart[i].quantity);
                              }
                            }
                            q++;
                            setState(() {});
                            if (q == 1) {
                              await DBHelper.insert(
                                'cart',
                                {
                                  'name': name,
                                  'price': price,
                                  'image': image,
                                  'des': des,
                                  'q': q.toString(),
                                  'buyPrice': buyPrice,
                                  'size': sizeChoseCatgetory,
                                  'productID': imageID,
                                  'nameEn': nameEn,
                                  //'totalQ': totalQ,
                                  'priceOld': priceOld,
                                },
                              ).whenComplete(
                                  () => addCartToast("تم وضعها في سلتك"));
                            } else {
                              int totalQint = 45;
                              //int.parse(totalQ);

                              if (q >= totalQint) {
                                errorToast(word("outOfStock", context));
                              } else {
                                await DBHelper.updateData(
                                        'cart',
                                        {
                                          'name': name,
                                          'price': price,
                                          'image': image,
                                          'des': des,
                                          'q': q.toString(),
                                          'buyPrice': buyPrice,
                                          'size': sizeChoseCatgetory,
                                          'productID': imageID,
                                          'nameEn': nameEn,
                                          // 'totalQ': totalQ,
                                          'priceOld': priceOld,
                                        },
                                        id)
                                    .whenComplete(
                                        () => addCartToast("تم وضعها في سلتك"));
                              }
                            }
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Theme.of(context).unselectedWidgetColor,
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              word("addToCart", context),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 18.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              word("exit", context),
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    }
    return q;
  }
}

List<String> catgoryArabic = [];
List<String> catgoryEnglish = [];

List<bool> selected = List.generate(20, (i) => false);

Widget seprater() {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8.0),
    height: 1,
    width: double.infinity,
    color: Colors.grey[300],
  );
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
