import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kene/control.dart';
import 'package:kene/database/db.dart';
import 'package:kene/widgets/custom_nav.dart';

class SaveAccount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _SaveAccountState();
  }
}

class _SaveAccountState extends State<SaveAccount> {
  static String category = "Select";
  String uid = "path";
  KDB db = KDB();

  TextEditingController _numberController = TextEditingController();
  TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((u) {
      setState(() {
        if (u != null) {
          uid = u.uid;
        } else {
          print("no user ======");
        }
      });
    });
    print(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          // height: MediaQuery.of(context).size.height,
          child: Column(
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: Colors.orange,
            child: Row(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                Text("Save Accounts",
                    style: TextStyle(color: Colors.white, fontSize: 28))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left:20.0, top:20,right: 20),
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              height: MediaQuery.of(context).size.height * 0.66,
              child: ListView(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(flex: 3, child: Text("Number")),
                      Expanded(
                          flex: 8,
                          child: TextField(
                            keyboardType: Platform.isAndroid ? TextInputType.number: TextInputType.text,
                            controller: _numberController,
                            decoration: InputDecoration(
                                hintText: "Enter number",
                                hintStyle: TextStyle(fontSize: 14),
                                border: InputBorder.none),
                          )),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(flex: 3, child: Text("Label")),
                      Expanded(
                          flex: 8,
                          child: TextField(
                            controller: _labelController,
                            decoration: InputDecoration(
                                hintText: "Enter label e.g home",
                                hintStyle: TextStyle(fontSize: 14),
                                border: InputBorder.none),
                          )),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(flex: 3, child: Text("Category")),
                      StreamBuilder(
                          stream: Firestore.instance
                              .collection("account_labels")
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Container();
                            }
                            return Expanded(
                              flex: 8,
                              child: DropdownButton(
                                  underline: Container(),
                                  value: category,
                                  onChanged: (v) {
                                    setState(() {
                                      category = v;
                                    });
                                  },
                                  items: populateAccountLabels(
                                      snapshot.data.documents)),
                            );
                          }),
                    ],
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (category == "Select") {
                        return showFlushBar(
                            "Alert!", "Please choose a category");
                      } else if (_numberController.text == "" ||
                          _labelController.text == "null") {
                        return showFlushBar("Alert!",
                            "label and number should not be empty. Please try again with inputs");
                      }
                      print("save");
                      Map<String, dynamic> data = {
                        "label": _labelController.text,
                        "number": _numberController.text,
                        "service_name": category
                      };
                      var res = db.firestoreAdd("accounts/$uid/data", data);
                      setState(() {
                        _numberController.text = "";
                        _labelController.text = "";
                      });
                      if (res == 1) {
                        return showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                content: Text("Account saved"),
                                actions: <Widget>[
                                  FlatButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text("Okay"),
                                  ),
                                ],
                              );
                            });
                      }
                    },
                    child: Container(
                      height: 48,
                      width: MediaQuery.of(context).size.width * 0.2,
                      decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(
                        child: Text(
                          "Save",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 40,
                  ),

                  //saved numbers listed here
                  StreamBuilder(
                    stream: Firestore.instance
                        .collection("accounts/$uid/data")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return Container(
                          child: Text("no data for $uid"),
                        );

                      return snapshot.data.documents.length > 0
                          ? Column(
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Saved Accounts",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                ),
                                SizedBox(
                                  height: 15,
                                ),
                                Column(
                                    children: saveNumbersListBuilder(
                                        snapshot.data.documents)),
                                SizedBox(
                                  height: 50,
                                )
                              ],
                            )
                          : Container();
                    },
                  ),
                ],
              ),
            ),
          )
        ],
      )),
    );
  }

  saveNumbersListBuilder(lists) {
    List<Widget> tmp = [];
    for (var list in lists) {
      tmp.add(buildSavedItem(list['label'], list['service_name'],
          list['number'], list.documentID));
    }

    return tmp;
  }

  Row buildSavedItem(
      String label, String serviceName, String number, String docId) {
    return Row(
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label),
            Text(
              "($serviceName)",
              style: TextStyle(fontSize: 11),
            ),
            Text(number),
          ],
        ),
        Spacer(),
        IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
          ),
          onPressed: () {
            return showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    content:
                        Text("Are you sure you want to delete this account ?"),
                    actions: <Widget>[
                      FlatButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text("No"),
                      ),
                      FlatButton(
                        onPressed: () {
                          db.firestoreDelete("accounts/$uid/data", docId);
                          Navigator.pop(context);
                        },
                        child: Text("Yes"),
                      )
                    ],
                  );
                });
          },
        ),
      ],
    );
  }

  showFlushBar(String title, String message) {
    Flushbar(
      title: title,
      message: message,
      duration: Duration(seconds: 8),
    )..show(context);
  }

  populateAccountLabels(lists) {
    List<DropdownMenuItem<String>> tmp = [];
    tmp.add(DropdownMenuItem(
      value: "Select",
      child: Text(
        "Select",
        style: TextStyle(fontSize: 14),
      ),
    ));

    for (var list in lists) {
      tmp.add(
        DropdownMenuItem(
          value: "${list['label']}",
          child: Text(
            "${list['label']}",
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    }

    return tmp;
  }
}
