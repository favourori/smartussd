import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


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
  if(FirebaseAuth.instance.currentUser() != null ){
      Firestore.instance.collection("services").getDocuments().then((s){
      print(s);
  });
  }
  else{
    print("not loged in");
  }

}