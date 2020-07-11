
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
        return console.log('Notification sent successfully:', response);

    }).catch((error) => {
        return console.log('Notification sent failed:', error);

    });
})

//----->> Send notification if employee choose order

var employeeData;
exports.employeeOrder = functions.firestore.document(
    'order/{orderId}'
).onUpdate((snapshot, context) => {
    employeeData = snapshot.after.data();
    return admin.firestore().collection('token').get().then(snapshots => {
        var tokens = [];
        for (var token of snapshots.docs) {
            tokens.push(token.data().token_user)
        }

        var payLoad;

        if (employeeData.driverID === "") {
            payLoad = {
                notification: {
                    title: "الإدارة",
                    body: "ألغى الكابتن " + employeeData.driverName + " توصيل طلب رقم " + employeeData.orderID,


                },
                data: {
                    click_action: "FLUTTER_NOTIFICATION_CLICK",


                }
            }
        } else {
            payLoad = {
                notification: {
                    title: "الإدارة",
                    body: "قبل الكابتن " + employeeData.driverName + " توصيل طلب رقم " + employeeData.orderID,


                },
                data: {
                    click_action: "FLUTTER_NOTIFICATION_CLICK",


                }
            }
        }


        return admin.messaging().sendToDevice(tokens, payLoad).then((responce) => {
            return console.log('pushed them all' + responce);

        }).catch((err) => {
            return console.log("Yousef There is error->>>" + err);

        })

    })

})
