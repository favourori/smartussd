import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kene/auth/verify_phone.dart';
import 'package:kene/control.dart';
import 'package:kene/pages/homepage.dart';
import 'package:kene/utils/functions.dart';
import 'package:flushbar/flushbar.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'dart:io';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:package_info/package_info.dart';
import 'package:kene/actions/auth_actions.dart';

class Signin extends StatefulWidget {
  final analytics;
  final observer;

  Signin({this.analytics, this.observer});
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  GlobalKey<FormState> _formkey = GlobalKey();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passworddController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  PackageInfo packageInfo;

  AuthCredential verifiedUser;
  String phoneNo;
  String verificationId;
  String smsCode;
  TextEditingController _yobController = TextEditingController();
  String countryName = "";
  bool isBtnClicked = false;
  bool canAuthenticate = false;
  String countryCode = "+250";
  String gender = "Select";
  String yob = "";

  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSignUp = true;

  @override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((f) {
      // for getting the package/build/version number on load
      setState(() {
        packageInfo = f;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body:
        GestureDetector(
          onTap: (){
            FocusScope.of(context).unfocus();
            },
          child:
          Form(
            key: _formkey,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: <Widget>[
                    Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: ListView(
                        shrinkWrap: true,
                        children: <Widget>[
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                          ),
                          Container(
                            height: 80,
                            decoration: BoxDecoration(
//                border: Border.all(),
                                image: DecorationImage(
                                    image: AssetImage("assets/images/nokanda.png"))),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  "Nokanda will send an SMS to verify your phone number.",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12),
                                )),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.07,
                          ),
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.withOpacity(0.3)),
                              // color: Colors.grey.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(5),
                              // border: Border(bottom: BorderSide(width: 1),
                              // )
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      height: 50,
                                      width: 300,
                                      child: StreamBuilder(
                                        stream: Firestore.instance
                                            .collection('country_codes')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData)
                                            return Center(child: Text(".."));
                                          return ButtonTheme(
                                            alignedDropdown: true,
                                            child: DropdownButton(
                                                underline: Container(),
                                                icon: Icon(Icons.arrow_drop_down,
                                                    size: 16, color: Colors.orange),
                                                value: countryCode,
                                                items: populateCountryCodes(
                                                    snapshot.data.documents),
                                                onChanged: (v) {
                                                  setState(() {
                                                    countryCode = v;
                                                  });
                                                }),
                                          );
                                        },
                                      )),
                                  flex: 2,
                                ),
                                Expanded(
                                  child: TextFormField(

                                    onChanged: (v) {
                                      if (v.substring(0, 1) == "0") {
                                        v = v.substring(1);
                                      }
                                      this.phoneNo = countryCode + v;
                                      print(phoneNo);
                                    },
                                    keyboardAppearance: Brightness.dark,
                                    keyboardType: TextInputType.phone,
                                    cursorColor: Colors.orangeAccent,
                                    decoration: InputDecoration(
                                        hintText: "Phone number",
                                        hintStyle: TextStyle(
                                            fontSize: 14, color: Colors.black),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 0, vertical: 15),
                                        border: InputBorder.none),
                                  ),
                                  flex: 4,
                                ),
                              ],
                            ),
                          ),

                          Padding(padding: EdgeInsets.only(left:5), child: Text("*phone number required", style: TextStyle(
                              color: Colors.redAccent,
                              fontSize: 11
                          ),),),

                          //other info
                          isSignUp
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.3)),
                                    // color: Colors.grey.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                    padding: const EdgeInsets.only(left: 20.0),
                                    child: Row(
                                      children: <Widget>[
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              gender = "Male";
                                            });
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Text("Male"),
                                              Radio(
                                                groupValue: gender,
                                                value: "Male",
                                                onChanged: (v) {
                                                  setState(() {
                                                    gender = v;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              gender = "Female";
                                            });
                                          },
                                          child: Row(
                                            children: <Widget>[
                                              Text("Female"),
                                              Radio(
                                                groupValue: gender,
                                                value: "Female",
                                                onChanged: (v) {
                                                  setState(() {
                                                    gender = v;
                                                  });
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    )

                                  // DropdownButton(
                                  //   icon: Icon(Icons.arrow_drop_down,
                                  //       size: 16, color: Colors.orange),
                                  //   underline: Container(),
                                  //   value: gender,
                                  //   onChanged: (v) {
                                  //     setState(() {
                                  //       gender = v;
                                  //     });
                                  //   },
                                  //   items: [
                                  //     DropdownMenuItem(
                                  //       value: "Select",
                                  //       child: Text(
                                  //         "Select gender",
                                  //         style: TextStyle(
                                  //             fontSize: 14, color: Colors.black),
                                  //       ),
                                  //     ),
                                  //     DropdownMenuItem(
                                  //       value: "Male",
                                  //       child: Text("Male",
                                  //           style: TextStyle(
                                  //               fontSize: 14,
                                  //               color: Colors.black)),
                                  //     ),
                                  //     DropdownMenuItem(
                                  //       value: "Female",
                                  //       child: Text("Female",
                                  //           style: TextStyle(
                                  //               fontSize: 14,
                                  //               color: Colors.black)),
                                  //     )
                                  //   ],
                                  // ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(top: 10),
                                height: 48,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.grey.withOpacity(0.3)),
                                    borderRadius: BorderRadius.circular(5)),
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20.0),
                                  child: GestureDetector(
                                      onTap: () {
                                        DatePicker.showDatePicker(context,
                                            showTitleActions: true,
                                            minTime: DateTime(1770, 3, 5),
                                            maxTime: DateTime(2019, 6, 7),
                                            onChanged: (date) {},
                                            onConfirm: (date) {
                                              setState(() {
                                                yob =
                                                    date.toString().substring(0, 10);
                                              });
                                            },
                                            currentTime: DateTime.now(),
                                            locale: LocaleType.en);
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Text(
                                            "Date of birth",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          ),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          Text(
                                            yob,
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.black),
                                          )
                                        ],
                                      )),
                                ),
                              )
                            ],
                          )
                              : Container(),
                          SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: () {
                              validate();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.orangeAccent,
                                  borderRadius: BorderRadius.circular(40)),
                              width: MediaQuery.of(context).size.width * 0.3,
                              height: 50,
                              child: Center(
                                  child: !isBtnClicked
                                      ? Text(
                                    !isSignUp ? "Log in" : "Sign up",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                      : CupertinoActivityIndicator(
                                    // animating: true,
                                    radius: 15,
                                    // backgroundColor: Colors.white,
                                  )),
                            ),
                          ),

                          Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: !isSignUp
                                ? GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignUp = true;
                                });
                              },
                              child: Text(
                                "Sign up",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
//                                fontSize: 12

                                ),
                                textAlign: TextAlign.center,
                              ),
                            )
                                : GestureDetector(
                              onTap: () {
                                setState(() {
                                  isSignUp = false;
                                });
                              },
                              child: Text(
                                "Log in",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
//                                fontSize: 12

                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
//                  SizedBox(
//                    height: MediaQuery.of(context).size.height * 0.02,
//                  ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: packageInfo != null
                          ? Text(
                        "Version: ${packageInfo.version.toString() + "+" + packageInfo.buildNumber}",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        textAlign: TextAlign.center,
                      )
                          : Text(""),
                    )
                  ],
                )),
          )
          ,
        ),

    );
  }

  inputDisplay(String label, controller) {
    return Container(
      height: 55,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          border: Border.all(width: 1, color: Colors.grey),
          borderRadius: BorderRadius.circular(30)),
      child: TextFormField(
          validator: (v) => v.isEmpty ? "Value can't be empty" : null,
          controller: controller,
          obscureText: label == "Password" ? true : false,
          keyboardType: label == "Email"
              ? TextInputType.emailAddress
              : TextInputType.text,
          decoration: InputDecoration(
            prefixIcon:
                label == "Email" ? Icon(Icons.email) : Icon(Icons.security),
            labelText: "$label",
            border: InputBorder.none,
          )),
    );
  }

  void validate() {
    if ((!isSignUp && phoneNo != "" && phoneNo != null) ||
        (isSignUp &&
            phoneNo != "" &&
            phoneNo != null
//            &&
//            gender != "Select" &&
//            yob.isNotEmpty
        )) {
      setState(() {
        isBtnClicked = true;
      });

      hasInternetConnection().then((b) {
        if (!b) {
          showFlushBar(
              "Hey Awesome!", "You only need internet to verify your number");
          setState(() {
            isBtnClicked = false;
          });
        } else {
          //then check phone number

          Firestore.instance
              .collection("country_codes")
              .where("code", isEqualTo: countryCode)
              .getDocuments()
              .then((v) {
            setState(() {
              countryName = v.documents[0]['name'];
            });

            authenticate(); //authentication process starts here
          });
        }
      }).catchError((f) {
        print("error ${f.message}");
        setState(() {
          isBtnClicked = false;
        });
      });
    }
//    else if (gender == "Select") {
//      return showFlushBar("Hey Awesome!", "You need to select your gender");
//    }
//    else if (yob.isEmpty || yob == null) {
//      return showFlushBar("Hey Awesome!", "You need to add year of birth");
//    }
    else {
      showFlushBar("Hey Brilliant!", "You need to enter the number to verify");
    }
  }

  /// FUNCTION FOR THE THE AUTHENTICATION FLOW
  authenticate() async {
    // var code = generateVerificationCode();
    // sendAuthSMS(phoneNo, code);

    if (!isSignUp) {
      //IF IT IS A LOGIN ACTION

      //check for number first
      var res = await _firestore
          .collection("users")
          .where("phone", isEqualTo: phoneNo)
          .getDocuments();
      if (res.documents.length >= 1) {
        setState(() {
          canAuthenticate = true;
        });
      } else {
        showFlushBar("Hey Awesome !!",
            "This number is not registered, please signup first");
        setState(() {
          isBtnClicked = false;
          canAuthenticate = false;
        });
      }
    } else {
      setState(() {
        canAuthenticate = true;
      });
    }

//0781802412
    if (canAuthenticate) {
      // VERIFY PHONE NUMBER

      verifyPhone();
    }
  }

  signIn(_email, _password) async {
    sendAnalytics(widget.analytics, "signin_button_clicked", null);
    FirebaseUser user = await _auth
        .signInWithEmailAndPassword(email: _email, password: _password)
        .then((f) => navigateUsers(f))
        .catchError((f) =>
            f.message.contains("no user record") ? print("No user") : null);
  }

  Future<AuthCredential> verifyPhone() async {
    // USER TO RETURN AFTER VERIFICATION

    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    // CALL BACK WHEN THE VERIFICATION CODE IS SENT
    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;

      Navigator.push(
          context,
          CustomPageRoute(
              navigateTo: PhoneVerify(
            signInPhone: signInPhone,
            verificationId: verificationId,
            pushUserDataToDB: pushUserDataToDB,
          )));
    };

    // CALLBACK WHEN VERIFICATION FAILS
    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print("${exception.message}");
      String mess = "Error, try again later";
      if (exception.message.toString().contains("incorrect")) {
        setState(() {
          mess = "The phone number is incorrect, please re-enter a correct one";
        });
      }

      showFlushBar("Error!", "$mess");
      setState(() {
        isBtnClicked = false;
      });
    };

    // CALLBACK WHEN VERIFICATION COMPLETES
    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      print("veri is completed");
      print(user);

      setState(() {
        verifiedUser = user;
      });

      if (verifiedUser != null) {
        print("has verified phone");
        print(verifiedUser);

        // SIGN VERIFIED USER IN
        signUserIn(verifiedUser).then((authenticatedUser) {
          // STORE SINGED IN USER DATA TO DB
          pushUserDataToDB(authenticatedUser);
        });
      }
    };

    // ACTUAL VERIFICATION FUNCTION
    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        timeout: Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve);

    return verifiedUser;
  }

  /// SIGN USER IN AFTER PHONE VERIFICATION
  Future<AuthResult> signUserIn(AuthCredential user) async {
    AuthResult signedInUser = await _auth.signInWithCredential(user);
    return signedInUser;
  }

  /// AFTER USER SIGNS IN, PUSH DATA TO THE DATABASE
  pushUserDataToDB(AuthResult u) async {
    if (!isSignUp) {
      //if its a login action
      var res = await Firestore.instance
          .collection("users")
          .where("phone", isEqualTo: u.user.phoneNumber)
          .getDocuments();
      var id = res.documents[0].documentID;

      _firestore.collection("users").document(id).updateData({
        'signIn': DateTime.now().toString().substring(0, 16),
        'version': packageInfo != null
            ? packageInfo.version.toString() +
                "+" +
                packageInfo.buildNumber.toString()
            : ''
      });

      Navigator.pushReplacement(
          context, CustomPageRoute(navigateTo: Control()));
    } else {
      var userData = {
        "country": countryName,
        "gender": gender,
        "yob": yob,
        "user_id": u.user.uid,
        "phone": phoneNo,
        "signedUp": DateTime.now().toString().substring(0, 16),
        "signIn": DateTime.now().toString().substring(0, 16),
        "device": Platform.isAndroid ? "Android" : "IOS",
        "version": packageInfo != null
            ? packageInfo.version.toString() +
                "+" +
                packageInfo.buildNumber.toString()
            : '',
      };
      Firestore.instance.collection("users").add(userData);

      Navigator.pushReplacement(
          context, CustomPageRoute(navigateTo: Control()));
    }
  }

  signInPhone(code) async {
    // print(verificationId);
    // print(code);
    AuthCredential credential;

    try {
      credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: code,
    );
    } catch (e) {
      print("error getting credentials");
    }
    // AuthResult res = await 
    signUserIn(credential).then((res){
        pushUserDataToDB(res);
    }).catchError((err){
      Navigator.push(
          context,
          CustomPageRoute(
              navigateTo: PhoneVerify(
            signInPhone: signInPhone,
          )));
    });

    return 1;
    
  }

  navigateUsers(f) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Homepage(
          analytics: widget.analytics,
          observer: widget.observer,
        ),
        settings: RouteSettings(name: 'Homepage'),
      ),
    );
  }

  showFlushBar(String title, String message) {
    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 8),
    )..show(context);
  }

  List<DropdownMenuItem<String>> populateCountryCodes(codes) {
    List<DropdownMenuItem<String>> tmp = [];
    for (var code in codes) {
      tmp.add(
        DropdownMenuItem(
            value: code['code'],
            child: Text(code['code'],
                style: TextStyle(fontSize: 14, color: Colors.black))),
      );
    }

    return tmp;
  }
}
