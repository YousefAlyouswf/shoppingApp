import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:shop_app/widgets/widgets2.dart';

class ShowItem extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  final String image;
  final String name;
  final String des;
  final String price;
  final Function fetchMyCart;
  final String imageID;
  final String buyPrice;
  final List size;
  const ShowItem(
      {Key key,
      this.onThemeChanged,
      this.changeLangauge,
      this.image,
      this.name,
      this.des,
      this.price,
      this.fetchMyCart,
      this.imageID,
      this.buyPrice,
      this.size})
      : super(key: key);
  @override
  _ShowItemState createState() => _ShowItemState();
}

class _ShowItemState extends State<ShowItem> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: appBar(),
        drawer: drawer(context, widget.onThemeChanged,
            changeLangauge: widget.changeLangauge),
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      imageOnTapCustomer(
                          NetworkImage(widget.image), widget.imageID);
                    },
                    child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          height: MediaQuery.of(context).size.width / 3,
                          width: MediaQuery.of(context).size.width,
                          child: StreamBuilder(
                              stream: Firestore.instance
                                  .collection("images")
                                  .where("imageID", isEqualTo: widget.imageID)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Text("Loading");
                                } else {
                                  return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: snapshot.data.documents[0]
                                          .data['images'].length,
                                      itemBuilder: (context, i) {
                                        String listImage = snapshot.data
                                            .documents[0].data['images'][i];

                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            height: 100,
                                            width: 100,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(15)),
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: NetworkImage(
                                                  listImage,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      });
                                }
                              }),
                        )),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "${widget.price} ر.س",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.all(16.0),
                      //   child: Text(
                      //     name,
                      //     style: TextStyle(
                      //         fontWeight: FontWeight.bold,

                      //         fontSize: 22),
                      //   ),
                      // ),
                      IconButton(
                        icon: Icon(
                          Icons.add_shopping_cart,
                          size: 40,
                          color: Colors.green,
                        ),
                        onPressed: () async {
                          await widget.fetchMyCart();
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
                                'buyPrice': widget.buyPrice
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
                                  'buyPrice': widget.buyPrice
                                },
                                id);
                          }
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                  Text("المقاس"),
                  Container(
                    height: 33,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: widget.size.length,
                        itemBuilder: (context, i) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              border: Border.all(),
                            ),
                            child: InkWell(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Center(
                                  child: Text(widget.size[i]),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      width: double.infinity,
                      height: 170,
                      child: SingleChildScrollView(
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
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
                                  style: TextStyle(fontWeight: FontWeight.bold),
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
            imageViewBottomSheet(closeImpageOntap, onPageChanged),
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

  void onPageChanged(int index) {
    currentIndex = 0;
    setState(() {
      currentIndex = index;
    });
  }
}
