package com.example.shop_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Context
import android.content.ContextWrapper
import android.content.Intent
import android.content.IntentFilter
import android.os.BatteryManager
import android.os.Build.VERSION
import android.os.Build.VERSION_CODES
import android.app.Activity
import androidx.appcompat.app.AppCompatActivity
import android.os.Bundle
import android.view.View
import android.widget.Button
import com.paytabs.paytabs_sdk.payment.ui.activities.PayTabActivity
import com.paytabs.paytabs_sdk.utils.PaymentParams
import androidx.core.app.ComponentActivity
import androidx.core.app.ComponentActivity.ExtraData
import androidx.core.content.ContextCompat.getSystemService
import android.icu.lang.UCharacter.GraphemeClusterBreak.T
import android.util.Log

class MainActivity: FlutterActivity() {
  private val CHANNEL = "samples.flutter.dev/battery"
  private var result_global: MethodChannel.Result? = null

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { 
        call, result ->
      result_global = result
      if (call.method == "getPayTabs") {
        val intent = Intent(applicationContext, PayTabActivity::class.java)
        intent.putExtra(PaymentParams.MERCHANT_EMAIL,"api.chc1989@gmail.com")
        intent.putExtra(
        PaymentParams.SECRET_KEY, "kvQYOuL2S4hdpbTKFfd9rS3kzgn2I6G3Cx1q1NsURK7gV00BgeLH7P2G5qJOwqR8YSzZF2UxM1NI1Okh25ZaV2Q0sAOZ0G8YyHYe")//Add your Sec
       intent.putExtra(PaymentParams.LANGUAGE, PaymentParams.ENGLISH)

        val hashMap: HashMap<String, String> = call.arguments as HashMap<String, String>
 
        
        intent.putExtra(PaymentParams.LANGUAGE, PaymentParams.ARABIC)
        intent.putExtra(PaymentParams.TRANSACTION_TITLE, "Test Paytabs android library")
        intent.putExtra(PaymentParams.AMOUNT, hashMap["amount"]?.toDouble())

        intent.putExtra(PaymentParams.CURRENCY_CODE, "SAR")
        intent.putExtra(PaymentParams.CUSTOMER_PHONE_NUMBER,  hashMap["phone"])
        intent.putExtra(PaymentParams.CUSTOMER_EMAIL, "customer-email@example.com")
        intent.putExtra(PaymentParams.ORDER_ID, hashMap["orderID"])
        intent.putExtra(PaymentParams.PRODUCT_NAME, hashMap["items"])

           //Billing Address
        intent.putExtra(PaymentParams.ADDRESS_BILLING,  hashMap["address"])
        intent.putExtra(PaymentParams.CITY_BILLING, hashMap["city"])
        intent.putExtra(PaymentParams.STATE_BILLING, hashMap["city"])
        intent.putExtra(PaymentParams.COUNTRY_BILLING, "SAR")
        intent.putExtra(
                PaymentParams.POSTAL_CODE_BILLING,
                hashMap["zipCode"]
        ) ///Put Country Phone code if Postal code not available '00973'

          //Shipping Address
        intent.putExtra(PaymentParams.ADDRESS_SHIPPING,  hashMap["address"])
        intent.putExtra(PaymentParams.CITY_SHIPPING, hashMap["city"])
        intent.putExtra(PaymentParams.STATE_SHIPPING, hashMap["city"])
        intent.putExtra(PaymentParams.COUNTRY_SHIPPING, "SAR")
        intent.putExtra(
            PaymentParams.POSTAL_CODE_SHIPPING,
            hashMap["zipCode"]) //Put Country Phone code if Postal code not available '00973'

//Payment Page Style
intent.putExtra(PaymentParams.PAY_BUTTON_COLOR, "#2474bc")
//Tokenization
intent.putExtra(PaymentParams.IS_TOKENIZATION, true)
startActivityForResult(intent, PaymentParams.PAYMENT_REQUEST_CODE)
      } else {
        result.notImplemented()
      }
    }
  }

   override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent? ) {
    super.onActivityResult(requestCode, resultCode, data)
    if (resultCode == RESULT_OK && requestCode == PaymentParams.PAYMENT_REQUEST_CODE) {
        val hashMap: HashMap<String, String> = HashMap()
        if(data?.getStringExtra(PaymentParams.RESPONSE_CODE)=="100"){
            hashMap[PaymentParams.RESPONSE_CODE] = data.getStringExtra(PaymentParams.RESPONSE_CODE)
            hashMap[PaymentParams.TRANSACTION_ID] = data.getStringExtra(PaymentParams.TRANSACTION_ID)
            hashMap[PaymentParams.RESULT_MESSAGE] = data.getStringExtra(PaymentParams.RESULT_MESSAGE)
        }else{
             hashMap[PaymentParams.RESPONSE_CODE] = data!!.getStringExtra(PaymentParams.RESPONSE_CODE)
             hashMap[PaymentParams.RESULT_MESSAGE] = data!!.getStringExtra(PaymentParams.RESULT_MESSAGE)
        }
  
        if (data.hasExtra(PaymentParams.TOKEN) && !data.getStringExtra(PaymentParams.TOKEN)!!.isEmpty()) {
            Log.e("Tag", data.getStringExtra(PaymentParams.TOKEN))
            Log.e("Tag", data.getStringExtra(PaymentParams.CUSTOMER_EMAIL))
            Log.e("Tag", data.getStringExtra(PaymentParams.CUSTOMER_PASSWORD))

            hashMap[PaymentParams.TOKEN] = data!!.getStringExtra(PaymentParams.TOKEN)
            hashMap[PaymentParams.CUSTOMER_EMAIL] = data!!.getStringExtra(PaymentParams.CUSTOMER_EMAIL)
            hashMap[PaymentParams.CUSTOMER_PASSWORD] = data!!.getStringExtra(PaymentParams.CUSTOMER_PASSWORD)
        }
        result_global?.success(hashMap)
    }else{
        result_global?.success("")
    }
}
 
}

