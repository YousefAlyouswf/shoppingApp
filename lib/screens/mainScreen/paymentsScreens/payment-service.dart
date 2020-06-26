import 'dart:convert';

import 'package:http/http.dart';
import 'package:stripe_payment/stripe_payment.dart';

class StripeTransactionResponse {
  final String message;
  final bool success;

  StripeTransactionResponse({this.message, this.success});
}

class StripeService {
  static String apiBase = 'https://api.stripe.com/v1';
  static String secret =
      'sk_test_51Gu5lDAqGkPlr5IZXZy2lgk6aomdcPjyAmGTdChf0OtVhMmi7JtMnufOPNPLgXBfxqwrDocqNOXjIeRmsuQtKXgp00lCyJ8K8h';
  static String paymentAPIURL = '${StripeService.apiBase}/payment_intents';
  static Map<String, String> header = {
    'Authorization': 'Bearer $secret',
    'Content-Type': 'application/x-www-form-urlencoded',
  };

  static init() {
    StripePayment.setOptions(StripeOptions(
        publishableKey:
            "pk_test_51Gu5lDAqGkPlr5IZhxqF8WC14kzDyiPtpcg6makkApVbF9TkasyzmAhftyVG0eQFLFuF5lzVyhGltO8ShXx5BFf800LR0yNOD9",
        merchantId: "Test",
        androidPayMode: 'test'));
  }

  static StripeTransactionResponse payViaExistingCard(
      {String amount, String currency, card}) {
    return StripeTransactionResponse(
        message: 'Transacation Successful', success: true);
  }

  static Future<StripeTransactionResponse> payWithNewCard(
      {String amount, String currency}) async {
    try {
      var paymentMethod = await StripePayment.paymentRequestWithCardForm(
        CardFormPaymentRequest(),
      );
      var paymentIntent = await StripeService.createPaymentIntent(
        amount,
        currency,
      );
      var response = await StripePayment.confirmPaymentIntent(
        PaymentIntent(
          clientSecret: paymentIntent['client_secret'],
          paymentMethodId: paymentMethod.id,
        ),
      );
      if (response.status == "succeeded") {
        return StripeTransactionResponse(
            message: 'عملية الدفع ناجحه', success: true);
      } else {
        return StripeTransactionResponse(
            message: 'فشلت عميلة الدفع', success: false);
      }
    } catch (e) {
      return StripeTransactionResponse(
          message: 'e', success: false);
    }
  }

  static Future<Map<String, dynamic>> createPaymentIntent(
      String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': amount,
        'currency': currency,
        'payment_method_types[]': 'card',
      };
      var response = await post(
        StripeService.paymentAPIURL,
        body: body,
        headers: header,
      );
      return jsonDecode(response.body);
    } catch (e) {
      print("Error charching user $e");
    }
    return null;
  }
}
