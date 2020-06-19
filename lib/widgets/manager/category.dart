import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/manager/edit.dart';
import 'package:shop_app/models/listHirzontalImage.dart';

import '../widgets.dart';
import 'addItem.dart';

Widget categoryScreen(
  Function selectCategory,
  Function takeImageGalaryForList,
  Function takeImageCameraForList,
) {
  return Column(
    children: [
      Container(height: 160, child: categores(selectCategory)),
      Divider(
        thickness: 5,
      ),
      Expanded(
          child: subCatgory(takeImageGalaryForList, takeImageCameraForList)),
    ],
  );
}

File getImageForlistFile;
String getImageForlistURL;
String catgoryName = "";
Widget subCatgory(
    Function takeImageGalaryForList, Function takeImageCameraForList) {
  List<ListHirezontalImage> listImages;

  return Container(
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('subCategory')
          .where('category', isEqualTo: catgoryName)
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
                show: asyncSnapshot.data.documents[0].data['items'][i]['show'],
                imageID: asyncSnapshot.data.documents[0].data['items'][i]
                    ['imageID'],
                buyPrice: asyncSnapshot.data.documents[0].data['items'][i]
                    ['buyPrice'],
              ));
            }
          } catch (e) {
            return Center(
              child: Container(
                height: 100,
                width: 100,
                child: Text("Select From Catgory List"),
              ),
            );
          }

          return Container(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    border: Border.all(),
                    borderRadius: BorderRadius.all(
                      Radius.circular(5),
                    ),
                  ),
                  child: Text(
                    catgoryName,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3, childAspectRatio: 0.7),
                      itemCount: listImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            showBottomSheet(
                                backgroundColor: Colors.black87,
                                context: context,
                                builder: (context) =>
                                    StatefulBuilder(builder: (BuildContext
                                            context,
                                        StateSetter
                                            setState /*You can rename this!*/) {
                                      return SingleChildScrollView(
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
                                              Container(
                                                height: 100,
                                                width: double.infinity,
                                                child: StreamBuilder(
                                                    stream: Firestore.instance
                                                        .collection("images")
                                                        .where("imageID",
                                                            isEqualTo:
                                                                listImages[
                                                                        index]
                                                                    .imageID)
                                                        .snapshots(),
                                                    builder:
                                                        (context, snapshot) {
                                                      if (!snapshot.hasData) {
                                                        return Text("Loading");
                                                      } else {
                                                        return ListView.builder(
                                                            scrollDirection:
                                                                Axis.horizontal,
                                                            itemCount: snapshot
                                                                .data
                                                                .documents[0]
                                                                .data['images']
                                                                .length,
                                                            itemBuilder:
                                                                (context, i) {
                                                              String listImage =
                                                                  snapshot
                                                                          .data
                                                                          .documents[
                                                                              0]
                                                                          .data[
                                                                      'images'][i];
                                                              print(listImage);
                                                              return InkWell(
                                                                onLongPress:
                                                                    () {
                                                                  if (i == 0) {
                                                                    errorToast(
                                                                        "لا يمكن حذف أول صورة من هذا المكان");
                                                                  } else {
                                                                    FirestoreFunctions().deleteImagesForList(
                                                                        snapshot
                                                                            .data
                                                                            .documents[0]
                                                                            .data['imageID'],
                                                                        listImage);
                                                                  }
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child:
                                                                      Container(
                                                                    height: 100,
                                                                    width: 100,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      image:
                                                                          DecorationImage(
                                                                        fit: BoxFit
                                                                            .fill,
                                                                        image:
                                                                            NetworkImage(
                                                                          listImage,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      }
                                                    }),
                                              ),
                                              IconButton(
                                                  icon: Icon(
                                                    Icons.add,
                                                    size: 44,
                                                    color: Colors.white,
                                                  ),
                                                  onPressed: () async {
                                                    await getImageForCatgory(
                                                        takeImageCameraForList(
                                                            listImages[index]
                                                                .imageID),
                                                        takeImageGalaryForList(
                                                            listImages[index]
                                                                .imageID),
                                                        context);
                                                  }),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceAround,
                                                children: [
                                                  IconButton(
                                                      icon: Icon(Icons.edit,
                                                          color: Colors.blue),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => EditItem(
                                                                listImages[
                                                                        index]
                                                                    .name,
                                                                listImages[
                                                                        index]
                                                                    .image,
                                                                listImages[
                                                                        index]
                                                                    .price,
                                                                listImages[
                                                                        index]
                                                                    .description,
                                                                listImages[
                                                                        index]
                                                                    .imageID,
                                                                listImages[
                                                                        index]
                                                                    .show,
                                                                catgoryName),
                                                          ),
                                                        ).then((value) =>
                                                            Navigator.pop(
                                                                context));
                                                      }),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Column(
                                                      children: [
                                                        Text(
                                                          "${listImages[index].price} ر.س",
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          "${listImages[index].buyPrice} ر.س",
                                                          textDirection:
                                                              TextDirection.rtl,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            16.0),
                                                    child: Text(
                                                      listImages[index].name,
                                                      style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                  ),
                                                  IconButton(
                                                    icon: Icon(
                                                      !listImages[index].show
                                                          ? Icons.cancel
                                                          : Icons.check_circle,
                                                      size: 40,
                                                      color: !listImages[index]
                                                              .show
                                                          ? Colors.red
                                                          : Colors.green,
                                                    ),
                                                    onPressed: () {
                                                      Map<String, dynamic>
                                                          itemMapRemove = {
                                                        "name":
                                                            listImages[index]
                                                                .name,
                                                        "description":
                                                            listImages[index]
                                                                .description,
                                                        "price":
                                                            listImages[index]
                                                                .price,
                                                        "image":
                                                            listImages[index]
                                                                .image,
                                                        "show": false,
                                                        "imageID":
                                                            listImages[index]
                                                                .imageID,
                                                      };
                                                      Map<String, dynamic>
                                                          itemMapAdd = {
                                                        "name":
                                                            listImages[index]
                                                                .name,
                                                        "description":
                                                            listImages[index]
                                                                .description,
                                                        "price":
                                                            listImages[index]
                                                                .price,
                                                        "image":
                                                            listImages[index]
                                                                .image,
                                                        "show": true,
                                                        "imageID":
                                                            listImages[index]
                                                                .imageID,
                                                      };
                                                      if (listImages[index]
                                                          .show) {
                                                        FirestoreFunctions()
                                                            .changeShowStatus(
                                                          catgoryName,
                                                          itemMapAdd,
                                                          itemMapRemove,
                                                        );
                                                      } else {
                                                        FirestoreFunctions()
                                                            .changeShowStatus(
                                                          catgoryName,
                                                          itemMapRemove,
                                                          itemMapAdd,
                                                        );
                                                      }
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                    },
                                                  )
                                                ],
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(16.0),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 200,
                                                  child: SingleChildScrollView(
                                                    child: Card(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Center(
                                                              child: Text(
                                                                "وصف المنتج",
                                                                textDirection:
                                                                    TextDirection
                                                                        .rtl,
                                                              ),
                                                            ),
                                                            Text(
                                                              listImages[index]
                                                                  .description,
                                                              textDirection:
                                                                  TextDirection
                                                                      .rtl,
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }));
                          },
                          onLongPress: () {
                            Map<String, dynamic> itemMap = {
                              "name": listImages[index].name,
                              "description": listImages[index].description,
                              "price": listImages[index].price,
                              "image": listImages[index].image,
                              'show': listImages[index].show,
                              'imageID': listImages[index].imageID,
                            };
                            deleteItemDialog(
                              context,
                              listImages[index].name,
                              catgoryName,
                              itemMap,
                              listImages[index].image,
                              listImages[index].price,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: <Widget>[
                                new Container(
                                  width: MediaQuery.of(context).size.width / 3,
                                  height: 100,
                                  decoration: new BoxDecoration(
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
                                Text(listImages[index].name),
                                Text(listImages[index].price),
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
Widget categores(Function selectCategory) {
  List<ListHirezontalImage> listImages;
  return Container(
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
                      onLongPress: () {
                        deleteCategoryDialog(context, listImages[index].name,
                            listImages[index].image);
                      },
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
                            height: 10,
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
Future uploadImageForList(String imageID) async {
  String fileName = '${DateTime.now()}.png';

  StorageReference firebaseStorage =
      FirebaseStorage.instance.ref().child(fileName);

  StorageUploadTask uploadTask = firebaseStorage.putFile(getImageForlistFile);
  await uploadTask.onComplete;
  getImageForlistURL = await firebaseStorage.getDownloadURL() as String;

  if (getImageForlistURL.isNotEmpty) {
    await FirestoreFunctions().addImagesForList(imageID, getImageForlistURL);
  }
}deleteItemDialog(
  BuildContext context,
  String itemTextName,
  String catgoryName,
  itemMap,
  String image,
  String price,
) {
  showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 300.0,
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        image,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            itemTextName,
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "R.S. $price",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirestoreFunctions().deleteItem(catgoryName, itemMap);
                      Navigator.pop(context);
                    },
                    label: Text(
                      'OK',
                      style: TextStyle(color: Colors.purple, fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
          ));
}

deleteCategoryDialog(
  BuildContext context,
  String catgoryTextName,
  String image,
) {
  showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Container(
              height: 300.0,
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      height: 100,
                      width: 100,
                      child: Image.network(
                        image,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        catgoryTextName,
                        style: TextStyle(fontSize: 15),
                      ),
                    ),
                  ),
                  FlatButton.icon(
                    icon: Icon(Icons.delete),
                    onPressed: () {
                      FirestoreFunctions()
                          .deleteCategory(catgoryTextName, image);
                      Navigator.pop(context);
                    },
                    label: Text(
                      'OK',
                      style: TextStyle(color: Colors.purple, fontSize: 18.0),
                    ),
                  ),
                ],
              ),
            ),
          ));
}