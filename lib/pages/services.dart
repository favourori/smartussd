import 'dart:core';
import 'package:kene/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:native_contact_picker/native_contact_picker.dart';

class Services extends StatefulWidget {
  final carierId;
  Services({this.carierId});
  @override
  State<StatefulWidget> createState() {
    return _ServicesState();
  }
}

class _ServicesState extends State<Services> {
  var codeData = [
    {"label": "Check Momo balance", "code": "*182*6*4", "inputLabel": ""},
    {
      "label": "Send Momo",
      "code": "*182*6*2*N*A",
      "inputLabel": "Recevier's Number"
    },
    {
      "label": "Buy Electricity",
      "code": "*182*6*4",
      "inputLabel": "Meter number"
    },
    {"label": "Pay Water", "code": "*182*6*4", "inputLabel": "Number"},
    {"label": "Check airtime balance", "code": "*182*6*4", "inputLabel": ""},
  ];
  static const platform = const MethodChannel('com.kene.momouusd');
  bool isOptionClicked = false;
  setHeaderColor() {
    if (widget.carierId == "00002") {
      setState(() {
        headerColor = Color(0xffED3737);
        headerTitle = "Airtel";
      });
    }
  }

  scrollListener() {
    print(_listViewController.offset);
    if (_listViewController.offset > 40 && !isOptionClicked) {
      _listViewController.animateTo(40,
          duration: Duration(milliseconds: 10), curve: Curves.linearToEaseOut);
    }

    // else if(_listViewController.offset < 469 && isOptionClicked){

    //     _listViewController.animateTo(469, duration: Duration(
    //       milliseconds: 10
    //     ),
    //     curve: Curves.linearToEaseOut
    //     );
    // }
  }

  GlobalKey _formKey = GlobalKey<FormState>();
  ScrollController _listViewController = new ScrollController();

  TextEditingController _amountController = TextEditingController();
  TextEditingController _recipientController = TextEditingController();

  bool needsContact = false;
  bool needsRecipient = false;
  String recipientLabel = "";
  int optionID = 0;
  String headerTitle = "Mtn";
  Color headerColor = Color(0xffE0C537);

  @override
  void initState() {
    super.initState();
    _listViewController.addListener(scrollListener);
    setHeaderColor();
    getServices();
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
                  color: headerColor,
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
                      onPressed: () {},
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
                      "$headerTitle",
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
                        buildServiceListItem(
                            codeData[0]['label'], "balance.png", 0),
                        buildServiceListItem(
                            codeData[1]['label'], "send_money.png", 1),
                        buildServiceListItem(
                          codeData[2]['label'],
                          "electricity.png",
                          2,
                        ),
                        buildServiceListItem(
                            codeData[3]['label'], "bank.ico", 3),
                        buildServiceListItem(
                            codeData[4]['label'], "balance.png", 4),
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
                        recentAmountBtn("1,500"),
                        recentAmountBtn("2,000"),
                        recentAmountBtn("10,000"),
                      ],
                    ),
                  )
                ],
              ),
            ),

         

           
            SizedBox(
              height: 20,
            ),
             needsContact ? chooseContactBtn() : Container(),
            needsRecipient ? textInputContainerRecipient(recipientLabel, _recipientController) : Container(),
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

  Container sendButton() {
    return Container(
      height: 58,
      width: MediaQuery.of(context).size.width * 0.45,
      decoration: BoxDecoration(
          color: Color(0xffED7937), borderRadius: BorderRadius.circular(40)),
      child: GestureDetector(
        onTap: () {
          String code = codeData[optionID]['code'];
          sendCode(platform, code, _recipientController.text,
              _amountController.text);
        },
        child: Center(
          child: Text(
            "Send",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Container chooseContactBtn() {
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

  Container textInputContainerRecipient(String label, TextEditingController controller){
    return Container(

    );
  }
  GestureDetector buildServiceListItem(String label, String imageName, int id,
      {bool needsContact, bool needsRecipient}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          needsContact = needsContact;
          needsRecipient = needsRecipient;
          optionID = id;
          recipientLabel = codeData[id]['inputLabel'];
          isOptionClicked = true;
        });
        _listViewController.animateTo(544,
            duration: Duration(milliseconds: 500),
            curve: Curves.linearToEaseOut);
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
                decoration: BoxDecoration(
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage("assets/images/$imageName")),
                    // color: Color(0xffC4C4C4),
                    borderRadius: BorderRadius.circular(15)),
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
}
