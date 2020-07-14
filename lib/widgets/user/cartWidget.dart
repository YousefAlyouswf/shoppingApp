import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/manager/manager/addItem.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/mainScreen/address_screen/address.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import '../widgets.dart';
import 'categoryScreen/showItem.dart';

class CartWidget extends StatefulWidget {
  @override
  _CartWidgetState createState() => _CartWidgetState();
}

class _CartWidgetState extends State<CartWidget> {
  double sumPrice = 0;
  double sumBuyPrice = 0;
  double eachPrice = 0;
  double eachBuyPrice = 0;
  int quantity = 0;
  double totalAfterTax = 0;

  bool deleteIcon = false;
  int tax = 0;
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
              nameEn: item['nameEn'],
              totalQuantity: item['totalQ'],
              preiceOld: item['priceOld'],
            ),
          )
          .toList();
    });

    for (var i = 0; i < cart.length; i++) {
      eachPrice =
          double.parse(cart[i].quantity) * double.parse(cart[i].itemPrice);
      eachBuyPrice =
          double.parse(cart[i].quantity) * double.parse(cart[i].buyPrice);
    }

    for (var i = 0; i < cart.length; i++) {
      sumPrice +=
          double.parse(cart[i].quantity) * double.parse(cart[i].itemPrice);
    }
    for (var i = 0; i < cart.length; i++) {
      sumBuyPrice +=
          double.parse(cart[i].quantity) * double.parse(cart[i].buyPrice);
    }
    quantity = 0;
    for (var i = 0; i < cart.length; i++) {
      quantity += int.parse(cart[i].quantity);
    }
    totalAfterTax = sumPrice;
    //* tax / 100 + sumPrice;
    // if (isDeliver) {
    //   totalAfterTax = sumPrice * tax / 100 + sumPrice + delivery;
    // } else {
    //   totalAfterTax = sumPrice * tax / 100 + sumPrice;
    // }
    // if (totalAfterTax == delivery) {
    //   totalAfterTax = 0.0;
    // }
  }

  emptyCartGoToCategory() {
    navIndex = 1;
    setState(() {});
  }

  double discount = 0.0;
  bool codeApllied = false;
  applyDiscount() async {
    bool isCorrect = false;
    print("Before--->>>>$totalAfterTax");
    if (!codeApllied) {
      await Firestore.instance.collection('discount').getDocuments().then((v) {
        v.documents.forEach((e) {
          if (e['code'] == discountController.text) {
            isCorrect = true;
            double x = double.parse(e['discount']);
            double beforeDiscount = totalAfterTax;
            setState(() {
              totalAfterTax = (x * totalAfterTax / 100 - totalAfterTax) * -1;
              discount = beforeDiscount - totalAfterTax;
            });
          }
          discountController.clear();
        });
      });
    } else {
      errorToast("لا يمكن أستخدام أكثر من كوبون في العملية الواحدة");
    }

    if (isCorrect) {
      addCartToast("تم تفعيل الخصم");
      setState(() {
        codeApllied = true;
      });
    } else {
      if (!codeApllied) {
        errorToast("الكوبون المدخل غير صحيح او منتهي الصلاحية");
      }
    }

    Navigator.pop(context);
  }

  getTaxAndDeliveryPrice() async {
    // await Firestore.instance.collection('app').getDocuments().then((value) {
    //   value.documents.forEach((element) {
    //     setState(() {
    //       tax = element['tax'];
    //     });
    //   });
    // });
    fetchToMyCart();
  }

  @override
  void initState() {
    super.initState();
    getTaxAndDeliveryPrice();
  }

  void updateCart(cart) {
    try {
      fetchToMyCart();
      FocusScope.of(context).requestFocus(FocusNode());
    } catch (e) {}
  }

  goToShowItem(
      String image,
      String itemName,
      String nameEn,
      String itemDes,
      String itemPrice,
      String productID,
      String buyPrice,
      List<String> size,
      String preiceOld) async {
    final cart = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ShowItem(
          image: image,
          name: itemName,
          nameEn: nameEn,
          des: itemDes,
          price: itemPrice,
          imageID: productID,
          buyPrice: buyPrice,
          size: size,
          priceOld: preiceOld,
        ),
      ),
    );
    updateCart(cart);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          header(context),
          invoiceTable(
            context,
            emptyCartGoToCategory,
          ),
          buttons(
            context,
            applyDiscount,
          ),
        ],
      ),
    );
  }

  bool showIcon = true;
  Widget invoiceTable(BuildContext context, Function emptyCartGoToCategory) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Container(
          child: cart.length == 0
              ? Center(
                  child: Container(
                      height: 300,
                      width: double.infinity,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            height: 100,
                            width: 100,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: AssetImage(
                                    'assets/images/logoBigTrans.png'),
                              ),
                            ),
                          ),
                          Text(
                            word("cart_empty", context),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 18),
                          ),
                          InkWell(
                            onTap: emptyCartGoToCategory,
                            child: Container(
                              height: 50,
                              width: 130,
                              decoration: BoxDecoration(
                                color: Color(0xFFFF834F),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(15),
                                ),
                              ),
                              child: Center(
                                  child: Text(
                                word("products", context),
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontFamily: "MainFont"),
                              )),
                            ),
                          )
                        ],
                      )),
                )
              : ScrollConfiguration(
                  behavior: MyBehavior(),
                  child: ListView.separated(
                    separatorBuilder: (context, i) {
                      return Container(
                        height: 0.5,
                        color: Colors.grey,
                      );
                    },
                    itemCount: cart.length,
                    itemBuilder: (context, i) {
                      eachPrice = double.parse(cart[i].quantity) *
                          double.parse(cart[i].itemPrice);
                      var item = cart[i].id.toString();
                      return Dismissible(
                        key: ValueKey(item),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: isEnglish
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          color: Colors.red,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FaIcon(
                              FontAwesomeIcons.trashAlt,
                              size: 50,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        onDismissed: (d) {
                          DBHelper.deleteItem("cart", cart[i].id);
                          fetchToMyCart();
                          cart.removeAt(i);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                InkWell(
                                  onTap: () {
                                    if (cart[i].sizeChose == "") {
                                      goToShowItem(
                                        cart[i].image,
                                        cart[i].itemName,
                                        cart[i].nameEn,
                                        cart[i].itemDes,
                                        cart[i].itemPrice,
                                        cart[i].productID,
                                        cart[i].buyPrice,
                                        [],
                                        cart[i].preiceOld,
                                      );
                                    } else {
                                      List<String> sizing = [];
                                      String compare = cart[i].sizeChose;
                                      if (compare == "XS" ||
                                          compare == "S" ||
                                          compare == "M" ||
                                          compare == "L" ||
                                          compare == "XL") {
                                        sizing = ['XS', 'S', 'M', 'L', 'XL'];
                                      } else {
                                        sizing = [
                                          '35',
                                          '36',
                                          '37',
                                          '38',
                                          '39',
                                          '40',
                                          '41',
                                          '42'
                                        ];
                                      }
                                      goToShowItem(
                                        cart[i].image,
                                        cart[i].itemName,
                                        cart[i].nameEn,
                                        cart[i].itemDes,
                                        cart[i].itemPrice,
                                        cart[i].productID,
                                        cart[i].buyPrice,
                                        sizing,
                                        cart[i].preiceOld,
                                      );
                                    }
                                  },
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    height:
                                        MediaQuery.of(context).size.width * 0.2,
                                    decoration: new BoxDecoration(
                                      shape: BoxShape.rectangle,
                                      image: new DecorationImage(
                                        fit: BoxFit.fill,
                                        image: new NetworkImage(cart[i].image),
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05,
                                ),
                                InkWell(
                                  onTap: () {
                                    if (cart[i].sizeChose == "") {
                                      goToShowItem(
                                        cart[i].image,
                                        cart[i].itemName,
                                        cart[i].nameEn,
                                        cart[i].itemDes,
                                        cart[i].itemPrice,
                                        cart[i].productID,
                                        cart[i].buyPrice,
                                        [],
                                        cart[i].preiceOld,
                                      );
                                    } else {
                                      List<String> sizing = [];
                                      String compare = cart[i].sizeChose;
                                      if (compare == "XS" ||
                                          compare == "S" ||
                                          compare == "M" ||
                                          compare == "L" ||
                                          compare == "XL") {
                                        sizing = ['XS', 'S', 'M', 'L', 'XL'];
                                      } else {
                                        sizing = [
                                          '35',
                                          '36',
                                          '37',
                                          '38',
                                          '39',
                                          '40',
                                          '41',
                                          '42'
                                        ];
                                      }
                                      goToShowItem(
                                        cart[i].image,
                                        cart[i].itemName,
                                        cart[i].nameEn,
                                        cart[i].itemDes,
                                        cart[i].itemPrice,
                                        cart[i].productID,
                                        cart[i].buyPrice,
                                        sizing,
                                        cart[i].preiceOld,
                                      );
                                    }
                                  },
                                  child: Column(
                                    children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width /
                                                3,
                                        child: AutoSizeText(
                                          isEnglish
                                              ? cart[i].nameEn
                                              : cart[i].itemName,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: "MainFont"),
                                          maxLines: 1,
                                        ),
                                      ),
                                      cart[i].sizeChose == ''
                                          ? Container()
                                          : Text(
                                              "(${cart[i].sizeChose}) ${word("size", context)}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w300,
                                              ),
                                            ),
                                      SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.01,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Container(
                                          child: Text(
                                            "${cart[i].itemPrice} ${word('currancy', context)}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "MainFont"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      decoration: BoxDecoration(
                                        // color: Colors.orange[100],
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(20),
                                        ),
                                      ),
                                      child: Table(
                                        columnWidths: {
                                          1: FractionColumnWidth(0.5)
                                        },
                                        border: TableBorder.symmetric(
                                            outside: BorderSide(
                                          color: Colors.grey[600],
                                        )),
                                        defaultVerticalAlignment:
                                            TableCellVerticalAlignment.middle,
                                        children: [
                                          TableRow(
                                            children: [
                                              Center(
                                                child: InkWell(
                                                  onTap: () {
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
                                                      fetchToMyCart();
                                                    }
                                                  },
                                                  child: Container(
                                                    child: Text(
                                                      "-",
                                                      style: TextStyle(
                                                          fontSize: 30,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Center(
                                                child: Text(
                                                  cart[i].quantity,
                                                  style:
                                                      TextStyle(fontSize: 20),
                                                ),
                                              ),
                                              Center(
                                                child: InkWell(
                                                  onTap: () {
                                                    int q = int.parse(
                                                        cart[i].quantity);
                                                    int totalQ = int.parse(
                                                      cart[i].totalQuantity,
                                                    );
                                                    if (q >= totalQ) {
                                                      errorToast(word(
                                                          "outOfStock",
                                                          context));
                                                    } else {
                                                      q++;
                                                    }

                                                    DBHelper.updateData(
                                                        "cart",
                                                        {
                                                          'q': q.toString(),
                                                        },
                                                        cart[i].id);
                                                    fetchToMyCart();
                                                  },
                                                  child: Container(
                                                    child: Text(
                                                      "+",
                                                      style: TextStyle(
                                                          fontSize: 25,
                                                          color: Colors.grey),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: FaIcon(
                                        FontAwesomeIcons.solidTrashAlt,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        deleteCategoryDialog(
                                          context,
                                          cart[i].itemName,
                                          cart[i].image,
                                          cart[i].id,
                                          fetchToMyCart,
                                        );
                                      },
                                    ),
                                  ],
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
    );
  }

  Widget header(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      alignment: isEnglish ? Alignment.centerLeft : Alignment.centerRight,
      child: Text(
        word("cart_header", context),
        style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w900, fontFamily: "MainFont"),
      ),
    );
  }

  TextEditingController discountController = TextEditingController();
  Widget buttons(
    BuildContext context,
    Function applyDiscount,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: cart.length == 0
          ? Container()
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                children: [
                  Center(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      decoration: BoxDecoration(
                          color: Theme.of(context).unselectedWidgetColor,
                          borderRadius: BorderRadius.all(Radius.circular(5))),
                      child: FlatButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Address(
                                  totalAfterTax: totalAfterTax.toString(),
                                  buyPrice: sumBuyPrice.toString(),
                                  price: sumPrice.toString(),
                                  discount: discount.toString(),
                                ),
                              ),
                            );
                          },
                          child: Text(
                            "$totalAfterTax ${word('currancy', context)}",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontFamily: "MainFont"),
                          )),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => Dialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Container(
                              height: 250.0,
                              width: 300.0,
                              child: Column(
                                children: <Widget>[
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        FaIcon(FontAwesomeIcons.gift),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          word("coupon", context),
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: "MainFont"),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Divider(),
                                  Expanded(
                                    child: Container(
                                      width:
                                          MediaQuery.of(context).size.width / 2,
                                      child: TextField(
                                        controller: discountController,
                                        textDirection: TextDirection.rtl,
                                        decoration: InputDecoration(
                                          hintText:
                                              word("type_coupon", context),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: InkWell(
                                      onTap: applyDiscount,
                                      child: Container(
                                        height: 50,
                                        alignment: Alignment.center,
                                        width: double.infinity,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(5)),
                                          color: Theme.of(context)
                                              .unselectedWidgetColor,
                                        ),
                                        child: Text(
                                          word("coupon_confirm", context),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                              child: Text(
                            word("coupon", context),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  deleteCategoryDialog(
    BuildContext context,
    String name,
    String image,
    int id,
    Function fetchMyCart,
  ) {
    showDialog(
        context: context,
        builder: (BuildContext context) => Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Container(
                height: 300.0,
                width: double.infinity,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                      child: Row(
                        children: [
                          FaIcon(
                            FontAwesomeIcons.trashAlt,
                            size: 30,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "حذف المنتج",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontFamily: "MainFont",
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 2,
                      color: Colors.grey[200],
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          "هل أنت متأكد من حذف $name؟",
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: "MainFont",
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          DBHelper.deleteItem("cart", id);
                          fetchMyCart();
                          Navigator.pop(context);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                            color: Theme.of(context).unselectedWidgetColor,
                          ),
                          child: Text(
                            "حذف",
                            style: TextStyle(
                                fontSize: 15,
                                fontFamily: "MainFont",
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 50,
                          alignment: Alignment.center,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            border: Border.all(),
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: Text(
                            "إلغاء",
                            style: TextStyle(
                              fontSize: 15,
                              fontFamily: "MainFont",
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
            ));
  }
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
