import 'package:shop_app/models/sizeListModel.dart';

class ListHirezontalImage {
  String name;
  String nameEn;
  String image;
  String description;
  String descriptionEn;
  String price;
  String buyPrice;
  String category;
  bool show;
  String imageID;
  List<String> size;
  List<SizeListModel> sizeModel;
  int totalQuantity;
  String priceOld;
  int percentage;

  ListHirezontalImage({
    this.name,
    this.nameEn,
    this.image,
    this.description,
    this.descriptionEn,
    this.price,
    this.category,
    this.show,
    this.imageID,
    this.buyPrice,
    this.size,
    this.sizeModel,
    this.totalQuantity,
    this.priceOld,
    this.percentage,
  });
}
