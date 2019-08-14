package com.hexakomb.nokanda;

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

//  TelephonyManager tel = (TelephonyManager) getSystemSerivce(Context.TELEPHONY_SERVICE);
//  String netWorkOperator = tel.getNetworkOperator();

    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                  if (call.method.equals("moMoDialNumber")) {
                      String code = call.argument("code");

                      startService(new Intent(MainActivity.this, USSDService.class));
                      dialNumber(code);
                  }
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


}
