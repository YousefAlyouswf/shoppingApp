import 'package:carousel_pro/carousel_pro.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shop_app/models/drawerbody.dart';

AppBar appBar({String text = "Shop App"}) {
  return AppBar(
    backgroundColor: Colors.red,
    elevation: 0,
    title: Text(text),
    actions: <Widget>[
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

Drawer drawer(BuildContext context) {
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
                  print("Hello");
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
