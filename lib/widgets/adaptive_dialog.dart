import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:kene/database/db.dart';

class AdaptiveDialog extends StatefulWidget {
  final serviceData;
  final recipientController;

  AdaptiveDialog({this.serviceData, this.recipientController});

  @override
  createState() => _AdaptiveDialogState();
}


class _AdaptiveDialogState extends State<AdaptiveDialog>{
  @override
  build(context){
    print("build called");
    return show(context);
  }

  KDB db = KDB();

  String uid = "";

  @override
  initState(){
    super.initState();
    FirebaseAuth.instance.currentUser().then((u) {
      if (u != null) {
        setState(() {
          uid = u.uid;
        });
      }
    });
  }
  var _labelFormKey = GlobalKey<FormState>();


  TextEditingController _labelController = TextEditingController();

 show(context){
   print("show called");
    return Platform.isIOS
        ? showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text(
                "Would you like to save ${widget.serviceData['recipientLabel']} ${widget.recipientController.text} for future use ?"),
            content: alertDialogContent(),
          );
        })
        : showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              "Would you like to save ${widget.serviceData['recipientLabel']} ${widget.recipientController.text} for future use ?",
              style: TextStyle(fontSize: 14),
            ),
            content: alertDialogContent(),
          );
        });
  }



  Widget alertDialogContent() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: Platform.isIOS
              ? CupertinoButton(
              child: Text("No"), onPressed: () => saveAccountsNoResponse())
              : IconButton(
              icon: Icon(
                Icons.cancel,
                color: Colors.grey,
                size: 48,
              ),
              onPressed: () {
                //IF RESPONSE IS NO, POP NAVIGATION AND SUBMIT REQUEST
                saveAccountsNoResponse();
              }),
        ),
        Expanded(
          flex: 1,
          child: Platform.isIOS
              ? CupertinoButton(child: Text("Yes"), onPressed: () {
            Navigator.pop(context);
            showDialogSaveAccountsYesCallback();
          })
              : IconButton(
              icon: Icon(Icons.check_box,
                  color: Colors.orangeAccent, size: 48),
              onPressed: () {
                // POP NAVIGATION, AND OPEN DIALOG TO ENTER LABEL. AFTER SAVE, SEND REQUEST

                Navigator.pop(context);

                showDialogSaveAccountsYesCallback();
              }),
        )
      ],
    );
  }


  void saveAccountsNoResponse() {
    Navigator.pop(context);
//    sendAnalytics(widget.analytics, serviceLable + "_submit", null);
//    sendCode(platform, codeToSend, _amountController.text,
//        _recipientController.text);
  }

  Future showDialogSaveAccountsYesCallback() {
    return Platform.isIOS
        ? showCupertinoDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            content: showDialogSaveAccountsYesCallbackContent(context),
          );
        })
        : showDialog(
//                                        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            content: showDialogSaveAccountsYesCallbackContent(context),
          );
        });
  }

  showDialogSaveAccountsYesCallbackContent(context) {
    return Form(
        key: _labelFormKey,
        child: Container(
          height: 160,
          child: Column(
            children: <Widget>[
              Platform.isIOS ?
              CupertinoTextField(
                prefix: Text("Enter a name"),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all()
                ),
                controller: _labelController,

              )
                  :
              TextFormField(
                decoration: InputDecoration(labelText: "Enter a name"),
                controller: _labelController,
                validator: (v) => v.isEmpty ? "Label can't be empty" : null,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 48,
                width: double.infinity,
                child:

                Platform.isIOS ?

                CupertinoButton.filled(child: Text("Save"), onPressed: (){

                  Navigator.pop(context);
                  saveAccountsAction(context);
                })
                    :

                RaisedButton(
                  color: Colors.orangeAccent,
                  // ignore: missing_return
                  onPressed: () {
                    // ignore: missing_return
                    // ignore: missing_return
                    if (_labelFormKey.currentState.validate()) {
                      Navigator.pop(context);
                      saveAccountsAction(context);
                    }
                  },
                  child: Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  saveAccountsAction(context) {
    if(_labelController.text.isNotEmpty){  //checking for ios versions, since there's no validator for text fields
      Map<String, dynamic> data = {
        "label": _labelController.text,
        "number": widget.recipientController.text,
        "service_name": widget.serviceData['serviceLable']
      };

      var res = db.firestoreAdd("accounts/$uid/data", data);
      setState(() {
        _labelController.text = "";
      });

      if (res == 1) {
        return Platform.isIOS ?

        showCupertinoDialog(context: context, builder: (context){
          return CupertinoAlertDialog(
            content: Text("Account saved"),
            actions: <Widget>[
              CupertinoButton(child: Text("Okay"), onPressed: (){
                Navigator.pop(context);
//                sendAnalytics(widget.analytics,
//                    serviceLable + "_submit", null);
//                sendCode(
//                    platform,
//                    codeToSend,
//                    _amountController.text,
//                    _recipientController.text);
              })
            ],
          );
        })

            :
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (context) {
              return AlertDialog(
                content: Text("Account saved"),
                actions: <Widget>[
                  FlatButton(
                    onPressed: () {
                      Navigator.pop(context);

//                      sendAnalytics(widget.analytics,
//                          serviceLable + "_submit", null);
//                      sendCode(
//                          platform,
//                          codeToSend,
//                          _amountController.text,
//                          _recipientController.text);
                    },
                    child: Text("Okay"),
                  ),
                ],
              );
            });
      }
    }
  }

}