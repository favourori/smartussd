import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';

launchURL(String link) async {
  String url = 'tel:$link';
  if (await canLaunch(url)) {
    print(url);
    await launch(url);
  } else {
    throw 'Could not launch $url';
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

Future getServices(String carier) async{
 if(FirebaseAuth.instance.currentUser() != null ){


try{
  var ser = await Firestore.instance
    .collection("services/$carier/services").getDocuments();

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



  Future sendCode(platform, code, aText, rText) async{
    String codeTosend = _computeCodeToSend(code, aText, rText);
    try{
      await platform.invokeMethod("moMoDialNumber", {"code": codeTosend});
      print(codeTosend);
    }on PlatformException catch(e){

      print("error check balance is $e");
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