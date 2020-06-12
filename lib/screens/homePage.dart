import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shop_app/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double imageShowSize = height / 3;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: appBar(),
        drawer: drawer(context),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      imageCarousel(imageShowSize, imageOnTap),
                    ],
                  ),
                ),
              ],
            ),
            imageView(closeImpageOntap),
          ],
        ),
      ),
    );
  }

  imageOnTap(int i) {
    isView = true;
    imageAsset = images[i];
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
}
