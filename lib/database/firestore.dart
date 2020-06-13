import 'package:cloud_firestore/cloud_firestore.dart';

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
  //  print(itemMap);
    Firestore.instance
        .collection('subCategory')
        .where('category', isEqualTo: category)
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        print(element.documentID);
        await Firestore.instance
            .collection('subCategory')
            .document(element.documentID)
            .updateData({
          "items": FieldValue.arrayRemove([itemMap])
        });
      });
    });
  }
}
