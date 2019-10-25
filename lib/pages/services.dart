import 'dart:core';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kene/database/db.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/pages/save_accounts.dart';
import 'package:kene/pages/settings.dart';
import 'package:kene/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kene/utils/stylesguide.dart';
import 'package:kene/widgets/custom_nav.dart';
import 'package:kene/widgets/service_item.dart';
import 'package:native_contact_picker/native_contact_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';
//import 'package:keyboard_visibility/keyboard_visibility.dart';
import 'package:flutter/cupertino.dart';

class Services extends StatefulWidget {
  final carrierId;
  final primaryColor;
  final carrierTitle;
  final analytics;

  Services(
      {this.carrierId, this.primaryColor, this.carrierTitle, this.analytics});
  @override
  State<StatefulWidget> createState() {
    return _ServicesState();
  }
}

class _ServicesState extends State<Services> with TickerProviderStateMixin {
  static const platform = const MethodChannel('com.kene.momouusd');
  scrollListener() {
//    print(_listViewController.offset);
  }

  GlobalKey _formKey = GlobalKey<FormState>();
  ScrollController _listViewController = new ScrollController();

  TextEditingController _amountController = TextEditingController();
  TextEditingController _recipientController = TextEditingController();

  bool showSubmit = false;
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

  String uid = "";

  ///default values that are changed when option clicked

  List navigationStack = [];
  String collectionURL = "";
  List headTitleStack = [];
  String codeToSend = "";
  bool needsContact = false;
  bool needsRecipient = false;
  String recipientLabel = "";
  int optionID = 0;
  bool showActionSection = false;
  String serviceLable = "";
  bool canSaveLabels;
  bool needsAmount;
  bool requiresCamera;
  bool isCardPinNext = false;
  File _image;
  bool cameraBtnClicked = false;
  bool hasChildren = false;
  String serviceDescription;

  String _recipientContactName = "";
  String pinFound = "";
  String childrenValue = "Select";
  String parentID = "";
  List<dynamic> savedAccounts = [];

