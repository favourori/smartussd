import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kene/auth/signin.dart';
import 'package:kene/pages/cariers.dart';
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
  bool isLogedIn = false;


  SharedPreferences prefs;

  
  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((f){
      f.setBool("isFirstLogin", true);
      setState(() {
        prefs = f;
      });
    });
    FirebaseAuth.instance.currentUser().then((user) {
      if (user != null) {
        setState(() {
          isLogedIn = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return prefs != null && prefs.getBool("isFirstLogin")  ? Welcome()  : isLogedIn ? Carriers(analytics: widget.analytics,) : Signin();
  }
}


class Welcome extends StatelessWidget{
  @override
  Widget build(BuildContext context) { 

    return Material(child:
     Container(
       padding: EdgeInsets.symmetric(horizontal: 15, ),
       decoration: BoxDecoration(
         color: Colors.orangeAccent
       ),
       child: Column(
      children: <Widget>[
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.15,
        ),
        Text("Welcome to Nokanda", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 40),),

        SizedBox(
          height: MediaQuery.of(context).size.height * 0.1,
        ),
        // Text("Cool things you can do with Nokanda", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 25),),

        // SizedBox(
        //   height: MediaQuery.of(context).size.height * 0.1,
        // ),
        Text("1.", style: TextStyle(color: Colors.white, fontSize: 70),),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.05,
        ),
        Text("Send money to a contact on your phone.", textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 20),),

        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Text("Skip", style: TextStyle(color: Colors.white),),
              ),
            ),

            Expanded(
              flex: 1,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children:displayDots(0),
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Center(
                child: Text("Next", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        )
      ],
    ),),);
  }

  displayDots(activeIndex){
    List<Widget> tmp = [];

    var color = Colors.white;
    for(int i=0;  i < 3; i ++){
      if (i == activeIndex){
         color = Colors.red;
      }
      else{
         color = Colors.white;
      }
        tmp.add(Container(
          margin: EdgeInsets.only(right: 5),
          height: 10,
          width: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5)
          ),
        ));
    }

    return tmp;
  }
  
}