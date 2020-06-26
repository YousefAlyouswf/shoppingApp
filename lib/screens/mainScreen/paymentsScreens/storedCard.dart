import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';
import 'package:shop_app/screens/mainScreen/paymentsScreens/payment-service.dart';
import 'package:shop_app/widgets/widgets.dart';

class StoredCard extends StatefulWidget {
  final String amount;

  const StoredCard({Key key, this.amount}) : super(key: key);
  @override
  _StoredCardState createState() => _StoredCardState();
}

class _StoredCardState extends State<StoredCard> {
  List cards = [
    {
      'cardNumber': '4242 5678 9123 1245',
      'expiryDate': '01/24',
      'cardHolderName': 'Yousef Al Youswf',
      'cvvCode': '123',
      'showBackView': false, //
    },
    {
      'cardNumber': '5155 5432 1012 4563',
      'expiryDate': '11/22',
      'cardHolderName': 'Shahad Almashaabi',
      'cvvCode': '456',
      'showBackView': false, //
    }
  ];
  payViaExistingCard(BuildContext context, card) {
    var respose = StripeService.payViaExistingCard(
      amount: widget.amount,
      currency: 'USD',
      card: card,
    );
    if (respose.success == true) {
      Scaffold.of(context)
          .showSnackBar(
            SnackBar(
              content: Text(respose.message),
              duration: Duration(seconds: 2),
            ),
          )
          .closed
          .then((value) {
        Navigator.pop(context);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    infoToast("أضغط مرتين لعرض البطاقه من الخلف");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: ListView.builder(
          itemCount: cards.length,
          itemBuilder: (context, i) {
            return InkWell(
              onTap: () {
                payViaExistingCard(context, cards[i]);
              },
              onDoubleTap: () {
                setState(() {
                  cards[i]['showBackView'] = !cards[i]['showBackView'];
                });
              },
              child: CreditCardWidget(
                cardNumber: cards[i]['cardNumber'],
                expiryDate: cards[i]['expiryDate'],
                cardHolderName: cards[i]['cardHolderName'],
                cvvCode: cards[i]['cvvCode'],
                showBackView: cards[i]['showBackView'],
              ),
            );
          }),
    );
  }
}
