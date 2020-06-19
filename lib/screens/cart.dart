import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/user/cartWidget.dart';
import 'package:shop_app/widgets/widgets.dart';

class Cart extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  const Cart({Key key, this.onThemeChanged, this.changeLangauge})
      : super(key: key);
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {
  Future<void> fetchMyCart() async {
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
                buyPrice: item['buyPrice']),
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
    if (!isEnglish) {
      arabicItem = [];
      items = [];
      for (var i = 0; i < cart.length; i++) {
        arabicItem.add(cart[i].itemName);
      }
      setState(() {});
      items = arabicItem;
    } else {
      englishItem = [];
      items = [];
      for (var i = 0; i < cart.length; i++) {
        await translator
            .translate(cart[i].itemName, from: 'ar', to: 'en')
            .then((s) {
          englishItem.add(s);
        });
      }
      setState(() {});
      items = englishItem;
    }

    if (isDeliver) {
      totalAfterTax = sumPrice * tax / 100 + sumPrice + delivery;
    } else {
      totalAfterTax = sumPrice * tax / 100 + sumPrice;
    }
    if (totalAfterTax == delivery) {
      totalAfterTax = 0.0;
    }
  }

  getTaxAndDeliveryPrice() async {
    await Firestore.instance.collection('app').getDocuments().then((value) {
      value.documents.forEach((element) {
        setState(() {
          tax = element['tax'];
          delivery = element['delivery'];
        });
      });
    });
    fetchMyCart();
  }

  @override
  void initState() {
    super.initState();
    getTaxAndDeliveryPrice();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: drawer(context, widget.onThemeChanged,
          changeLangauge: widget.changeLangauge, fetchMyCart: fetchMyCart),
      body: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header(showDeleteIcon),
            invoiceTable(fetchMyCart),
            taxText(),
            delvierText(chooseDeliver),
            buttons(context, widget.onThemeChanged, widget.changeLangauge),
          ],
        ),
      ),
    );
  }

  showDeleteIcon() {
    setState(() {
      deleteIcon = !deleteIcon;
    });
  }

  chooseDeliver(value) {
    setState(() {
      isDeliver = value;
    });
    fetchMyCart();
  }
}
