package com.example.kene;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Toast;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {

  private static final String CHANNEL = "com.kene.momouusd";
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
//      Hover.initialize(this);

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                  if (call.method.equals("moMoDialNumber")) {
                      String code = call.argument("code");
//                      USSDCheckBalance(pin);

                      dialNumber(code);
                  }

//                  else if (call.method.equals("moMoHoverSendMoneyMoMoUser")) {
//                      String receiver = call.argument("receiver");
//                      USSDsendMoney(receiver);
//                  }
                  else {
                      result.notImplemented();
                  }
              }
            });


  }

    private void dialNumber(String code) {
        String codeToSend = code + Uri.encode("#");
        System.out.println(codeToSend);
        startActivity(new Intent("android.intent.action.CALL", Uri.parse("tel:" + codeToSend)));
    }
//
//  public String USSDCheckBalance(String pin){
//    Intent i = new HoverParameters.Builder(MainActivity.this)
//            .request("5f6751c0") // Add your action ID here
////                    .extra("momoPin1", pin) // Uncomment and add your variables if any
//            .buildIntent();
//        startActivityForResult(i, 0);
//
//      return "";
//  }


//    public String USSDsendMoney(String receiver){
//      System.out.println(" ==================== send money from platform called =======================");
//        Intent i = new HoverParameters.Builder(MainActivity.this)
//                .request("cadd1850") // Add your action ID here
//                    .extra("receiverNumber1", receiver) // Uncomment and add your variables if any
//                .buildIntent();
//        startActivityForResult(i, 0);
//
//        return "";
//    }


}
