import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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

class _PhoneVerifyState extends State<PhoneVerify>
    with SingleTickerProviderStateMixin {
  GlobalKey<FormState> _formkey = GlobalKey();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String code;
  bool isBtnClicked = false;

  bool isAuthenticating = true;

  durationCount() {
    var duration = Duration(seconds: 10);
    Future.delayed(duration).then((f) {
      setState(() {
        isAuthenticating = false;
      });
    });
  }

  @override
  void initState() {
    super.initState();

    durationCount();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: isAuthenticating
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SpinKitFadingFour(
                      color: Colors.orangeAccent,
                      size: 120.0,
                      controller: AnimationController(
                          vsync: this,
                          duration: const Duration(milliseconds: 1200)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Almost there",
                        style: TextStyle(fontSize: 28),
                      ),
                    )
                  ],
                ),
              )
            : Form(
                key: _formkey,
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: ListView(
                      children: <Widget>[
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                        ),
                        Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Nokanda",
                              style: TextStyle(fontSize: 18),
                            )),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.18,
                        ),
                        TextFormField(
                          onChanged: (v) {
                            this.code = v;
                          },
                          keyboardAppearance: Brightness.dark,
                          // textAlign: TextAlign.center,
                          keyboardType: TextInputType.phone,
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                              hintText: "Enter the code that you will receive",
                              hintStyle: TextStyle(fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 15),
                              icon: Icon(Icons.confirmation_number),
                              border: InputBorder.none),
                        ),
                        SizedBox(
                          height: 40,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (code != "") {
                              print("$code");
                              setState(() {
                                isBtnClicked = true;
                              });

                              widget.signInPhone(code);

//                       FirebaseAuth.instance.currentUser().then((user) {
//                    if (user != null) {
//                      print("thanks for verifying your phone, welcome");
//                      Navigator.push(context, CustomPageRoute(navigateTo: Control()));
//                    } else {
//                      // Navigator.pop(context);
//                      widget.signInPhone(code);
//                    }
//                  });
                            } else {
                              print("enter number");
                              showFlushBar("Error", "Enter Pin");
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.orangeAccent,
                                borderRadius: BorderRadius.circular(40)),
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            child: Center(
                                child: Text(
                              !isBtnClicked ? "Verify" : "Verifying ...",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ),
                        )
                      ],
                    )),
              ));
  }

  showFlushBar(String title, String message) {
    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 8),
    )..show(context);
  }
}
