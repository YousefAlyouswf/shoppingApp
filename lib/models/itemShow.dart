class ItemShow {
  final int id;
  final String quantity;
  final String itemName;
  final String nameEn;
  final String itemPrice;
  final String itemDes;
  final String itemDesEn;
  final String image;
  final String imageID;
  final String buyPrice;
  final List<String> size;
  final String sizeChose;
  final String productID;
  final String totalQuantity;
  final String preiceOld;

  ItemShow({
    this.id,
    this.itemName,
    this.itemPrice,
    this.itemDes,
    this.itemDesEn,
    this.image,
    this.quantity,
    this.imageID,
    this.buyPrice,
    this.size,
    this.sizeChose,
    this.productID,
    this.totalQuantity,
    this.nameEn,
    this.preiceOld,
  });
}
