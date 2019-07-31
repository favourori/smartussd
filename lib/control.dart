import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kene/auth/signin.dart';
import 'package:kene/pages/cariers.dart';

class Control extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _ControlState();
  }
}

class _ControlState extends State<Control> {
  bool isLogedIn = false;
  @override
  void initState() {
    super.initState();

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
    return isLogedIn ? Carriers() : Signin();
  }
}
