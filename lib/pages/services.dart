import 'dart:core';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kene/pages/cariers.dart';
import 'package:kene/pages/save_accounts.dart';
import 'package:kene/pages/settings.dart';
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
  scrollListener() {}

  GlobalKey _formKey = GlobalKey<FormState>();
  ScrollController _listViewController = new ScrollController();

  TextEditingController _amountController = TextEditingController();
  TextEditingController _recipientController = TextEditingController();

  String uid = "";

  ///default values that are changed when option clicked
  String headTitle = "";
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



  Future getImage() async {
    File image = await ImagePicker.pickImage(source: ImageSource.camera);
    print("image herererererererererererererererererererere");
    print(image);
    mlkit(image);

    setState(() {
      _image = image;
    });
  }



  ///function for processing image taken and extracting the pin needed
  mlkit(_image) async{
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
    final BarcodeDetector barcodeDetector = FirebaseVision.instance.barcodeDetector();
//    final ImageLabeler cloudLabeler = FirebaseVision.instance.cloudImageLabeler();
//    final FaceDetector faceDetector = FirebaseVision.instance.faceDetector();
//    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler();
    final TextRecognizer textRecognizer = FirebaseVision.instance.textRecognizer();


    final List<Barcode> barcodes = await barcodeDetector.detectInImage(visionImage);
//    final List<ImageLabel> cloudLabels = await cloudLabeler.processImage(visionImage);
//    final List<Face> faces = await faceDetector.processImage(visionImage);
//    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    final VisionText visionText = await textRecognizer.processImage(visionImage);



    String card = "*130*";
    String text = visionText.text;
    for (TextBlock block in visionText.blocks) {
//      final Rect boundingBox = block.boundingBox;
//      final List<Offset> cornerPoints = block.cornerPoints;
      final String text = block.text;
//      print("heerereeeeeeeeeeeee ooooooooooohhhhhhhhhhhhhhh >>>>>>>>>>>>>>>>>");
//      print(text);

      //using the string voucher to detect pin
      if(isCardPinNext){
        card += text;
        setState(() {
          isCardPinNext = false;
        });
      }

      List splitText = text.split(" ");
      if(splitText.length >= 3 && splitText.length <= 4){
        int c = 0;
        for(var item in splitText){
          if (isNumeric(item)){
            c += 1;
          }
        }
        if (c == splitText.length){
          card += text;
        }
      }


//      final List<RecognizedLanguage> languages = block.recognizedLanguages;

//      for (TextLine line in block.lines) {
//        // Same getters as TextBlock
//        for (TextElement element in line.elements) {
//          // Same getters as TextBlock
//
//          print(element.text);
//          if(isNumeric(element.text) && element.text.length <= 5){
//            card += element.text.trim();
//          }
//        }
//      }
    }
    print(card);
    sendCode(platform, card, _amountController.text,
        _recipientController.text);


  }

  bool isNumeric(String str) {
    if(str == null) {
      return false;
    }
    return double.tryParse(str) != null;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      headTitle = widget.carrierTitle;
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
    askCallPermission(platform);
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    //  decoration: BoxDecoration(
                    //    border: Border.all()
                    //  ),
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(context,
                                  CustomPageRoute(navigateTo: Carriers()));
                            },
                            icon: Icon(
                              Icons.home,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Align(
                            alignment: Alignment.topRight,
                            child: IconButton(
                              onPressed: () {
                                Navigator.push(context,
                                    CustomPageRoute(navigateTo: Settings()));
                              },
                              icon: Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        ),
                      ],
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
                        !showActionSection
                            ? StreamBuilder(
                                stream: Firestore.instance
                                    .collection(
                                        "services/${widget.carrierId}/services")
                                    .where("isActive", isEqualTo: true)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                        child: Text("Loading services"));
                                  }
                                  snapshot.data.documents.sort(
                                      (DocumentSnapshot a,
                                              DocumentSnapshot b) =>
                                          getServiceOrderNo(a)
                                              .compareTo(getServiceOrderNo(b)));

                                  return Column(
                                      children: displayServices(
                                          snapshot.data.documents));
                                },
                              )
                            : actionContainer(),
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
                  child: showActionSection
                      ? Container(
                          decoration: BoxDecoration(
                              color: Color(0xffED7937),
                              borderRadius: BorderRadius.circular(30)),
                          height: 60,
                          width: 60,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                showActionSection = false;
                                headTitle = widget.carrierTitle;
                                _amountController.text = "";
                                _recipientController.text = "";
                                cameraBtnClicked = false;
                              });
                            },
                            icon: Icon(
                              Icons.keyboard_arrow_up,
                              color: Colors.white,
                              size: 25,
                            ),
                          ),
                        )
                      : Container(),
                )),
          ],
        ),
      ),
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
            needsAmount == null || needsAmount ? textInputContainerAmount("Amount", _amountController) : Container(),
            SizedBox(
              height: 20,
            ),
            needsRecipient
                ? textInputContainerRecipient(recipientLabel)
                : Container(),
            needsContact ? chooseContactBtn(recipientLabel) : Container(),
            SizedBox(
              height: 20,
            ),
            canSaveLabels != null && canSaveLabels ? GestureDetector(
              onTap: () {
                Navigator.push(
                    context, CustomPageRoute(navigateTo: SaveAccount()));
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom:10.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "Click to save $serviceLable Number",
                    style: TextStyle(fontSize: 14, color: Colors.orangeAccent, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ): Container(),
             SizedBox(
              height: 10,
            ),

            serviceLable == "LoadAirtime" ? showCameraButton() : Container(),


            serviceLable != "LoadAirtime" ? Align(
              alignment: Alignment.centerLeft,
              child: sendButton(),
            ) : Container(),
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
          sendCode(platform, codeToSend, _amountController.text,
              _recipientController.text);
        },
        child: Container(
            height: 58,
            width: MediaQuery.of(context).size.width * 0.45,
            decoration: BoxDecoration(
                color: Color(0xffED7937),
                borderRadius: BorderRadius.circular(40)),
            child: Center(
              child: Text(
                "Submit",
                style: TextStyle(color: Colors.white),
              ),
            )));
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

  Container textInputContainerAmount(
      String label, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(40)),
      child: TextFormField(
//        keyboardType: TextInputType.number,
        controller: controller,
        decoration: InputDecoration(
            labelText: "$label",
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 20)),
      ),
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
          StreamBuilder(
              stream: Firestore.instance
                  .collection("accounts/$uid/data")
                  .where("service_name", isEqualTo: serviceLable)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Container(
                    child: Text("Loading ..."),
                  );
                return snapshot.data.documents.length > 0
                    ? Column(
                        children: <Widget>[
                          Text("Saved $label"),
                          SizedBox(
                            height: 20,
                          ),
                          Container(
                            height: 40,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children:
                                  populateSavedAccount(snapshot.data.documents),
                            ),
                          ),
                        ],
                      )
                    : Container();
              }),
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

  GestureDetector buildServiceListItem(
      list) {
    return GestureDetector(
      onTap: () {
        setState(() {
          headTitle = list['name'];
          serviceLable = list['label'];
          needsContact = list['needsContact'];
          needsRecipient = list['needsRecipient'];
          codeToSend = list['code'];
          recipientLabel = list['recipientLabel'];
          canSaveLabels = list['canSaveLabels'];
          needsAmount = list['needsAmount'];
          requiresCamera = list["requiresCamera"];
        });
        if (!list['requiresInput']) {
          sendCode(platform, codeToSend, _amountController.text,
              _recipientController.text);
        } else {
          setState(() {
            showActionSection = true;
          });
          _listViewController.animateTo(0,
              duration: Duration(milliseconds: 10), curve: Curves.easeIn);
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
                  imageUrl: list['icon'],
                  placeholder: (context, url) => new Icon(Icons.album),
                  errorWidget: (context, url, error) => new Icon(Icons.album),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(list['name']),
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

  displayServices(lists) {
    List<Widget> tmp = [];
    for (var list in lists) {
      tmp.add(
        buildServiceListItem(list),
      );
    }

    return tmp;
  }


  showCameraButton(){
    return Column(
      children: <Widget>[
        GestureDetector(
        onTap: (){
          setState(() {
            cameraBtnClicked = true;
          });
      getImage();
    },
    child:Container(
    margin: EdgeInsets.only(bottom: 20),
    decoration: BoxDecoration(
    color: Colors.orangeAccent,
    borderRadius: BorderRadius.circular(40)
    ),
    height: 48,
    width: MediaQuery.of(context).size.width*0.4,
    child: Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.camera_enhance, color: Colors.white,),
        Padding(padding: EdgeInsets.only(left: 10), child: Text(cameraBtnClicked ? "Loading ...." : "Scan Card", style: TextStyle(color: Colors.white),),)
      ],
    ),
    ),
    ),
    ),
        Padding(padding: EdgeInsets.only(bottom: 20), child: Text("Please make sure the camera takes the whole voucher card",textAlign: TextAlign.center,),)
      ],
    );
      
      

  }

}
