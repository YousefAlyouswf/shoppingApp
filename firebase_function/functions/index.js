
const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp(functions.config().firebase);

var msgData;

exports.customerMsg = functions.firestore.document(
    'message/{messageId}'
).onUpdate((snapshot, context) => {
    msgData = snapshot.after.data();
    var payLoad = {
        notification: {
            title: msgData.title,
            body: msgData.body,
            icon: "default",
            sound: "default"

        },
        data: {
            click_action: "FLUTTER_NOTIFICATION_CLICK",
            title: "costumer"

        }
    };

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
                    title: "manager"

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
                    title: "manager"

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


//-------- Send notification when set an order

var order;
exports.customerOrder = functions.firestore.document(
    'order/{orderId}'
).onCreate((snapshot, context) => {
    order = snapshot.data();
    return admin.firestore().collection('token').get().then(snapshots => {
        var tokens = [];
        for (var token of snapshots.docs) {
            tokens.push(token.data().token_user)
        }

        var payLoad;

        payLoad = {
            notification: {
                title: "فاتورة شراء",
                body: "تم شراء بمبلغ " + order.total + " فاتورة رقم " + order.orderID,


            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                title: "manager"

            }
        }


        return admin.messaging().sendToDevice(tokens, payLoad).then((responce) => {
            return console.log('pushed them all' + responce);

        }).catch((err) => {
            return console.log("Yousef There is error->>>" + err);

        })

    })

})




var employeeNotification;
exports.employeeNotification = functions.firestore.document(
    'order/{orderId}'
).onUpdate((snapshot, context) => {
    employeeNotification = snapshot.after.data();

    return admin.firestore().collection('tokenEmp').get().then(snapshots => {
        var tokens = [];
        for (var token of snapshots.docs) {
            tokens.push(token.data().token_user)
        }

        var payLoad = {
            notification: {
                title: "الإدارة",
                body: "فيه طلب جاهز للتوصيل أسرع قبل يروح عليك!!",


            },
            data: {
                click_action: "FLUTTER_NOTIFICATION_CLICK",
                title: "employee"

            },


        }



        if (employeeNotification.status !== "1" || employeeNotification.driverID !== "") {
            return null;
        } else {
            try {
                console.log("Status is: ----> " + employeeNotification.status + " and ID --->" + employeeNotification.driverID);
                return admin.messaging().sendToDevice(tokens, payLoad);
            } catch (e) {
                return console.log("Yousef There is error->>>" + e);
            }
            // return admin.messaging().sendToDevice(tokens, payLoad).then((responce) => {
            //     return console.log('pushed them all' + responce);

            // }).catch((err) => {
            //     return console.log("Yousef There is error->>>" + err);

            // })
        }


    })



})