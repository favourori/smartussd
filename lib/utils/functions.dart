import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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

Future getServices() async{
//  if(FirebaseAuth.instance.currentUser() != null ){
//      Firestore.instance.collection("services").getDocuments().then((s){
//      print(s);
//  });
//  }
//  else{
//    print("not loged in");
//  }

}



  sendCode(platform, code, aText, rText) async{
    String codeTosend = _computeCodeToSend(code, aText, rText);
    try{
      print(codeTosend);
      await platform.invokeMethod("moMoDialNumber", {"code": codeTosend});
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
      else{
        tmp += rawCode[x];
      }
  }

  return tmp;
}