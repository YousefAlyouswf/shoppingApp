import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/listHirzontalImage.dart';
import 'package:shop_app/screens/showItem.dart';
import 'package:shop_app/widgets/user/cartWidget.dart';

import '../langauge.dart';
import '../widgets.dart';
import '../widgets2.dart';

List<String> catgoryArabic = [];
List<String> catgoryEnglish = [];


List<bool> selected = List.generate(20, (i) => false);
Widget headerCatgory(Function selectedSection, Function categorySelectedColor, Function translateCategory) {
catgoryEnglish = [];
  return Padding(
    padding: const EdgeInsets.only(top: 48.0, left: 8.0, right: 8.0),
    child: Container(
      decoration: BoxDecoration(),
      height: 50,
      width: double.infinity,
      child: StreamBuilder(
        stream: Firestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading");
          for (var i = 0; i < snapshot.data.documents[0].data['collection'].length; i++) {
             String name =
                    snapshot.data.documents[0].data['collection'][i]['name'];
          
          }
         
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.documents[0].data['collection'].length,
              itemBuilder: (context, i) {
                String name =
                    snapshot.data.documents[0].data['collection'][i]['name'];
               
              
                return Container(
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color:
                          selected[i] ? Color(0xFFFF834F) : Colors.transparent,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      selectedSection(name);
                      categorySelectedColor(i);
                    },
                    child: Center(
                      child: Text(
                        name,
                        style: TextStyle(
                            color: selected[i] ? Colors.teal : Colors.grey[600],
                            fontFamily: "MainFont"),
                      ),
                    ),
                  ),
                );
              });
        },
      ),
    ),
  );
}

Widget seprater() {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8.0),
    height: 1,
    width: double.infinity,
    color: Colors.grey[300],
  );
}

