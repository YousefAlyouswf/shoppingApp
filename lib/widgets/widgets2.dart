import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/models/listHirzontalImage.dart';

List<ListHirezontalImage> listImages;
Widget listViewHorznintal(Function selectCategory) {
  return Container(
    height: 160,
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('categories').snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          int listLength =
              asyncSnapshot.data.documents[0].data['collection'].length;
          listImages = List();
          for (var i = 0; i < listLength; i++) {
            listImages.add(ListHirezontalImage(
              asyncSnapshot.data.documents[0].data['collection'][i]['name'],
              asyncSnapshot.data.documents[0].data['collection'][i]['image'],
            ));
          }

          return Container(
            color: Colors.black12,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: listImages.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        selectCategory(listImages[index].name);
                      },
                      child: Column(
                        children: <Widget>[
                          new Container(
                            width: 100,
                            height: 100,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                fit: BoxFit.fill,
                                image:
                                    new NetworkImage(listImages[index].image),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(listImages[index].name),
                        ],
                      ),
                    ),
                  );
                }),
          );
        } else if (asyncSnapshot.hasError) {
          return Text('There was an error...');
        } else {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    ),
  );
}

bool isViewBottom = false;
NetworkImage imageBottomSheet;
Container imageViewBottomSheet(closeImpageOntap) {
  return isViewBottom
      ? Container(
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  height: 100,
                  color: Colors.white,
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        size: 40,
                        color: Colors.black,
                      ),
                      onPressed: closeImpageOntap)),
              Expanded(
                child: PhotoView(
                  filterQuality: FilterQuality.high,
                  minScale: 0.4,
                  backgroundDecoration: BoxDecoration(color: Colors.white),
                  imageProvider: imageBottomSheet,
                ),
              ),
            ],
          ),
        )
      : Container();
}

