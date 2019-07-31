import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kene/auth/verify_phone.dart';
import 'package:kene/control.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:kene/pages/homepage.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/custom_nav.dart';

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
                  this.phoneNo = v;
                },
                keyboardAppearance: Brightness.dark,
                // textAlign: TextAlign.center,
                keyboardType: TextInputType.phone,
                cursorColor: Colors.orangeAccent,
                decoration: InputDecoration(
                    hintText: "Phone number e.g +25078650456",
                    hintStyle: TextStyle(fontSize: 14),
                    contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 15),
                    icon: Icon(Icons.phone),

                    border: InputBorder.none),
              ),
              SizedBox(
                height: 40,
              ),
              GestureDetector(
                onTap: (){
                  if(phoneNo != ""){
                      verifyPhone();
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
                  child: Center(child: Text("Sign in", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,),)),
                ),
              )
            ],
          )
          // ListView(
          //   children: <Widget>[

          //     SizedBox(
          //       height: MediaQuery.of(context).size.height * 0.2,
          //     ),

          //     Text("Kene Smart USSD", textAlign: TextAlign.center, style: TextStyle(
          //       fontSize: 30
          //     ),),

          //     SizedBox(
          //       height: 40,
          //     ),

          //     inputDisplay("Email", _emailController),
          //     SizedBox(
          //       height: 20,
          //     ),
          //     inputDisplay("Password", _passworddController),

          //     TextField(
          //       decoration: InputDecoration(hintText: "Enter number"),
          //       onChanged: (v){
          //         this.phoneNo = v;
          //       },
          //     ),
          //     RaisedButton(
          //       onPressed: verifyPhone,
          //       child: Text("Verify"),
          //     ),
          //     SizedBox(
          //       height: 60,
          //     ),

          //     Container(
          //       decoration: BoxDecoration(
          //           color: Colors.redAccent,
          //           borderRadius:BorderRadius.circular(30)
          //       ),
          //       height: 50,
          //       child: GestureDetector(
          //         onTap: (){
          //           validate();
          //         },

          //         child: Center(
          //           child:
          //           Text("Login", style: TextStyle(
          //             color: Colors.white
          //           ),),
          //         )
          //       ),
          //     )

          //   ],
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

       Navigator.push(context, CustomPageRoute(navigateTo: PhoneVerify()));
      // smsCodeDialog(context).then((value) {
      //   print("signed in");
      // });
    };

    final PhoneVerificationFailed veriFailed = (AuthException exception) {
      print("${exception.message}");
    };
    final PhoneVerificationCompleted verifiedSuccess = (FirebaseUser user) {
      print('verified ${user.phoneNumber} as user');
      Navigator.push(context, CustomPageRoute(navigateTo: Control()));
    };
    await _auth.verifyPhoneNumber(
        phoneNumber: this.phoneNo,
        timeout: Duration(seconds: 5),
        verificationCompleted: verifiedSuccess,
        verificationFailed: veriFailed,
        codeSent: smsCodeSent,
        codeAutoRetrievalTimeout: autoRetrieve);
  }

  // Future smsCodeDialog(BuildContext context) {
  //   return showDialog(
  //       context: context,
  //       barrierDismissible: false,
  //       builder: (BuildContext context) {
  //         return AlertDialog(
  //           title: Text("Enter SMS code"),
  //           content: TextField(
  //             onChanged: (v) {
  //               this.smsCode = v;
  //             },
  //           ),
  //           contentPadding: EdgeInsets.all(10),
  //           actions: <Widget>[
  //             FlatButton(
  //               onPressed: () {
                 
  //               },
  //               child: Text("Done"),
  //             )
  //           ],
  //         );
  //       });
  // }

  signInPhone(code) {
    FirebaseAuth.instance
        .signInWithPhoneNumber(
      verificationId: verificationId,
      smsCode: code,
    )
        .then((user) {
      print("yes again login");
      if(user != null){
         Navigator.push(context, CustomPageRoute(navigateTo: Control()));
      }
    }).catchError((onError) {
      print("sorry could not verify you");
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
}