String categoryNameSelected = '';
List<String> sizes = [];
Widget subCollection(
  BuildContext context,
  Function setFirstElemntInSubCollection,
  Function fetchMyCart,
) {
  List<ListHirezontalImage> listImages;
  return Expanded(
    child: Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('subCategory')
            .where('category', isEqualTo: categoryNameSelected)
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            try {
              int listLength =
                  asyncSnapshot.data.documents[0].data['items'].length;
              listImages = List();

              for (var i = 0; i < listLength; i++) {
                sizes = [];

                if (asyncSnapshot
                        .data.documents[0].data['items'][i]['size'].length !=
                    0) {
                  sizes = [];
                  if (asyncSnapshot
                          .data.documents[0].data['items'][i]['size'].length ==
                      8) {
                    for (var j = 35;
                        j <
                            asyncSnapshot.data.documents[0]
                                    .data['items'][i]['size'].length +
                                35;
                        j++) {
                      var value = asyncSnapshot.data.documents[0].data['items']
                          [i]['size'][j.toString()];
                      if (value) {
                        sizes.add(j.toString());
                      }
                    }
                  } else {
                    List<String> sizeWord = ['XS', 'S', 'M', 'L', 'XL'];
                    for (var j = 0; j < 5; j++) {
                      var value = asyncSnapshot.data.documents[0].data['items']
                          [i]['size'][sizeWord[j]];
                      if (value) {
                        sizes.add(sizeWord[j]);
                      }
                    }
                  }
                }

                listImages.add(ListHirezontalImage(
                  name: asyncSnapshot.data.documents[0].data['items'][i]
                      ['name'],
                  image: asyncSnapshot.data.documents[0].data['items'][i]
                      ['image'],
                  description: asyncSnapshot.data.documents[0].data['items'][i]
                      ['description'],
                  price: asyncSnapshot.data.documents[0].data['items'][i]
                      ['price'],
                  imageID: asyncSnapshot.data.documents[0].data['items'][i]
                      ['imageID'],
                  buyPrice: asyncSnapshot.data.documents[0].data['items'][i]
                      ['buyPrice'],
                  size: sizes,
                  totalQuantity: asyncSnapshot.data.documents[0].data['items']
                      [i]['totalQuantity'],
                ));
              }
            } catch (e) {
              setFirstElemntInSubCollection();
              return Center(
                child: Container(
                    height: 200,
                    width: MediaQuery.of(context).size.width * .9,
                    child: CircularProgressIndicator()),
              );
            }

            return Container(
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: listImages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowItem(
                                    image: listImages[index].image,
                                    name: listImages[index].name,
                                    des: listImages[index].description,
                                    price: listImages[index].price,
                                    fetchToMyCart: fetchMyCart,
                                    imageID: listImages[index].imageID,
                                    buyPrice: listImages[index].buyPrice,
                                    size: listImages[index].size,
                                    totalQuantity: "4",
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  new Container(
                                    height: 190,
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
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        child: IconButton(
                                            icon: Icon(
                                              Icons.add_shopping_cart,
                                              color: Colors.teal[600],
                                            ),
                                            onPressed: () {
                                              addToMyCartFromCategory(
                                                context,
                                                listImages[index].size,
                                                fetchMyCart,
                                                listImages[index].name,
                                                listImages[index].price,
                                                listImages[index].description,
                                                listImages[index].image,
                                                listImages[index].imageID,
                                                listImages[index].buyPrice,
                                              );
                                            }),
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        alignment: Alignment.bottomRight,
                                        child: Text(
                                          listImages[index].name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[600]),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    width: double.infinity,
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "${listImages[index].price} ${isEnglish ? english[61] : arabic[61]}",
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                          color: Colors.teal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20),
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
            return Container(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
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
    ),
  );
}

String sizeChoseCatgetory = '';
addToMyCartFromCategory(
  BuildContext context,
  List size,
  Function fetchMyCart,
  String name,
  String price,
  String des,
  String image,
  String imageID,
  String buyPrice,
) async {
  if (size.length == 0) {
    await fetchMyCart();
    int q = 0;
    int id;
    for (var i = 0; i < cart.length; i++) {
      if (cart[i].itemName == name &&
          cart[i].itemPrice == price &&
          cart[i].itemDes == des) {
        id = cart[i].id;
        q = int.parse(cart[i].quantity);
      }
    }
    q++;
    if (q == 1) {
      await DBHelper.insert(
        'cart',
        {
          'name': name,
          'price': price,
          'image': image,
          'des': des,
          'q': q.toString(),
          'buyPrice': buyPrice,
          'size': '',
          'productID': imageID,
        },
      ).whenComplete(() => addCartToast("تم وضعها في سلتك"));
    } else {
      await DBHelper.updateData(
              'cart',
              {
                'name': name,
                'price': price,
                'image': image,
                'des': des,
                'q': q.toString(),
                'buyPrice': buyPrice,
                'size': '',
                'productID': imageID,
              },
              id)
          .whenComplete(() => addCartToast("تم وضعها في سلتك"));
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 350.0,
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: Text(
                      "أختر المقاس",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 200,
                      alignment: Alignment.center,
                      margin: EdgeInsets.all(8.0),
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      decoration: BoxDecoration(
                          border: Border.all(),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: size.length,
                        itemBuilder: (context, i) {
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 8.0),
                            decoration: BoxDecoration(
                              color: sizeChoseCatgetory == size[i]
                                  ? Colors.teal
                                  : Colors.white,
                              border: Border.all(),
                            ),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  sizeChoseCatgetory = size[i];
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Center(
                                  child: Text(size[i]),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          'إلغاء',
                          style:
                              TextStyle(color: Colors.purple, fontSize: 18.0),
                        ),
                      ),
                      FlatButton(
                        onPressed: () async {
                          if (sizeChoseCatgetory == '') {
                            errorToast("أختر المقاس");
                          } else {
                            await fetchMyCart();
                            int q = 0;
                            int id;
                            for (var i = 0; i < cart.length; i++) {
                              if (cart[i].itemName == name &&
                                  cart[i].itemPrice == price &&
                                  cart[i].itemDes == des &&
                                  cart[i].sizeChose == sizeChoseCatgetory) {
                                id = cart[i].id;
                                q = int.parse(cart[i].quantity);
                              }
                            }
                            q++;
                            setState(() {});
                            if (q == 1) {
                              await DBHelper.insert(
                                'cart',
                                {
                                  'name': name,
                                  'price': price,
                                  'image': image,
                                  'des': des,
                                  'q': q.toString(),
                                  'buyPrice': buyPrice,
                                  'size': sizeChoseCatgetory,
                                  'productID': imageID,
                                },
                              ).whenComplete(
                                  () => addCartToast("تم وضعها في سلتك"));
                            } else {
                              await DBHelper.updateData(
                                      'cart',
                                      {
                                        'name': name,
                                        'price': price,
                                        'image': image,
                                        'des': des,
                                        'q': q.toString(),
                                        'buyPrice': buyPrice,
                                        'size': sizeChoseCatgetory,
                                        'productID': imageID,
                                      },
                                      id)
                                  .whenComplete(
                                      () => addCartToast("تم وضعها في سلتك"));
                            }
                            Navigator.pop(context);
                          }
                        },
                        child: Text(
                          'أضف',
                          style:
                              TextStyle(color: Colors.purple, fontSize: 18.0),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
