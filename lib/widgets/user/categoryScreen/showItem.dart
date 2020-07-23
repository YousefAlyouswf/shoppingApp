import 'dart:io';

import 'package:carousel_pro/carousel_pro.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:meet_network_image/meet_network_image.dart';
import 'package:mobile_number/mobile_number.dart';
import 'package:shop_app/database/firestore.dart';
import 'package:shop_app/database/local_db.dart';
import 'package:shop_app/manager/manager/addItem.dart';
import 'package:shop_app/models/itemShow.dart';
import 'package:shop_app/screens/mainScreen/homePage.dart';
import 'package:shop_app/widgets/user/categoryScreen/categoroesWidget.dart';
import 'package:shop_app/widgets/user/homeWidget.dart';
import 'package:shop_app/widgets/widgets.dart';
import 'package:intl/intl.dart' as intl;

class ShowItem extends StatefulWidget {
  final Function onThemeChanged;
  final Function changeLangauge;
  final String image;
  final String name;
  final String nameEn;
  final String des;
  final String price;
  final String imageID;
  final String buyPrice;
  final List size;

  final String priceOld;
  const ShowItem({
    Key key,
    this.onThemeChanged,
    this.changeLangauge,
    this.image,
    this.name,
    this.nameEn,
    this.des,
    this.price,
    this.imageID,
    this.buyPrice,
    this.size,
    this.priceOld,
  }) : super(key: key);
  @override
  _ShowItemState createState() => _ShowItemState();
}

