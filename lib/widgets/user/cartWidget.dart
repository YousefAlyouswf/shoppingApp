import 'package:flutter/material.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/mainScreen/address.dart';
import 'package:translator/translator.dart';
import '../widgets.dart';

List<ItemShow> cart = [];
double sumPrice = 0;
double sumBuyPrice = 0;
double eachPrice = 0;
double eachBuyPrice = 0;
int quantity = 0;
double totalAfterTax = 0;
List<String> englishItem = [];
List<String> arabicItem = [];
List<String> items = [];
bool deleteIcon = false;
int tax = 0;
int delivery = 0;
bool isDeliver = true;
final translator = new GoogleTranslator();

Widget header(Function showDeleteIcon) {
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

Widget invoiceTable(Function fetchMyCart) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        child: items.length == 0
            ? Container(
                child: Center(
                  child: Text("السلة فارغة"),
                ),
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
                                          items[i],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              fontFamily: "MainFont"),
                                        ),
                                        cart[i].sizeChose == ''
                                            ? Container()
                                            : Text(
                                                "(${cart[i].sizeChose}) المقاس",
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
                                  items[i],
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

Widget delvierText(Function chooseDeliver) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          child: Text(
            "بدون توصيل",
            textDirection: TextDirection.rtl,
            style: TextStyle(
                fontWeight: isDeliver ? FontWeight.normal : FontWeight.w800),
          ),
        ),
        Container(
          height: 10,
          child: Switch(
            value: isDeliver,
            onChanged: chooseDeliver,
            activeTrackColor: Colors.green[500],
            activeColor: Colors.green[100],
            inactiveTrackColor: Colors.grey[500],
            inactiveThumbColor: Colors.grey[100],
          ),
        ),
        Container(
          child: Text(
            "سعر التوصيل $delivery",
            textDirection: TextDirection.rtl,
            style: TextStyle(
                fontWeight: !isDeliver ? FontWeight.normal : FontWeight.w800),
          ),
        ),
      ],
    ),
  );
}

Widget buttons(
  BuildContext context,
  Function onThemeChanged,
  Function changeLangauge,
  Function changeDelvierValue,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            InkWell(
              onTap: changeDelvierValue,
              child: Container(
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                    border: Border.all(
                      color: !isDeliver ? Colors.grey[400] : Colors.teal[600],
                    ),
                    color: !isDeliver ? Colors.grey[300] : Colors.teal,
                    borderRadius: BorderRadius.all(Radius.circular(50))),
                child: Text(
                  !isDeliver ? "بدون توصيل" : "مع التوصيل",
                  style: TextStyle(
                      color: isDeliver ? Colors.white : Colors.black,
                      fontFamily: "MainFont"),
                ),
              ),
            ),
          ],
        ),
        Container(
            width: double.infinity,
            alignment: Alignment.bottomRight,
            child: Text(
              "السعر شامل الضريبة*",
            ))
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
                        image: DecorationImage(image: NetworkImage(image))),
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
