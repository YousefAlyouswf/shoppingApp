import 'package:flutter/cupertino.dart';

import 'lang/appLocale.dart';

List<String> english = [
  'Home',
  'deliver',
  'Cart',
  'My Order',
  'Categories',
  "a",
  'Settings',
  'Dark Mode',
  'App Info',
  'Guest',
  'اللغة العربية',
  'Shopping Cart',
  'Items',
  'Edit',
  'To delete drag to left',
  'R.S.',
  'Buy R.S',
  "Continue Shopping",
  "Shipping Info",
  "Choose Your Address",
  "New Address",
  "Continue",
  "Personal Info",
  "Full Name",
  "Phone",
  "Address",
  "Type your national Address",
  "Select from map",
  "OR",
  "City",
  "District",
  "Street",
  "House Number",
  "Type Full Name",
  "Phone Number 10 Digits",
  "Choose your Address",
  'NEW ARRIVAL',
  "Cart is empty\nGo to products page to add your items",
  "Products",
  "Size",
  "Tax included",
  "No order sumbitted",
  "Order date:",
  "Product",
  "Quantity",
  "Price",
  "Cancel Order",
  "Your order will cancel",
  "Sure",
  "Exit",
  "You cannot cancel this order",
  "Copied",
  "Order #:",
  "Pickup location",
  "Order Received",
  "Ready to Pickup",
  "Ready to deliver",
  "On its way",
  "Received",
  "Delivered",
  "Tax & shipping included",
  "R.S"
  //53
];
List<String> arabic = [
  'الرئيسية',
  'المندوب',
  'السلة',
  'طلباتي',
  'الأقسام',
  "a",
  'الإعدادات',
  'وضع الداكن',
  'معلومات التطبيق',
  'زائر',
  'English',
  'سلة التسوق',
  'المحتويات',
  'تعديل',
  "للحذف إسحب إلى اليسار",
  'ر.س.',
  'ر.س  شراء',
  "الرجوع للتسوق",
  "معلومات الشحن",
  "أختر عنوانك",
  "عنوان جديد",
  "متابعه",
  "البيانات الشخصية",
  "الأسم كامل",
  "رقم الجوال",
  "العنوان",
  "أدخل عنوانك الوطني هنا",
  "حدد من الخريطة",
  "أو",
  "المدينة",
  "الحي",
  "الشارع",
  "رقم المنزل",
  "أكتب الأسم كامل",
  "رقم الجوال 10 أرقام",
  "أكتب العنوان بالشكل الصحيح",
  'أحدث ماوصلنا',
  "سلة التسوق فارغة\nيمكنك الذهاب الى صفحة المنتجات لإظافة ماترغب به",
  "المنتجات",
  "المقاس",
  "السعر شامل الضريبة",
  "لا يوجد لديك طلبات",
  "تاريخ الطلب",
  "المنتج",
  "العدد",
  "السعر",
  "إلغاء الطلب",
  "سوف يتم الغاء طلبك",
  'تأكيد',
  'خروج',
  "لا يكمنك إلغاء الطلب",
  "تم النسخ",
  "رقم الطلب:",
  "موقع الإستلام",
  "أستلمنا طلبك",
  "جاهز للإستلام",
  "جاهز لتوصيل",
  "طلبك في الطريق",
  "تم التسليم",
  "تم التوصيل",
  "السعر شامل الضريبة والتوصيل",
  "ر.س",
];

String word(String key, BuildContext context) {
  return AppLocale.of(context).getTranslated(key);
}
