import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/models/listHirzontalImage.dart';
import 'package:shop_app/screens/showItem.dart';

List<bool> selected = List.generate(20, (i) => false);
Widget headerCatgory(Function selectedSection, Function categorySelectedColor) {
  return Padding(
    padding: const EdgeInsets.only(top: 48.0),
    child: Container(
      decoration: BoxDecoration(),
      height: 140,
      width: double.infinity,
      child: StreamBuilder(
        stream: Firestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Text("Loading");
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: snapshot.data.documents[0].data['collection'].length,
              itemBuilder: (context, i) {
                String name =
                    snapshot.data.documents[0].data['collection'][i]['name'];
                String image =
                    snapshot.data.documents[0].data['collection'][i]['image'];
                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(5)),
                    border: Border.all(
                      color: selected[i] ? Colors.teal : Colors.transparent,
                    ),
                  ),
                  child: InkWell(
                    onTap: () {
                      selectedSection(name);
                      categorySelectedColor(i);
                    },
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            margin: EdgeInsets.all(8.0),
                            height: 50,
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(15)),
                              image: DecorationImage(
                                  image: NetworkImage(image), fit: BoxFit.fill),
                            ),
                          ),
                        ),
                        Text(
                          name,
                          style: TextStyle(
                            color: selected[i] ? Colors.teal : Colors.grey[600],
                          ),
                        )
                      ],
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
Widget subCollection(BuildContext context, Function setFirstElemntInSubCollection, Function fetchMyCart) {
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
                  child: CircularProgressIndicator()
                ),
              );
            }

            return Container(
              child: Column(
                children: [
                  Expanded(
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.6,
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
                                  totalQuantity:
                                      listImages[index].totalQuantity,
                                ),
                              ),
                            );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: <Widget>[
                                  new Container(
                                    height: 250,
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
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    width: double.infinity,
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      listImages[index].name,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[600]
                                      ),
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 8.0),
                                    width: double.infinity,
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      "${listImages[index].price} ر.س",
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
