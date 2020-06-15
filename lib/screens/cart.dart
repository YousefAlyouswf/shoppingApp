import 'package:flutter/material.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/address.dart';

class Cart extends StatefulWidget {
  final Function onThemeChanged;

  const Cart({Key key, this.onThemeChanged}) : super(key: key);
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  List<ItemShow> cart = [];
  double sumPrice = 0;
  double eachPrice = 0;
  Future<void> fetchMyCart() async {
    sumPrice = 0;
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
            ),
          )
          .toList();
    });

    for (var i = 0; i < cart.length; i++) {
      eachPrice =
          double.parse(cart[i].quantity) * double.parse(cart[i].itemPrice);
    }

    for (var i = 0; i < cart.length; i++) {
      sumPrice +=
          double.parse(cart[i].quantity) * double.parse(cart[i].itemPrice);
    }
  }

  bool deleteIcon = false;
  @override
  void initState() {
    fetchMyCart();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "سلة التسوق",
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                ),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("${cart.length} المحتويات"),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Center(
              child: Container(
                height: 2,
                width: MediaQuery.of(context).size.width * 0.9,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      border: Border.all()),
                  // height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      eachPrice = double.parse(cart[i].quantity) *
                          double.parse(cart[i].itemPrice);
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Dismissible(
                          key: Key(cart[i].id.toString()),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            color: Colors.red,
                            child: Icon(
                              Icons.delete,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (d) {
                            DBHelper.deleteItem("cart", cart[i].id);
                            fetchMyCart();
                          },
                          child: Container(
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 70,
                                      height: 70,
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: new DecorationImage(
                                          fit: BoxFit.fill,
                                          image:
                                              new NetworkImage(cart[i].image),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      height: 130,
                                      width: 170,
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            cart[i].itemName,
                                            style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w700),
                                          ),
                                          Text(
                                            "$eachPrice ر.س",
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      children: [
                                        Visibility(
                                          visible: deleteIcon,
                                          child: Container(
                                            child: IconButton(
                                                icon: Icon(
                                                  Icons.delete,
                                                  color: Colors.red,
                                                ),
                                                onPressed: () {
                                                  DBHelper.deleteItem(
                                                      "cart", cart[i].id);
                                                  fetchMyCart();
                                                }),
                                          ),
                                        ),
                                        Container(
                                            height: 120,
                                            alignment: Alignment.bottomCenter,
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  width: 40,
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      int q = int.parse(
                                                          cart[i].quantity);

                                                      if (q == 1) {
                                                      } else {
                                                        q--;
                                                        DBHelper.updateData(
                                                            "cart",
                                                            {
                                                              'q': q.toString(),
                                                            },
                                                            cart[i].id);
                                                        fetchMyCart();
                                                      }
                                                    },
                                                    child: Text(
                                                      "-",
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  cart[i].quantity,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                                SizedBox(
                                                  width: 40,
                                                  child: FlatButton(
                                                    onPressed: () {
                                                      int q = int.parse(
                                                          cart[i].quantity);
                                                      q++;

                                                      DBHelper.updateData(
                                                          "cart",
                                                          {
                                                            'q': q.toString(),
                                                          },
                                                          cart[i].id);
                                                      fetchMyCart();
                                                    },
                                                    child: Text("+"),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Center(
                                  child: Container(
                                    height: 1,
                                    width:
                                        MediaQuery.of(context).size.width * 0.9,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                color: Colors.blue,
                child: FlatButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Address(
                                amount: sumPrice.toString(),
                                onThemeChanged: widget.onThemeChanged)),
                      );
                    },
                    icon: Icon(
                      Icons.payment,
                      color: Colors.white,
                    ),
                    label: Text(
                      "$sumPrice ر.س  شراء",
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: Colors.white, fontSize: 22),
                    )),
              ),
            ),
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Center(
                child: Text(
                  "الرجوع للتسوق",
                  style: TextStyle(decoration: TextDecoration.underline),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            )
          ],
        ),
      ),
    );
  }
}
