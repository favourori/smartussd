import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kene/utils/functions.dart';
import 'package:kene/widgets/adaptive_dialog.dart';
import 'package:kene/widgets/bloc_provider.dart';
import 'package:native_contact_picker/native_contact_picker.dart';

class InputActionContainer extends StatefulWidget{

  final primaryColor;
  final analytics;
  final carrierTitle;

  InputActionContainer({this.primaryColor, this.analytics, this.carrierTitle});

  @override
  createState() => _InputContainerState();
}


class _InputContainerState extends State<InputActionContainer> with SingleTickerProviderStateMixin {

  static const platform = const MethodChannel('com.kene.momouusd');

  var _formKey = GlobalKey<FormState>();
  var _amountController = TextEditingController();
  var _recipientController = TextEditingController();
  String uid = "";

  String _recipientContactName = "";

  Map<String, dynamic> serviceData;
  bool cameraBtnClicked = false;
  File _image;
  String pinFound = "";
  bool isCardPinNext = false;

  var appBloc;

  bool showSubmit = false;

  List<dynamic> savedAccounts = [];

  _recipientControllerListener() {
    if (_recipientController.text == null ||
        _recipientController.text.isEmpty) {
      setState(() {
        showSubmit = false;
        _recipientContactName = "";
      });
    } else {
      setState(() {
        showSubmit = true;
      });
    }
  }


  @override
  void initState() {
    super.initState();

    appBloc = BlocProvider.of(context);
    appBloc.serviceDataOut.listen((dataFromStream){
     if(mounted){ //avoid setting state after this component is unmounted
       setState(() {
         serviceData = dataFromStream != null ? dataFromStream : {};
       });
     }
    });

    _recipientController.addListener(_recipientControllerListener);

    FirebaseAuth.instance.currentUser().then((u) {  //setting the uid
      if (u != null) {
        setState(() {
          uid = u.uid;
        });
      }
    });

  }

  @override
  build(context) =>
  serviceData != null ?
    Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            serviceData['needsAmount'] == null || serviceData['needsAmount'] ?  // show amount if needed
                 textInputContainerAmount("Amount", _amountController)
                : Container(),
            SizedBox(
              height: 10,
            ),
        serviceData['needsContact'] ?
                  chooseContactBtn( serviceData['recipientLabel']) : Container(), //show contact if needed

        serviceData['needsRecipient'] ? //show recipient if needed
                  textInputContainerRecipient(serviceData['recipientLabel'])
                : Container(),
            SizedBox(
              height: 20,
            ),

