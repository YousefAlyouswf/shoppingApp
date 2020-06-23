import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/user/cartWidget.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:shop_app/widgets/widgets2.dart';

class ShowItem extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  final String image;
  final String name;
  final String des;
  final String price;
  final Function fetchToMyCart;
  final String imageID;
  final String buyPrice;
  final List size;
  final String totalQuantity;
  const ShowItem({
    Key key,
    this.onThemeChanged,
    this.changeLangauge,
    this.image,
    this.name,
    this.des,
    this.price,
    this.fetchToMyCart,
    this.imageID,
    this.buyPrice,
    this.size,
    this.totalQuantity,
  }) : super(key: key);
  @override
  _ShowItemState createState() => _ShowItemState();
}

class _ShowItemState extends State<ShowItem>
    with TickerProviderStateMixin<ShowItem> {
  ScrollController controller;

  String sizeChose = '';
  int quantity = 100;
  @override
  void initState() {
    getImagesToShowItems();
    super.initState();
    setState(() {
      quantity = int.parse(widget.totalQuantity);
    });
  }

  @override
  Widget build(BuildContext context) {
    print(widget.imageID);
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                controller: controller,
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height / 2,
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
                              MediaQuery.of(context).size.height / 2, null),
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
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            width: double.infinity,
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${widget.name}",
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          quantity < 5
                              ? Container(
                                  child: Text(
                                    quantity == 1
                                        ? "أخر قطعه لدينا"
                                        : quantity == 2
                                            ? "أخر قطعتين لدينا"
                                            : "أخر $quantity قطع متوفرة",
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(color: Colors.red),
                                  ),
                                )
                              : Container(),
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.0),
                            width: double.infinity,
                            alignment: Alignment.centerRight,
                            child: Text(
                              "${widget.price} ر.س",
                              textDirection: TextDirection.rtl,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal),
                            ),
                          ),
                          widget.size.length == 0
                              ? Container()
                              : Column(
                                  children: [
                                    Text(
                                      "المقاس",
                                      style: TextStyle(fontSize: 22),
                                    ),
                                    Container(
                                      height: 75,
                                      alignment: Alignment.center,
                                      margin: EdgeInsets.all(8.0),
                                      padding:
                                          EdgeInsets.symmetric(vertical: 8.0),
                                      decoration: BoxDecoration(
                                          border: Border.all(),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: widget.size.length,
                                          itemBuilder: (context, i) {
                                            return Container(
                                              margin: EdgeInsets.symmetric(
                                                  horizontal: 8.0),
                                              decoration: BoxDecoration(
                                                color:
                                                    sizeChose == widget.size[i]
                                                        ? Color(0xFFFF834F)
                                                        : null,
                                                border: Border.all(),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    sizeChose = widget.size[i];
                                                  });
                                                },
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                          .symmetric(
                                                      horizontal: 16.0),
                                                  child: Center(
                                                    child: Text(widget.size[i]),
                                                  ),
                                                ),
                                              ),
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Container(
                              width: double.infinity,
                              height: MediaQuery.of(context).size.height / 3,
                              child: SingleChildScrollView(
                                child: Card(
                                  elevation: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Center(
                                          child: Text(
                                            "وصف المنتج",
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                        Text(
                                          widget.des,
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                color: Colors.teal,
                height: 50,
                width: double.infinity,
                child: FlatButton(
                  child: Text(
                    "أضف إلى سلة التسوق",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  onPressed: () async {
                    if (widget.size.length == 0) {
                      await widget.fetchToMyCart();
                      int q = 0;
                      int id;
                      for (var i = 0; i < cartToCheck.length; i++) {
                        if (cartToCheck[i].itemName == widget.name &&
                            cartToCheck[i].itemPrice == widget.price &&
                            cartToCheck[i].itemDes == widget.des) {
                          id = cartToCheck[i].id;
                          q = int.parse(cartToCheck[i].quantity);
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
                          },
                        ).whenComplete(() => addCartToast("تم وضعها في سلتك"));
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
                                },
                                id)
                            .whenComplete(
                                () => addCartToast("تم وضعها في سلتك"));
                      }
                      Navigator.pop(context);
                    } else {
                      if (sizeChose == '') {
                        errorToast("أختر المقاس");
                      } else {
                        await widget.fetchToMyCart();
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
                            },
                          ).whenComplete(
                              () => addCartToast("تم وضعها في سلتك"));
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
                                  },
                                  id)
                              .whenComplete(
                                  () => addCartToast("تم وضعها في سلتك"));
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
    );
  }

  selectCategory(String name) {
    setState(() {});
    catgoryNameCustomer = name;
  }

  imageOnTapCustomer(NetworkImage networkImage, String imageID) {
    isViewBottom = true;
    imageBottomSheet = networkImage;
    idImage = imageID;
    currentIndex = 0;
    setState(() {});
  }

  closeImpageOntap() {
    isViewBottom = false;
    setState(() {});
  }

  Future<bool> _onBackPressed() {
    if (isViewBottom) {
      return closeImpageOntap();
    } else {
      Navigator.pop(context);
    }
    return null;
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

  void onPageChanged(int index) {
    currentIndex = 0;
    setState(() {
      currentIndex = index;
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
    print(networkItemShow);
  }
}

List<NetworkImage> networkItemShow = [];
Widget imageCarouselItemShow(double height, Function imageOnTap) {
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
            onImageTap: imageOnTap,
            indicatorBgPadding: 10,
            dotBgColor: Colors.transparent,
            dotColor: Colors.black,
          ),
        );
}
