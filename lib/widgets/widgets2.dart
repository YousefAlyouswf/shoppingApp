import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/models/listHirzontalImage.dart';
import 'package:shop_app/screens/showItem.dart';
import 'package:shop_app/widgets/widgets.dart';

List<String> sizes = [];
String catgoryNameCustomer = "";
Widget subCatgoryCustomer(Function imageOnTapCustomer, Function fetchMyCart) {
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
                    var value = asyncSnapshot.data.documents[0].data['items'][i]
                        ['size'][j.toString()];
                    if (value) {
                      sizes.add(j.toString());
                    }
                  }
                } else {
                  List<String> sizeWord = ['XS', 'S', 'M', 'L', 'XL'];
                  for (var j = 0; j < 5; j++) {
                    var value = asyncSnapshot.data.documents[0].data['items'][i]
                        ['size'][sizeWord[j]];
                    if (value) {
                      sizes.add(sizeWord[j]);
                    }
                  }
                }
              }

              listImages.add(ListHirezontalImage(
                name: asyncSnapshot.data.documents[0].data['items'][i]['name'],
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
                totalQuantity: asyncSnapshot.data.documents[0].data['items'][i]
                    ['totalQuantity'],
              ));
            }
          } catch (e) {
            return Center(
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width * .9,
                child: Card(
                  elevation: 10,
                  color: Colors.amber,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Center(
                          child: Text(
                            appInfo[0].title.isEmpty
                                ? Container()
                                : appInfo[0].title,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          appInfo[0].content.isEmpty
                              ? Container()
                              : appInfo[0].content,
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
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
                            // showtheBottomSheet(
                            //   context,
                            //   listImages[index].image,
                            //   listImages[index].name,
                            //   listImages[index].description,
                            //   listImages[index].price,
                            //   imageOnTapCustomer,
                            //   fetchMyCart,
                            //   listImages[index].imageID,
                            //   listImages[index].buyPrice,
                            //   listImages[index].size,
                            // );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShowItem(
                                  image: listImages[index].image,
                                  name: listImages[index].name,
                                  des: listImages[index].description,
                                  price: listImages[index].price,
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
                                          "${listImages[index].price} ر.س",
                                          textDirection: TextDirection.rtl,
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
  );
}

List<ItemShow> cartToCheck = new List();
// showtheBottomSheet(
//   BuildContext context,
//   String image,
//   String name,
//   String des,
//   String price,
//   Function imageOnTapCustomer,
//   Function fetchMyCart,
//   String imageID,
//   String buyPrice,
//   List size,
// ) {
//   showModalBottomSheet(
//       elevation: 0,
//       //  backgroundColor: Colors.transparent,
//       context: context,
//       builder: (context) => SingleChildScrollView(
//             child: Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.only(
//                   topRight: Radius.circular(40),
//                   topLeft: Radius.circular(40),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       imageOnTapCustomer(NetworkImage(image), imageID);
//                     },
//                     child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: Container(
//                           height: MediaQuery.of(context).size.width / 3,
//                           width: MediaQuery.of(context).size.width,
//                           child: StreamBuilder(
//                               stream: Firestore.instance
//                                   .collection("images")
//                                   .where("imageID", isEqualTo: imageID)
//                                   .snapshots(),
//                               builder: (context, snapshot) {
//                                 if (!snapshot.hasData) {
//                                   return Text("Loading");
//                                 } else {
//                                   return ListView.builder(
//                                       scrollDirection: Axis.horizontal,
//                                       itemCount: snapshot.data.documents[0]
//                                           .data['images'].length,
//                                       itemBuilder: (context, i) {
//                                         String listImage = snapshot.data
//                                             .documents[0].data['images'][i];

//                                         return Padding(
//                                           padding: const EdgeInsets.all(8.0),
//                                           child: Container(
//                                             height: 100,
//                                             width: 100,
//                                             decoration: BoxDecoration(
//                                               borderRadius: BorderRadius.all(
//                                                   Radius.circular(15)),
//                                               image: DecorationImage(
//                                                 fit: BoxFit.fill,
//                                                 image: NetworkImage(
//                                                   listImage,
//                                                 ),
//                                               ),
//                                             ),
//                                           ),
//                                         );
//                                       });
//                                 }
//                               }),
//                         )),
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Text(
//                           "$price ر.س",
//                           textDirection: TextDirection.rtl,
//                           style: TextStyle(
//                               fontWeight: FontWeight.bold, fontSize: 22),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(
//                           Icons.add_shopping_cart,
//                           size: 40,
//                           color: Colors.green,
//                         ),
//                         onPressed: () async {
//                           await fetchMyCart();
//                           int q = 0;
//                           int id;
//                           for (var i = 0; i < cartToCheck.length; i++) {
//                             if (cartToCheck[i].itemName == name &&
//                                 cartToCheck[i].itemPrice == price &&
//                                 cartToCheck[i].itemDes == des) {
//                               id = cartToCheck[i].id;
//                               q = int.parse(cartToCheck[i].quantity);
//                             }
//                           }
//                           q++;
//                           if (q == 1) {
//                             await DBHelper.insert(
//                               'cart',
//                               {
//                                 'name': name,
//                                 'price': price,
//                                 'image': image,
//                                 'des': des,
//                                 'q': q.toString(),
//                                 'buyPrice': buyPrice
//                               },
//                             ).whenComplete(
//                                 () => addCartToast("تم وضعها في سلتك"));
//                           } else {
//                             await DBHelper.updateData(
//                                 'cart',
//                                 {
//                                   'name': name,
//                                   'price': price,
//                                   'image': image,
//                                   'des': des,
//                                   'q': q.toString(),
//                                   'buyPrice': buyPrice
//                                 },
//                                 id);
//                           }
//                           Navigator.pop(context);
//                         },
//                       )
//                     ],
//                   ),
//                   Text("المقاس"),
//                   Container(
//                     height: 33,
//                     child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: size.length,
//                         itemBuilder: (context, i) {
//                           return Container(
//                             margin: EdgeInsets.symmetric(horizontal: 8.0),
//                             decoration: BoxDecoration(
//                               border: Border.all(),
//                             ),
//                             child: InkWell(
//                               child: Padding(
//                                 padding:
//                                     const EdgeInsets.symmetric(horizontal: 8.0),
//                                 child: Center(
//                                   child: Text(size[i]),
//                                 ),
//                               ),
//                             ),
//                           );
//                         }),
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Container(
//                       width: double.infinity,
//                       height: 170,
//                       child: SingleChildScrollView(
//                         child: Card(
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.end,
//                               children: [
//                                 Center(
//                                   child: Text(
//                                     "وصف المنتج",
//                                     textDirection: TextDirection.rtl,
//                                   ),
//                                 ),
//                                 Text(
//                                   des,
//                                   textDirection: TextDirection.rtl,
//                                   style: TextStyle(fontWeight: FontWeight.bold),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ));
// }

addCartToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}
