class MyOrderModel {
  final List<ItemModel> items;

  final String city;
  final String date;
  final String driverID;
  final String driverName;
  final String lat;
  final String long;
  final String orderID;
  final String payment;
  final String phone;
  final String status;
  final String total;
  final String docID;
  final String address;
  final String postal;
  final String customerName;
  MyOrderModel({
    this.address,
    this.postal,
    this.date,
    this.driverID,
    this.driverName,
    this.lat,
    this.long,
    this.orderID,
    this.payment,
    this.phone,
    this.status,
    this.total,
    this.items,
    this.city,
    this.customerName,
    this.docID,
  });
}

class ItemModel {
  final String price;
  final String name;
  final String quatity;
  final String productID;

  ItemModel({this.price, this.name, this.quatity, this.productID});
}
