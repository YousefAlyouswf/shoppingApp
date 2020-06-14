import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

class FirestoreFunctions {
  addNewItemRoExistCategory(itemMap, String category) async {
    await Firestore.instance
        .collection('subCategory')
        .where("category", isEqualTo: category)
        .getDocuments()
        .then((value) {
      value.documents.forEach((result) async {
        await Firestore.instance
            .collection('subCategory')
            .document(result.documentID)
            .updateData({
          "items": FieldValue.arrayUnion([itemMap])
        });
      });
    }).catchError((e) => print("error fetching data: $e"));
  }

  addNewItemToNewCategory(catgoryMap, itemMap) async {
    await Firestore.instance
        .collection('categories')
        .document("category")
        .updateData({
      "collection": FieldValue.arrayUnion([catgoryMap])
    }).whenComplete(() async {
      await Firestore.instance.collection('subCategory').add(itemMap);
    });
  }

  deleteItem(String category, itemMap) async {
    await Firestore.instance
        .collection('subCategory')
        .where('category', isEqualTo: category)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        await Firestore.instance
            .collection('subCategory')
            .document(element.documentID)
            .updateData({
          "items": FieldValue.arrayRemove([itemMap])
        });
      });
    });
  }

  deleteCategory(String name, String image) async {
    await Firestore.instance
        .collection('categories')
        .document("category")
        .updateData({
      "collection": FieldValue.arrayRemove([
        {
          'name': name,
          'image': image,
        }
      ])
    });
    await Firestore.instance
        .collection('subCategory')
        .where('category', isEqualTo: name)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        await Firestore.instance
            .collection('subCategory')
            .document(element.documentID)
            .delete();
      });
    });
  }

  Future<List> getAllImages() async {
    List<String> image = new List();
    await Firestore.instance
        .collection('subCategory')
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        for (var i = 0; i < element.data['items'].length; i++) {
          image.add(element.data['items'][i]['image']);
        }
      });
    });

    return Future.value(image);
  }
}
