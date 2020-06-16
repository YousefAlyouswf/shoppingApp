import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:shop_app/widgets/widgets2.dart';
import 'cart.dart';

class HomePage extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  const HomePage({Key key, this.onThemeChanged, this.changeLangauge})
      : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController controller;
  @override
  void initState() {
    super.initState();
    controller = ScrollController();
    getAppInfoFireBase();
    getAllimagesFromFireStore();
    controller.addListener(_scrollListener);
  }

  double showFloatingBtn = 0.0;
  _scrollListener() {
    setState(() {
      showFloatingBtn = controller.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double imageShowSize = height / 3;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        drawer: drawer(context, widget.onThemeChanged,
            changeLangauge: widget.changeLangauge),
        floatingActionButton: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              showFloatingBtn > 300
                  ? FloatingActionButton(
                      elevation: 8,
                      heroTag: "btn2",
                      backgroundColor: Colors.green,
                      onPressed: () {
                        controller.animateTo(0.0,
                            duration: Duration(seconds: 1), curve: Curves.ease);
                      },
                      child: Icon(
                        Icons.arrow_upward,
                        color: Colors.white,
                        size: 30,
                      ),
                    )
                  : Container(),
              SizedBox(
                width: MediaQuery.of(context).size.width * .6,
              ),
              FloatingActionButton(
                heroTag: "btn1",
                backgroundColor: Colors.blue,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Cart(
                          onThemeChanged: widget.onThemeChanged,
                          changeLangauge: widget.changeLangauge),
                    ),
                  );
                },
                child: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        body: Stack(
          children: [
            CustomScrollView(
              controller: controller,
              slivers: <Widget>[
                SliverAppBar(
                  iconTheme: new IconThemeData(color: Colors.white),
                  title: Text(
                    "الدباس",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w900),
                  ),
                  backgroundColor: Colors.black38,
                  floating: false,
                  pinned: true,
                  elevation: 8,
                  expandedHeight: MediaQuery.of(context).size.height / 3,
                  flexibleSpace: FlexibleSpaceBar(
                    background: networkImage2 == null
                        ? Center(
                            child: Container(
                              height: 100,
                              width: 100,
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : imageCarousel(imageShowSize, imageOnTap),
                  ),
                ),
                SliverFillRemaining(
                  child: Column(
                    children: [
                      listViewHorznintal(selectCategory, controller),
                      Expanded(
                          child: subCatgoryCustomer(
                              imageOnTapCustomer, fetchMyCart)),
                    ],
                  ),
                ),
              ],
            ),
            imageViewBottomSheet(closeImpageOntap),
          ],
        ),
      ),
    );
  }

  selectCategory(String name) {
    setState(() {});
    catgoryNameCustomer = name;
  }

  imageOnTap(int i) {
    print(itemShow[i].itemName);
    showtheBottomSheet(
        context,
        itemShow[i].image,
        itemShow[i].itemName,
        itemShow[i].itemDes,
        itemShow[i].itemPrice,
        imageOnTapCustomer,
        fetchMyCart);
    setState(() {});
  }

  imageOnTapCustomer(NetworkImage networkImage) {
    isViewBottom = true;
    imageBottomSheet = networkImage;
    Navigator.pop(context);
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
      return null;
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
}
