import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meet_network_image/meet_network_image.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/user/homeWidget.dart';
import 'package:shop_app/widgets/widgets.dart';

class ShowItem extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  final String image;
  final String name;
  final String nameEn;
  final String des;
  final String price;
  final String imageID;
  final String buyPrice;
  final List size;

  final String priceOld;
  const ShowItem({
    Key key,
    this.onThemeChanged,
    this.changeLangauge,
    this.image,
    this.name,
    this.nameEn,
    this.des,
    this.price,
    this.imageID,
    this.buyPrice,
    this.size,
    this.priceOld,
  }) : super(key: key);
  @override
  _ShowItemState createState() => _ShowItemState();
}

class _ShowItemState extends State<ShowItem>
    with TickerProviderStateMixin<ShowItem> {
  ScrollController controller;

  String sizeChose = '';
  int quantity;
  @override
  void initState() {
    getImagesToShowItems();
    super.initState();

    fetchToMyCart();
    getQuantityForThis();
  }

  getQuantityForThis() async {
    await Firestore.instance
        .collection('quantityItem')
        .where('id', isEqualTo: widget.imageID)
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).unselectedWidgetColor,
      child: SafeArea(
        child: Scaffold(
          body: quantity == null
              ? Container(
                  child: Image.network(
                    "https://i.ya-webdesign.com/images/shopping-transparent-animated-gif.gif",
                    fit: BoxFit.fill,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        controller: controller,
                        slivers: <Widget>[
                          SliverAppBar(
                            expandedHeight:
                                MediaQuery.of(context).size.height / 2,
                            flexibleSpace: FlexibleSpaceBar(
                              background: networkImage2 == null
                                  ? Center(
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : imageCarouselItemShow(
                                      MediaQuery.of(context).size.height / 2),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(40),
                                  topLeft: Radius.circular(40),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        isEnglish ? widget.nameEn : widget.name,
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          fontFamily: "MainFont",
                                        ),
                                      ),
                                    ),
                                    quantity < 5
                                        ? Container(
                                            child: Text(
                                              quantity == 1
                                                  ? word("lastOne", context)
                                                  : quantity == 2
                                                      ? word("lastTwo", context)
                                                      : word("almostOutOfStock",
                                                          context),
                                              textDirection: TextDirection.rtl,
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    widget.priceOld != ""
                                        ? Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            alignment: Alignment.centerRight,
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                    text:
                                                        '${widget.priceOld} ${word("currancy", context)}',
                                                    style: new TextStyle(
                                                      color: Colors.grey,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      width: double.infinity,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        "${widget.price} ${word("currancy", context)}",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                    widget.size.length == 0
                                        ? Container()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  word("size", context),
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      fontFamily: "MainFont"),
                                                ),
                                              ),
                                              Container(
                                                height: 75,
                                                alignment: Alignment.center,
                                                margin: EdgeInsets.all(8.0),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        widget.size.length,
                                                    itemBuilder: (context, i) {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .2,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: sizeChose ==
                                                                  widget.size[i]
                                                              ? Color(
                                                                  0xFFFF834F)
                                                              : null,
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey[300]),
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              sizeChose = widget
                                                                  .size[i];
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Center(
                                                              child: Text(
                                                                widget.size[i],
                                                                style: TextStyle(
                                                                    color: sizeChose ==
                                                                            widget.size[
                                                                                i]
                                                                        ? Colors
                                                                            .white
                                                                        : null),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                    Divider(
                                      thickness: 3,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Text(
                                                    word("itemDes", context),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 20,
                                                        fontFamily: "MainFont"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Text(
                                                  widget.des,
                                                  textDirection:
                                                      TextDirection.rtl,
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).unselectedWidgetColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        height: 50,
                        width: double.infinity,
                        child: FlatButton(
                          child: Text(
                            word("addToCart", context),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            await fetchToMyCart();
                            if (widget.size.length == 0) {
                              int q = 0;
                              int id;

                              for (var i = 0; i < cart.length; i++) {
                                if (cart[i].itemName == widget.name &&
                                    cart[i].itemPrice == widget.price &&
                                    cart[i].itemDes == widget.des) {
                                  id = cart[i].id;
                                  q = int.parse(cart[i].quantity);
                                }
                              }
                              q++;
                              if (q == 1) {
                                await DBHelper.insert(
                                  'cart',
                                  {
                                    'name': widget.name,
                                    'price': widget.price,
                                    'image': widget.image,
                                    'des': widget.des,
                                    'q': q.toString(),
                                    'buyPrice': widget.buyPrice,
                                    'size': '',
                                    'productID': widget.imageID,
                                    'nameEn': widget.nameEn,
                                    'totalQ': quantity.toString(),
                                    'priceOld': widget.priceOld,
                                  },
                                ).whenComplete(
                                    () => addCartToast("تم وضعها في سلتك"));
                              } else {
                                int totalQint = quantity;

                                if (q > totalQint) {
                                  errorToast(word("outOfStock", context));
                                } else {
                                  await DBHelper.updateData(
                                          'cart',
                                          {
                                            'name': widget.name,
                                            'price': widget.price,
                                            'image': widget.image,
                                            'des': widget.des,
                                            'q': q.toString(),
                                            'buyPrice': widget.buyPrice,
                                            'size': '',
                                            'productID': widget.imageID,
                                            'nameEn': widget.nameEn,
                                            'totalQ': quantity.toString(),
                                            'priceOld': widget.priceOld,
                                          },
                                          id)
                                      .whenComplete(() =>
                                          addCartToast("تم وضعها في سلتك"));
                                }
                              }
                              Navigator.pop(context);
                            } else {
                              if (sizeChose == '') {
                                errorToast("أختر المقاس");
                              } else {
                                int q = 0;
                                int id;
                                for (var i = 0; i < cart.length; i++) {
                                  if (cart[i].itemName == widget.name &&
                                      cart[i].itemPrice == widget.price &&
                                      cart[i].itemDes == widget.des &&
                                      cart[i].sizeChose == sizeChose) {
                                    id = cart[i].id;
                                    q = int.parse(cart[i].quantity);
                                  }
                                }
                                q++;
                                if (q == 1) {
                                  await DBHelper.insert(
                                    'cart',
                                    {
                                      'name': widget.name,
                                      'price': widget.price,
                                      'image': widget.image,
                                      'des': widget.des,
                                      'q': q.toString(),
                                      'buyPrice': widget.buyPrice,
                                      'size': sizeChose,
                                      'productID': widget.imageID,
                                      'nameEn': widget.nameEn,
                                      'totalQ': quantity.toString(),
                                      'priceOld': widget.priceOld,
                                    },
                                  ).whenComplete(
                                      () => addCartToast("تم وضعها في سلتك"));
                                } else {
                                  int totalQint = quantity;

                                  if (q > totalQint) {
                                    errorToast(word("outOfStock", context));
                                  } else {
                                    await DBHelper.updateData(
                                            'cart',
                                            {
                                              'name': widget.name,
                                              'price': widget.price,
                                              'image': widget.image,
                                              'des': widget.des,
                                              'q': q.toString(),
                                              'buyPrice': widget.buyPrice,
                                              'size': sizeChose,
                                              'productID': widget.imageID,
                                              'nameEn': widget.nameEn,
                                              'totalQ': quantity.toString(),
                                              'priceOld': widget.priceOld,
                                            },
                                            id)
                                        .whenComplete(() =>
                                            addCartToast("تم وضعها في سلتك"));
                                  }
                                }
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
        ),
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
            child: Carousel(
              boxFit: BoxFit.cover,
              images: networkItemShow,
              animationCurve: Curves.easeInExpo,
              animationDuration: Duration(seconds: 1),
              autoplay: true,
              autoplayDuration: Duration(seconds: 5),
              indicatorBgPadding: 10,
              dotBgColor: Colors.transparent,
              dotColor: Colors.white,
              dotIncreasedColor: Theme.of(context).unselectedWidgetColor,
            ),
          );
  }

  List<ItemShow> itemShow = new List();
  getAllimagesFromFireStore() async {
    try {
      itemShow = new List();
      networkImage = new List();
      await FirestoreFunctions().getAllImages().then((value) {
        int listLength = value.length;
        for (var i = 0; i < listLength; i++) {
          networkImage.add(
            MeetNetworkImage(
              imageUrl: value[i].image,
              loadingBuilder: (context) => Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, e) => Center(
                child: Text('Error appear!'),
              ),
            ),
          );
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

  getImagesToShowItems() async {
    networkItemShow = [];
    await Firestore.instance
        .collection("images")
        .where("imageID", isEqualTo: widget.imageID)
        .getDocuments()
        .then(
          (value) => {
            value.documents.forEach(
              (e) {
                for (var i = 0; i < e['images'].length; i++) {
                  setState(() {});
                  networkItemShow.add(NetworkImage(e['images'][i]));
                }
              },
            )
          },
        );
  }

  double sumPrice = 0;
  double sumBuyPrice = 0;
  double eachPrice = 0;
  double eachBuyPrice = 0;
  double totalAfterTax = 0;

  bool deleteIcon = false;
  int tax = 0;
  int delivery = 0;
  bool isDeliver = true;
  List<ItemShow> cart = [];

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
  }
}

List<NetworkImage> networkItemShow = [];
List<ItemShow> cartToCheck = new List();
