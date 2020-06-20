import 'package:shop_app/models/sizeListModel.dart';

class ListHirezontalImage {
  String name;
  String image;
  String description;
  String price;
  String buyPrice;
  String category;
  bool show;
  String imageID;
  List<String> size;
  List<SizeListModel> sizeModel;
  String totalQuantity;

  ListHirezontalImage({
    this.name,
    this.image,
    this.description,
    this.price,
    this.category,
    this.show,
    this.imageID,
    this.buyPrice,
    this.size,
    this.sizeModel,
    this.totalQuantity,
  });
}
