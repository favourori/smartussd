import 'package:cloud_firestore/cloud_firestore.dart';
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
  String yob = "Year of birth";

  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isSignUp = true;


@override
  void initState() {
    super.initState();

    PackageInfo.fromPlatform().then((f){ // for getting the package/build/version number on load
       setState(() {
         packageInfo = f;
       });
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        body: Form(
          key: _formkey,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                children: <Widget>[
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.12,
                  ),
            Container(
              height: 80,
              decoration: BoxDecoration(
//                border: Border.all(),
                  image: DecorationImage(image: AssetImage("assets/images/nokanda.png") )
              ),),

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
                    height: MediaQuery.of(context).size.height * 0.07 ,
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
//                            color: Colors.red,
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
                          // textAlign: TextAlign.center,
                          keyboardType: TextInputType.phone,
                          cursorColor: Colors.orangeAccent,
                          decoration: InputDecoration(
                              labelText: "Phone number",
                              labelStyle: TextStyle(fontSize: 14, color: Colors.black),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 15),
//                              icon: Icon(Icons.phone),
                              border: InputBorder.none),
                        ),
                        flex: 4,
                      ),

                    ],
                  ),

                  //other info
                isSignUp ?  Padding(
                    padding: const EdgeInsets.only(left:20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DropdownButton(
                      underline: Container(),
                      value: gender,
                      onChanged: (v){
                          setState(() {
                            gender = v;
                          });
                      },
                      items: [
                        DropdownMenuItem(
                        value: "Select",
                        child: Text("Select gender"),
                      ),
                      DropdownMenuItem(
                        value: "Male",
                        child: Text("Male"),
                      ),
                      DropdownMenuItem(
                        value: "Female",
                        child: Text("Female"),
                      )
                      ],
                    ),
                        GestureDetector(
                          onTap: (){
                            DatePicker.showDatePicker(context,
                                showTitleActions: true,
                                minTime: DateTime(1770, 3, 5),
                                maxTime: DateTime(2019, 6, 7),
                                onChanged: (date) {
//                                  print('change $date');
                                }, onConfirm: (date) {
                                  setState(() {
                                    yob = date.toString().substring(0,10);
                                  });
                                },
                                currentTime: DateTime.now(), locale: LocaleType.en);
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top:25),
                            child: Row(
                            children: <Widget>[
                              Text("Date of birth", style: TextStyle(fontSize: 15, color: Colors.black),),
                              SizedBox(width: 30,),
                              Text(yob, style: TextStyle(fontSize: 15, color: Colors.black),)
                            ],
                          ),)

                        )
                        ],
                    ),
                  ) : Container(),
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
                      width: MediaQuery.of(context).size.width,
                      height: 50,
                      child: Center(
                          child: !isBtnClicked
                              ? Text(
                                  !isSignUp ? "Sign in" : "Sign up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.only(top:30),
                    child: !isSignUp ? GestureDetector(
                      onTap: (){
                        setState(() {
                          isSignUp = true;
                        });
                      },
                      child: Text("Don't have an account? Click here to Signup", textAlign: TextAlign.center,),
                    ):

                    GestureDetector(
                      onTap: (){
                        setState(() {
                          isSignUp = false;
                        });
                      },
                      child: Text("Already have an account? Click here to Login", textAlign: TextAlign.center,),
                    )
                    ,
                  )
                ],
              )
              ),
        ));
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
    if ( (!isSignUp && phoneNo != "" && phoneNo != null) || (isSignUp && phoneNo != "" && phoneNo != null && gender != "Select" && yob != "Year of birth")) {
      setState(() {
        isBtnClicked = true;
      });

      hasInternetConnection().then((b) {
        if (!b) {
          showFlushBar("Hey Awesome!",
              "You only need internet to verify your number");
          setState(() {
            isBtnClicked = false;
          });
        } else {
          //then check phone number

          Firestore.instance.collection("country_codes").where("code", isEqualTo: countryCode).getDocuments()
              .then((v){

            setState(() {
              countryName = v.documents[0]['name'];
            });


            authenticate();  //authentication process starts here
          });



        }
      }).catchError((f) {
        print("error ${f.message}");
        setState(() {
          isBtnClicked = false;
        });
      });
    }
    else if(gender == "Select"){
      return showFlushBar("Hey Awesome!", "You need to select your gender");
    }
    else if(yob == "Year of birth"){
      return showFlushBar("Hey Awesome!", "You need to add year of birth");
    }
    else {
      showFlushBar("Hey Brilliant!",
          "You need to enter the number to verify");
    }
  }


  /// FUNCTION FOR THE THE AUTHENTICATION FLOW
  authenticate() async{
  

    // var code = generateVerificationCode();
    // sendAuthSMS(phoneNo, code);



  if(!isSignUp){ //IF IT IS A LOGIN ACTION
    
    //check for number first
    var res = await _firestore.collection("users").where("phone", isEqualTo: phoneNo).getDocuments();
    if(res.documents.length >= 1){
      setState(() {
        canAuthenticate = true;
      });
    }
    else{
      showFlushBar("Hey Awesome !!", "This number is not registered, please signup first");
      setState(() {
        isBtnClicked = false;
      });
    }
  }
  else{
    setState(() {
      canAuthenticate = true;
    });
  }


  if(canAuthenticate){
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


      if(verifiedUser !=  null){
        print("has verified phone");
        print(verifiedUser);

        // SIGN VERIFIED USER IN
        signUserIn(verifiedUser).then((authenticatedUser){

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
  pushUserDataToDB(AuthResult u) async{
    if(!isSignUp){ //if its a login action
        var res = await Firestore.instance.collection("users").where("phone", isEqualTo: u.user.phoneNumber).getDocuments();
        var id = res.documents[0].documentID;

        _firestore.collection("users").document(id).updateData({'signIn' : DateTime.now().toString().substring(0, 16), 'version': packageInfo != null ?  packageInfo.version.toString() + "+"+packageInfo.buildNumber.toString(): ''});

        Navigator.pushReplacement(
            context, CustomPageRoute(navigateTo: Control()));
    }
    else{
      var userData = {
        "country": countryName,
        "gender": gender,
        "yob": yob,
        "user_id": u.user.uid,
        "phone": phoneNo,
        "signedUp": DateTime.now().toString().substring(0,16),
        "signIn": DateTime.now().toString().substring(0, 16),
        "device": Platform.isAndroid ? "Android": "IOS",
        "version": packageInfo != null ?  packageInfo.version.toString() + "+"+packageInfo.buildNumber.toString(): '',
      };
       Firestore.instance.collection("users").add(userData);

       Navigator.pushReplacement(
          context, CustomPageRoute(navigateTo: Control()));

    }

  }


  signInPhone(code) async{
  print(verificationId);
  print(code);
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: code,
    );

//    final AuthResult result = await _auth.signInWithCredential(credential);
//
//    //check if signed already b4 adding documents
//        Firestore.instance.collection("users").where('user_id', isEqualTo: result.user.uid).getDocuments().then((f){
//          if(f.documents.length == 0){
//            var userData = {
//                              "country": countryName,
//                              "gender": gender,
//                              "yob": _yobController.text,
//                              "user_id": result.user.uid
//                            };
//               Firestore.instance.collection("users").add(userData);
//          }
//           Navigator.pushReplacement(
//            context, CustomPageRoute(navigateTo: Control()));
//        });

  AuthResult res = await signUserIn(credential);
  pushUserDataToDB(res);
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
            child: Text(
              code['code'],
            )),
      );
    }

    return tmp;
  }
}
