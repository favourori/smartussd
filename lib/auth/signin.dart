import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kene/auth/verify_phone.dart';
import 'package:kene/control.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:kene/pages/homepage.dart';
import 'package:kene/utils/functions.dart';
import 'package:flushbar/flushbar.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:country_code_picker/country_code_picker.dart';

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
  // final GoogleSignIn _googleSignIn = GoogleSignIn();
  String phoneNo;
  String verificationId;
  String smsCode;
  TextEditingController _yobController = TextEditingController();
  String countryName = "";
  bool isBtnClicked = false;
  String countryCode = "+250";
  String gender = "Select";

  GlobalKey _scaffoldKey = GlobalKey<ScaffoldState>();


@override
  void initState() {
    super.initState();
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
                    height: MediaQuery.of(context).size.height * 0.20,
                  ),
                  Align(
                      alignment: Alignment.center,
                      child: Text(
                        "noKanda",
                        style: TextStyle(fontSize: 18),
                      )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "noKanda will send an SMS message to verify your phone number.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        )),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.18,
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
                              hintText: "Phone number e.g +25078650456",
                              hintStyle: TextStyle(fontSize: 14),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 15),
//                              icon: Icon(Icons.phone),
                              border: InputBorder.none),
                        ),
                        flex: 4,
                      ),

                    ],
                  ),

                  //other infos
                  Padding(
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
                    TextField(
                      keyboardType: TextInputType.number,
                      controller: _yobController,
                      decoration: InputDecoration(
                        hintText: "Year of birth",
                        border: InputBorder.none
                      ),
                      
                    ),
                        ],
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (phoneNo != "" && phoneNo != null && gender != "Select" && _yobController.text != "") {
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
                               verifyPhone();
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
                      else if(_yobController.text == ""){
                          return showFlushBar("Hey Awesome!", "You need to add year of birth");
                      }
                       else {
                        showFlushBar("Hey Brilliant!",
                            "You need to enter the number to verify");
                      }
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
                                  "Sign in",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : CircularProgressIndicator(
                                  backgroundColor: Colors.white,
                                )),
                    ),
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
    var form = _formkey.currentState;
    if (form.validate()) {
      print("validated");
      signIn(_emailController.text, _passworddController.text);
    } else {
      print("not");
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

  Future verifyPhone() async {
    final PhoneCodeAutoRetrievalTimeout autoRetrieve = (String verId) {
      this.verificationId = verId;
    };

    final PhoneCodeSent smsCodeSent = (String verId, [int forceCodeResend]) {
      this.verificationId = verId;

      Navigator.push(
          context,
          CustomPageRoute(
              navigateTo: PhoneVerify(
            signInPhone: signInPhone,
          )));

    };

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
    final PhoneVerificationCompleted verifiedSuccess = (AuthCredential user) {
      print(user);
      //check if signed in and give access to app
     _auth.signInWithCredential(user).then((u){
       Firestore.instance.collection("users").where('user_id', isEqualTo: u.user.uid).getDocuments().then((f){
            if(f.documents.length == 0){
              var userData = {
                "country": countryName,
                "gender": gender,
                "yob": _yobController.text,
                "user_id": u.user.uid
              };
              Firestore.instance.collection("users").add(userData);
            }
            Navigator.pushReplacement(
                context, CustomPageRoute(navigateTo: Control()));
          });
     });


    };
//    _auth.verifyPhoneNumber(phoneNumber: null, timeout: null, verificationCompleted: null, verificationFailed: null, codeSent: null, codeAutoRetrievalTimeout: null);
    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        timeout: Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve);
  }



  signInPhone(code) async{
  print(verificationId);
  print(code);
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: verificationId,
      smsCode: code,
    );
    final AuthResult result = await _auth.signInWithCredential(credential);

    //check if signed already b4 adding documents
        Firestore.instance.collection("users").where('user_id', isEqualTo: result.user.uid).getDocuments().then((f){
          if(f.documents.length == 0){
            var userData = {
                              "country": countryName,
                              "gender": gender,
                              "yob": _yobController.text,
                              "user_id": result.user.uid
                            };
               Firestore.instance.collection("users}").add(userData);
          }
           Navigator.pushReplacement(
            context, CustomPageRoute(navigateTo: Control()));
        });

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
