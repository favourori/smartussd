import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:kene/pages/success.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:kene/database/db.dart';
import 'package:kene/pages/NeedsPermissison.dart';
import 'package:permission_handler/permission_handler.dart';


requestPermission() async{
  Map<PermissionGroup, PermissionStatus> permissions = await PermissionHandler().requestPermissions([PermissionGroup.phone]);
  print("asked for permission and answer is");
  print(permissions[PermissionGroup.phone]);

  return permissions[PermissionGroup.phone];
}

checkPermission() async{

  PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.phone);
  print("app permisions for phone is");
  print(permission);
  return permission;

}

openAppSettings() async{
  bool isOpened = await PermissionHandler().openAppSettings();
  print(isOpened);
  return isOpened;
}



// Launch given URL
launchURL(String link) async {
  String url = link;
  if (await canLaunch(url)) {
    print(url);
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

// Send events analytics to fireBase
Future<Null> sendAnalytics(analytics, eventName, parameters) async{

  // Replace spaces with underscore in the eventName
  var eventNameToSend = "";

  for(int i=0; i < eventName.length; i++ ){
    if(eventName[i] == " "){
      eventNameToSend += "_";
    }
    else{
      eventNameToSend += eventName[i];
    }
  }

  await analytics.logEvent(
    name:"$eventNameToSend",
    parameters: parameters,
  ).then((f) =>
      print("event logged")
  );
}


addToShortcut(Map<String, dynamic> service) async{
  KDB db = KDB();
  print(service);
  var userID = await getUserID();
  db.firestoreAdd("shortcuts/$userID/shortcuts", service);

}


deleteShortcut(String docID) async{
  KDB db = KDB();
  var userID = await getUserID();
  db.firestoreDelete("shortcuts/$userID/shortcuts", docID);

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
   print("not logged in");
 }


}


// Return user ID
Future<String> getUserID() async{
  var user = await FirebaseAuth.instance.currentUser();
  if (user != null){
    return user.uid.toString();
  }
  return "";
}


// Return true if string is numeric
bool isNumeric(String str) {
  if (str == null) {
    return false;
  }
  return double.tryParse(str) != null;
}



// Call platform code and make call to given url/call code
Future sendCode(platform, code, aText, rText, context) async{
  int motive = 1;

  String codeToSend = computeCodeToSend(code, aText, rText);
  if(Platform.isIOS){


    try{
      var res = await platform.invokeMethod("moMoDialNumber", {"code": codeToSend, "motive": motive});
      print(res);

    }on PlatformException catch(e){

      print("error check balance is $e");
      Navigator.push(context, MaterialPageRoute(builder: (context) => NeedsPermission()));

    }


    Future.delayed(Duration(seconds: 1)).then((f){
      Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage()));
    });
  }
  else{
    try{

        requestPermission().then((res) async{
          if(res == PermissionStatus.granted){

            var sendCode = await platform.invokeMethod("moMoDialNumber", {"code": codeToSend});
            print("resposne from sendcode");
            print(sendCode);

            Future.delayed(Duration(seconds: 5)).then((f){
              Navigator.push(context, MaterialPageRoute(builder: (context) => SuccessPage()));
            });
          }

          else if(res == PermissionStatus.neverAskAgain){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NeedsPermission()));
          }
          else{
            // Do nothing here
          }
        });

    }on PlatformException catch(e){

        print("error check balance is $e");
        Navigator.push(context, MaterialPageRoute(builder: (context) => NeedsPermission()));
      }
    }



}


// Invoke native code to ask for user permission for calls [Android only]
  Future askCallPermission(platform) async{
    try{
      await platform.invokeMethod("nokandaAskCallPermission");
    }
    on PlatformException catch(e){
      print("error on asking permision is $e");
    }
  }



// Decode and add appropriate numbers to the code to eventually send as phone call
String computeCodeToSend(String rawCode, aText, rText){
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


// Check if phone has internet connection
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

// Check if user is authenticated
bool isAuthenticatedUser(){
  var isAuth;
  FirebaseAuth.instance.currentUser().then((f){
    if(f != null){
      isAuth = f;
    }
  });


  return isAuth != null;

}

upDateButtonAction(){
  Firestore.instance.collection("settings").getDocuments().then((d){
    List docs = d.documents;
    for(var item in docs){
      print(item.documentID);
      if(item.documentID == "share_text"){

        launchURL(item['url']);

      }
    }


  });
}

// Invoke the  share apps screen asking users to share the app
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

    FlutterShare.share(
        title: 'Nokanda App',
        text: '$text',
        linkUrl: '$url',
        chooserTitle: 'Share Nokanda App'
    );

  });


}


