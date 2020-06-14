import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';

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
                      
                      Expanded(child: subCatgoryCustomer()),
                    ],
                  ),
                ),
              ],
            ),imageView(closeImpageOntap),
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
    isView = true;
    imageNetwork = networkImage2[i];
    setState(() {});
  }

  closeImpageOntap() {
    isView = false;
    setState(() {});
  }

  Future<bool> _onBackPressed() {
    if (isView) {
      return closeImpageOntap();
    } else {
      return null;
    }
  }

  getAllimagesFromFireStore() async {
    try {
      networkImage = new List();
      await FirestoreFunctions().getAllImages().then((value) {
        int listLength = value.length;

        if (listLength <= 4) {
          for (var i = 0; i < listLength; i++) {
            networkImage.add(NetworkImage(value[i]));
          }
        } else {
          for (var i = listLength - 4; i < listLength; i++) {
            networkImage.add(NetworkImage(value[i]));
          }
        }

        setState(() {});
        networkImage2 = networkImage;
      });
    } catch (e) {}
  }
}
