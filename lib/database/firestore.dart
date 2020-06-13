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
}
