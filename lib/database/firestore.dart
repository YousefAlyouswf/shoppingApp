import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shop_app/models/appInfo.dart';
import 'package:shop_app/models/itemShow.dart';

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
    List<ItemShow> image = new List();
    await Firestore.instance
        .collection('subCategory')
        .getDocuments()
        .then((value) {
      value.documents.forEach((element) async {
        for (var i = 0; i < element.data['items'].length; i++) {
          if (element.data['items'][i]['show'] == true) {
            image.add(
              ItemShow(
                  itemName: element.data['items'][i]['name'],
                  itemPrice: element.data['items'][i]['price'],
                  itemDes: element.data['items'][i]['description'],
                  image: element.data['items'][i]['image']),
            );
          }
        }
      });
    });

    return Future.value(image);
  }

  changeShowStatus(String category, itemMapRemove, itemMapAdd) async {
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
          "items": FieldValue.arrayRemove([itemMapRemove])
        });
        await Firestore.instance
            .collection('subCategory')
            .document(element.documentID)
            .updateData({
          "items": FieldValue.arrayUnion([itemMapAdd])
        });
      });
    });
  }

  Future<List> getAppInfo() async {
    List<AppInfoModel> appInfo = new List();
    await Firestore.instance.collection('app').getDocuments().then((value) {
      value.documents.forEach((element) async {
        appInfo.add(
          AppInfoModel(
            element.data['title'],
            element.data['content'],
          ),
        );
      });
    });

    return Future.value(appInfo);
  }
}
