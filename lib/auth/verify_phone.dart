import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kene/control.dart';
import 'package:kene/pages/homepage.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/custom_nav.dart';

class PhoneVerify extends StatefulWidget {
  final analytics;
  final observer;
  final signInPhone;

  PhoneVerify({this.analytics, this.observer, this.signInPhone});
  @override
  _PhoneVerifyState createState() => _PhoneVerifyState();
}

class _PhoneVerifyState extends State<PhoneVerify> {
  GlobalKey<FormState> _formkey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String code;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: Form(
      key: _formkey,
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: ListView(
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.25,
              ),
              Align(alignment: Alignment.center, child: Text("noKanda", style: TextStyle(fontSize: 18),)),
                SizedBox(
                height:  MediaQuery.of(context).size.height * 0.18,
              ),
              TextFormField(
                onChanged: (v){
                  this.code = v;
                },
                keyboardAppearance: Brightness.dark,
                // textAlign: TextAlign.center,
                keyboardType: TextInputType.phone,
                cursorColor: Colors.orangeAccent,
                decoration: InputDecoration(
                    hintText: "Enter code you received",
                    hintStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                    icon: Icon(Icons.confirmation_number),

                    border: InputBorder.none),
              ),
              SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: (){
                  if(code != ""){
                       FirebaseAuth.instance.currentUser().then((user) {
                    if (user != null) {
                      print("thanks for verifying your phone, welcome");
                      Navigator.push(context, CustomPageRoute(navigateTo: Control()));
                    } else {
                      // Navigator.pop(context);
                      widget.signInPhone(code);
                    }
                  });
                  }
                  else{
                    print("enter number");
                  }
                },
                child: Container(
                  decoration: BoxDecoration(color: Colors.orangeAccent, 
                  borderRadius: BorderRadius.circular(40)
                  ),
                  width: MediaQuery.of(context).size.width,
                  height: 50,  
                  child: Center(child: Text("Verify", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),)),
                ),
              )
            ],
          )
          ),
    ));
  }





}
