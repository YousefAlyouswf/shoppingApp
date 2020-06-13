import 'package:flutter/material.dart';
import 'package:shop_app/models/tabModels.dart';
import 'package:shop_app/widgets/widgets.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
          firstPage(selectCategory),
          secondPage(
            context,
            showItemTextFileds,
            isChanged,
          ),
        ],
      ),
    );
  }

  selectCategory(String name) {
    setState(() {});
    catgoryName = name;
  }

  isChanged(v) {
    if (itemName.text.isNotEmpty &&
        itemPrice.text.isNotEmpty &&
        itemDis.text.isNotEmpty) {
      showBtnPost = true;
    } else {
      showBtnPost = false;
    }
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
}
