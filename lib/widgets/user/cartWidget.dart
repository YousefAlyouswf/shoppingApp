import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/mainScreen/address.dart';
import '../langauge.dart';
import '../widgets.dart';

List<ItemShow> cart = [];
double sumPrice = 0;
double sumBuyPrice = 0;
double eachPrice = 0;
double eachBuyPrice = 0;
int quantity = 0;
double totalAfterTax = 0;

bool deleteIcon = false;
int tax = 0;
int delivery = 0;
bool isDeliver = true;

Widget header() {
  return Align(
    alignment: Alignment.centerRight,
    child: Padding(
      padding: const EdgeInsets.only(right: 32.0, top: 40.0),
      child: Text(
        isEnglish ? english[11] : arabic[11],
        textDirection: TextDirection.rtl,
        style: TextStyle(
            fontSize: 25, fontWeight: FontWeight.w900, fontFamily: "MainFont"),
      ),
    ),
  );
}

Widget invoiceTable(Function fetchMyCart, Function emptyCartGoToCategory) {
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
                              image:
                                  AssetImage('assets/images/logoBigTrans.png'),
                            ),
                          ),
                        ),
                        Text(
                          isEnglish ? english[37] : arabic[37],
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
                              isEnglish ? english[38] : arabic[38],
                              textDirection: TextDirection.rtl,
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
                    return Stack(
                      children: [
                        InkWell(
                          onTap: () {},
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
                              color: Colors.white,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 100,
                                      height: 100,
                                      decoration: new BoxDecoration(
                                        shape: BoxShape.rectangle,
                                        image: new DecorationImage(
                                          fit: BoxFit.fill,
                                          image:
                                              new NetworkImage(cart[i].image),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 20,
                                    ),
                                    Column(
                                      children: [
                                        Text(
                                          cart[i].itemName,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: "MainFont"),
                                        ),
                                        cart[i].sizeChose == ''
                                            ? Container()
                                            : Text(
                                                "(${cart[i].sizeChose}) ${isEnglish ? english[39] : arabic[39]}",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                        Container(
                                          width: 100,
                                          child: Table(
                                            columnWidths: {
                                              1: FractionColumnWidth(0.5)
                                            },
                                            border: TableBorder.all(
                                                color: Colors.grey[300]),
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
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
                                                                'q': q
                                                                    .toString(),
                                                              },
                                                              cart[i].id);
                                                          fetchMyCart();
                                                        }
                                                      },
                                                      child: Container(
                                                        child: Text(
                                                          "-",
                                                          style: TextStyle(
                                                              fontSize: 30,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: Text(
                                                      cart[i].quantity,
                                                      style: TextStyle(
                                                          fontSize: 20),
                                                    ),
                                                  ),
                                                  Center(
                                                    child: InkWell(
                                                      onTap: () {
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
                                                      child: Container(
                                                        child: Text(
                                                          "+",
                                                          style: TextStyle(
                                                              fontSize: 25,
                                                              color:
                                                                  Colors.grey),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Spacer(),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Container(
                                        child: Text(
                                          isEnglish
                                              ? "${cart[i].itemPrice} ${english[15]}"
                                              : "${cart[i].itemPrice} ${arabic[15]}",
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(
                                              color: Colors.teal,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "MainFont"),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                deleteCategoryDialog(
                                  context,
                                  cart[i].itemName,
                                  cart[i].image,
                                  cart[i].id,
                                  fetchMyCart,
                                );
                              }),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    ),
  );
}

TextEditingController discountController = TextEditingController();
Widget buttons(
  BuildContext context,
  Function onThemeChanged,
  Function changeLangauge,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: cart.length == 0
        ? Container()
        : Column(
            children: [
              Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.7,
                  decoration: BoxDecoration(
                      color: Color(0xFFFF834F),
                      borderRadius: BorderRadius.all(Radius.circular(5))),
                  child: FlatButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Address(
                              totalAfterTax: totalAfterTax.toString(),
                              onThemeChanged: onThemeChanged,
                              changeLangauge: changeLangauge,
                              buyPrice: sumBuyPrice.toString(),
                              price: sumPrice.toString(),
                              isDeliver: isDeliver,
                            ),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.payment,
                        color: Colors.white,
                      ),
                      label: Text(
                        isEnglish
                            ? "$totalAfterTax ${english[16]}"
                            : "$totalAfterTax ${arabic[16]}",
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontFamily: "MainFont"),
                      )),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Container(
                    alignment: isEnglish
                        ? Alignment.bottomLeft
                        : Alignment.bottomRight,
                    child: Text(
                      isEnglish
                          ? "${english[40]} $tax%"
                          : "${arabic[40]} $tax%",
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) => Dialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Container(
                            height: 150.0,
                            width: 300.0,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Container(
                                  width: MediaQuery.of(context).size.width / 2,
                                  child: TextField(
                                    controller: discountController,
                                    textDirection: TextDirection.rtl,
                                    decoration: InputDecoration(
                                      hintText: "أدخل كود الخصم",
                                    ),
                                  ),
                                ),
                                StatefulBuilder(builder: (BuildContext context,
                                    StateSetter setState) {
                                  return FlatButton(
                                    onPressed: () async {
                                      bool isCorrect = false;
                                      print(discountController.text);
                                      await Firestore.instance
                                          .collection('discount')
                                          .getDocuments()
                                          .then((v) {
                                        v.documents.forEach((e) {
                                          if (e['code'] ==
                                              discountController.text) {
                                            isCorrect = true;
                                            double x =
                                                double.parse(e['discount']);
                                            totalAfterTax =
                                                (x * totalAfterTax / 100 -
                                                        totalAfterTax) *
                                                    -1;
                                          }
                                        });
                                      });
                                      if (isCorrect) {
                                        infoToast("تم تفعيل الخصم");
                                      } else {
                                        errorToast("الكود غير صحيح");
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      'تفعيل',
                                      style: TextStyle(
                                          color: Color(0xFFFF834F),
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    child: Card(
                      color: Colors.grey[300],
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("كوبون خصم"),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
  );
}

class MyBehavior extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
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
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: Text(
                      name,
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(15),
                      ),
                      image: DecorationImage(
                        image: NetworkImage(image),
                      ),
                    ),
                  ),
                  FlatButton.icon(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.purple,
                    ),
                    onPressed: () {
                      DBHelper.deleteItem("cart", id);
                      fetchMyCart();
                      Navigator.pop(context);
                    },
                    label: Text(
                      'حذف',
                      style: TextStyle(
                          color: Colors.purple,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ));
}
