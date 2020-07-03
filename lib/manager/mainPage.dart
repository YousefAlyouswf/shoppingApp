import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/models/tabModels.dart';

import 'package:shop_app/widgets/widgets.dart';

import 'manager/addItem.dart';
import 'manager/category.dart';
import 'manager/employeeWidget.dart';
import 'manager/order.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<TabModels> pages = [
    TabModels(
      "الأقسام",
      Icon(Icons.dashboard),
    ),
    TabModels(
      "إظافة",
      Icon(Icons.add),
    ),
    TabModels(
      "الطلبات",
      Icon(Icons.shopping_basket),
    ),
    TabModels(
      "المندوبين",
      Icon(Icons.people),
    ),
  ];
  TextEditingController taxController = TextEditingController();
  TextEditingController driverController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: pages.length, vsync: this);
    showItemFileds = false;
    showBtnPost = false;
    newCategory = false;
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  TextEditingController title = TextEditingController();
  TextEditingController content = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 1,
                child: FlatButton(
                  onPressed: () {
                    showBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) => Container(
                        height: MediaQuery.of(context).size.height,
                        color: Colors.white,
                        child: Column(
                          children: [
                            MyTextFormField(
                              editingController: title,
                              hintText: "العنوان",
                            ),
                            MyTextFormField(
                              editingController: content,
                              hintText: "المحتوى",
                              isMultiLine: true,
                            ),
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                              color: Colors.blue,
                              padding: EdgeInsets.all(16.0),
                              child: InkWell(
                                onTap: () {
                                  if (title.text.isEmpty) {
                                    errorToast("أكتب عنوان الرسالة");
                                  } else if (content.text.isEmpty) {
                                    errorToast("أكتب محتوى الرسالة");
                                  } else {
                                    FirestoreFunctions().upDateAppInfo(
                                        title.text, content.text);
                                    addCartToast("تم تحديث الرسالة");
                                    Navigator.pop(context);
                                  }
                                },
                                child: Text(
                                  "أعرض",
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 22),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                  child: Text("رسالة العرض"),
                ),
              ),
              PopupMenuItem(
                value: 2,
                child: FlatButton(
                  onPressed: () {
                    changeTax(context);
                  },
                  child: Text("الضريبة والتوصيل"),
                ),
              ),
            ];
          })
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: TabBar(
            controller: _tabController,
            tabs: [
              Tab(
                text: pages[0].text,
                icon: pages[0].icon,
              ),
              Tab(
                text: pages[1].text,
                icon: pages[1].icon,
              ),
              Tab(
                text: pages[2].text,
                icon: pages[2].icon,
              ),
              Tab(
                text: pages[3].text,
                icon: pages[3].icon,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          CategoryManager(),
          AddItemManager(),
          OrderManager(),
          EmplyeeManager(),
        ],
      ),
    );
  }

  changeTax(
    BuildContext context,
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
                  "تحديث البيانات",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: MyTextFormField(
                            hintText: "الضريبة",
                            isNumber: true,
                            editingController: taxController,
                          )),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width / 2,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: MyTextFormField(
                            hintText: "التوصيل",
                            isNumber: true,
                            editingController: driverController,
                          )),
                    ),
                  ),
                ],
              ),
              FlatButton(
                onPressed: () {
                  Firestore.instance
                      .collection('app')
                      .document('1YGqmBXRZGQrsAdIvKin')
                      .updateData({
                    'delivery': int.parse(driverController.text),
                    'tax': int.parse(taxController.text),
                  });
                  Navigator.pop(context);
                },
                child: Text(
                  'تحديث',
                  style: TextStyle(color: Colors.purple, fontSize: 18.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
