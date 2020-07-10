
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//   functions.logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var msgData;

exports.customerMsg = functions.firestore.document(
    'message/{messageId}'
).onCreate((snapshot, context) => {
    msgData = snapshot.data();
    var payLoad = {
        notification: {
            title: msgData.title,
            body: "Thanks for downloading our app",
            icon: "default",
            sound: "default"

        },
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            //"icond": "app_icon.jpg",

        }
    }
    return admin.messaging().sendToTopic("News", payLoad).then((response) => {
      return  console.log('Notification sent successfully:', response);

    }).catch((error) => {
        return  console.log('Notification sent failed:', error);

    });
})
