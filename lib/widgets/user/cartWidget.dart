import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/address.dart';
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
  return Column(
    children: [
      Align(
        alignment: Alignment.centerRight,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            isEnglish ? english[11] : arabic[11],
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
          ),
        ),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(isEnglish
                ? "$quantity ${english[12]}"
                : "$quantity ${arabic[12]}"),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              child: FlatButton(
                onPressed: showDeleteIcon,
                child: Text(
                  isEnglish ? english[13] : arabic[13],
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ),
          ),
        ],
      )
    ],
  );
}

Widget invoiceTable(Function fetchMyCart) {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20)),
            border: Border.all()),
        child: items.length == 0
            ? Container(
                child: Center(
                  child: Text("السلة فارغة"),
                ),
              )
            : ListView.builder(
                itemCount: cart.length,
                itemBuilder: (context, i) {
                  eachPrice = double.parse(cart[i].quantity) *
                      double.parse(cart[i].itemPrice);
                  return InkWell(
                    onTap: () {
                      Fluttertoast.showToast(
                          msg: isEnglish ? english[14] : arabic[14],
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.grey,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    },
                    child: Padding(
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
                                        image: new NetworkImage(cart[i].image),
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
                                          items[i],
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        Text(
                                          isEnglish
                                              ? "$eachPrice ${english[15]}"
                                              : "$eachPrice ${arabic[15]}",
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
                                                    style:
                                                        TextStyle(fontSize: 20),
                                                  ),
                                                ),
                                              ),
                                              Text(
                                                cart[i].quantity,
                                                style: TextStyle(fontSize: 20),
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
                    ),
                  );
                },
              ),
      ),
    ),
  );
}

Widget taxText() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Container(
      width: double.infinity,
      child: Text(
        "سعر الضريبة $tax%",
        textDirection: TextDirection.rtl,
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
    BuildContext context, Function onThemeChanged, Function changeLangauge) {
  return Column(
    children: [
      SizedBox(
        height: 20,
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
            isEnglish ? english[17] : arabic[17],
            style: TextStyle(decoration: TextDecoration.underline),
          ),
        ),
      ),
      SizedBox(
        height: 30,
      )
    ],
  );
}
