import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/models/tabModels.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:shop_app/widgets/widgets2.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  List<TabModels> pages = [
    TabModels(
      "Catgories",
      Icon(Icons.dashboard),
    ),
    TabModels(
      "Add New",
      Icon(Icons.add),
    ),
  ];

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
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          firstPage(selectCategory, takeImageGalaryForList,takeImageCameraForList),
          secondPage(
            context,
            showItemTextFileds,
            _takePictureForCatgory,
            _takeFromGalaryForCatgory,
            _takePictureForItems,
            _takeFromGalaryForItems,
            switchToCategoryPage,
          ),
        ],
      ),
    );
  }

  selectCategory(String name) {
    setState(() {});
    catgoryName = name;
  }

  switchToCategoryPage() {
    setState(() {});

    if (categoryName.text.isNotEmpty) {
      catgoryName = categoryName.text;
    } else {
      catgoryName = selectedCurrency;
    }

    categoryName.clear();
    itemName.clear();
    itemPrice.clear();
    itemDis.clear();
    imageStoredCategory = null;
    urlImageCategory = null;
    imageStoredItems = null;
    urlImageItems = null;
  }

  showItemTextFileds() {
    setState(() {
      if (selectedCurrency != null) {
        showItemFileds = true;

        if (selectedCurrency == "New Category") {
          newCategory = true;
        } else {
          newCategory = false;
        }
      }
    });
  }

  final picker = ImagePicker();
  takeImageGalaryForList(String imageID) async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        getImageForlistFile = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageForList(imageID);
  }
    takeImageCameraForList(String imageID) async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        getImageForlistFile = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageForList(imageID);
  }

  _takeFromGalaryForCatgory() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        imageStoredCategory = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageForCatefory();
  }

  _takePictureForCatgory() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        imageStoredCategory = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageForCatefory();
  }

  _takeFromGalaryForItems() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.gallery, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        imageStoredItems = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageItems();
  }

  _takePictureForItems() async {
    final pickedFile = await picker.getImage(
        source: ImageSource.camera, imageQuality: 100, maxWidth: 1200);
    setState(() {
      try {
        imageStoredItems = File(pickedFile.path);
      } catch (e) {}
    });
    uploadImageItems();
  }
}
