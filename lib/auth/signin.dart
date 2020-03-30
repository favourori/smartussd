import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kene/auth/verify_phone.dart';
import 'package:kene/control.dart';
import 'package:kene/pages/homepage.dart';
import 'package:kene/utils/functions.dart';
import 'package:flushbar/flushbar.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'dart:io';
import 'package:package_info/package_info.dart';

class Signin extends StatefulWidget {
  final analytics;
  final observer;

  Signin({this.analytics, this.observer});
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  GlobalKey<FormState> _formkey = GlobalKey();
//  TextEditingController _emailController = TextEditingController();
//  TextEditingController _passworddController = TextEditingController();
  FocusManager focusManager = FocusManager();

  FocusNode fNode;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _firestore = Firestore.instance;

  PackageInfo packageInfo;

  AuthCredential verifiedUser;
  String phoneNo;
  String verificationId;
  String smsCode;
//  TextEditingController _yobController = TextEditingController();
  String countryName = "";
  bool isBtnClicked = false;
  bool canAuthenticate = false;
  String countryCode = "+250";
  String gender = "Select";
  String yob = "";

  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSignUp = true;

  ScrollController _scrollController;

  listener() {
    if (_scrollController.offset >= 45) {
      _scrollController.jumpTo(45);
    }
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController(initialScrollOffset: 0.0);
    _scrollController.addListener(listener);

    fNode = FocusNode(debugLabel: "phoneInput");
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
      body: GestureDetector(
          onTap: () {
            if (FocusScope.of(context) != null &&
                FocusScope.of(context).focusedChild != null &&
                FocusScope.of(context).focusedChild.debugLabel ==
                    "phoneInput") {
              FocusScope.of(context).unfocus();
            } else {
              print("nothing to unfocus");
            }
          },
          child: NestedScrollView(
              controller: _scrollController,
              headerSliverBuilder: (context, bool isScrolled) {
                return <Widget>[
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.height * 0.175,
                    elevation: 14,
                    pinned: true,
                    floating: true,
                    centerTitle: true,
                    forceElevated: isScrolled,
                    actions: <Widget>[],
                    title: AutoSizeText(
                      isSignUp ? "Signup" : "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontFamily: buttonTextFamily,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 2,
                    ),
                    backgroundColor: mainColor,
                    leading: Container(),
                    flexibleSpace: Container(
                      decoration: BoxDecoration(
                        color: mainColor,
//                          border: Border.all(),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              "Thank you for downloading the Nokanda app. \n We will send you an SMS to verify \nyour phone number",
                              textAlign: TextAlign.center,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ];
              },
              body: Container(
                  height: MediaQuery.of(context).size.height,
                  child: Stack(children: <Widget>[
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.35,
                      decoration: BoxDecoration(
                        color: mainColor,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
//
                        ],
                      ),
                    ),
                    Positioned(
                        top: 10,
                        child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20.0, horizontal: 0),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              // MediaQuery.of(context).size.width - 40,
//                              height: MediaQuery.of(context).size.height * 0.75,
                              decoration: BoxDecoration(
                                  color: Color(0xfff6f7f9),
                                  borderRadius: BorderRadius.circular(40)),
                              child: Form(
                                key: _formkey,
                                child: Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 20),
                                    child: ListView(
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        Container(
//                                          height: MediaQuery.of(context)
//                                                  .size
//                                                  .height *
//                                              0.1,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: <Widget>[
//                                              SizedBox(
//                                                height: MediaQuery.of(context)
//                                                        .size
//                                                        .height *
//                                                    0.07,
//                                              ),
//                                              Container(
//                                                height: 80,
//                                                decoration: BoxDecoration(
////                border: Border.all(),
//                                                    image: DecorationImage(
//                                                        image: AssetImage(
//                                                            "assets/images/nokanda.png"))),
//                                              ),
//
//                                              Padding(
//                                                padding:
//                                                    const EdgeInsets.all(8.0),
//                                                child: Align(
//                                                    alignment: Alignment.center,
//                                                    child: Text(
//                                                      "Nokanda will send an SMS to verify your phone number.",
//                                                      textAlign:
//                                                          TextAlign.center,
//                                                      style: TextStyle(
//                                                          fontSize: 12),
//                                                    )),
//                                              ),
                                              SizedBox(
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.04,
                                              ),
                                              Container(
                                                height: 43,
                                                decoration: BoxDecoration(),
                                                child: Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      key: Key("countrySelectorKey"),
                                                      child: Container(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 5),
                                                          decoration: BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          5),
                                                              border: Border.all(
                                                                  color: accentColor
                                                                      .withOpacity(
                                                                          0.5))),
                                                          child: StreamBuilder(
                                                            stream: Firestore
                                                                .instance
                                                                .collection(
                                                                    'country_codes')
                                                                .snapshots(),
                                                            builder: (context,
                                                                snapshot) {
                                                              if (!snapshot
                                                                  .hasData)
                                                                return Center(
                                                                    child: Text(
                                                                        ".."));
                                                              return
//                                                                ButtonTheme(
//                                                                alignedDropdown:
//                                                                    true,
//                                                                child:
                                                                  DropdownButton(
                                                                    
                                                                      underline:
                                                                          Container(),
                                                                      icon: Icon(
                                                                          Icons
                                                                              .arrow_drop_down,
                                                                          size:
                                                                              16,
                                                                          color:
                                                                              accentColor),
                                                                      value:
                                                                          countryCode,
                                                                      items: populateCountryCodes(snapshot
                                                                          .data
                                                                          .documents),
                                                                      onChanged:
                                                                          (v) {
                                                                        setState(
                                                                            () {
                                                                          countryCode =
                                                                              v;
                                                                        });
                                                                      });
//                                                              );
                                                            },
                                                          )),
                                                      flex: 2,
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    Expanded(
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                            border: Border.all(
                                                                color: accentColor
                                                                    .withOpacity(
                                                                        0.5))),
                                                        child: TextFormField(
                                                          key: Key("phoneNumberTextInput"),
                                                          focusNode: fNode,
                                                          onChanged: (v) {
                                                            FocusScope.of(
                                                                    context)
                                                                .requestFocus(
                                                                    fNode);
                                                            if (v.substring(
                                                                    0, 1) ==
                                                                "0") {
                                                              v = v
                                                                  .substring(1);
                                                            }
                                                            this.phoneNo =
                                                                countryCode + v;
                                                            print(phoneNo);
                                                          },
                                                          keyboardAppearance:
                                                              Brightness.dark,
                                                          keyboardType:
                                                              TextInputType
                                                                  .phone,
                                                          cursorColor:
                                                              accentColor,
                                                          decoration: InputDecoration(
                                                              hintText:
                                                                  "Phone number",
                                                              hintStyle: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black),
                                                              contentPadding:
                                                                  EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          10,
                                                                      vertical:
                                                                          15),
                                                              border:
                                                                  InputBorder
                                                                      .none),
                                                        ),
                                                      ),
                                                      flex: 7,
                                                    ),
                                                    Expanded(
                                                        child: Container(),
                                                        flex: 2),
                                                  ],
                                                ),
                                              ),

                                              Padding(
                                                padding: EdgeInsets.only(
                                                    left: 5, top: 5),
                                                child: Text(
                                                  "*phone number required",
                                                  style: TextStyle(
                                                      color: accentColor,
                                                      fontSize: 11),
                                                ),
                                              ),

                                              //other info
                                              isSignUp
                                                  ? Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        SizedBox(
                                                          height: 15,
                                                        ),
                                                        Container(
                                                          height: 45,
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 10),
                                                          width:
                                                              double.infinity,
                                                          decoration:
                                                              BoxDecoration(
                                                                  border: Border.all(
                                                                      color: accentColor
                                                                          .withOpacity(
                                                                              0.5)),
                                                                  // color: Colors.grey.withOpacity(0.3),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5)),
                                                          child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left:
                                                                          20.0),
                                                              child: Row(
                                                                key: Key("genderWidgetKey"),
                                                                children: <
                                                                    Widget>[
                                                                  GestureDetector(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        gender =
                                                                            "Male";
                                                                      });
                                                                    },
                                                                    child: Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                            "Male"),
                                                                        Radio(
                                                                          activeColor:
                                                                              accentColor,
                                                                          groupValue:
                                                                              gender,
                                                                          value:
                                                                              "Male",
                                                                          onChanged:
                                                                              (v) {
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
                                                                      setState(
                                                                          () {
                                                                        gender =
                                                                            "Female";
                                                                      });
                                                                    },
                                                                    child: Row(
                                                                      children: <
                                                                          Widget>[
                                                                        Text(
                                                                            "Female"),
                                                                        Radio(
                                                                          activeColor:
                                                                              accentColor,
                                                                          groupValue:
                                                                              gender,
                                                                          value:
                                                                              "Female",
                                                                          onChanged:
                                                                              (v) {
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

                                                        SizedBox(
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.05,
                                                        ),
//                                                        GestureDetector(
//                                                          onTap: () {
//                                                            DatePicker.showDatePicker(
//                                                                context,
//                                                                showTitleActions:
//                                                                    true,
//                                                                minTime:
//                                                                    DateTime(
//                                                                        1770,
//                                                                        3,
//                                                                        5),
//                                                                maxTime:
//                                                                    DateTime(
//                                                                        2019,
//                                                                        6,
//                                                                        7),
//                                                                onChanged:
//                                                                    (date) {},
//                                                                onConfirm:
//                                                                    (date) {
//                                                              setState(() {
//                                                                yob = date
//                                                                    .toString()
//                                                                    .substring(
//                                                                        0, 10);
//                                                              });
//                                                            },
//                                                                currentTime:
//                                                                    DateTime
//                                                                        .now(),
//                                                                locale:
//                                                                    LocaleType
//                                                                        .en);
//                                                          },
//                                                          child: Container(
//                                                            margin:
//                                                                EdgeInsets.only(
//                                                                    top: 10),
//                                                            height: 43,
//                                                            decoration: BoxDecoration(
//                                                                border: Border.all(
//                                                                    color: accentColor
//                                                                        .withOpacity(
//                                                                            0.5)),
//                                                                borderRadius:
//                                                                    BorderRadius
//                                                                        .circular(
//                                                                            5)),
//                                                            child: Padding(
//                                                                padding:
//                                                                    const EdgeInsets
//                                                                            .only(
//                                                                        left:
//                                                                            20.0),
//                                                                child: Row(
//                                                                  children: <
//                                                                      Widget>[
//                                                                    Text(
//                                                                      "Date of birth",
//                                                                      style: TextStyle(
//                                                                          fontSize:
//                                                                              14,
//                                                                          color:
//                                                                              Colors.black),
//                                                                    ),
//                                                                    SizedBox(
//                                                                      width: 30,
//                                                                    ),
//                                                                    Text(
//                                                                      yob,
//                                                                      style: TextStyle(
//                                                                          fontSize:
//                                                                              14,
//                                                                          color:
//                                                                              Colors.black),
//                                                                    )
//                                                                  ],
//                                                                )),
//                                                          ),
//                                                        ),
                                                      ],
                                                    )
                                                  : Container(),
                                              SizedBox(
                                                height: 30,
                                              ),
                                              GestureDetector(
                                                key: Key("LoginSignupKey"),
                                                onTap: () {
                                                  validate();
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      boxShadow: [
                                                        buttonBoxShadow
                                                      ],
                                                      color: accentColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              serviceItemBorderRadius)),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.3,
                                                  height: 43,
                                                  child: Center(
                                                      child: !isBtnClicked
                                                          ? Text(
                                                              
                                                              !isSignUp
                                                                  ? "Log in"
                                                                  : "Sign up",
                                                              style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                            )
                                                          : CupertinoActivityIndicator(
                                                            key: Key("loginButtonClickedLoader"),
                                                              radius: 15,
                                                              // backgroundColor: Colors.white,
                                                            )),
                                                ),
                                              ),

                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 20),
                                                  child: Column(
                                                    children: <Widget>[
                                                      !isSignUp
                                                          ? GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  isSignUp =
                                                                      true;
                                                                });
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    "Don't have an account? ",
                                                                    style:
                                                                        TextStyle(

//                                fontSize: 12
                                                                            ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  Text(
                                                                    "Sign up",
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
//                                fontSize: 12
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          : GestureDetector(
                                                              onTap: () {
                                                                setState(() {
                                                                  isSignUp =
                                                                      false;
                                                                });
                                                              },
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: <
                                                                    Widget>[
                                                                  Text(
                                                                    "Already have an account? ",
                                                                    style:
                                                                        TextStyle(),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                  Text(
                                                                    "Log in",
                                                                    style:
                                                                        TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
//                                fontSize: 12
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                      isSignUp
                                                          ? Padding(
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      top: 30,
                                                                      left: 30,
                                                                      right:
                                                                          30),
                                                              child: Text(
                                                                "By continuing, you agree to Nokanda's Terms of use and Privacy Policy",
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                            )
                                                          : Container()
                                                    ],
                                                  )),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: isSignUp
                                              ? MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.02
                                              : MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.08,
                                        ),
                                        Align(
                                          alignment: Alignment.bottomCenter,
                                          child: packageInfo != null
                                              ? Text(
                                                  "Version: ${packageInfo.version.toString() + " Build: " + packageInfo.buildNumber}",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey),
                                                  textAlign: TextAlign.center,
                                                )
                                              : Text(""),
                                        )
                                      ],
                                    )),
                              ),
                            )))
                  ])))),
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
        (isSignUp && phoneNo != "" && phoneNo != null
//            &&
//            gender != "Select" &&
//            yob.isNotEmpty
        )) {
      setState(() {
        isBtnClicked = true;
      });

      hasInternetConnection().then((b) {
        if (!b) {
          showFlushBar("Sorry!",
              "You need an internet connection to verify your number.");
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
      showFlushBar("Hello!",
          "Please provide a real phone number to verify your account");
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
        showFlushBar("Hello!",
            "This number is not registered, please click signup first");
        setState(() {
          isBtnClicked = false;
          canAuthenticate = false;
        });
      }
    } else {
      /// FOR SIGN UP USERS
      ///check for number and ask to login

      var res = await _firestore
          .collection("users")
          .where("phone", isEqualTo: phoneNo)
          .getDocuments();
      if (res.documents.length >= 1) {
        showFlushBar("Hey Awesome !!",
            "This number is already registered, please login");
        setState(() {
          isBtnClicked = false;
          canAuthenticate = false;
        });

//        setState(() {
//          canAuthenticate = true;
//        });
      } else {
        setState(() {
          canAuthenticate = true;
        });
      }
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
          mess =
              "The phone number provided is incorrect, please re-enter a correct one";
        });
      }

      showFlushBar("Error!", "${exception.message}");
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
    signUserIn(credential).then((res) {
      pushUserDataToDB(res);
    }).catchError((err) {
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
    return Flushbar(
      key: Key("flushBarKey"),
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
