import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/helper/HelperFunction.dart';
import 'package:shop_app/manager/homePage.dart';
import 'package:shop_app/manager/mainPage.dart';
import 'package:shop_app/models/drawerbody.dart';
import 'package:shop_app/models/listHirzontalImage.dart';

AppBar appBar({String text = "Shop App"}) {
  return AppBar(
    elevation: 0,
    title: Text(text),
    actions: text == "Manager"
        ? []
        : <Widget>[
            IconButton(
                icon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
                onPressed: () {}),
            IconButton(
                icon: Icon(
                  Icons.shopping_cart,
                  color: Colors.white,
                ),
                onPressed: () {})
          ],
  );
}

Drawer drawer(BuildContext context, Function onThemeChanged) {
  List<Widget> drawerBody;
  List<DrawerBodyModel> drawerModel = [
    DrawerBodyModel(
      "Home Page",
      Icon(
        Icons.home,
        color: Colors.red,
      ),
    ),
    DrawerBodyModel(
      "My Account",
      Icon(
        Icons.person,
        color: Colors.red,
      ),
    ),
    DrawerBodyModel(
      "My Order",
      Icon(
        Icons.shopping_basket,
        color: Colors.red,
      ),
    ),
    DrawerBodyModel(
      "Categories",
      Icon(
        Icons.dashboard,
        color: Colors.red,
      ),
    ),
    DrawerBodyModel(
      "Favourites",
      Icon(
        Icons.favorite,
        color: Colors.red,
      ),
    ),
  ];
  drawerBody = new List();
  for (var i = 0; i < drawerModel.length; i++) {
    drawerBody.add(ListTile(
      title: Text(drawerModel[i].text),
      leading: drawerModel[i].icon,
      onTap: () => print(drawerModel[i].text),
    ));
  }

  return Drawer(
    child: Column(
      children: [
        UserAccountsDrawerHeader(
          accountName: Text("زائر"),
          accountEmail: Text("yousef.alyouswf1989@gmail.com"),
          currentAccountPicture: GestureDetector(
            child: CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(
                Icons.person,
                size: 50,
                color: Colors.white,
              ),
            ),
          ),
          decoration: BoxDecoration(color: Colors.pink),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: drawerBody.length,
            itemBuilder: (context, i) {
              return drawerBody[i];
            },
          ),
        ),
        Divider(
          thickness: 1,
        ),
        ListTile(
          title: Text("Settings"),
          leading: Icon(
            Icons.settings,
          ),
          onTap: () {},
        ),
        ListTile(
          title: Text("Dark Mode"),
          leading: Icon(
            Icons.lightbulb_outline,
          ),
          onTap: onThemeChanged,
        ),
        ListTile(
          title: Text("About"),
          leading: Icon(
            Icons.help,
          ),
          onTap: () {
            showAboutDialog(
              context: context,
              applicationName: "SHOP APP",
              applicationVersion: "0.0.1",
              applicationLegalese: "Developed by Yousef Al Yousef",
              useRootNavigator: false,
              children: [Icon(Icons.developer_board)],
              applicationIcon: InkWell(
                child: Icon(Icons.shopping_basket),
                onDoubleTap: () {
                  HelperFunction.getManagerLogin().then((value) {
                    if (value == null) {
                      value = false;
                    }
                    if (value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MainPage()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HomePageManager()),
                      );
                    }
                  });
                },
              ),
            );
          },
        ),
        SizedBox(
          height: 150,
        )
      ],
    ),
  );
}

//Image in the Header
bool isView = false;
AssetImage imageAsset;
List<AssetImage> images = [
  AssetImage("assets/images/1.jpg"),
  AssetImage("assets/images/2.jpg"),
  AssetImage("assets/images/3.jpg"),
  AssetImage("assets/images/4.jpg"),
  AssetImage("assets/images/5.jpg"),
  AssetImage("assets/images/6.jpg"),
  AssetImage("assets/images/7.jpg"),
  AssetImage("assets/images/8.jpg"),
  AssetImage("assets/images/9.jpg"),
  AssetImage("assets/images/10.jpg"),
  AssetImage("assets/images/11.jpg"),
  AssetImage("assets/images/12.jpg"),
];
Container imageCarousel(double height, Function imageOnTap) {
  return Container(
    height: height,
    child: Carousel(
      boxFit: BoxFit.cover,
      images: images,
      animationCurve: Curves.fastOutSlowIn,
      autoplay: false,
      onImageTap: imageOnTap,
      indicatorBgPadding: 10,
    ),
  );
}

Container imageView(Function closeImpageOntap) {
  return isView
      ? Container(
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  color: Colors.black38,
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                      onPressed: closeImpageOntap)),
              Expanded(
                child: PhotoView(
                  filterQuality: FilterQuality.high,
                  minScale: 0.4,
                  backgroundDecoration: BoxDecoration(color: Colors.black38),
                  imageProvider: imageAsset,
                ),
              ),
            ],
          ),
        )
      : Container();
}
//End Image in the Header

Widget continaer(String text, Color color) {
  return Padding(
    padding:
        const EdgeInsets.only(top: 100, bottom: 16.0, left: 16.0, right: 16.0),
    child: Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.all(
          Radius.circular(20),
        ),
      ),
      child: FlatButton(
        onPressed: () {},
        child: Text(text),
      ),
    ),
  );
}

//Manager Screen
Container listHorzintal(BuildContext context) {
  return Container(
    alignment: Alignment.topCenter,
    height: MediaQuery.of(context).size.height / 3,
    color: Colors.red,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        continaer("Categories", Colors.yellow),
        continaer("Images", Colors.orange),
        continaer("bla bla", Colors.amber),
        continaer("bla bla", Colors.deepOrange),
        continaer("bla bla", Colors.green),
        continaer("bla bla", Colors.lightBlue),
      ],
    ),
  );
}

