import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:kene/pages/success.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';


launchURL(String link) async {
  String url = 'tel:$link#';
  if (await canLaunch(url)) {
    print(url);
    await launch(url);
  } else {
    throw 'Could not launch $url o';
  }
}

Future<Null> sendAnalytics(analytics, eventName, parameters) async{
  await analytics.logEvent(
    name:"$eventName",
    parameters: parameters,
  ).then((f) =>
      print("event logged")
  );
} 

Future getServices(String carrier) async{
 if(FirebaseAuth.instance.currentUser() != null ){


try{
  var ser = await Firestore.instance
    .collection("services/$carrier/services").getDocuments();

  print(ser.documents[0].data);

}
catch(e){
  print(e);
}
 }
 else{
   print("not loged in");
 }


}


bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}


Future sendCode(platform, code, aText, rText, context) async{
  String codeToSend = _computeCodeToSend(code, aText, rText);
  if(Platform.isIOS){
    launchURL(codeToSend+"");

    Future.delayed(Duration(seconds: 1)).then((f){
      Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage()));
    });
  }
  else{
    try{
      print("beforeee wait" );
      Future.delayed(Duration(seconds: 2)).then((f){
        Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage()));
      });
      await platform.invokeMethod("moMoDialNumber", {"code": codeToSend});
      print("afterrr await");
      print(codeToSend);

    }on PlatformException catch(e){

        print("error check balance is $e");
      }
    }



}


  Future askCallPermission(platform) async{
    try{
      await platform.invokeMethod("nokandaAskCallPermission");
    }
    on PlatformException catch(e){
      print("error on asking permision is $e");
    }
  }


String _computeCodeToSend(String rawCode, aText, rText){
  String tmp = "";
  for(int x=0; x < rawCode.length; x++){
      if(rawCode[x] == "N"){
          tmp += rText;
      }
      else if(rawCode[x] == "A"){
          tmp += aText;
      }
      else if(rawCode[x] == " "){
        continue;
      }
      else if(rawCode[x] == "  "){
        continue;
      }
      else{
        tmp += rawCode[x];
      }
  }

  return tmp;
}

 Future<bool> hasInternetConnection() async{
   try {
     final result = await InternetAddress.lookup('google.com');
     if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
       return true;
     }
   } on SocketException catch (_) {
     return false;
   }
  return false;
}


Future<void> share() async {
  String text = "";
  String url = "";

  Firestore.instance.collection("settings").getDocuments().then((d){
    List docs = d.documents;
    for(var item in docs){
      print(item.documentID);
      if(item.documentID == "share_text"){
        text = item['text'];
        url = item['url'];

      }
    }

    print("$text and $url");

    FlutterShare.share(
        title: 'Nokanda App',
        text: '$text',
        linkUrl: '$url',
        chooserTitle: 'Share Nokanda App'
    );

  });


}


void addTransactions(String label, int amount){
  Firestore.instance.collection("transactions").add({"service": label, "amount":amount});

}


getLocale(context){
  var locale;
  SharedPreferences.getInstance().then((p){
    locale = p.getString("locale") != null ? p.getString("locale") : "en";
    // Add locale to stream
    var appBloc = BlocProvider.of(context);

    appBloc.localeIn(locale);
  });


}

setLocale(v){
  SharedPreferences.getInstance().then((p){
    p.setString("locale", v);
    print(v);
    // Add locale to sharedPreference

  });



}