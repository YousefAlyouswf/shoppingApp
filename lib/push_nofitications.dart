import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationsManager {
  PushNotificationsManager._();

  factory PushNotificationsManager() => _instance;

  static final PushNotificationsManager _instance =
      PushNotificationsManager._();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  bool _initialized = false;

  Future<void> init() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();
      print("FirebaseMessaging token: $token");
      bool exist = false;
      await Firestore.instance
          .collection('token')
          .where('token_user', isEqualTo: token)
          .getDocuments()
          .then((value) => value.documents.forEach((e) {
                exist = true;
              }));
      if (!exist) {
        await Firestore.instance.collection("token").add({
          'token_user': token,
        });
      }

      _initialized = true;
    }
  }

  Future<void> initEmployee() async {
    if (!_initialized) {
      // For iOS request permission first.
      _firebaseMessaging.requestNotificationPermissions();
      _firebaseMessaging.configure();

      // For testing purposes print the Firebase Messaging token
      String token = await _firebaseMessaging.getToken();

      bool exist = false;
      await Firestore.instance
          .collection('tokenEmp')
          .where('token_user', isEqualTo: token)
          .getDocuments()
          .then((value) => value.documents.forEach((e) {
                exist = true;
              }));
      if (!exist) {
        await Firestore.instance.collection("tokenEmp").add({
          'token_user': token,
        });
      }

      _initialized = true;
    }
  }
}