  var _labelFormKey = GlobalKey<FormState>();
  TextEditingController _labelController = TextEditingController();
  KDB db = KDB();

  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });

    if (_image != null) {
      mlkit(_image);
    }
  }

  ///function for processing image taken and extracting the pin needed
  mlkit(_image) async {
    print("ml kit called");
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(_image);
//    final BarcodeDetector barcodeDetector =
//        FirebaseVision.instance.barcodeDetector();
    final TextRecognizer textRecognizer =
        FirebaseVision.instance.textRecognizer();

//    final List<Barcode> barcodes =
//        await barcodeDetector.detectInImage(visionImage);
    final VisionText visionText =
        await textRecognizer.processImage(visionImage);

    String card = "*130*";
    String text = visionText.text;
    print("text is $text");
    for (TextBlock block in visionText.blocks) {
      final String text = block.text;
      print(text);

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

    sendCode(platform, card, _amountController.text, _recipientController.text);
    sendAnalytics(widget.analytics, serviceLable + "_sent", null);
    setState(() {
      cameraBtnClicked = false;
      pinFound = card.substring(
        5,
      );
    });
  }

  bool isNumeric(String str) {
    if (str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  @override
  void initState() {
    super.initState();

    _recipientController.addListener(_recipientControllerListener);
    var tmpHeader = [widget.carrierTitle];
    setState(() {
      headTitleStack = tmpHeader;
    });
    _listViewController.addListener(scrollListener);
    FirebaseAuth.instance.currentUser().then((u) {
      if (u != null) {
        setState(() {
          uid = u.uid;
        });
      }
    });

    //call for permissions
//    askCallPermission(platform);

    String initialCollection = "services/${widget.carrierId}/services";
    navigationStack.add(initialCollection);
    setState(() {
      collectionURL = initialCollection;
    });

//    KeyboardVisibilityNotification().addNewListener(
//      onChange: (bool isVisible){
//          print("keyboard status is $isVisible");
//      }
//    );

//    print(Color(0xffffcc00).value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
//       resizeToAvoidBottomInset: true,
        body: GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Container(
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    //  decoration: BoxDecoration(
                    //    border: Border.all()
                    //  ),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          flex: 2,
                          child: Align(
                              alignment: Alignment.topLeft,
                              child: navigationStack.length > 1 ||
                                      showActionSection
                                  ? IconButton(
                                      onPressed: () {
                                        if (!showActionSection) {
                                          navigationStack.removeLast();

                                          setState(() {
                                            collectionURL = navigationStack[
                                                navigationStack.length - 1];
                                          });
                                        }
                                        headTitleStack.removeLast();
                                        var ht2 = headTitleStack;
                                        setState(() {
                                          serviceDescription = "";
                                          headTitleStack = ht2;
                                          showActionSection = false;
                                          _amountController.text = "";
                                          _recipientController.text = "";
                                          cameraBtnClicked = false;
                                        });
                                      },
                                      icon: Icon(
                                        Icons.arrow_back_ios,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    )
                                  : IconButton(
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            CustomPageRoute(
                                                navigateTo: Carriers()));
                                      },
                                      icon: Icon(
                                        Icons.home,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                    )),
                        ),
                        Expanded(
                          flex: 3,
                          child: Align(
                            alignment: Alignment.center,
                            child: AutoSizeText(
                              "Nokanda",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                              ),
                              maxLines: 2,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(context,
                                    CustomPageRoute(navigateTo: Settings()));
                              },
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
//                  SizedBox(
//                    height: 5,
//                  ),
                  Row(
                    children:[
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),

                      Expanded(
                        flex:4,
                        child:Align(
                          alignment: Alignment.center,
                          child: Text(
                            "${headTitleStack[headTitleStack.length - 1]}",
                            style: TextStyle(color: Colors.white, fontSize: 14),
                          ),
                        )
                      ),

                      Expanded(
                        flex: 1,
                        child: serviceDescription != null && serviceDescription.isNotEmpty ? GestureDetector(
                          child: IconButton(icon: Icon(Icons.info_outline, color: Colors.white,), onPressed: (){
                            Platform.isIOS ? 
                                showCupertinoDialog(context: context, builder: (context){
                                  return CupertinoAlertDialog(
                                    title: Center(
                                      child: Text("Info"),
                                    ),
                                    content: Text("$serviceDescription "),
                                    actions: <Widget>[
                                      CupertinoButton(child: Text("Close"), onPressed: (){
                                        Navigator.pop(context);
                                      })
                                    ],
                                  );
                                })
                                
                                :
                            
                            showDialog(context: context, builder: (context){
                              return AlertDialog(
                                title: Center(
                                  child: Text("Info"),
                                ),
                                content: Text("$serviceDescription"),
                              );
                            });
                          }),
                        ):
                        Container(),
                      ),
                    ]
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
                        !showActionSection
                            ? showServices("$collectionURL")
                            : actionContainer(),
                        SizedBox(
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ));
  }


  /// Receives collection url and display children if available else, displays action
  StreamBuilder showServices(String collectionLink) {
    print(navigationStack);
    return StreamBuilder(
      stream: Firestore.instance
          .collection("$collectionLink")
          .where("isActive", isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: Text("Loading services"));
        }
        snapshot.data.documents.sort((DocumentSnapshot a, DocumentSnapshot b) =>
            getServiceOrderNo(a).compareTo(getServiceOrderNo(b)));

        return Column(children: displayServices(snapshot.data.documents));
      },
    );
  }

  int getServiceOrderNo(x) {
    return x['orderNo'];
  }

  Container actionContainer() {
    return Container(
      child: Form(
        key: _formKey,
        child: Column(
          children: <Widget>[
            needsAmount == null || needsAmount
                ? textInputContainerAmount("Amount", _amountController)
                : Container(),
            SizedBox(
              height: 10,
            ),
            needsContact ? chooseContactBtn(recipientLabel) : Container(),
            needsRecipient
                ? textInputContainerRecipient(recipientLabel)
                : Container(),
            SizedBox(
              height: 20,
            ),
//            canSaveLabels != null && canSaveLabels
//                ? GestureDetector(
//                    onTap: () {
//                      Navigator.push(
//                          context,
//                          CustomPageRoute(
//                              navigateTo: SaveAccount(
//                            label: serviceLable,
//                          )));
//                    },
//                    child: Padding(
//                      padding: const EdgeInsets.only(bottom: 10.0),
//                      child: Align(
//                        alignment: Alignment.centerLeft,
//                        child: Text(
//                          "Click to save $serviceLable Number",
//                          style: TextStyle(
//                              fontSize: 14,
//                              color: Colors.orangeAccent,
//                              fontWeight: FontWeight.bold),
//                        ),
//                      ),
//                    ),
//                  )
//                : Container(),
            SizedBox(
              height: 10,
            ),
            serviceLable == "LoadAirtime" ? showCameraButton() : Container(),
            hasChildren ? showChildren(parentID) : Container(),
            SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }

  bool numberNotInSavedAccounts(number) {
    for (int i = 0; i < savedAccounts.length; i++) {
      if (number == savedAccounts[i]['number']) {
        return false;
      }
    }
    return true;
  }

  GestureDetector sendButton() {
    return GestureDetector(
        onTap: () {
          if (canSaveLabels &&
              numberNotInSavedAccounts(_recipientController.text)) {
            showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(
                        "Would you like to save  ${_recipientController.text} for future use ?"),
                    content: Row(
                      children: <Widget>[
                        IconButton(
                            icon: Icon(
                              Icons.cancel,
                              size: 18,
                            ),
                            onPressed: () {
                              print("Cancel");
                              Navigator.pop(context);

                              //if response is NO, remove dialog box and submit request
                              sendAnalytics(widget.analytics,
                                  serviceLable + "_submit", null);
                              sendCode(
                                  platform,
                                  codeToSend,
                                  _amountController.text,
                                  _recipientController.text);
                            }),
                        IconButton(
                            icon: Icon(Icons.check_box,
                                color: Colors.orangeAccent, size: 18),
                            onPressed: () {}),
                      ],
                    ),
                  );
                });
            bool response = false;
            if (response) {
//              show label field save and send
            }
          } else {
            sendAnalytics(widget.analytics, serviceLable + "_submit", null);
            sendCode(platform, codeToSend, _amountController.text,
                _recipientController.text);
          }
        },
        child: Container(
            height: 58,
            width: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
                color: Color(0xffED7937),
                borderRadius: BorderRadius.circular(40)),
            child: Center(
              child: AutoSizeText(
                "Submit",
                style: TextStyle(
                  color: Colors.white,
                ),
                minFontSize: 11,
                maxLines: 2,
              ),
            )));
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
                      if (needsContact) {
                        _listViewController.animateTo(101.5,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeIn);
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
                          if ((canSaveLabels != null && canSaveLabels) &&
                              numberNotInSavedAccounts(
                                  _recipientController.text)) {
                            bool response = false;
                            adaptiveDialog();
                          } else {
                            sendAnalytics(widget.analytics,
                                serviceLable + "_submit", null);
                            sendCode(
                                platform,
                                codeToSend,
                                _amountController.text,
                                _recipientController.text);
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
          canSaveLabels != null && canSaveLabels ?
          StreamBuilder(
              stream: Firestore.instance
                  .collection("accounts/$uid/data")
                  .where("service_name", isEqualTo: serviceLable)
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

  List<Widget> populateSavedAccount(accounts) {
    List<Widget> tmp = [];
    for (var account in accounts) {
      tmp.add(recentRecipient(account['label'], account['number']));
    }

    return tmp;
  }


  updateCollectionURL(String url){

    if (url.isNotEmpty){

      var tmp = navigationStack;
      tmp.add(collectionURL + url);
      setState(() {
        collectionURL = collectionURL + url;
        navigationStack = tmp;
      });
    }
  }

  GestureDetector buildServiceListItem(list) {
    return GestureDetector(
      onTap: () {
        var hT = headTitleStack;
        if (list['requiresInput'] != null && list['requiresInput']) {
          hT.add(list['name']);
        }

        setState(() {
          headTitleStack = hT;
          serviceLable = list['label'];
          needsContact = list['needsContact'];
          needsRecipient = list['needsRecipient'];
          codeToSend = list['code'];
          recipientLabel = list['recipientLabel'];
          canSaveLabels = list['canSaveLabels'];
          needsAmount = list['needsAmount'];
          requiresCamera = list["requiresCamera"];
          serviceDescription = list["serviceDescription"];
          hasChildren =
              list['hasChildren'] != null ? list['hasChildren'] : false;
          parentID = list.documentID;
        });

        if (list['hasChildren'] != null && list['hasChildren']) {
          setState(() {
            collectionURL = collectionURL + "/" + parentID + "/children";
          });

          var tmp = navigationStack;
          tmp.add(collectionURL);

          setState(() {
            navigationStack = tmp;
          });
        } else if (!list['requiresInput']) {
          sendCode(platform, codeToSend, _amountController.text,
              _recipientController.text);
        } else {
          setState(() {
            showActionSection = true;
          });
          _listViewController.animateTo(0,
              duration: Duration(milliseconds: 10), curve: Curves.easeIn);
        }

        sendAnalytics(widget.analytics, serviceLable, null);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10),
        height: 70,
        decoration: BoxDecoration(
            // border: Border.all(color: widget.primaryColor),
            color: Colors.white,
            borderRadius: BorderRadius.circular(40)),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, top: 10, bottom: 10),
          child: Row(
            children: <Widget>[
              Container(
                height: 50,
                width: 50,
                child: list['icon'] != null && list['icon'].isNotEmpty ?  CachedNetworkImage(
                  imageUrl: list['icon'].trim(),
                  placeholder: (context, url) => new Icon(
                    Icons.album,
                    size: 50,
                  ),
                  errorWidget: (context, url, error) => new Icon(
                    Icons.album,
                    size: 50,
                  ),
                ):
                Icon(
                  Icons.album,
                  size: 50,
                )
                ,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: ListView(
                    shrinkWrap: true,
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[Text(list['name'])],
                  ),
                ),
              ),
              (list['hasChildren'] != null && list['hasChildren']) || (list['requiresInput'] != null && list['requiresInput'])
                  ? Padding(
                      padding: EdgeInsets.only(left: 3, right: 15),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 25,
                        color: Colors.grey,
                      ),
                    )
                  : Text(""),
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
        _recipientContactName = contact.fullName;
      });
    }
  }



  ///receives list and calls build services, function which builds the single items
  displayServices(lists) {
    List<Widget> tmp = [];
    for (var list in lists) {

      if (list['label'] == "LoadAirtime" && Platform.isIOS) {
        continue;
      } else {
        tmp.add(
          buildServiceListItem(list),
//        ServiceItem(
//          backgroundColor: Colors.white,
//          icon:list['icon'],
//          name:list['name'],
//          serviceLabel: list['serviceLabel'],
//          needsContact: list['needsContact'],
//          needsRecipient: list['needsRecipient'],
//          requiresInput: list['requiresInput'],
//          codeToSend: list['codeToSend'],
//          recipientLabel:list['recipientLabel'],
//          canSaveLabels:list['canSaveLabels'],
//          needsAmount:list['needsAmount'],
//          requiresCamera:list['requiresCamera'],
//          serviceDescription:list['serviceDescription'],
//          hasChildren:list['hasChildren'],
//          parentID:list.documentID,
//          updateCollectionURL: updateCollectionURL,
//
//
//        ),
        );
      }
    }

    return tmp;
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

  Widget showChildren(parent) {
    return StreamBuilder(
      stream: Firestore.instance
          .collection("services/${widget.carrierId}/services/$parent/children")
          .orderBy('orderNo')
          .snapshots(),
      builder: (context, snapshot) {
        return snapshot.hasData && snapshot.data.documents.length > 0
            ? Container(
                child: Column(
                  children: <Widget>[
                    Text("Select below"),
                    Padding(
                      padding: EdgeInsets.all(20),
                      child: DropdownButton(
                        underline: Container(),
                        icon: Icon(
                          Icons.arrow_drop_down,
                          size: 24,
                          color: widget.primaryColor,
                        ),
                        isExpanded: true,
                        value: childrenValue,
                        onChanged: (v) {
                          setState(() {
                            childrenValue = v;
                          });
                        },
                        items: populateChildren(snapshot.data.documents),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    GestureDetector(
                      onTap: () {
                        if (childrenValue != "Select") {
                          sendCode(platform, childrenValue, "", "");
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            color: widget.primaryColor,
                            borderRadius: BorderRadius.circular(40)),
                        height: 50,
                        width: 150,
                        child: Center(
                          child: Text(
                            "Submit",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                child: Center(
                  child: Text("Loading ..."),
                ),
              );
      },
    );
  }

  List<DropdownMenuItem> populateChildren(childrenList) {
    print(childrenList.length);
    List<DropdownMenuItem> tmp = [];

    tmp.add(DropdownMenuItem(value: "Select", child: Text("Select")));

    for (int i = 0; i < childrenList.length; i++) {
      print(childrenList[i]['name']);
      tmp.add(DropdownMenuItem(
          value: "${childrenList[i]['code']}",
          child: Text(
            "${childrenList[i]['name']}",
          )));
    }

    return tmp;
  }

  adaptiveDialog() {
    return Platform.isIOS
        ? showCupertinoDialog(
            context: context,
            builder: (context) {
              return CupertinoAlertDialog(
                title: Text(
                    "Would you like to save $recipientLabel ${_recipientController.text} for future use ?"),
                content: alertDialogContent(),
              );
            })
        : showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(
                  "Would you like to save $recipientLabel ${_recipientController.text} for future use ?",
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
    sendAnalytics(widget.analytics, serviceLable + "_submit", null);
    sendCode(platform, codeToSend, _amountController.text,
        _recipientController.text);
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
          "number": _recipientController.text,
          "service_name": serviceLable
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
                      sendAnalytics(widget.analytics,
                          serviceLable + "_submit", null);
                      sendCode(
                          platform,
                          codeToSend,
                          _amountController.text,
                          _recipientController.text);
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

                        sendAnalytics(widget.analytics,
                            serviceLable + "_submit", null);
                        sendCode(
                            platform,
                            codeToSend,
                            _amountController.text,
                            _recipientController.text);
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
