import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/models/itemShow.dart';

import 'package:shop_app/widgets/widgets.dart';
import 'package:shop_app/widgets/widgets2.dart';

class HomePage extends StatefulWidget {
  final Function onThemeChanged;

  const HomePage({Key key, this.onThemeChanged}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    getAllimagesFromFireStore();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double imageShowSize = height / 3;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        drawer: drawer(context, widget.onThemeChanged),
        body: Stack(
          children: [
            CustomScrollView(
              slivers: <Widget>[
                SliverAppBar(
                  iconTheme: new IconThemeData(color: Colors.white),
                  title: Text(
                    'Shop App',
                    style: TextStyle(color: Colors.white),
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
                      listViewHorznintal(selectCategory),
                      Expanded(child: subCatgoryCustomer(imageOnTapCustomer)),
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
    showtheBottomSheet(context, itemShow[i].image, itemShow[i].itemName,
        itemShow[i].itemDes, itemShow[i].itemPrice, imageOnTapCustomer);
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

        if (listLength <= 4) {
          for (var i = 0; i < listLength; i++) {
            networkImage.add(NetworkImage(value[i].image));
          }
          itemShow = value;
        } else {
          for (var i = listLength - 4; i < listLength; i++) {
            networkImage.add(NetworkImage(value[i].image));
            itemShow.add(value[i]);
          }
        }

        setState(() {});
        networkImage2 = networkImage;
      });
    } catch (e) {}
  }
}