            SizedBox(
              height: 10,
            ),
            serviceData['serviceLabel'] == "LoadAirtime" ? showCameraButton() : Container(),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    ):
  
  Container(
    margin: EdgeInsets.only(top: MediaQuery.of(context).size.width * 0.3),
    child: Center(
      child: Text("Loading..."),
    ),
  );


  Column textInputContainerAmount(
      String label, TextEditingController controller) {
    return Column(
      children: <Widget>[
        Container(
          height: 60,
          // padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(40)),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: TextField(
                    onTap: () {
                      if (serviceData['needsContact']) {
//                        _listViewController.animateTo(101.5,
//                            duration: Duration(milliseconds: 500),
//                            curve: Curves.easeIn);
                      }
                    },
                    keyboardType: label != "Amount" ? TextInputType.text : TextInputType.number,
                    controller: controller,
                    decoration: InputDecoration(
                        labelText: "Enter $label",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 20)),
                  ),
                ),
              ),
              label != "Amount" && showSubmit
                  ? Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: () {
                    if ((serviceData['canSaveLabels'] != null && serviceData['canSaveLabels']) &&
                        numberNotInSavedAccounts(
                            _recipientController.text)) {
//                      bool response = false;
                      AdaptiveDialog(serviceData: serviceData, recipientController: _recipientController);
                    } else {

                      // push analytics to Firebase
                      sendAnalytics(widget.analytics,
                          widget.carrierTitle + "_" + serviceData['label'] + "_submit", null);

                      // make the dial
                      sendCode(
                          platform,
                          serviceData['code'],
                          _amountController.text,
                          _recipientController.text,
                          context);

                      // send transaction if amount present
                      if (_amountController.text.isNotEmpty && _amountController.text != null){
                        addTransactions(widget.carrierTitle + "_" + serviceData['label'],int.parse( _amountController.text));
                      }


                    }
                  },
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                        color: widget.primaryColor,
                        // border: Border.all(),
                        borderRadius: BorderRadius.only(
                            topRight: Radius.circular(40),
                            bottomRight: Radius.circular(40))),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              "Submit",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              minFontSize: 11,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.send,
                              color: Colors.white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              )
                  : Container()
            ],
          ),
        ),
        label != "Amount" && showSubmit
            ? Padding(
            padding: EdgeInsets.only(
              top: 5,
            ),
            child: Text(
              _recipientContactName.isNotEmpty
                  ? "Sending to:  $_recipientContactName"
                  : "",
              style: TextStyle(fontSize: 12),
            ))
            : Container(),
      ],
    );
  }


  Container textInputContainerRecipient(String label) {
    // var docs = data;
    return Container(
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          textInputContainerAmount(label, _recipientController),
          SizedBox(
            height: 20,
          ),
          serviceData['canSaveLabels'] != null && serviceData['canSaveLabels'] ?
          StreamBuilder(
              stream: Firestore.instance
                  .collection("accounts/$uid/data")
                  .where("service_name", isEqualTo: serviceData['label'])
                  .snapshots(),
              builder: (context, accountsSnapshot) {
                if (!accountsSnapshot.hasData)
                  return Container(
                    child: Text("Loading ..."),
                  );

                savedAccounts = accountsSnapshot.data.documents;
                savedAccounts.sort((a,b) => a['label'].compareTo(b['label']));
                return accountsSnapshot.data.documents.length > 0
                    ? Column(
                  children: <Widget>[
                    Text("Saved $label"),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
//                            height: 40,
                        child: Wrap(
                          children: populateSavedAccount(savedAccounts),
                        )
                    ),
                  ],
                )
                    : Container();
              }):
          Container(),
        ],
      ),
    );
  }


  GestureDetector chooseContactBtn(label) {
    return GestureDetector(
      onTap: () {
        getContact();
      },
      child: Container(
        // height: 58,
        width: MediaQuery.of(context).size.width,

        child: Column(
          children: <Widget>[
//            Center(
//              child: Text("OR"),
//            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 58,
              decoration: BoxDecoration(
                  color: widget.primaryColor,
                  // Color(0xffED7937),
                  borderRadius: BorderRadius.circular(40)),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.perm_identity,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      "Choose Contact",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ]),
            ),

            SizedBox(
              height: 20,
            ),
            Text("OR")
          ],
        ),
      ),
    );
  }



  showCameraButton() {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: () {
            setState(() {
              cameraBtnClicked = true;
            });
            getImage();
          },
          child: Container(
            margin: EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
                color: Colors.orange, borderRadius: BorderRadius.circular(40)),
            height: 48,
            width: MediaQuery.of(context).size.width * 0.4,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.camera_enhance,
                    color: Colors.white,
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 10),
                    child: Text(
                      cameraBtnClicked ? "Loading ...." : "Take a Picture",
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        Text(
          pinFound.isNotEmpty ? "voucher: $pinFound" : "",
          style: TextStyle(
            fontSize: 18,
            color: Colors.orangeAccent,
          ),
        ),
        cameraBtnClicked
            ? SpinKitFadingFour(
          color: Colors.orangeAccent,
          size: 120.0,
          controller: AnimationController(
              vsync: this, duration: const Duration(milliseconds: 1200)),
        )
            : Container(),
        Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: Text(
            "Simply take a picture of the entire voucher card to automatically load the airtime",
            textAlign: TextAlign.center,
          ),
        )
      ],
    );
  }


  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });

    if (_image != null) {
      mlKit(_image);
    }
  }

  mlKit(_image) async {
    final FirebaseVisionImage visionImage =
    FirebaseVisionImage.fromFile(_image);
    final TextRecognizer textRecognizer =
    FirebaseVision.instance.textRecognizer();


    final VisionText visionText =
    await textRecognizer.processImage(visionImage);
    String card = "*130*";
    for (TextBlock block in visionText.blocks) {
      final String text = block.text;

      //using the string voucher to detect pin
      if (isCardPinNext) {
        card += text;
        setState(() {
          isCardPinNext = false;
        });
      }

      List splitText = text.split(" ");
      if (splitText.length >= 3 && splitText.length <= 4) {
        int c = 0;
        for (var item in splitText) {
          if (isNumeric(item)) {
            c += 1;
          }
        }
        if (c == splitText.length) {
          card += text;
        }
      }
    }

    sendCode(platform, card, _amountController.text, _recipientController.text, context);
    sendAnalytics(widget.analytics, serviceData['label'] + "_sent", null);
    setState(() {
      cameraBtnClicked = false;
      pinFound = card.substring(
        5,
      );
    });
  }


  bool numberNotInSavedAccounts(number) {
    for (int i = 0; i < savedAccounts.length; i++) {
      if (number == savedAccounts[i]['number']) {
        return false;
      }
    }
    return true;
  }

  List<Widget> populateSavedAccount(accounts) {
    List<Widget> tmp = [];
    for (var account in accounts) {
      tmp.add(recentRecipient(account['label'], account['number']));
    }

    return tmp;
  }


  GestureDetector recentRecipient(String label, String val) {
    return GestureDetector(
        onTap: () {
          setState(() {
            _recipientController.text = val;
          });
        },
        child: Container(
          width: MediaQuery.of(context).size.width*0.35,
          margin: EdgeInsets.only(bottom: 10, right: 10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(5)),
          height: 48,
          child: Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: Center(
                child: AutoSizeText(
                  "$label",
                  minFontSize: 11,
                  maxLines: 3,
                )),
          ),
        ));
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
        _recipientContactName = contact.fullName;
      });
    }
  }

}