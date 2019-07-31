import 'dart:core';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kene/control.dart';
import 'package:kene/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:native_contact_picker/native_contact_picker.dart';

class Services extends StatefulWidget {
  final carrierId;
  final primaryColor;
  final carrierTitle;
  Services({this.carrierId, this.primaryColor, this.carrierTitle});
  @override
  State<StatefulWidget> createState() {
    return _ServicesState();
  }
}

class _ServicesState extends State<Services> {
  static const platform = const MethodChannel('com.kene.momouusd');
  bool isOptionClicked = false;

  scrollListener() {
    // print(_listViewController.offset);
    if (_listViewController.offset > 40 && !isOptionClicked) {
      _listViewController.animateTo(40,
          duration: Duration(milliseconds: 10), curve: Curves.linearToEaseOut);
    }

    else if(_listViewController.offset < 469 && isOptionClicked){

        _listViewController.animateTo(469, duration: Duration(
          milliseconds: 10
        ),
        curve: Curves.linearToEaseOut
        );
    }
  }

  GlobalKey _formKey = GlobalKey<FormState>();
  ScrollController _listViewController = new ScrollController();

  TextEditingController _amountController = TextEditingController();
  TextEditingController _recipientController = TextEditingController();

  ///default values that are changed when option clicked
  String headTitle = "";
  String codeToSend = "";
  bool needsContact = false;
  String recipientLabel = "";
  int optionID = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      headTitle =  widget.carrierTitle;
    });
    _listViewController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height * 0.35,
              decoration: BoxDecoration(
                  color: widget.primaryColor,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40),
                      bottomRight: Radius.circular(40))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  SizedBox(
                    height: 40,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () {
                        print("signout pressed");
                        FirebaseAuth.instance.signOut().then((f){
                          Navigator.push(context, CustomPageRoute(navigateTo: Control()));
                        });
                      },
                      icon: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "$headTitle",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18),
                    ),
                  )
                ],
              ),
            ),
            Positioned(
              top: 130,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  width: MediaQuery.of(context).size.width - 40,
                  height: MediaQuery.of(context).size.height * 0.75,
                  decoration: BoxDecoration(
                      color: Color(0xffE3E1E1),
                      borderRadius: BorderRadius.circular(40)),
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: ListView(
                      controller: _listViewController,
                      children: <Widget>[
                      StreamBuilder(
                        stream: Firestore.instance.collection("services/${widget.carrierId}/services").snapshots(),
                        builder: (context, snapshot){
                          if(!snapshot.hasData) return Center(child: Text("Loading services"));
                          return Column(
                            children: displayServices(snapshot.data.documents)
                          );
                        },
                      ),

                        actionContainer()
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
                top: MediaQuery.of(context).size.height * 0.88,
                left: MediaQuery.of(context).size.width * 0.75,
                child: Material(
                  color: Colors.transparent,
                  elevation: 14,
                  child: Container(
                    decoration: BoxDecoration(
                        color: Color(0xffED7937),
                        borderRadius: BorderRadius.circular(30)),
                    height: 60,
                    width: 60,
                    child: IconButton(
                      onPressed: () {
                        _listViewController
                            .animateTo(0,
                                duration: Duration(milliseconds: 1000),
                                curve: Curves.linearToEaseOut)
                            .then((f) {
                          setState(() {
                            isOptionClicked = false;
                            headTitle = widget.carrierTitle;
                            _amountController.text = "";
                            _recipientController.text = "";
                          });
                        });
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_up,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Container actionContainer() {
    return Container(
      margin: EdgeInsets.only(top: 150),
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            textInputContainerAmount("Amount", _amountController),
            //most recent amount section
            Container(
              margin: EdgeInsets.only(top: 20),
              child: Column(
                children: <Widget>[
                  Text("Most recent amount"),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        recentAmountBtn("1500"),
                        recentAmountBtn("2000"),
                        recentAmountBtn("10000"),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 20,
            ),
             needsContact ? chooseContactBtn(recipientLabel) : textInputContainerRecipient(recipientLabel),
            SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: sendButton(),
            ),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  GestureDetector sendButton() {
    return GestureDetector(
        onTap: () {
          sendCode(platform, codeToSend, _amountController.text, _recipientController.text);
        },
        child:Container(
      height: 58,
      width: MediaQuery.of(context).size.width * 0.45,
      decoration: BoxDecoration(
          color: Color(0xffED7937), borderRadius: BorderRadius.circular(40)),
      child: Center(
        child: Text(
          "Send",
          style: TextStyle(color: Colors.white),
        ),
      )
    )
    );
  }

  Container chooseContactBtn(label) {
    return Container(
      // height: 58,
      width: MediaQuery.of(context).size.width,

      child: Column(
        children: <Widget>[
          Center(
            child: Text("OR"),
          ),
          SizedBox(
            height: 20,
          ),
          textInputContainerAmount(label, _recipientController),

          SizedBox(
            height: 30,
          ),
          Container(
            height: 58,
            decoration: BoxDecoration(
                color: Color(0xffED7937),
                borderRadius: BorderRadius.circular(40)),
            child: GestureDetector(
              onTap: () {
                getContact();
              },
              child: Center(
                  child: Text(
                "Choose Contact",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )),
            ),
          )
        ],
      ),
    );
  }

  Container recentAmountBtn(String label) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      height: 30,
      width: MediaQuery.of(context).size.width * 0.25,
      child: GestureDetector(
        child: Center(child: Text("$label")),
        onTap: () {
          setState(() {
            _amountController.text = label;
          });
        },
      ),
    );
  }

  Container recentRecipient(String label, String val) {
    return Container(
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(5)),
      height: 30,
      width: MediaQuery.of(context).size.width * 0.25,
      child: GestureDetector(
        child: Center(child: Text("$label")),
        onTap: () {
          setState(() {
            _recipientController.text = val;
          });
        },
      ),
    );
  }

  Container textInputContainerAmount(String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(40)),
      child: TextFormField(
        keyboardType: TextInputType.number,
        controller: controller,
        decoration: InputDecoration(
            labelText: "$label",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      ),
    );
  }

  Container textInputContainerRecipient(String label){
    return Container(
      child:
        Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            textInputContainerAmount(label, _recipientController),
            SizedBox(
              height: 20,
            ),
            Text("Saved $label"),
            SizedBox(
              height: 20,
            ),
            Container(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  recentRecipient("mom", "65832467582389"),
                  recentRecipient("office", "834758732958723"),
                  recentRecipient("home", "5789327589273489"),
                ],
              ),
            ),


          ],
        ),
    );
  }

  GestureDetector buildServiceListItem(String label, String imageName, String code, xrecipientLabel, requiresInput, xneedsContact
      ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          headTitle = label;
          needsContact = xneedsContact;
          codeToSend =  code;
          recipientLabel = xrecipientLabel;
          isOptionClicked = true;
        });
        if(!requiresInput){
          sendCode(platform, codeToSend,_amountController.text, _recipientController.text
              );
        }
        else{
          _listViewController.animateTo(480,
              duration: Duration(milliseconds: 500),
              curve: Curves.linearToEaseOut);
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        height: 70,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(40)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Row(
            children: <Widget>[
              Container(
                height: 30,
                width: 30,
                child: CachedNetworkImage(
                  imageUrl: imageName,
                  placeholder: (context, url) => new Icon(Icons.error),
                  errorWidget: (context, url, error) => new Icon(Icons.error),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(label),
              )
            ],
          ),
        ),
      ),
    );
  }

  getContact() async {
    final NativeContactPicker _contactPicker = new NativeContactPicker();
    Contact contact = await _contactPicker.selectContact();
    if (contact != null) {
      String number = "";
      for (int x = 0; x < contact.phoneNumber.length; x++) {
        if (contact.phoneNumber[x] != " ") {
          number += contact.phoneNumber[x];
        }
      }

      String numberToStore =
          number.contains("+250") ? number.substring(3) : number;
      setState(() {
        _recipientController.text = numberToStore;
      });
    }
  }


  displayServices(lists){
    List<Widget> tmp = [];
    for(var list in lists){
        tmp.add(

            buildServiceListItem(
                list['label'], list['icon'], list['code'], list['recipientLabel'], list['requiresInput'], list['needsContact']),
        );
    }

    return tmp;
  }
}
