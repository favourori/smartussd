import 'package:flutter/material.dart';


class Signin extends StatefulWidget {
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Signin> {
  GlobalKey<FormState> _formkey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Form(
        key:_formkey,
          child: ListView(
        children: <Widget>[

          SizedBox(
            height: MediaQuery.of(context).size.height * 0.2,
          ),

          TextFormField(
            decoration: InputDecoration(

            )
          )

        ],
      )),
    );
  }
}
