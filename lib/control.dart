import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kene/auth/signin.dart';
import 'package:kene/pages/NeedsPermissison.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/pages/welcome.dart';
import 'package:kene/utils/functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';



class Control extends StatefulWidget {
  final analytics;

  Control({this.analytics});
  @override
  State<StatefulWidget> createState() {
    return _ControlState();
  }
}

class _ControlState extends State<Control> {
  bool isLoggedIn = false;

  var pageToGo;

  SharedPreferences prefs;
  @override

  void initState() {
    super.initState();
    updatePerOpenUsageCount();
   
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          isLoggedIn = true;
        });


        getLocale(context); // Set the locale

         SharedPreferences.getInstance().then((f){
      f.setBool("isFirstLogin", false);
      setState(() {
        prefs = f;
      });
    });
      }else{
         SharedPreferences.getInstance().then((f){
           var isFirstLogin = f.getBool("isFirstLogin");
          if(isFirstLogin == null){
              f.setBool("isFirstLogin", true);
          }
      setState(() {
        prefs = f;
      });
    });
      }
    });



    SharedPreferences.getInstance().then((prefs) async{

      setState(() {
        pageToGo =  Carriers(analytics: widget.analytics,);
      });

      var res = await checkPermission();
      if(res == PermissionStatus.neverAskAgain){
        setState(() {
          pageToGo =  NeedsPermission(analytics: widget.analytics,);
        });
        print("is going to neverask again");
        return 0;
      }
      else{
        setState(() {
          pageToGo =  Carriers(analytics: widget.analytics,);
        });
        return 0;
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return prefs != null && prefs.getBool("isFirstLogin")  ? Welcome()  : isLoggedIn ? pageToGo : Signin();
  }
}



