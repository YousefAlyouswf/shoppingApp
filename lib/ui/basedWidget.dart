import 'package:flutter/material.dart';
import 'package:shop_app/ui/sizingInfo.dart';

class BasedWidget extends StatelessWidget {
  final Widget Function(BuildContext context, SizingInfo sizingInfo) builder;
  const BasedWidget({Key key, this.builder}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
