import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kene/auth/signin.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/pages/welcome.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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


  SharedPreferences prefs;
  @override

  void initState() {
    super.initState();

   
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
  }

  @override
  Widget build(BuildContext context) {
    return prefs != null && prefs.getBool("isFirstLogin")  ? Welcome()  : isLoggedIn ? Carriers(analytics: widget.analytics,) : Signin();
  }
}