class _ShowItemState extends State<ShowItem>
    with TickerProviderStateMixin<ShowItem> {
  String sizeChose = '';
  int quantity;

  getQuantityForThis() async {
    await Firestore.instance
        .collection('quantityItem')
        .where('id', isEqualTo: widget.imageID)
        .getDocuments()
        .then(
          (value) => value.documents.forEach(
            (e) {
              setState(() {
                quantity = int.parse(e['number']);
              });
            },
          ),
        );
  }

  AndroidDeviceInfo androidInfo;
  IosDeviceInfo iosDeviceInfo;
  String device;
  void deviceID() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.androidId;
    } else if (Platform.isIOS) {
      iosDeviceInfo = await deviceInfo.iosInfo;
      device = iosDeviceInfo.identifierForVendor;
    }
  }

  String _mobileNumber = '';
  Future<void> initMobileNumberState() async {
    if (!await MobileNumber.hasPhonePermission) {
      await MobileNumber.requestPhonePermission;
      return;
    }
    String mobileNumber = '';
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      mobileNumber = await MobileNumber.mobileNumber;
    } on PlatformException catch (e) {
      debugPrint("Failed to get mobile number because of '${e.message}'");
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _mobileNumber = mobileNumber;
    });
    List<String> numberList = _mobileNumber.split('');
    bool getNum = false;
    for (var i = 0; i < numberList.length; i++) {
      if (numberList[i] == '5' && !getNum) {
        setState(() {
          getNum = true;
          _mobileNumber = '0';
        });
      }
      if (getNum) {
        _mobileNumber += numberList[i];
      }
    }
  }

  ScrollController _controllerGridViewCatgories, scrollController;
  _scrollListener() {
    if (_controllerGridViewCatgories.offset >=
            _controllerGridViewCatgories.position.maxScrollExtent &&
        !_controllerGridViewCatgories.position.outOfRange) {}
    if (_controllerGridViewCatgories.offset <=
            _controllerGridViewCatgories.position.minScrollExtent &&
        !_controllerGridViewCatgories.position.outOfRange) {
      setState(() {
        scrollController.animateTo(180.0,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      });
    }
  }

  @override
  void initState() {
    getImagesToShowItems();
    super.initState();

    fetchToMyCart();
    getQuantityForThis();
    deviceID();
    initMobileNumberState();
    _controllerGridViewCatgories = ScrollController();
    _controllerGridViewCatgories.addListener(_scrollListener);
    scrollController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).unselectedWidgetColor,
      child: SafeArea(
        child: Scaffold(
          body: quantity == null
              ? Container(
                  child: Image.network(
                    "https://i.ya-webdesign.com/images/shopping-transparent-animated-gif.gif",
                    fit: BoxFit.fill,
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: CustomScrollView(
                        controller: scrollController,
                        slivers: <Widget>[
                          SliverAppBar(
                            expandedHeight:
                                MediaQuery.of(context).size.height / 2,
                            flexibleSpace: FlexibleSpaceBar(
                              background: networkImage2 == null
                                  ? Center(
                                      child: Container(
                                        height: 100,
                                        width: 100,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : imageCarouselItemShow(
                                      MediaQuery.of(context).size.height / 2),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(40),
                                  topLeft: Radius.circular(40),
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            child: Text(
                                              isEnglish
                                                  ? widget.nameEn
                                                  : widget.name,
                                              style: TextStyle(
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: "MainFont",
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () {
                                            scrollController.animateTo(700.0,
                                                duration: Duration(
                                                    milliseconds: 1000),
                                                curve: Curves.easeInOutCirc);
                                          },
                                          child: Container(
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              border: Border.all(),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                            ),
                                            width: 75,
                                            child: Text(
                                              word("reviews", context),
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                    quantity < 5
                                        ? Container(
                                            child: Text(
                                              quantity == 1
                                                  ? word("lastOne", context)
                                                  : quantity == 2
                                                      ? word("lastTwo", context)
                                                      : word("almostOutOfStock",
                                                          context),
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          )
                                        : Container(),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    widget.priceOld != ""
                                        ? Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal: 16.0),
                                            alignment: isEnglish
                                                ? Alignment.centerLeft
                                                : Alignment.centerRight,
                                            child: Text.rich(
                                              TextSpan(
                                                children: <TextSpan>[
                                                  new TextSpan(
                                                    text:
                                                        '${widget.priceOld} ${word("currancy", context)}',
                                                    style: new TextStyle(
                                                      color: Colors.grey,
                                                      decoration: TextDecoration
                                                          .lineThrough,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          )
                                        : Container(),
                                    Container(
                                      margin: EdgeInsets.symmetric(
                                          horizontal: 16.0),
                                      width: double.infinity,
                                      child: Text(
                                        "${widget.price} ${word("currancy", context)}",
                                        style: TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal,
                                        ),
                                      ),
                                    ),
                                    widget.size.length == 0
                                        ? Container()
                                        : Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8.0),
                                                child: Text(
                                                  word("size", context),
                                                  style: TextStyle(
                                                      fontSize: 22,
                                                      fontFamily: "MainFont"),
                                                ),
                                              ),
                                              Container(
                                                height: 75,
                                                alignment: Alignment.center,
                                                margin: EdgeInsets.all(8.0),
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 8.0),
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                    Radius.circular(10),
                                                  ),
                                                ),
                                                child: ListView.builder(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemCount:
                                                        widget.size.length,
                                                    itemBuilder: (context, i) {
                                                      return Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            .2,
                                                        margin: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: sizeChose ==
                                                                  widget.size[i]
                                                              ? Color(
                                                                  0xFFFF834F)
                                                              : null,
                                                          border: Border.all(
                                                              color: Colors
                                                                  .grey[300]),
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            setState(() {
                                                              sizeChose = widget
                                                                  .size[i];
                                                            });
                                                          },
                                                          child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        16.0),
                                                            child: Center(
                                                              child: Text(
                                                                widget.size[i],
                                                                style: TextStyle(
                                                                    color: sizeChose ==
                                                                            widget.size[
                                                                                i]
                                                                        ? Colors
                                                                            .white
                                                                        : null),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      );
                                                    }),
                                              ),
                                            ],
                                          ),
                                    Divider(
                                      thickness: 3,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height /
                                                3,
                                        child: SingleChildScrollView(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Center(
                                                  child: Text(
                                                    word("itemDes", context),
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w800,
                                                        fontSize: 20,
                                                        fontFamily: "MainFont"),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Container(
                                                  padding: EdgeInsets.all(8.0),
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: Colors.grey[300],
                                                    ),
                                                  ),
                                                  child: Text(
                                                    widget.des,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Divider(
                                      thickness: 3,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Text(
                                          "أراء العملاء",
                                          style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                              fontFamily: "MainFont"),
                                        ),
                                        InkWell(
                                          splashColor: Colors.transparent,
                                          onTap: () async {
                                            bool isBuyer = false;
                                            await Firestore.instance
                                                .collection('order')
                                                .where('userID',
                                                    isEqualTo: device)
                                                .getDocuments()
                                                .then((v) {
                                              v.documents.forEach((e) {
                                                for (var i = 0;
                                                    i < e['items'].length;
                                                    i++) {
                                                  if (e['items'][i]
                                                          ['productID'] ==
                                                      widget.imageID) {
                                                    setState(() {
                                                      isBuyer = true;
                                                    });
                                                  }
                                                }
                                              });
                                            });

                                            int countStars = 0;
                                            FaIcon emptyStar = FaIcon(
                                              FontAwesomeIcons.star,
                                              color: Colors.grey,
                                            );
                                            FaIcon solidStar = FaIcon(
                                              FontAwesomeIcons.solidStar,
                                              color: Colors.yellow[700],
                                            );
                                            bool first = false;
                                            bool second = false;
                                            bool third = false;
                                            bool forth = false;
                                            bool fifth = false;
                                            TextEditingController name =
                                                TextEditingController();
                                            TextEditingController phone =
                                                TextEditingController();
                                            TextEditingController text =
                                                TextEditingController();
                                            if (_mobileNumber != null) {
                                              phone.text = _mobileNumber;
                                            }
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  StatefulBuilder(builder:
                                                      (context, setState) {
                                                return Dialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                      10.0,
                                                    ),
                                                  ),
                                                  child: SingleChildScrollView(
                                                    child: Container(
                                                      height: 450,
                                                      width: width,
                                                      child: Column(
                                                        children: [
                                                          Text(
                                                            "(سوف يتم عرض رأيك بكل شفافيه)",
                                                            style: TextStyle(
                                                              fontFamily:
                                                                  "MainFont",
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: 20,
                                                          ),
                                                          Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              //First
                                                              IconButton(
                                                                icon: first
                                                                    ? solidStar
                                                                    : emptyStar,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    first =
                                                                        !first;
                                                                    if (!first) {
                                                                      second =
                                                                          false;
                                                                      third =
                                                                          false;
                                                                      forth =
                                                                          false;
                                                                      fifth =
                                                                          false;
                                                                    } else {
                                                                      countStars =
                                                                          1;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              //Second
                                                              IconButton(
                                                                icon: second
                                                                    ? solidStar
                                                                    : emptyStar,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    second =
                                                                        !second;
                                                                    if (!second) {
                                                                      third =
                                                                          false;
                                                                      forth =
                                                                          false;
                                                                      fifth =
                                                                          false;
                                                                    } else {
                                                                      first =
                                                                          true;
                                                                      second =
                                                                          true;
                                                                      countStars =
                                                                          2;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              //Third
                                                              IconButton(
                                                                icon: third
                                                                    ? solidStar
                                                                    : emptyStar,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    third =
                                                                        !third;
                                                                    if (!third) {
                                                                      forth =
                                                                          false;
                                                                      fifth =
                                                                          false;
                                                                    } else {
                                                                      first =
                                                                          true;
                                                                      second =
                                                                          true;
                                                                      third =
                                                                          true;
                                                                      countStars =
                                                                          3;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              //Forth
                                                              IconButton(
                                                                icon: forth
                                                                    ? solidStar
                                                                    : emptyStar,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    forth =
                                                                        !forth;
                                                                    if (!forth) {
                                                                      fifth =
                                                                          false;
                                                                    } else {
                                                                      first =
                                                                          true;
                                                                      second =
                                                                          true;
                                                                      third =
                                                                          true;
                                                                      countStars =
                                                                          4;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                              //Fifth
                                                              IconButton(
                                                                icon: fifth
                                                                    ? solidStar
                                                                    : emptyStar,
                                                                onPressed: () {
                                                                  setState(() {
                                                                    fifth =
                                                                        !fifth;
                                                                    if (fifth) {
                                                                      first =
                                                                          true;
                                                                      second =
                                                                          true;
                                                                      third =
                                                                          true;
                                                                      forth =
                                                                          true;
                                                                      countStars =
                                                                          5;
                                                                    }
                                                                  });
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                          MyTextFormField(
                                                            editingController:
                                                                name,
                                                            labelText: "الأسم",
                                                          ),
                                                          MyTextFormField(
                                                            editingController:
                                                                phone,
                                                            isNumber: true,
                                                            labelText:
                                                                "رقم الجوال لن يتم عرضه",
                                                          ),
                                                          MyTextFormField(
                                                            limitText: true,
                                                            editingController:
                                                                text,
                                                            isMultiLine: true,
                                                            labelText:
                                                                "رأيك يهمنا",
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(8.0),
                                                            child: Container(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              width: double
                                                                  .infinity,
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .all(
                                                                        Radius
                                                                            .circular(
                                                                          10,
                                                                        ),
                                                                      ),
                                                                      color: Theme.of(
                                                                              context)
                                                                          .unselectedWidgetColor),
                                                              child: InkWell(
                                                                onTap:
                                                                    () async {
                                                                  Map<String,
                                                                          dynamic>
                                                                      reviewMap =
                                                                      {
                                                                    'name': name
                                                                        .text,
                                                                    'phone': phone
                                                                        .text,
                                                                    'text': text
                                                                        .text,
                                                                    'stars':
                                                                        countStars
                                                                            .toString(),
                                                                    'date': DateTime
                                                                            .now()
                                                                        .toString(),
                                                                    'isBuyer':
                                                                        isBuyer,
                                                                  };
                                                                  await Firestore
                                                                      .instance
                                                                      .collection(
                                                                          "reviews")
                                                                      .where(
                                                                          'itemID',
                                                                          isEqualTo: widget
                                                                              .imageID)
                                                                      .getDocuments()
                                                                      .then(
                                                                        (value) => value
                                                                            .documents
                                                                            .forEach(
                                                                          (e) async {
                                                                            await Firestore.instance.collection('reviews').document(e.documentID).updateData({
                                                                              'review': FieldValue.arrayUnion([
                                                                                reviewMap
                                                                              ])
                                                                            });
                                                                          },
                                                                        ),
                                                                      )
                                                                      .then(
                                                                          (value) {
                                                                    Navigator.pop(
                                                                        context);
                                                                    addCartToast(
                                                                        "تم نشر تعليقك");
                                                                  });
                                                                },
                                                                child: Text(
                                                                  "أرسل",
                                                                  style: TextStyle(
                                                                      fontFamily:
                                                                          "MainFont",
                                                                      fontSize:
                                                                          18,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              }),
                                            );
                                          },
                                          child:
                                              FaIcon(FontAwesomeIcons.feather),
                                        )
                                      ],
                                    ),
                                    Container(
                                      height: 350,
                                      padding: EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                          color:
                                              Colors.orange.withOpacity(0.05),
                                          border:
                                              Border.all(color: Colors.grey),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(15))),
                                      width: double.infinity,
                                      child: StreamBuilder(
                                          stream: Firestore.instance
                                              .collection('reviews')
                                              .where('itemID',
                                                  isEqualTo: widget.imageID)
                                              .snapshots(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return Text("...");
                                            } else if (snapshot.hasError) {
                                              return Text("Error");
                                            } else {
                                              List<Reviews> listReviews = [];
                                              for (var i = 0;
                                                  i <
                                                      snapshot
                                                          .data
                                                          .documents[0]
                                                          .data['review']
                                                          .length;
                                                  i++) {
                                                String name = snapshot
                                                    .data
                                                    .documents[0]
                                                    .data['review'][i]['name'];
                                                String stars = snapshot
                                                    .data
                                                    .documents[0]
                                                    .data['review'][i]['stars'];
                                                String text = snapshot
                                                    .data
                                                    .documents[0]
                                                    .data['review'][i]['text'];
                                                String date = snapshot
                                                    .data
                                                    .documents[0]
                                                    .data['review'][i]['date'];
                                                bool isBuyer = snapshot
                                                        .data
                                                        .documents[0]
                                                        .data['review'][i]
                                                    ['isBuyer'];

                                                DateTime reviewDate =
                                                    DateTime.parse(date);
                                                var formatter =
                                                    new intl.DateFormat(
                                                        'dd/MM/yyyy');
                                                String formatDate = formatter
                                                    .format(reviewDate);

                                                listReviews.add(Reviews(
                                                  name: name,
                                                  date: formatDate,
                                                  isBuyer: isBuyer,
                                                  stars: int.parse(stars),
                                                  text: text,
                                                ));
                                              }

                                              listReviews.sort((b, a) =>
                                                  a.date.compareTo(b.date));

                                              return ListView.builder(
                                                  itemCount: listReviews.length,
                                                  itemBuilder: (context, i) {
                                                    List<String> dateList =
                                                        listReviews[i]
                                                            .date
                                                            .split('/');
                                                    DateTime dateReview;
                                                    for (var j = 0;
                                                        j < dateList.length;
                                                        j++) {
                                                      dateReview = DateTime(
                                                        int.parse(dateList[2]),
                                                        int.parse(dateList[1]),
                                                        int.parse(dateList[0]),
                                                      );
                                                    }
                                                    final date2 =
                                                        DateTime.now();

                                                    final difference = date2
                                                        .difference(dateReview)
                                                        .inDays;
                                                    String dateShow;
                                                    if (difference == 0) {
                                                      dateShow = "اليوم";
                                                    } else if (difference ==
                                                        1) {
                                                      dateShow = "أمس";
                                                    } else if (difference ==
                                                        2) {
                                                      dateShow = "قبل أمس";
                                                    } else if (difference ==
                                                        3) {
                                                      dateShow = "قبل يومين";
                                                    } else {
                                                      dateShow =
                                                          listReviews[i].date;
                                                    }
                                                    return Container(
                                                        margin:
                                                            EdgeInsets.all(8.0),
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors
                                                                .grey[300],
                                                          ),
                                                        ),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                Text(
                                                                  "${listReviews[i].name}",
                                                                ),
                                                                Text(
                                                                  "${listReviews[i].isBuyer ? "تم الشراء" : "لم يتم الشراء"}",
                                                                  style:
                                                                      TextStyle(
                                                                    color: listReviews[
                                                                                i]
                                                                            .isBuyer
                                                                        ? Colors
                                                                            .green
                                                                        : Colors
                                                                            .red,
                                                                  ),
                                                                ),
                                                                starsWidget(
                                                                  listReviews[i]
                                                                      .stars,
                                                                ),
                                                              ],
                                                            ),
                                                            Text(
                                                              listReviews[i]
                                                                  .text,
                                                              style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            ),
                                                            Text(
                                                              dateShow,
                                                              style: TextStyle(
                                                                  fontSize: 12),
                                                            ),
                                                          ],
                                                        ));
                                                  });
                                            }
                                          }),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 16.0, right: 16.0, bottom: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).unselectedWidgetColor,
                          borderRadius: BorderRadius.all(
                            Radius.circular(10),
                          ),
                        ),
                        height: 50,
                        width: double.infinity,
                        child: FlatButton(
                          child: Text(
                            word("addToCart", context),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            await fetchToMyCart();
                            if (widget.size.length == 0) {
                              int q = 0;
                              int id;

                              for (var i = 0; i < cart.length; i++) {
                                if (cart[i].itemName == widget.name &&
                                    cart[i].itemPrice == widget.price &&
                                    cart[i].itemDes == widget.des) {
                                  id = cart[i].id;
                                  q = int.parse(cart[i].quantity);
                                }
                              }
                              q++;
                              if (q == 1) {
                                await DBHelper.insert(
                                  'cart',
                                  {
                                    'name': widget.name,
                                    'price': widget.price,
                                    'image': widget.image,
                                    'des': widget.des,
                                    'q': q.toString(),
                                    'buyPrice': widget.buyPrice,
                                    'size': '',
                                    'productID': widget.imageID,
                                    'nameEn': widget.nameEn,
                                    'totalQ': quantity.toString(),
                                    'priceOld': widget.priceOld,
                                  },
                                ).whenComplete(
                                    () => addCartToast("تم وضعها في سلتك"));
                              } else {
                                int totalQint = quantity;

                                if (q > totalQint) {
                                  errorToast(word("outOfStock", context));
                                } else {
                                  await DBHelper.updateData(
                                          'cart',
                                          {
                                            'name': widget.name,
                                            'price': widget.price,
                                            'image': widget.image,
                                            'des': widget.des,
                                            'q': q.toString(),
                                            'buyPrice': widget.buyPrice,
                                            'size': '',
                                            'productID': widget.imageID,
                                            'nameEn': widget.nameEn,
                                            'totalQ': quantity.toString(),
                                            'priceOld': widget.priceOld,
                                          },
                                          id)
                                      .whenComplete(() =>
                                          addCartToast("تم وضعها في سلتك"));
                                }
                              }
                              Navigator.pop(context);
                            } else {
                              if (sizeChose == '') {
                                errorToast("أختر المقاس");
                              } else {
                                int q = 0;
                                int id;
                                for (var i = 0; i < cart.length; i++) {
                                  if (cart[i].itemName == widget.name &&
                                      cart[i].itemPrice == widget.price &&
                                      cart[i].itemDes == widget.des &&
                                      cart[i].sizeChose == sizeChose) {
                                    id = cart[i].id;
                                    q = int.parse(cart[i].quantity);
                                  }
                                }
                                q++;
                                if (q == 1) {
                                  await DBHelper.insert(
                                    'cart',
                                    {
                                      'name': widget.name,
                                      'price': widget.price,
                                      'image': widget.image,
                                      'des': widget.des,
                                      'q': q.toString(),
                                      'buyPrice': widget.buyPrice,
                                      'size': sizeChose,
                                      'productID': widget.imageID,
                                      'nameEn': widget.nameEn,
                                      'totalQ': quantity.toString(),
                                      'priceOld': widget.priceOld,
                                    },
                                  ).whenComplete(
                                      () => addCartToast("تم وضعها في سلتك"));
                                } else {
                                  int totalQint = quantity;

                                  if (q > totalQint) {
                                    errorToast(word("outOfStock", context));
                                  } else {
                                    await DBHelper.updateData(
                                            'cart',
                                            {
                                              'name': widget.name,
                                              'price': widget.price,
                                              'image': widget.image,
                                              'des': widget.des,
                                              'q': q.toString(),
                                              'buyPrice': widget.buyPrice,
                                              'size': sizeChose,
                                              'productID': widget.imageID,
                                              'nameEn': widget.nameEn,
                                              'totalQ': quantity.toString(),
                                              'priceOld': widget.priceOld,
                                            },
                                            id)
                                        .whenComplete(() =>
                                            addCartToast("تم وضعها في سلتك"));
                                  }
                                }
                                Navigator.pop(context);
                              }
                            }
                          },
                        ),
                      ),
                    )
                  ],
                ),
        ),
      ),
    );
  }

  Widget starsWidget(int stars) {
    FaIcon solidStar = FaIcon(
      FontAwesomeIcons.solidStar,
      color: Colors.yellow[700],
    );
    FaIcon emptyStar = FaIcon(
      FontAwesomeIcons.star,
      color: Colors.grey,
    );
    if (stars == 5) {
      return Row(
        children: [
          solidStar,
          solidStar,
          solidStar,
          solidStar,
          solidStar,
        ],
      );
    } else if (stars == 4) {
      return Row(
        children: [
          solidStar,
          solidStar,
          solidStar,
          solidStar,
          emptyStar,
        ],
      );
    } else if (stars == 3) {
      return Row(
        children: [
          solidStar,
          solidStar,
          solidStar,
          emptyStar,
          emptyStar,
        ],
      );
    } else if (stars == 2) {
      return Row(
        children: [
          solidStar,
          solidStar,
          emptyStar,
          emptyStar,
          emptyStar,
        ],
      );
    } else {
      return Row(
        children: [
          solidStar,
          emptyStar,
          emptyStar,
          emptyStar,
          emptyStar,
        ],
      );
    }
  }

  Widget imageCarouselItemShow(double height) {
    return networkItemShow.length == 0
        ? Container(
            height: 100,
            width: 100,
            child: Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            ),
          )
        : Container(
            height: height,
            child: Carousel(
              boxFit: BoxFit.cover,
              images: networkItemShow,
              animationCurve: Curves.easeInExpo,
              animationDuration: Duration(seconds: 1),
              autoplay: true,
              autoplayDuration: Duration(seconds: 5),
              indicatorBgPadding: 10,
              dotBgColor: Colors.transparent,
              dotColor: Colors.white,
              dotIncreasedColor: Theme.of(context).unselectedWidgetColor,
            ),
          );
  }

  List<ItemShow> itemShow = new List();
  getAllimagesFromFireStore() async {
    try {
      itemShow = new List();
      networkImage = new List();
      await FirestoreFunctions().getAllImages().then((value) {
        int listLength = value.length;
        for (var i = 0; i < listLength; i++) {
          networkImage.add(
            MeetNetworkImage(
              imageUrl: value[i].image,
              loadingBuilder: (context) => Center(
                child: CircularProgressIndicator(),
              ),
              errorBuilder: (context, e) => Center(
                child: Text('Error appear!'),
              ),
            ),
          );
          itemShow.add(value[i]);
        }

        setState(() {});
        networkImage2 = networkImage;
      });
    } catch (e) {}
  }

  getAppInfoFireBase() async {
    await FirestoreFunctions().getAppInfo().then((value) {
      setState(() {});
      appInfo = value;
    });
  }

  getImagesToShowItems() async {
    networkItemShow = [];
    await Firestore.instance
        .collection("images")
        .where("imageID", isEqualTo: widget.imageID)
        .getDocuments()
        .then(
          (value) => {
            value.documents.forEach(
              (e) {
                for (var i = 0; i < e['images'].length; i++) {
                  setState(() {});
                  networkItemShow.add(NetworkImage(e['images'][i]));
                }
              },
            )
          },
        );
  }

  double sumPrice = 0;
  double sumBuyPrice = 0;
  double eachPrice = 0;
  double eachBuyPrice = 0;
  double totalAfterTax = 0;

  bool deleteIcon = false;
  int tax = 0;
  int delivery = 0;
  bool isDeliver = true;
  List<ItemShow> cart = [];

  Future<void> fetchToMyCart() async {
    sumPrice = 0;
    sumBuyPrice = 0;
    final dataList = await DBHelper.getData('cart');
    setState(() {
      cart = dataList
          .map(
            (item) => ItemShow(
              id: item['id'],
              itemName: item['name'],
              itemPrice: item['price'],
              image: item['image'],
              itemDes: item['des'],
              quantity: item['q'],
              buyPrice: item['buyPrice'],
              sizeChose: item['size'],
              productID: item['productID'],
            ),
          )
          .toList();
    });
  }
}

List<NetworkImage> networkItemShow = [];
List<ItemShow> cartToCheck = new List();

class Reviews {
  final String name;
  final String text;
  final int stars;
  final String date;
  final bool isBuyer;

  Reviews({this.name, this.text, this.stars, this.date, this.isBuyer});
}
