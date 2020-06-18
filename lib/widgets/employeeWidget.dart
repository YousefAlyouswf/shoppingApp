import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';

Widget employeeList() {
  return Container(
    child: StreamBuilder(
        stream: Firestore.instance
            .collection('employee')
            .orderBy('accept')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: Text("لا يوجد مندوب"),
            );
          } else {
            return ListView.separated(
                itemBuilder: (context, i) {
                  DocumentSnapshot ds = snapshot.data.documents[i];
                  return Container(
                    color: ds['accept'] == "مقبول"
                        ? Colors.green[100]
                        : ds['accept'] == "مرفوض"
                            ? Colors.red[100]
                            : Colors.yellow[100],
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("الأسم: ${ds['name']}",
                                textDirection: TextDirection.rtl),
                            Text("الجوال: ${ds['phone']}",
                                textDirection: TextDirection.rtl),
                            Text("الهوية: ${ds['id']}",
                                textDirection: TextDirection.rtl),
                            Text("كلمة المرور: ${ds['pass']}",
                                textDirection: TextDirection.rtl),
                            Text("الحالة: ${ds['accept']}",
                                textDirection: TextDirection.rtl),
                          ],
                        ),
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                RaisedButton(
                                  onPressed: () {
                                    Firestore.instance
                                        .collection('employee')
                                        .where('id', isEqualTo: ds['id'])
                                        .getDocuments()
                                        .then((value) {
                                      value.documents.forEach((element) {
                                        Firestore.instance
                                            .collection('employee')
                                            .document(element.documentID)
                                            .updateData(
                                          {'accept': 'مرفوض'},
                                        );
                                      });
                                    });
                                  },
                                  color: Colors.red,
                                  child: Text("رفض"),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    Firestore.instance
                                        .collection('employee')
                                        .where('id', isEqualTo: ds['id'])
                                        .getDocuments()
                                        .then((value) {
                                      value.documents.forEach((element) {
                                        Firestore.instance
                                            .collection('employee')
                                            .document(element.documentID)
                                            .updateData(
                                          {'accept': 'مقبول'},
                                        );
                                      });
                                    });
                                  },
                                  color: Colors.green,
                                  child: Text("قبول"),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                RaisedButton(
                                  onPressed: () {
                                    showImageinSheet(context, ds['idImage']);
                                  },
                                  child: Text("الهوية"),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                  showImageinSheet(context, ds['licImage']);
                                  },
                                  child: Text("الرخصة"),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                     showImageinSheet(context, ds['carImage']);
                                  },
                                  child: Text("الأستمارة"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (context, i) {
                  return Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.grey,
                  );
                },
                itemCount: snapshot.data.documents.length);
          }
        }),
  );
}

Widget images(String image) {
  return Container(
    height: 100,
    width: 100,
    decoration: BoxDecoration(
        image: DecorationImage(
      image: NetworkImage(image),
      fit: BoxFit.fill,
    )),
  );
}

void showImageinSheet(BuildContext context, String image) {
  showBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => Container(
            decoration: BoxDecoration(
              image:
                  DecorationImage(image: NetworkImage(image), fit: BoxFit.fill),
            ),
          ));
}