// Record the transactions made to database
void addTransactions(String label, int amount){
  Firestore.instance.collection("transactions").add({"service": label, "amount":amount, "created_at": DateTime.now()});

}

Future<Map<String, String>> getDeviceVersionAndBuildNumber() async{
  Map<String, String> versionBuildNumber = {};

  var packageInfo = await PackageInfo.fromPlatform();

  versionBuildNumber = {
    "build": packageInfo.buildNumber.toString(),
    "version":packageInfo.version.toString(),
  };

  return versionBuildNumber;
}



// Check if device is supported to display services
// Update the boolean to handle the different cases of supported devices and unsupported
Future<bool> isOldVersion() async{

  var phoneBuildVersion = await getDeviceVersionAndBuildNumber();

  // Get the supported minimum version from database
  var f = await Firestore.instance.collection("settings").getDocuments();

  var minimumSupportedVersion = f.documents[0].data['minimum_supported_version'];


  double phoneVersion = double.parse(phoneBuildVersion['version'].split(".").join());

  double phoneBuild = double.parse(phoneBuildVersion['build']);

  double minVersion = double.parse(minimumSupportedVersion.split("+")[0].split(".").join());

  double minBuild = double.parse(minimumSupportedVersion.split("+")[1]);

  return phoneVersion < minVersion || (phoneVersion == minVersion && phoneBuild < minBuild);

}

// Get the current device locale
getLocale(context){
  var locale;
  SharedPreferences.getInstance().then((p){
    locale = p.getString("locale") != null ? p.getString("locale") : "en";
    // Add locale to stream
    var appBloc = BlocProvider.of(context);

    appBloc.localeIn(locale);
  });


}


// Set the selected locale to device
setLocale(v){
  SharedPreferences.getInstance().then((p){
    p.setString("locale", v);
    print(v);
    // Add locale to sharedPreference

  });

}

// Get the current app version of the logged in user
Future<String> getCurrentVersionOnFireBase(String uid) async{
  String version = "";
  if(isAuthenticatedUser()){
      // Get stored version and return
    var userRecord = await Firestore.instance.collection("users").where("user_id", isEqualTo: uid).getDocuments();
    version =  userRecord.documents[0]['version'];
  }

  return version;

}


// Update the version of the app on FireBase
updateVersion() async{
  String userID = await getUserID();
  if(userID.isNotEmpty){

    String userCurrentVersionFromFireBase = await getCurrentVersionOnFireBase(userID);
    Map<String, dynamic> deviceUserVersion = await getDeviceVersionAndBuildNumber();
    String deviceVersionString = deviceUserVersion['version']+"+"+deviceUserVersion['build'];


    // Update the database if not equal
    if(deviceVersionString != userCurrentVersionFromFireBase){
      String uid = await getUserID();

    var userData = await Firestore.instance.collection("users").where("user_id", isEqualTo: userID).getDocuments();


    // In scenarios there are more than one record for this user
      for(int i=0; i < userData.documents.length; i++){

        var userDocumentID = userData.documents[i].documentID;
        Firestore.instance.collection("users").document(userDocumentID).updateData({
          "version": deviceVersionString
        });

      }


    }


  }
}

Future<Map> getPageData(String pageName) async{
  var pages =  await Firestore.instance.collection("/pages").getDocuments();
  for(var doc in pages.documents){
    if(doc.documentID == pageName){
      return doc.data;
    }
  }

  return {};
}

String getTextFromPageData(Map pageData, String str, String locale){
//  print(pageData);
//  print(locale);
  if(pageData.containsKey(str)){
//    print(pageData[str][locale]);
    var data = pageData[str][locale];
    return data != null ? data : pageData[str]['en'];  // Default to english if the locale is not available
  }

  return "";
}

String addThousandDelimeter(String value){

  // 1000
  // 10000
 // 100000
 // 1000000
  String tmp = "";
  bool canAddComma = true;
  int threesCount = 0;

  if(value.length > 3){
    for(int i=value.length-1; i >=0; i--){
      threesCount += 1;
      tmp = value[i] + tmp;
      if(threesCount == 3 && canAddComma){

        // Add the comma
        tmp = ","+tmp;
        threesCount = 0;
        if(i < 4){
          canAddComma = false;
        }
      }
    }
    return tmp;
  }
  return value;
  
}

// setLastVersionNumber(){
//   String version = "";
//   SharedPreferences.getInstance().then((p){
//     p.setString("version", version);
//   });
// }

