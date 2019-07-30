import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
import 'package:kene/pages/homepage.dart';
import 'package:kene/utils/functions.dart';


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
  String phone;
  String verificationId;
  String smsCode;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
        key:_formkey,
          child: Padding(padding: EdgeInsets.symmetric(
            horizontal: 20
          ),
            child: ListView(
              children: <Widget>[

                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                ),

                Text("Kene Smart USSD", textAlign: TextAlign.center, style: TextStyle(
                  fontSize: 30
                ),),

                SizedBox(
                  height: 40,
                ),

                inputDisplay("Email", _emailController),
                SizedBox(
                  height: 20,
                ),
                inputDisplay("Password", _passworddController),

                SizedBox(
                  height: 60,
                ),

                Container(
                  decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius:BorderRadius.circular(30)
                  ),
                  height: 50,
                  child: GestureDetector(
                    onTap: (){
                      validate();
                    },

                    child: Center(
                      child:
                      Text("Login", style: TextStyle(
                        color: Colors.white
                      ),),
                    )
                  ),
                )


              ],
            ),

          )

      ),
    );
  }

  inputDisplay(String label, controller){
    return
      Container(
        height: 55,
        padding: EdgeInsets.symmetric(
            horizontal:20
        ),
        decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
            borderRadius:BorderRadius.circular(30)
        ),
        child:
        TextFormField(
          validator: (v) => v.isEmpty ? "Value can't be empty" : null,
          controller: controller,
            obscureText: label == "Password" ? true: false,
            keyboardType: label == "Email" ? TextInputType.emailAddress : TextInputType.text,
            decoration: InputDecoration(
              prefixIcon: label == "Email" ? Icon(Icons.email): Icon(Icons.security),
              labelText: "$label",
              border:  InputBorder.none,

            )
        ),
      );
  }

  void validate(){
    var form =_formkey.currentState;
    if(form.validate()){
          print("validated");
          signIn(_emailController.text, _passworddController.text);
    }
    else{
      print("not");
    }

  }

  signIn(_email, _password) async{
    verifyPhone();
    sendAnalytics(widget.analytics, "signin_button_clicked", null);
    FirebaseUser user = await _auth.signInWithEmailAndPassword(email: _email, password: _password).then((f)=>
    navigateUsers(f)
    ).catchError((f)=>
      f.message.contains("no user record") ? print("No user") : null
    );
//    print(user.email);
  }


  Future verifyPhone() async{
      await _auth.verifyPhoneNumber(
          phoneNumber: "+250784650455",
          timeout: Duration(seconds: 6),
          verificationCompleted: (user) => print("completed"),
          verificationFailed: (e) => print("${e.message}"),
          codeSent: (String id, [int forceResend]){this.verificationId = id; print("code sent");},
          codeAutoRetrievalTimeout: (String id) => this.verificationId = id);
  }

  // Example code of how to sign in with phone.
  void _signInWithPhoneNumber() async {
    // final AuthCredential credential = PhoneAuthProvider.getCredential(
    //   verificationId: verificationId,
    //   smsCode: "",
    // );
    // final FirebaseUser user = await _auth.signInWithCredential(credential);
    // final FirebaseUser currentUser = await _auth.currentUser();
    // assert(user.uid == currentUser.uid);
//    setState(() {
//      if (user != null) {
//        _message = 'Successfully signed in, uid: ' + user.uid;
//      } else {
//        _message = 'Sign in failed';
//      }
//    });
  }

  // void _signInWithGoogle() async {
  //   final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  //   final GoogleSignInAuthentication googleAuth =
  //   await googleUser.authentication;
  //   final AuthCredential credential = GoogleAuthProvider.getCredential(
  //     accessToken: googleAuth.accessToken,
  //     idToken: googleAuth.idToken,
  //   );
  //   final FirebaseUser user = await _auth.signInWithCredential(credential);
  //   assert(user.email != null);
  //   assert(user.displayName != null);
  //   assert(!user.isAnonymous);
  //   assert(await user.getIdToken() != null);

  //   final FirebaseUser currentUser = await _auth.currentUser();
  // }


  Future navigateUsers(f){
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => Homepage(analytics: widget.analytics, observer: widget.observer,),
        settings: RouteSettings(name: 'Homepage'),
      ),
    );
  }
}
