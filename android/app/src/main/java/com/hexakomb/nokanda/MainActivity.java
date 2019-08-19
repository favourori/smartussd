package com.hexakomb.nokanda;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Bundle;
import android.widget.Toast;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

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




    new MethodChannel(getFlutterView(), CHANNEL).setMethodCallHandler(
            new MethodChannel.MethodCallHandler() {
              @Override
              public void onMethodCall(MethodCall call, MethodChannel.Result result) {
                  if (call.method.equals("moMoDialNumber")) {
                      String code = call.argument("code");

                      startService(new Intent(MainActivity.this, USSDService.class));
                      dialNumber(code);
                  }

                  else if(call.method.equals("nokandaAskCallPermission")){
                      askForCallPermission();
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

    private void askForCallPermission(){
        int MY_PERMISSIONS_REQUEST_READ_CONTACTS = 98234;

        //checking if app has call permisions
        if(ContextCompat.checkSelfPermission(MainActivity.this, Manifest.permission.CALL_PHONE) != PackageManager.PERMISSION_GRANTED){
            //request permision here
            ActivityCompat.requestPermissions(MainActivity.this,
                    new String[]{Manifest.permission.CALL_PHONE},
                    MY_PERMISSIONS_REQUEST_READ_CONTACTS);

        }
    }


}
