import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:kene/database/db.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/bloc_provider.dart';

class SaveAccount extends StatefulWidget {
  final String label;
  final analytics;

  SaveAccount({this.label, this.analytics});
  @override
  State<StatefulWidget> createState() {
    return _SaveAccountState();
  }
}

class _SaveAccountState extends State<SaveAccount> {
  static String category = "Select";
  String uid = "path";
  KDB db = KDB();
  
  String locale = "en";
  Map pageData = {};

  TextEditingController _numberController = TextEditingController();
  TextEditingController _labelController = TextEditingController();

  @override
  void initState() {
    super.initState();

    var appBloc;

    appBloc = BlocProvider.of(context);

    appBloc.localeOut.listen((data) {
      setState(() {
        locale = data != null ? data : locale;
      });
    });


    getPageData("save_accounts").then((data){
      setState(() {
        pageData = data;
      });
    });

    

    // Send analytics on page load/initialize
    sendAnalytics(widget.analytics, "AccountPage_Open", null);


    FirebaseAuth.instance.currentUser().then((u) {
      setState(() {
        if (u != null) {
          uid = u.uid;
        } else {
          print("no user ======");
        }
      });
    });

    if (widget.label != null && widget.label.isNotEmpty) {
      setState(() {
        category = widget.label;
      });
    }
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
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.1,
                ),
                Expanded(child: AutoSizeText(
                  getTextFromPageData(pageData, "title", locale),
                  style: TextStyle(color: Colors.white, fontSize: 28),
                  maxLines: 2,
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20, right: 20),
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              height: MediaQuery.of(context).size.height * 0.66,
              child: ListView(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(flex: 3, child: Text(getTextFromPageData(pageData, "number", locale))),
                      Expanded(
                          flex: 8,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _numberController,
                            decoration: InputDecoration(
                                hintText: getTextFromPageData(pageData, "number_hint", locale),
                                hintStyle: TextStyle(fontSize: 14),
                                border: InputBorder.none),
                          )),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(flex: 3, child: Text(getTextFromPageData(pageData, "label", locale))),
                      Expanded(
                          flex: 8,
                          child: TextField(
                            controller: _labelController,
                            decoration: InputDecoration(
                                hintText: getTextFromPageData(pageData, "label_hint", locale),
                                hintStyle: TextStyle(fontSize: 14),
                                border: InputBorder.none),
                          )),
                    ],
                  ),

                  Row(
                    children: <Widget>[
                      Expanded(flex: 3, child: Text(getTextFromPageData(pageData, "category", locale))),
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
                          color: accentColor,
                          borderRadius: BorderRadius.circular(serviceItemBorderRadius)),
                      child: Center(
                        child: Text(
                          getTextFromPageData(pageData, "save", locale),
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
                                    getTextFromPageData(pageData, "saved_account", locale),
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

  Widget buildSavedItem(
      String label, String serviceName, String number, String docId) {
    return Column(
      children: <Widget>[
        Row(
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
                            Text("Are you sure you want to delete $label?"),
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
        ),
        Divider(
          height: 8,
          thickness: 1,
        )
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