String catgoryNameCustomer = "";
Widget subCatgoryCustomer(Function imageOnTapCustomer, Function fetchMyCart) {
  List<ListHirezontalImage> listImages;

  return Container(
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('subCategory')
          .where('category', isEqualTo: catgoryNameCustomer)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<QuerySnapshot> asyncSnapshot) {
        if (asyncSnapshot.hasData) {
          try {
            int listLength =
                asyncSnapshot.data.documents[0].data['items'].length;
            listImages = List();
            for (var i = 0; i < listLength; i++) {
              listImages.add(ListHirezontalImage(
                asyncSnapshot.data.documents[0].data['items'][i]['name'],
                asyncSnapshot.data.documents[0].data['items'][i]['image'],
                description: asyncSnapshot.data.documents[0].data['items'][i]
                    ['description'],
                price: asyncSnapshot.data.documents[0].data['items'][i]
                    ['price'],
              ));
            }
          } catch (e) {
            return Center(
              child: Container(
                height: 200,
                width: MediaQuery.of(context).size.width * .9,
                child: Card(
                  elevation: 10,
                  color: Colors.amber,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Center(
                          child: Text(
                            "متجر الدباس",
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          " يحتوي على جميع الماركات من الشنط والأحذية والإكسسوارات يحتوي على جميع الماركات من الشنط والأحذية والإكسسوارات يحتوي على جميع الماركات من الشنط والأحذية والإكسسوارات",
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return Container(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.all(
                        Radius.circular(5),
                      ),
                    ),
                    child: Text(
                      catgoryNameCustomer,
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                      ),
                      itemCount: listImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                          onTap: () {
                            showtheBottomSheet(
                              context,
                              listImages[index].image,
                              listImages[index].name,
                              listImages[index].description,
                              listImages[index].price,
                              imageOnTapCustomer,
                              fetchMyCart,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Stack(
                              children: <Widget>[
                                new Container(
                                  decoration: new BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(8)),
                                    image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(
                                          listImages[index].image),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    height: 45,
                                    color: Colors.black45,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "${listImages[index].price} ر.س",
                                          textDirection: TextDirection.rtl,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        Text(
                                          listImages[index].name,
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          );
        } else if (asyncSnapshot.hasError) {
          return Text('There was an error...');
        } else if (!asyncSnapshot.hasData) {
          return Text("data");
        } else {
          return Center(
            child: Container(
              height: 100,
              width: 100,
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    ),
  );
}

List<ItemShow> cartToCheck = new List();
showtheBottomSheet(BuildContext context, String image, String name, String des,
    String price, Function imageOnTapCustomer, Function fetchMyCart) {
  showModalBottomSheet(
      backgroundColor: Colors.transparent,
      context: context,
      builder: (context) => SingleChildScrollView(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(40),
                  topLeft: Radius.circular(40),
                ),
              ),
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      imageOnTapCustomer(NetworkImage(image));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        height: MediaQuery.of(context).size.width / 3,
                        width: MediaQuery.of(context).size.width / 3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.circular(5),
                          ),
                          image: new DecorationImage(
                            fit: BoxFit.fill,
                            image: new NetworkImage(
                              image,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          "$price ر.س",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          name,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width / 1.5,
                          height: 200,
                          child: SingleChildScrollView(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Center(
                                      child: Text(
                                        "وصف المنتج",
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    Text(
                                      des,
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                          icon: Icon(
                            Icons.add_shopping_cart,
                            size: 40,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            await fetchMyCart();
                            int q = 0;
                            int id;
                            for (var i = 0; i < cartToCheck.length; i++) {
                              if (cartToCheck[i].itemName == name &&
                                  cartToCheck[i].itemPrice == price &&
                                  cartToCheck[i].itemDes == des) {
                                id = cartToCheck[i].id;
                                q = int.parse(cartToCheck[i].quantity);
                              }
                            }
                            q++;
                            if (q == 1) {
                              await DBHelper.insert(
                                'cart',
                                {
                                  'name': name,
                                  'price': price,
                                  'image': image,
                                  'des': des,
                                  'q': q.toString()
                                },
                              ).whenComplete(
                                  () => addCartToast("تم وضعها في سلتك"));
                            } else {
                              await DBHelper.updateData(
                                  'cart',
                                  {
                                    'name': name,
                                    'price': price,
                                    'image': image,
                                    'des': des,
                                    'q': q.toString(),
                                  },
                                  id);
                            }
                          })
                    ],
                  ),
                ],
              ),
            ),
          ));
}

addCartToast(String text) {
  Fluttertoast.showToast(
      msg: text,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0);
}
//  List<String> cities = [
//     'الرياض',
//     'جدة',
//     'مكة المكرمة',
//     'المدينة المنورة',
//     'الاحساء',
//     'الدمام',
//     'الطائف',
//     'بريدة',
//     'تبوك',
//     'القطيف',
//     'خميس مشيط',
//     'الخبر',
//     'حفر الباطن',
//     'الجبيل',
//     'الخرج',
//     'أبها',
//     'حائل',
//     'نجران',
//     'ينبع',
//     'صبيا',
//     'الدوادمي',
//     'بيشة',
//     'أبو عريش',
//     'القنفذة',
//     'محايل',
//     'سكاكا',
//     'عرعر',
//     'عنيزة',
//     'القريات',
//     'صامطة',
//     'جازان',
//     'المجمعة',
//     'القويعية',
//     'احد المسارحه',
//     'الرس',
//     'وادي الدواسر',
//     'بحرة',
//     'الباحة',
//     'الجموم',
//     'رابغ',
//     'أحد رفيدة',
//     'شرورة',
//     'الليث',
//     'رفحاء',
//     'عفيف',
//     'العرضيات',
//     'العارضة',
//     'الخفجي',
//     'بالقرن',
//     'الدرعية',
//     'ضمد',
//     'طبرجل',
//     'بيش',
//     'الزلفي',
//     'الدرب',
//     'الافلاج',
//     'سراة عبيدة',
//     'رجال المع',
//     'بلجرشي',
//     'الحائط',
//     'ميسان',
//     'بدر',
//     'املج',
//     'رأس تنوره',
//     'المهد',
//     'الدائر',
//     'البكيريه',
//     'البدائع',
//     'خليص',
//     'الحناكية',
//     'العلا',
//     'الطوال',
//     'النماص',
//     'المجاردة',
//     'بقيق',
//     'تثليث',
//     'المخواة',
//     'النعيرية',
//     'الوجه',
//     'ضباء',
//     'بارق',
//     'طريف',
//     'خيبر',
//     'أضم',
//     'النبهانية',
//     'رنيه',
//     'دومة' 'الجندل',
//     'المذنب',
//     'تربه',
//     'ظهران الجنوب',
//     'حوطة بني تميم',
//     'الخرمة',
//     'قلوه',
//     'شقراء',
//     'المويه',
//     'المزاحمية',
//     'الأسياح',
//     'بقعاء',
//     'السليل',
//     'تيماء',
//   ];
