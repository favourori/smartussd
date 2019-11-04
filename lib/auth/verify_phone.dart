import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
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
  final verificationId;
  final pushUserDataToDB;
  
  PhoneVerify({this.analytics, this.observer, this.signInPhone, this.verificationId, this.pushUserDataToDB});
  @override
  _PhoneVerifyState createState() => _PhoneVerifyState();
}

class _PhoneVerifyState extends State<PhoneVerify>
    with SingleTickerProviderStateMixin {
  GlobalKey<FormState> _formKey = GlobalKey();
  FocusNode focusNode;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  String code;
  bool isBtnClicked = false;

  bool isAuthenticating = true;


  /// SIGN USER IN AFTER PHONE VERIFICATION
  Future<AuthResult> signUserIn(AuthCredential user) async {
    AuthResult signedInUser = await _auth.signInWithCredential(user);
    return signedInUser;
  }

  signInPhone(code) async {
    AuthCredential credential;
    try {
      credential = PhoneAuthProvider.getCredential(
      verificationId: widget.verificationId,
      smsCode: code,
    );
    } catch (e) {
      print("error getting credentials");
    }
    // AuthResult res = await 
    signUserIn(credential).then((res){
        //call push to database from signin
        widget.pushUserDataToDB(res);
    }).catchError((err){
        //reset back button click and reset text input
        setState(() {
          isBtnClicked = false;
          code = "";
        });

        showDialog(
          context: context,
          builder: (context){
            return AlertDialog(
              content: Text("Error, please confirm code and try again!!"),
            );
          }
        );
    });

    return 1;
    
  }

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
    focusNode = FocusNode(debugLabel: "verifyInput");
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
            :

            GestureDetector(
              onTap: (){
                if(FocusScope.of(context) != null && FocusScope.of(context).focusedChild != null && FocusScope.of(context).focusedChild.debugLabel == "verifyInput"){
                  FocusScope.of(context).unfocus();
                }
                else{
                  print("nothing to unfocus");
                }

              },
              child: Form(
                key: _formKey,
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
                          focusNode: focusNode,
                          onChanged: (v) {
                            FocusScope.of(context).requestFocus(focusNode);
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

                              signInPhone(code);

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
                                child: !isBtnClicked ?  Text(
                                  "Verify",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ):

                                CupertinoActivityIndicator(
                                  // animating: true,
                                  radius: 15,
                                  // backgroundColor: Colors.white,
                                )),
                          ),
                        )
                      ],
                    )),
              ),
            )
    );
  }

  showFlushBar(String title, String message) {
    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 8),
    )..show(context);
  }
}
