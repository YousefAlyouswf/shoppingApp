import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shop_app/models/listHirzontalImage.dart';

List<ListHirezontalImage> listImages;
Widget listViewHorznintal(Function selectCategory) {
  return Container(
    height: 160,
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('categories').snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          int listLength =
              asyncSnapshot.data.documents[0].data['collection'].length;
          listImages = List();
          for (var i = 0; i < listLength; i++) {
            listImages.add(ListHirezontalImage(
              asyncSnapshot.data.documents[0].data['collection'][i]['name'],
              asyncSnapshot.data.documents[0].data['collection'][i]['image'],
            ));
          }

          return Container(
            color: Colors.black12,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listImages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        selectCategory(listImages[index].name);
                      },
                      child: Column(
                        children: <Widget>[
                          new Container(
                            width: 100,
                            height: 100,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image:
                                    new NetworkImage(listImages[index].image),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(listImages[index].name),
                        ],
                      ),
                    ),
                  );
                }),
          );
        } else if (asyncSnapshot.hasError) {
          return Text('There was an error...');
        } else {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    ),
  );
}

bool isViewBottom = false;
NetworkImage imageBottomSheet;
Container imageViewBottomSheet(closeImpageOntap) {
  return isViewBottom
      ? Container(
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 40,
                        color: Colors.black,
                      ),
                      onPressed: closeImpageOntap)),
              Expanded(
                child: PhotoView(
                  filterQuality: FilterQuality.high,
                  minScale: 0.4,
                  backgroundDecoration: BoxDecoration(color: Colors.white),
                  imageProvider: imageBottomSheet,
                ),
              ),
            ],
          ),
        )
      : Container();
}

String catgoryNameCustomer = "";
Widget subCatgoryCustomer(Function imageOnTapCustomer) {
  List<ListHirezontalImage> listImages;

  return Container(
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('subCategory')
          .where('category', isEqualTo: catgoryNameCustomer)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          try {
            int listLength =
                asyncSnapshot.data.documents[0].data['items'].length;
            listImages = List();
            for (var i = 0; i < listLength; i++) {
              listImages.add(ListHirezontalImage(
                asyncSnapshot.data.documents[0].data['items'][i]['name'],
                asyncSnapshot.data.documents[0].data['items'][i]['image'],
                description: asyncSnapshot.data.documents[0].data['items'][i]
                    ['description'],
                price: asyncSnapshot.data.documents[0].data['items'][i]
                    ['price'],
              ));
            }
          } catch (e) {
            return Center(
              child: Container(
                height: 100,
                width: MediaQuery.of(context).size.width * .9,
                child: Text(
                  "متجر الدباس يحتوي على جميع الماركات من الشنط والأحذية",
                  textDirection: TextDirection.rtl,
                ),
              ),
            );
          }

          return Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Text(
                      catgoryNameCustomer,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                      ),
                      itemCount: listImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            showtheBottomSheet(
                                context,
                                listImages[index].image,
                                listImages[index].name,
                                listImages[index].description,
                                listImages[index].price,
                                imageOnTapCustomer);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: <Widget>[
                                new Container(
                                  decoration: new BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(
                                          listImages[index].image),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 45,
                                    color: Colors.black45,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "R.S. ${listImages[index].price}",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          listImages[index].name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        } else if (asyncSnapshot.hasError) {
          return Text('There was an error...');
        } else if (!asyncSnapshot.hasData) {
          return Text("data");
        } else {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    ),
  );
}

showtheBottomSheet(BuildContext context, String image, String name, String des,
    String price, Function imageOnTapCustomer) {
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      imageOnTapCustomer(NetworkImage(image));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.width / 3,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                              image,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "R.S. $price",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: 200,
                          child: SingleChildScrollView(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Text(
                                      "وصف المنتج",
                                      textDirection: TextDirection.rtl,
                                    ),
                                    Text(
                                      des,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart,
                            size: 40,
                            color: Colors.red,
                          ),
                          onPressed: () {})
                    ],
                  ),
                ],
              ),
            ),
          ));
}