Widget managerBody() {
  return Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Scaffold(),
      ),
    ),
  );
}

Widget categores(Function selectCategory) {
  List<ListHirezontalImage> listImages;
  return Container(
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('categories')
          .where('table', isEqualTo: "category")
          .snapshots(),
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

          return ListView.builder(
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
                              image: new NetworkImage(listImages[index].image),
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
              });
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

String catgoryName = "";
Widget subCatgory() {
  List<ListHirezontalImage> listImages;

  return Container(
    child: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance
          .collection('subCategory')
          .where('category', isEqualTo: catgoryName)
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
              ));
            }
          } catch (e) {
            return Center(
              child: Container(
                height: 100,
                width: 100,
                child: CircularProgressIndicator(),
              ),
            );
          }

          return Container(
            child: Column(
              children: [
                Text(catgoryName),
                Expanded(
                  child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2),
                      itemCount: listImages.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: <Widget>[
                              new Container(
                                width: 100,
                                height: 100,
                                decoration: new BoxDecoration(
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
                              Text(listImages[index].name),
                            ],
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

Widget firstPage(Function selectCategory) {
  return Column(
    children: [
      Container(height: 150, child: categores(selectCategory)),
      Divider(
        thickness: 5,
      ),
      Expanded(child: subCatgory()),
    ],
  );
}

var selectedCurrency;
bool showItemFileds = false;
bool showBtnPost = false;
bool newCategory = false;
TextEditingController itemName = TextEditingController();
TextEditingController itemPrice = TextEditingController();
TextEditingController itemDis = TextEditingController();
TextEditingController categoryName = TextEditingController();
Widget secondPage(
    BuildContext context, Function showItemTextFileds, Function isChanged) {
  final halfMediaWidth = MediaQuery.of(context).size.width / 2.0;
  return Container(
    child: SingleChildScrollView(
      child: Column(
        children: <Widget>[
          DropDownMen(showItemTextFileds: showItemTextFileds),
          Visibility(
            visible: newCategory,
            child: Container(
              alignment: Alignment.topCenter,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    width: halfMediaWidth,
                    child: MyTextFormField(
                      editingController: categoryName,
                      hintText: 'Category Name',
                    ),
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    width: halfMediaWidth,
                    child: MyTextFormField(
                      hintText: 'Category Image',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: showItemFileds,
            child: Column(
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topCenter,
                        width: halfMediaWidth,
                        child: MyTextFormField(
                          isChanged: isChanged,
                          editingController: itemName,
                          hintText: 'Item Name',
                        ),
                      ),
                      Container(
                        alignment: Alignment.topCenter,
                        width: halfMediaWidth,
                        child: MyTextFormField(
                          isChanged: isChanged,
                          editingController: itemPrice,
                          hintText: 'Price',
                          isNumber: true,
                        ),
                      ),
                    ],
                  ),
                ),
                MyTextFormField(
                  isChanged: isChanged,
                  editingController: itemDis,
                  hintText: 'Description',
                ),
                MyTextFormField(
                  hintText: 'Image',
                ),
              ],
            ),
          ),
          Visibility(
            visible: showBtnPost,
            child: RaisedButton(
              color: Colors.blueAccent,
              onPressed: () {
                Map<String, dynamic> itemMap = {
                  "name": itemName.text,
                  "description": itemDis.text,
                  "price": itemPrice.text,
                  "image":
                      "https://images-na.ssl-images-amazon.com/images/I/910zU0vyBrL._AC_UL1500_.jpg",
                };
                FirestoreFunctions()
                    .addNewItemRoExistCategory(itemMap, selectedCurrency);
              },
              child: Text(
                'POST',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          )
        ],
      ),
    ),
  );
}

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final bool isPassword;
  final bool isNumber;
  final Function isChanged;
  final TextEditingController editingController;
  MyTextFormField({
    this.hintText,
    this.isPassword = false,
    this.isNumber = false,
    this.editingController,
    this.isChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextField(
        onChanged: isChanged,
        controller: editingController,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        obscureText: isPassword ? true : false,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      ),
    );
  }
}

class DropDownMen extends StatefulWidget {
  final Function showItemTextFileds;

  const DropDownMen({Key key, this.showItemTextFileds}) : super(key: key);
  @override
  _DropDownMenState createState() => _DropDownMenState();
}

class _DropDownMenState extends State<DropDownMen> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: StreamBuilder(
          stream: Firestore.instance
              .collection("categories")
              .where("table", isEqualTo: "category")
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Text("Loading.....");
            else {
              int listLength =
                  snapshot.data.documents[0].data['collection'].length;

              List<DropdownMenuItem> currencyItems = [];
              currencyItems.add(
                DropdownMenuItem(
                  child: Text(
                    "New Category",
                    style: TextStyle(color: Colors.black),
                  ),
                  value: "New Category",
                ),
              );
              for (int i = 0; i < listLength; i++) {
                String snap =
                    snapshot.data.documents[0].data['collection'][i]['name'];
                currencyItems.add(
                  DropdownMenuItem(
                    child: Text(
                      snap,
                      style: TextStyle(color: Colors.black),
                    ),
                    value: "$snap",
                  ),
                );
              }
              return DropdownButton(
                items: currencyItems,
                onChanged: (currencyValue) {
                  setState(() {
                    selectedCurrency = currencyValue;
                  });
                  widget.showItemTextFileds();
                },
                value: selectedCurrency,
                isExpanded: false,
                hint: new Text(
                  "Choose Category",
                  style: TextStyle(color: Colors.black),
                ),
              );
            }
          }),
    );
  }
}
